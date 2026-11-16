class UserProgressModel {
  final String userId;
  final int currentLevel;
  final int xp;
  final int totalSolved;
  final int totalAttempts;
  final int currentStreak;
  final int longestStreak;
  final String lastActiveDate;
  final List<String> topicsMastered;
  final List<String> assignedQuestionIds;
  final List<String> completedQuestionIds;

  UserProgressModel({
    required this.userId,
    this.currentLevel = 1,
    this.xp = 0,
    this.totalSolved = 0,
    this.totalAttempts = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate = '',
    this.topicsMastered = const [],
    this.assignedQuestionIds = const [],
    this.completedQuestionIds = const [],
  });

  int get xpForNextLevel => (100 * (1 + (currentLevel - 1) * 0.25)).round();
  double get levelProgress => (xp % xpForNextLevel) / xpForNextLevel;

  String get currentDifficultyBand {
    if (currentLevel <= 10) return 'Beginner';
    if (currentLevel <= 30) return 'Easy to Intermediate';
    if (currentLevel <= 75) return 'Intermediate';
    if (currentLevel <= 150) return 'Intermediate to Advanced';
    if (currentLevel <= 300) return 'Advanced';
    if (currentLevel <= 500) return 'Expert';
    if (currentLevel <= 750) return 'Very Advanced';
    return 'Master';
  }

  UserProgressModel copyWith({
    String? userId,
    int? currentLevel,
    int? xp,
    int? totalSolved,
    int? totalAttempts,
    int? currentStreak,
    int? longestStreak,
    String? lastActiveDate,
    List<String>? topicsMastered,
    List<String>? assignedQuestionIds,
    List<String>? completedQuestionIds,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      currentLevel: currentLevel ?? this.currentLevel,
      xp: xp ?? this.xp,
      totalSolved: totalSolved ?? this.totalSolved,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      topicsMastered: topicsMastered ?? this.topicsMastered,
      assignedQuestionIds: assignedQuestionIds ?? this.assignedQuestionIds,
      completedQuestionIds: completedQuestionIds ?? this.completedQuestionIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'current_level': currentLevel,
        'xp': xp,
        'total_solved': totalSolved,
        'total_attempts': totalAttempts,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'last_active_date': lastActiveDate,
        'topics_mastered': topicsMastered,
        'assigned_question_ids': assignedQuestionIds,
        'completed_question_ids': completedQuestionIds,
      };

  factory UserProgressModel.fromJson(Map<String, dynamic> json) => UserProgressModel(
        userId: (json['user_id'] ?? '') as String,
        currentLevel: (json['current_level'] as num?)?.toInt() ?? 1,
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        totalSolved: (json['total_solved'] as num?)?.toInt() ?? 0,
        totalAttempts: (json['total_attempts'] as num?)?.toInt() ?? 0,
        currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
        longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
        lastActiveDate: (json['last_active_date'] ?? '') as String,
        topicsMastered: (json['topics_mastered'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        assignedQuestionIds: (json['assigned_question_ids'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        completedQuestionIds: (json['completed_question_ids'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}

