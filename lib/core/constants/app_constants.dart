class AppConstants {
  static const String appName = 'Code to Unlock';
  static const String appTagline = 'Your time. Your rules. Your progress.';
  static const String appPhilosophy = 'Use less social media. Solve more coding problems. Improve your programming skills. Earn your screen time.';

  // Reward Rules
  static const int rewardDurationMinutes = 20;
  static const int rewardDurationSeconds = rewardDurationMinutes * 60; // 1200s
  static const int firstUnlockRequiredQuestions = 1;
  static const int subsequentUnlockRequiredQuestions = 2;

  /// Calculates required questions based on exponential doubling across the daily cycle:
  /// 1st unlock today (completedUnlocksToday == 0): 1 question (2^0)
  /// 2nd unlock today (completedUnlocksToday == 1): 2 questions (2^1)
  /// 3rd unlock today (completedUnlocksToday == 2): 4 questions (2^2)
  /// 4th unlock today (completedUnlocksToday == 3): 8 questions (2^3)
  /// Doubles each subsequent unlock across all managed applications today.
  static int getRequiredQuestionsForUnlock(int completedUnlocksToday) {
    if (completedUnlocksToday <= 0) return 1;
    if (completedUnlocksToday >= 6) return 64; // safety cap
    return 1 << completedUnlocksToday;
  }

  // Anti-cheating & Manual typing rules
  static const int maxPasteBurstCharacters = 15; // Pasting large chunks is blocked
  static const double minimumTypingPercentageForValidation = 0.85; // 85% of characters must be manually typed
  static const int maxKeystrokesPerSecondAcceptable = 20; // Human typing threshold

  // Supported Programming Languages
  static const List<String> supportedLanguages = ['Java', 'Python', 'C++', 'JavaScript'];
  static const String defaultLanguage = 'Python';

  // Level Progression Configuration
  static const int maxLevel = 1000;
  static const int baseLevelXp = 100;
  static const double xpScalingFactor = 1.15;

  // Level Bands
  static const Map<String, List<int>> levelBands = {
    'Beginner': [1, 10],
    'Easy to Intermediate': [11, 30],
    'Intermediate': [31, 75],
    'Intermediate to Advanced': [76, 150],
    'Advanced': [151, 300],
    'Expert': [301, 500],
    'Very Advanced': [501, 750],
    'Master': [751, 1000],
  };

  // Supported Topics
  static const List<String> topics = [
    'Arrays',
    'Strings',
    'Searching and Sorting',
    'Hash Maps and Sets',
    'Linked Lists',
    'Stacks and Queues',
    'Trees and Binary Search Trees',
    'Graphs',
    'Dynamic Programming',
    'Backtracking',
    'Sliding Window',
    'Monotonic Stacks',
    'Heaps and Priority Queues',
    'Tries',
    'Bit Manipulation',
    'Greedy Algorithms',
    'Union Find',
    'Segment Trees',
  ];

  // Default Managed Apps
  static const List<Map<String, dynamic>> defaultTargetApps = [
    {
      'packageName': 'com.google.android.youtube',
      'appName': 'YouTube',
      'defaultLimitMinutes': 60,
      'category': 'Entertainment',
      'iconIdentifier': 'youtube',
    },
    {
      'packageName': 'com.instagram.android',
      'appName': 'Instagram',
      'defaultLimitMinutes': 45,
      'category': 'Social Media',
      'iconIdentifier': 'instagram',
    },
    {
      'packageName': 'com.facebook.katana',
      'appName': 'Facebook',
      'defaultLimitMinutes': 30,
      'category': 'Social Media',
      'iconIdentifier': 'facebook',
    },
    {
      'packageName': 'com.snapchat.android',
      'appName': 'Snapchat',
      'defaultLimitMinutes': 20,
      'category': 'Social Media',
      'iconIdentifier': 'snapchat',
    },
    {
      'packageName': 'com.reddit.frontpage',
      'appName': 'Reddit',
      'defaultLimitMinutes': 45,
      'category': 'Community',
      'iconIdentifier': 'reddit',
    },
    {
      'packageName': 'com.twitter.android',
      'appName': 'X (Twitter)',
      'defaultLimitMinutes': 30,
      'category': 'News & Social',
      'iconIdentifier': 'twitter',
    },
    {
      'packageName': 'com.whatsapp',
      'appName': 'WhatsApp',
      'defaultLimitMinutes': 60,
      'category': 'Messaging',
      'iconIdentifier': 'whatsapp',
    },
    {
      'packageName': 'com.zhiliaoapp.musically',
      'appName': 'TikTok',
      'defaultLimitMinutes': 30,
      'category': 'Entertainment',
      'iconIdentifier': 'tiktok',
    },
    {
      'packageName': 'com.netflix.mediaclient',
      'appName': 'Netflix',
      'defaultLimitMinutes': 60,
      'category': 'Entertainment',
      'iconIdentifier': 'netflix',
    },
  ];
}

