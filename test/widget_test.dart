import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_to_unlock/core/constants/app_constants.dart';
import 'package:code_to_unlock/core/services/notification_service.dart';
import 'package:code_to_unlock/data/execution/code_execution_engine.dart';
import 'package:code_to_unlock/data/models/user_progress_model.dart';
import 'package:code_to_unlock/data/questions/curated_problem_bank.dart';
import 'package:code_to_unlock/data/questions/procedural_problem_generator.dart';
import 'package:code_to_unlock/data/repositories/app_usage_repository.dart';
import 'package:code_to_unlock/data/repositories/question_repository.dart';

void main() {
  group('Code to Unlock: Core Rules & Logic Tests', () {
    test('Reward rules must enforce 20 minutes and 1st vs subsequent questions', () {
      expect(AppConstants.rewardDurationMinutes, 20);
      expect(AppConstants.rewardDurationSeconds, 1200);
      expect(AppConstants.firstUnlockRequiredQuestions, 1);
      expect(AppConstants.subsequentUnlockRequiredQuestions, 2);
    });

    test('1,000+ Level System: Generates unique canonical problems with valid bands', () {
      final Set<String> canonicalIds = {};

      for (int level = 1; level <= 50; level++) {
        final problem = ProceduralProblemGenerator.generateForLevel(level);
        expect(problem.id, isNotEmpty);
        expect(problem.canonicalProblemId, isNotEmpty);
        expect(problem.title, contains('Level $level'));
        expect(problem.sampleTestCases, isNotEmpty);
        expect(problem.hiddenTestCases, isNotEmpty);
        expect(problem.starterCode.keys, containsAll(['Python', 'JavaScript', 'Java', 'C++']));

        // Assert strictly unique canonical IDs
        expect(canonicalIds.contains(problem.canonicalProblemId), isFalse);
        canonicalIds.add(problem.canonicalProblemId);
      }

      // Verify difficulty bands for different level ranges
      final lvl5 = ProceduralProblemGenerator.generateForLevel(5);
      expect(lvl5.difficultyBand, 'Beginner');

      final lvl20 = ProceduralProblemGenerator.generateForLevel(20);
      expect(lvl20.difficultyBand, 'Easy to Intermediate');

      final lvl50 = ProceduralProblemGenerator.generateForLevel(50);
      expect(lvl50.difficultyBand, 'Intermediate');

      final lvl100 = ProceduralProblemGenerator.generateForLevel(100);
      expect(lvl100.difficultyBand, 'Intermediate to Advanced');

      final lvl200 = ProceduralProblemGenerator.generateForLevel(200);
      expect(lvl200.difficultyBand, 'Advanced');

      final lvl400 = ProceduralProblemGenerator.generateForLevel(400);
      expect(lvl400.difficultyBand, 'Expert');

      final lvl600 = ProceduralProblemGenerator.generateForLevel(600);
      expect(lvl600.difficultyBand, 'Very Advanced');

      final lvl900 = ProceduralProblemGenerator.generateForLevel(900);
      expect(lvl900.difficultyBand, 'Master');
    });

    test('Curated Problem Bank: Validates comprehensive interview catalog', () {
      final problems = CuratedProblemBank.getCuratedProblems();
      expect(problems.length, greaterThanOrEqualTo(10));

      for (final p in problems) {
        expect(p.canonicalProblemId, startsWith('canonical_'));
        expect(p.title, isNotEmpty);
        expect(p.description, isNotEmpty);
        expect(p.sampleTestCases, isNotEmpty);
        expect(p.hiddenTestCases, isNotEmpty);
        expect(p.starterCode.keys, containsAll(['Python', 'JavaScript', 'Java', 'C++']));
      }
    });

    test('Question Repository: Strict uniqueness guarantees no repetition', () {
      final repo = QuestionRepository();
      final assigned = <String>[];
      final completed = <String>[];

      final q1 = repo.getNextUniqueQuestion(
        userLevel: 1,
        assignedQuestionIds: assigned,
        completedQuestionIds: completed,
      );
      expect(q1, isNotNull);

      assigned.add(q1.id);
      assigned.add(q1.canonicalProblemId);

      final q2 = repo.getNextUniqueQuestion(
        userLevel: 1,
        assignedQuestionIds: assigned,
        completedQuestionIds: completed,
      );

      // Must be completely distinct canonical problem
      expect(q2.id != q1.id, isTrue);
      expect(q2.canonicalProblemId != q1.canonicalProblemId, isTrue);
    });

    test('Code Execution Engine: Syntax checks and anti-cheating paste flagging', () async {
      final question = ProceduralProblemGenerator.generateForLevel(1);

      // Test 1: Paste detected should flag submission
      final pasteResult = await CodeExecutionEngine.execute(
        question: question,
        language: 'Python',
        userCode: 'def max_subarray_len(nums, threshold): return 0',
        isSubmission: true,
        manualTypingRatio: 0.40, // Low manual typing
        keystrokesCount: 5,
        pasteAttemptsCount: 1, // Paste occurred!
      );

      expect(pasteResult.isFlaggedForCheating, isTrue);
      expect(pasteResult.isAccepted, isFalse);
      expect(pasteResult.errorMessage, contains('Anti-cheating'));

      // Test 2: Mismatched brackets syntax error
      final syntaxResult = await CodeExecutionEngine.execute(
        question: question,
        language: 'Python',
        userCode: 'def test(): return [1, 2',
        isSubmission: false,
        manualTypingRatio: 1.0,
        keystrokesCount: 30,
        pasteAttemptsCount: 0,
      );

      expect(syntaxResult.status.name, 'compilationError');
      expect(syntaxResult.errorMessage, contains('Unclosed bracket'));
    });

    test('User Progress Model: Correct level and XP progression', () {
      final progress = UserProgressModel(
        userId: 'test_user',
        currentLevel: 1,
        xp: 45,
        totalSolved: 3,
      );

      expect(progress.currentDifficultyBand, 'Beginner');
      expect(progress.xpForNextLevel, 100);
      expect(progress.levelProgress, 0.45);
    });

    test('Notification Service: Dispatches and rings notifications', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = NotificationService(prefs);

      expect(service.isEnabled, isTrue);
      expect(service.recentNotifications, isEmpty);

      service.notifyLimitExhausted('Instagram');
      expect(service.recentNotifications.length, 1);
      expect(service.recentNotifications.first.title, contains('Instagram Limit Reached'));

      service.notifyRewardUnlocked('Instagram');
      expect(service.recentNotifications.length, 2);
      expect(service.recentNotifications.first.title, contains('20 Minutes Unlocked'));
    });

    test('App Usage Repository: Exports data and records rollover cleanly', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = await AppUsageRepository.create();

      final export = repo.exportAllData();
      expect(export.containsKey('managed_apps'), isTrue);
      expect(export.containsKey('reward_transactions'), isTrue);
      expect(export.containsKey('unlock_sessions'), isTrue);
    });
  });
}
