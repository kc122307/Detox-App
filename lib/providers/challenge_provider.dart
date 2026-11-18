import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../data/execution/code_execution_engine.dart';
import '../data/models/question_model.dart';
import '../data/models/reward_transaction_model.dart';
import '../data/models/submission_model.dart';
import '../data/repositories/question_repository.dart';
import 'progression_provider.dart';
import 'usage_tracking_provider.dart';

class ChallengeProvider extends ChangeNotifier {
  final QuestionRepository _questionRepo;
  final ProgressionProvider _progressionProvider;
  final UsageTrackingProvider _usageProvider;
  final NotificationService? notificationService;

  QuestionModel? _currentQuestion;
  String _selectedLanguage = AppConstants.defaultLanguage;
  String _currentCode = '';

  // Anti-cheating & manual typing tracking
  int _keystrokesCount = 0;
  int _pasteAttemptsCount = 0;
  int _manualCharactersEntered = 0;
  DateTime? _firstEditTime;

  bool _isEvaluating = false;
  SubmissionResult? _lastResult;
  RewardTransactionModel? _recentlyEarnedReward;
  bool _requiresSecondQuestion = false;
  int _solvedQuestionsInSession = 0;
  int _totalRequiredInSession = 1;

  ChallengeProvider(
    this._questionRepo,
    this._progressionProvider,
    this._usageProvider, {
    this.notificationService,
  });

  QuestionModel? get currentQuestion => _currentQuestion;
  String get selectedLanguage => _selectedLanguage;
  String get currentCode => _currentCode;
  int get keystrokesCount => _keystrokesCount;
  int get pasteAttemptsCount => _pasteAttemptsCount;
  bool get isEvaluating => _isEvaluating;
  SubmissionResult? get lastResult => _lastResult;
  RewardTransactionModel? get recentlyEarnedReward => _recentlyEarnedReward;
  bool get requiresSecondQuestion => _requiresSecondQuestion;
  bool get requiresMoreQuestions => _requiresSecondQuestion;
  int get solvedQuestionsInSession => _solvedQuestionsInSession;
  int get totalRequiredInSession => _totalRequiredInSession;

  /// Ratio of manual typing (0.0 to 1.0)
  double get manualTypingRatio {
    if (_currentCode.trim().isEmpty) return 1.0;
    if (_pasteAttemptsCount > 0) return 0.0; // Strictly penalized if paste attempted
    final ratio = _manualCharactersEntered / _currentCode.length;
    return ratio.clamp(0.0, 1.0);
  }

  /// Typing progress towards solution structure
  double get typingProgress {
    if (_currentQuestion == null) return 0.0;
    // Goal of ~50 characters of manually typed code to complete progress bar
    return (_manualCharactersEntered / 50.0).clamp(0.0, 1.0);
  }

  /// Loads or assigns the next unique challenge for a specific app's unlock session
  void prepareChallengeForApp(String packageName) {
    final session = _usageProvider.getActiveUnlockSession(packageName);
    final userProgress = _progressionProvider.progress;

    // Check if user already has an assigned question for this session
    String? targetQId;
    if (session.assignedQuestionIds.length > session.solvedQuestionIds.length) {
      targetQId = session.assignedQuestionIds.last;
    }

    QuestionModel question;
    if (targetQId != null) {
      final existing = _questionRepo.getQuestionById(targetQId);
      question = existing ??
          _questionRepo.getNextUniqueQuestion(
            userLevel: userProgress.currentLevel,
            assignedQuestionIds: userProgress.assignedQuestionIds,
            completedQuestionIds: userProgress.completedQuestionIds,
          );
    } else {
      question = _questionRepo.getNextUniqueQuestion(
        userLevel: userProgress.currentLevel,
        assignedQuestionIds: userProgress.assignedQuestionIds,
        completedQuestionIds: userProgress.completedQuestionIds,
      );

      // Permanently record assignment before displaying
      _progressionProvider.recordQuestionAssigned(question.id, question.canonicalProblemId);
      _usageProvider.getActiveUnlockSession(packageName);
    }

    _currentQuestion = question;
    _resetEditorState();
    notifyListeners();
  }

  void _resetEditorState() {
    // Editor starts completely empty so the user must type the solution manually
    _currentCode = '';
    _keystrokesCount = 0;
    _pasteAttemptsCount = 0;
    _manualCharactersEntered = 0;
    _firstEditTime = null;
    _lastResult = null;
    _recentlyEarnedReward = null;
    _requiresSecondQuestion = false;
  }

  void setLanguage(String language) {
    if (AppConstants.supportedLanguages.contains(language)) {
      _selectedLanguage = language;
      _currentCode = ''; // Keeps editor clean and empty on language change
      _manualCharactersEntered = 0;
      _keystrokesCount = 0;
      _lastResult = null;
      notifyListeners();
    }
  }

  /// Inserts only the blank function signature/template if user requests it
  void insertStarterTemplate() {
    final template = _currentQuestion?.starterCode[_selectedLanguage] ?? '';
    if (template.isNotEmpty) {
      _currentCode = template;
      _manualCharactersEntered = template.length;
      notifyListeners();
    }
  }

  void onCodeChanged(String newCode, {bool isPaste = false}) {
    if (isPaste) {
      _pasteAttemptsCount++;
    } else {
      _keystrokesCount++;
      final delta = newCode.length - _currentCode.length;
      if (delta > 0) {
        if (delta > AppConstants.maxPasteBurstCharacters) {
          // Large burst detected (e.g. keyboard clipboard insert)
          _pasteAttemptsCount++;
        } else {
          _manualCharactersEntered += delta;
        }
      }
    }

    _firstEditTime ??= DateTime.now();
    _currentCode = newCode;
    notifyListeners();
  }

  void registerPasteAttempt() {
    _pasteAttemptsCount++;
    notifyListeners();
  }

  /// Run sample tests (visible test cases)
  Future<void> runSampleTests() async {
    if (_currentQuestion == null) return;
    _isEvaluating = true;
    _lastResult = null;
    notifyListeners();

    await _progressionProvider.onProblemAttempted();

    final result = await CodeExecutionEngine.execute(
      question: _currentQuestion!,
      language: _selectedLanguage,
      userCode: _currentCode,
      isSubmission: false,
      manualTypingRatio: manualTypingRatio,
      keystrokesCount: _keystrokesCount,
      pasteAttemptsCount: _pasteAttemptsCount,
    );

    _isEvaluating = false;
    _lastResult = result;
    notifyListeners();
  }

  /// Submit solution (evaluated against hidden test cases for reward qualification)
  Future<bool> submitSolution(String targetPackageName) async {
    if (_currentQuestion == null) return false;
    _isEvaluating = true;
    _lastResult = null;
    notifyListeners();

    await _progressionProvider.onProblemAttempted();

    final result = await CodeExecutionEngine.execute(
      question: _currentQuestion!,
      language: _selectedLanguage,
      userCode: _currentCode,
      isSubmission: true,
      manualTypingRatio: manualTypingRatio,
      keystrokesCount: _keystrokesCount,
      pasteAttemptsCount: _pasteAttemptsCount,
    );

    _isEvaluating = false;
    _lastResult = result;

    if (result.isAccepted) {
      notificationService?.notifyGoalCompleted(_progressionProvider.progress.totalSolved + 1);

      // 1. Advance user progression & XP
      await _progressionProvider.onProblemSolved(_currentQuestion!);

      // 2. Update unlock session
      final session = _usageProvider.getActiveUnlockSession(targetPackageName);
      final updatedSolved = [...session.solvedQuestionIds, _currentQuestion!.id];
      _totalRequiredInSession = session.requiredQuestionCount;
      _solvedQuestionsInSession = updatedSolved.length;

      if (updatedSolved.length >= session.requiredQuestionCount) {
        // All required questions for this unlock completed!
        final reward = await _usageProvider.grantRewardForSession(
          packageName: targetPackageName,
          unlockSessionId: session.id,
          challengeIds: updatedSolved,
        );
        _recentlyEarnedReward = reward;
        _requiresSecondQuestion = false;
      } else {
        // More questions required (doubling rule: 1 -> 2 -> 4 -> 8...)
        _requiresSecondQuestion = true;
        final nextQuestion = _questionRepo.getNextUniqueQuestion(
          userLevel: _progressionProvider.progress.currentLevel,
          assignedQuestionIds: _progressionProvider.progress.assignedQuestionIds,
          completedQuestionIds: _progressionProvider.progress.completedQuestionIds,
        );
        _progressionProvider.recordQuestionAssigned(nextQuestion.id, nextQuestion.canonicalProblemId);
        _currentQuestion = nextQuestion;
        _resetEditorState();
      }
    }

    notifyListeners();
    return result.isAccepted;
  }
}
