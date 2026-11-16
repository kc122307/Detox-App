import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../models/achievement_model.dart';
import '../models/question_model.dart';
import '../models/user_progress_model.dart';

class ProgressionRepository {
  static const _kUserProgressKey = 'user_progress_data';
  static const _kAchievementsKey = 'user_achievements_list';

  final SharedPreferences _prefs;

  ProgressionRepository(this._prefs);

  static Future<ProgressionRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressionRepository(prefs);
  }

  // --- User Progress ---

  UserProgressModel getUserProgress() {
    final jsonStr = _prefs.getString(_kUserProgressKey);
    if (jsonStr == null) {
      final initial = UserProgressModel(
        userId: 'local_user',
        currentLevel: 1,
        xp: 0,
        totalSolved: 0,
        totalAttempts: 0,
        currentStreak: 1,
        longestStreak: 1,
        lastActiveDate: TimeUtils.getTodayDateKey(),
        topicsMastered: ['Basic Syntax'],
        assignedQuestionIds: [],
        completedQuestionIds: [],
      );
      saveUserProgress(initial);
      return initial;
    }

    try {
      return UserProgressModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(jsonStr) as Map),
      );
    } catch (_) {
      return UserProgressModel(userId: 'local_user');
    }
  }

  Future<void> saveUserProgress(UserProgressModel progress) async {
    await _prefs.setString(_kUserProgressKey, jsonEncode(progress.toJson()));
  }

  /// Permanently records question assignment to guarantee no duplicates
  Future<void> recordQuestionAssigned(String questionId, String canonicalProblemId) async {
    final progress = getUserProgress();
    final updatedAssigned = {...progress.assignedQuestionIds, questionId, canonicalProblemId}.toList();
    await saveUserProgress(progress.copyWith(assignedQuestionIds: updatedAssigned));
  }

  /// Advances user level, XP, and streaks when a problem is accepted
  Future<UserProgressModel> recordProblemSolved(QuestionModel question) async {
    var progress = getUserProgress();
    final today = TimeUtils.getTodayDateKey();

    // Calculate streak
    int newStreak = progress.currentStreak;
    int longestStreak = progress.longestStreak;
    if (progress.lastActiveDate != today) {
      // Check if active yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey = TimeUtils.formatShortDate(yesterday);
      if (progress.lastActiveDate == yesterdayKey) {
        newStreak += 1;
      } else if (progress.lastActiveDate.isEmpty) {
        newStreak = 1;
      } else {
        newStreak = 1; // Streak reset
      }
      if (newStreak > longestStreak) {
        longestStreak = newStreak;
      }
    }

    // Calculate XP earned (base + difficulty multiplier)
    final earnedXp = 50 + (question.difficultyRating * 25);
    int newXp = progress.xp + earnedXp;
    int newLevel = progress.currentLevel;

    // Check for level ups (supporting up to 1,000+ levels)
    while (newXp >= (100 * (1 + (newLevel - 1) * 0.25)).round() && newLevel < AppConstants.maxLevel) {
      newXp -= (100 * (1 + (newLevel - 1) * 0.25)).round();
      newLevel++;
    }

    // Add topic to mastered list if not present
    final updatedTopics = {...progress.topicsMastered, question.topic}.toList();
    final updatedSolved = {...progress.completedQuestionIds, question.id, question.canonicalProblemId}.toList();

    progress = progress.copyWith(
      currentLevel: newLevel,
      xp: newXp,
      totalSolved: progress.totalSolved + 1,
      totalAttempts: progress.totalAttempts + 1,
      currentStreak: newStreak,
      longestStreak: longestStreak,
      lastActiveDate: today,
      topicsMastered: updatedTopics,
      completedQuestionIds: updatedSolved,
    );

    await saveUserProgress(progress);
    await _checkAchievementUnlocks(progress);

    return progress;
  }

  // --- Achievements ---

  List<AchievementModel> getAchievements() {
    final jsonStr = _prefs.getString(_kAchievementsKey);
    if (jsonStr == null) {
      final initial = _getDefaultAchievements();
      _saveAchievements(initial);
      return initial;
    }

    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => AchievementModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return _getDefaultAchievements();
    }
  }

  Future<void> _saveAchievements(List<AchievementModel> list) async {
    final jsonList = list.map((a) => a.toJson()).toList();
    await _prefs.setString(_kAchievementsKey, jsonEncode(jsonList));
  }

  Future<void> _checkAchievementUnlocks(UserProgressModel progress) async {
    final list = getAchievements();
    bool changed = false;

    for (int i = 0; i < list.length; i++) {
      var ach = list[i];
      if (ach.isUnlocked) continue;

      int currentVal = 0;
      switch (ach.id) {
        case 'ach_first_solve':
          currentVal = progress.totalSolved;
          break;
        case 'ach_7_streak':
          currentVal = progress.currentStreak;
          break;
        case 'ach_30_streak':
          currentVal = progress.currentStreak;
          break;
        case 'ach_dsa_explorer':
          currentVal = progress.topicsMastered.length;
          break;
        case 'ach_100_solved':
          currentVal = progress.totalSolved;
          break;
        case 'ach_lvl_100':
          currentVal = progress.currentLevel;
          break;
        case 'ach_lvl_500':
          currentVal = progress.currentLevel;
          break;
        case 'ach_lvl_1000':
          currentVal = progress.currentLevel;
          break;
      }

      ach = ach.copyWith(progress: currentVal);
      if (currentVal >= ach.maxProgress) {
        ach = ach.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
        changed = true;
      }
      list[i] = ach;
    }

    if (changed) {
      await _saveAchievements(list);
    }
  }

  static List<AchievementModel> _getDefaultAchievements() {
    return [
      AchievementModel(
        id: 'ach_first_solve',
        title: 'First Solve',
        description: 'Complete your first coding question to earn screen time.',
        icon: 'terminal',
        xpReward: 50,
        maxProgress: 1,
      ),
      AchievementModel(
        id: 'ach_no_distractions',
        title: 'No Distractions',
        description: 'Stay completely within your daily allowance for an entire day.',
        icon: 'shield_check',
        xpReward: 100,
        maxProgress: 1,
      ),
      AchievementModel(
        id: 'ach_7_streak',
        title: '7-Day Streak',
        description: 'Code and maintain your focus for seven consecutive days.',
        icon: 'fire',
        xpReward: 200,
        maxProgress: 7,
      ),
      AchievementModel(
        id: 'ach_dsa_explorer',
        title: 'DSA Explorer',
        description: 'Master at least 5 different algorithmic problem topics.',
        icon: 'compass',
        xpReward: 250,
        maxProgress: 5,
      ),
      AchievementModel(
        id: 'ach_100_solved',
        title: 'Problem Solver',
        description: 'Solve 100 unique coding challenges.',
        icon: 'trophy',
        xpReward: 500,
        maxProgress: 100,
      ),
      AchievementModel(
        id: 'ach_30_streak',
        title: 'Consistency King',
        description: 'Maintain a 30-day coding streak.',
        icon: 'crown',
        xpReward: 1000,
        maxProgress: 30,
      ),
      AchievementModel(
        id: 'ach_lvl_100',
        title: 'Level 100',
        description: 'Advance to coding level 100.',
        icon: 'military_tech',
        xpReward: 1000,
        maxProgress: 100,
      ),
      AchievementModel(
        id: 'ach_lvl_500',
        title: 'Mastermind',
        description: 'Reach coding level 500.',
        icon: 'diamond',
        xpReward: 2500,
        maxProgress: 500,
      ),
      AchievementModel(
        id: 'ach_lvl_1000',
        title: 'Legend',
        description: 'Reach maximum coding level 1000.',
        icon: 'star',
        xpReward: 5000,
        maxProgress: 1000,
      ),
    ];
  }
}
