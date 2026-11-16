import 'package:flutter/foundation.dart';
import '../data/models/achievement_model.dart';
import '../data/models/question_model.dart';
import '../data/models/user_progress_model.dart';
import '../data/repositories/progression_repository.dart';

class ProgressionProvider extends ChangeNotifier {
  final ProgressionRepository _repository;

  UserProgressModel _progress = UserProgressModel(userId: 'local_user');
  List<AchievementModel> _achievements = [];

  ProgressionProvider(this._repository) {
    _loadData();
  }

  UserProgressModel get progress => _progress;
  List<AchievementModel> get achievements => _achievements;

  int get currentLevel => _progress.currentLevel;
  int get xp => _progress.xp;
  int get totalSolved => _progress.totalSolved;
  int get totalAttempts => _progress.totalAttempts;
  int get currentStreak => _progress.currentStreak;
  int get longestStreak => _progress.longestStreak;
  List<String> get topicsMastered => _progress.topicsMastered;

  double get acceptanceRate {
    if (_progress.totalAttempts == 0) return 1.0;
    return (_progress.totalSolved / _progress.totalAttempts).clamp(0.0, 1.0);
  }

  /// Calculates verifiable saved time in minutes.
  /// Baseline average social media time is 180 min (3 hrs).
  /// Saved time is (Baseline - Actual usage) + coding productivity time.
  int calculateSavedMinutes(int actualUsedSeconds) {
    const baselineSeconds = 180 * 60; // 3 hours baseline
    final screenTimeDiff = baselineSeconds - actualUsedSeconds;
    final savedScreenMinutes = (screenTimeDiff > 0 ? screenTimeDiff : 0) ~/ 60;
    final codingMinutes = _progress.totalSolved * 15; // Avg 15 min focus per problem
    return savedScreenMinutes + codingMinutes;
  }

  void _loadData() {
    _progress = _repository.getUserProgress();
    _achievements = _repository.getAchievements();
    notifyListeners();
  }

  Future<void> onProblemSolved(QuestionModel question) async {
    _progress = await _repository.recordProblemSolved(question);
    _achievements = _repository.getAchievements();
    notifyListeners();
  }

  Future<void> onProblemAttempted() async {
    _progress = _progress.copyWith(totalAttempts: _progress.totalAttempts + 1);
    await _repository.saveUserProgress(_progress);
    notifyListeners();
  }

  Future<void> recordQuestionAssigned(String questionId, String canonicalProblemId) async {
    await _repository.recordQuestionAssigned(questionId, canonicalProblemId);
    _progress = _repository.getUserProgress();
    notifyListeners();
  }
}

