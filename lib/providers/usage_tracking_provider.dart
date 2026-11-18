import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/time_utils.dart';
import '../data/models/managed_app_model.dart';
import '../data/models/reward_transaction_model.dart';
import '../data/models/unlock_session_model.dart';
import '../data/repositories/app_usage_repository.dart';
import '../data/platform/app_usage_bridge.dart';

class UsageTrackingProvider extends ChangeNotifier {
  final AppUsageRepository _repository;
  final NotificationService? notificationService;
  Timer? _tickerTimer;

  List<ManagedAppModel> _managedApps = [];
  Map<String, int> _todayUsage = {};
  Map<String, RewardTransactionModel?> _activeRewards = {};
  Map<String, bool> _restrictedStatus = {};

  String? _currentlyRestrictedAppPackage;
  String _currentDateKey = TimeUtils.getTodayDateKey();
  bool _isSyncingApps = false;

  UsageTrackingProvider(this._repository, {this.notificationService}) {
    _loadState();
    syncInstalledApplications();
    _startUsageTicker();
  }

  List<ManagedAppModel> get managedApps => _managedApps;
  Map<String, int> get todayUsage => _todayUsage;
  Map<String, RewardTransactionModel?> get activeRewards => _activeRewards;
  Map<String, bool> get restrictedStatus => _restrictedStatus;
  String? get currentlyRestrictedAppPackage => _currentlyRestrictedAppPackage;
  bool get isSyncingApps => _isSyncingApps;

  /// Scans all launchable applications installed on the phone and merges them into detox manager
  Future<void> syncInstalledApplications() async {
    _isSyncingApps = true;
    notifyListeners();
    try {
      final installed = await AppUsageBridge.getInstalledApplications();
      if (installed.isNotEmpty) {
        _managedApps = await _repository.syncWithInstalledApps(installed);
        _refreshUsageData();
      }
    } catch (_) {}
    _isSyncingApps = false;
    notifyListeners();
  }

  int get totalAllowedSeconds => _managedApps
      .where((a) => a.protectionEnabled)
      .fold(0, (acc, app) => acc + app.dailyLimitSeconds);

  int get totalUsedSeconds => _managedApps
      .where((a) => a.protectionEnabled)
      .fold(0, (acc, app) => acc + (_todayUsage[app.packageName] ?? 0));

  int get totalRemainingSeconds {
    final diff = totalAllowedSeconds - totalUsedSeconds;
    return diff > 0 ? diff : 0;
  }

  void _loadState() {
    _managedApps = _repository.getManagedApps();
    _refreshUsageData();
  }

  void _refreshUsageData() {
    final newUsage = <String, int>{};
    final newRewards = <String, RewardTransactionModel?>{};
    final newRestricted = <String, bool>{};

    for (final app in _managedApps) {
      final used = _repository.getTodayUsageSeconds(app.packageName);
      newUsage[app.packageName] = used;

      final reward = _repository.getActiveReward(app.packageName);
      newRewards[app.packageName] = reward;

      final isRestricted = _repository.isAppRestricted(app.packageName);
      newRestricted[app.packageName] = isRestricted;
    }

    _todayUsage = newUsage;
    _activeRewards = newRewards;
    _restrictedStatus = newRestricted;

    // Sync active state to platform channel bridge
    final restrictedList = _managedApps
        .where((a) => _restrictedStatus[a.packageName] == true)
        .map((a) => a.packageName)
        .toList();
    final rewardsMap = <String, int>{};
    _activeRewards.forEach((pkg, r) {
      if (r != null && !r.isExpired) {
        rewardsMap[pkg] = r.remainingSeconds;
      }
    });

    AppUsageBridge.updateActiveRestrictions(
      restrictedPackages: restrictedList,
      activeRewardSeconds: rewardsMap,
    );

    notifyListeners();
  }

  void _startUsageTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Check for midnight rollover
      final nowKey = TimeUtils.getTodayDateKey();
      if (nowKey != _currentDateKey) {
        _currentDateKey = nowKey;
        _repository.recordDateActive(nowKey);
        _refreshUsageData();
        return;
      }

      // Check countdowns for active rewards
      bool shouldNotify = false;
      for (final app in _managedApps) {
        final reward = _activeRewards[app.packageName];
        if (reward != null) {
          if (reward.isExpired) {
            // Reward expired! Transition back to restricted
            _refreshUsageData();
            return;
          } else {
            shouldNotify = true;
          }
        }
      }
      if (shouldNotify) {
        notifyListeners();
      }
    });
  }

  int getRemainingSecondsForApp(String packageName) {
    final app = _managedApps.firstWhere(
      (a) => a.packageName == packageName,
      orElse: () => ManagedAppModel(id: '', userId: '', packageName: '', appName: '', dailyLimitSeconds: 0),
    );
    final used = _todayUsage[packageName] ?? 0;
    final limitRemaining = app.dailyLimitSeconds - used;

    final reward = _activeRewards[packageName];
    if (reward != null && !reward.isExpired) {
      return reward.remainingSeconds;
    }

    return limitRemaining > 0 ? limitRemaining : 0;
  }

  Future<void> updateAppLimit(String packageName, int newMinutes) async {
    final newSeconds = newMinutes * 60;
    await _repository.updateAppLimit(packageName, newSeconds);
    _managedApps = _repository.getManagedApps();
    _refreshUsageData();
  }

  Future<void> toggleProtection(String packageName, bool enabled) async {
    await _repository.toggleAppProtection(packageName, enabled);
    _managedApps = _repository.getManagedApps();
    _refreshUsageData();
  }

  /// Simulates usage progression or records real device usage
  Future<void> recordActiveUsage(String packageName, int secondsDelta) async {
    await _repository.addUsageSeconds(packageName, secondsDelta);
    _refreshUsageData();

    // If limit exceeded and no active reward, set as restricted
    if (_repository.isAppRestricted(packageName)) {
      _currentlyRestrictedAppPackage = packageName;
      final app = _managedApps.firstWhere(
        (a) => a.packageName == packageName,
        orElse: () => ManagedAppModel(id: '', userId: '', packageName: packageName, appName: 'App', dailyLimitSeconds: 0),
      );
      notificationService?.notifyLimitExhausted(app.appName);
      notifyListeners();
    }
  }

  /// Sets custom usage (useful for manual configuration and testing)
  Future<void> setAppUsage(String packageName, int usedMinutes) async {
    await _repository.setTodayUsageSeconds(packageName, usedMinutes * 60);
    _refreshUsageData();
  }

  UnlockSessionModel getActiveUnlockSession(String packageName) {
    return _repository.getOrCreateUnlockSession(packageName);
  }

  /// Grants 20-minute reward when required coding challenge(s) are passed
  Future<RewardTransactionModel> grantRewardForSession({
    required String packageName,
    required String unlockSessionId,
    required List<String> challengeIds,
  }) async {
    final reward = await _repository.grantReward(
      packageName: packageName,
      unlockSessionId: unlockSessionId,
      challengeIds: challengeIds,
      durationMinutes: AppConstants.rewardDurationMinutes,
    );

    // Complete the unlock session
    final session = _repository.getOrCreateUnlockSession(packageName);
    await _repository.updateUnlockSession(
      session.copyWith(
        status: 'completed',
        solvedQuestionIds: challengeIds,
        completedAt: DateTime.now(),
      ),
    );

    _currentlyRestrictedAppPackage = null;
    final app = _managedApps.firstWhere(
      (a) => a.packageName == packageName,
      orElse: () => ManagedAppModel(id: '', userId: '', packageName: packageName, appName: 'App', dailyLimitSeconds: 0),
    );
    notificationService?.notifyRewardUnlocked(app.appName);
    _refreshUsageData();
    return reward;
  }

  void clearCurrentlyRestrictedApp() {
    _currentlyRestrictedAppPackage = null;
    notifyListeners();
  }

  void triggerAppRestriction(String packageName) {
    _currentlyRestrictedAppPackage = packageName;
    notifyListeners();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
