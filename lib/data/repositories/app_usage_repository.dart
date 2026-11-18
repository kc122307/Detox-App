import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../models/managed_app_model.dart';
import '../models/reward_transaction_model.dart';
import '../models/unlock_session_model.dart';

class AppUsageRepository {
  static const _kManagedAppsKey = 'managed_apps_list';
  static const _kDailyUsagePrefix = 'daily_usage_';
  static const _kRewardTransactionsKey = 'reward_transactions_list';
  static const _kUnlockSessionsKey = 'unlock_sessions_list';
  static const _kLastActiveDateKey = 'last_active_date_key';
  static const _uuid = Uuid();

  final SharedPreferences _prefs;

  AppUsageRepository(this._prefs);

  static Future<AppUsageRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppUsageRepository(prefs);
  }

  // --- Managed Apps ---

  List<ManagedAppModel> getManagedApps() {
    final jsonStr = _prefs.getString(_kManagedAppsKey);
    if (jsonStr == null) {
      // Initialize with default target apps
      final defaultApps = AppConstants.defaultTargetApps.map((target) {
        return ManagedAppModel(
          id: target['packageName'] as String,
          userId: 'local_user',
          packageName: target['packageName'] as String,
          appName: target['appName'] as String,
          dailyLimitSeconds: (target['defaultLimitMinutes'] as int) * 60,
          protectionEnabled: true,
          category: target['category'] as String,
          iconIdentifier: target['iconIdentifier'] as String,
        );
      }).toList();
      saveManagedApps(defaultApps);
      return defaultApps;
    }

    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => ManagedAppModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveManagedApps(List<ManagedAppModel> apps) async {
    final jsonList = apps.map((a) => a.toJson()).toList();
    await _prefs.setString(_kManagedAppsKey, jsonEncode(jsonList));
  }

  Future<void> updateAppLimit(String packageName, int newLimitSeconds) async {
    final apps = getManagedApps();
    final index = apps.indexWhere((a) => a.packageName == packageName);
    if (index != -1) {
      apps[index] = apps[index].copyWith(dailyLimitSeconds: newLimitSeconds);
      await saveManagedApps(apps);
    }
  }

  Future<void> toggleAppProtection(String packageName, bool enabled) async {
    final apps = getManagedApps();
    final index = apps.indexWhere((a) => a.packageName == packageName);
    if (index != -1) {
      apps[index] = apps[index].copyWith(protectionEnabled: enabled);
      await saveManagedApps(apps);
    }
  }

  // --- Usage Tracking & Rollover ---

  int getTodayUsageSeconds(String packageName) {
    final dateKey = TimeUtils.getTodayDateKey();
    final key = '$_kDailyUsagePrefix${dateKey}_$packageName';
    return _prefs.getInt(key) ?? 0;
  }

  int getUsageForDate(String packageName, String dateKey) {
    final key = '$_kDailyUsagePrefix${dateKey}_$packageName';
    return _prefs.getInt(key) ?? 0;
  }

  Future<void> addUsageSeconds(String packageName, int secondsDelta) async {
    final dateKey = TimeUtils.getTodayDateKey();
    final key = '$_kDailyUsagePrefix${dateKey}_$packageName';
    final current = _prefs.getInt(key) ?? 0;
    await _prefs.setInt(key, current + secondsDelta);
  }

  Future<void> setTodayUsageSeconds(String packageName, int seconds) async {
    final dateKey = TimeUtils.getTodayDateKey();
    final key = '$_kDailyUsagePrefix${dateKey}_$packageName';
    await _prefs.setInt(key, seconds);
  }

  String getLastKnownDateKey() {
    return _prefs.getString(_kLastActiveDateKey) ?? TimeUtils.getTodayDateKey();
  }

  Future<void> recordDateActive(String dateKey) async {
    await _prefs.setString(_kLastActiveDateKey, dateKey);
  }

  // --- Reward Transactions ---

  List<RewardTransactionModel> getRewardTransactions() {
    final jsonStr = _prefs.getString(_kRewardTransactionsKey);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => RewardTransactionModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  RewardTransactionModel? getActiveReward(String packageName) {
    final rewards = getRewardTransactions();
    final active = rewards.where((r) => r.packageName == packageName && !r.isExpired).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
    return active.first;
  }

  Future<RewardTransactionModel> grantReward({
    required String packageName,
    required String unlockSessionId,
    required List<String> challengeIds,
    int durationMinutes = AppConstants.rewardDurationMinutes,
  }) async {
    final now = DateTime.now();
    final durationSecs = durationMinutes * 60;
    final expiresAt = now.add(Duration(seconds: durationSecs));

    final reward = RewardTransactionModel(
      id: _uuid.v4(),
      userId: 'local_user',
      packageName: packageName,
      unlockSessionId: unlockSessionId,
      challengeIds: challengeIds,
      durationSeconds: durationSecs,
      grantedAt: now,
      expiresAt: expiresAt,
      status: 'active',
    );

    final rewards = getRewardTransactions();
    rewards.add(reward);
    final jsonList = rewards.map((r) => r.toJson()).toList();
    await _prefs.setString(_kRewardTransactionsKey, jsonEncode(jsonList));

    return reward;
  }

  // --- Unlock Sessions (Tracking sequence: 1st unlock = 1 question, 2nd+ = 2 questions) ---

  List<UnlockSessionModel> getUnlockSessions() {
    final jsonStr = _prefs.getString(_kUnlockSessionsKey);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => UnlockSessionModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  UnlockSessionModel getOrCreateUnlockSession(String packageName) {
    final sessions = getUnlockSessions();
    // Look for pending session for this app today
    final pending = sessions.where((s) => s.packageName == packageName && s.status == 'in_progress').toList();
    if (pending.isNotEmpty) {
      return pending.first;
    }

    // Determine sequence number today across all apps (questions double each time: 1 -> 2 -> 4 -> 8...)
    final todayKey = TimeUtils.getTodayDateKey();
    final totalCompletedTodayAcrossApps = sessions.where((s) =>
        s.status == 'completed' &&
        s.completedAt != null &&
        todayKey == TimeUtils.formatShortDate(s.completedAt!)).length;

    final nextSequence = totalCompletedTodayAcrossApps + 1;
    final requiredQuestions = AppConstants.getRequiredQuestionsForUnlock(totalCompletedTodayAcrossApps);

    final newSession = UnlockSessionModel(
      id: _uuid.v4(),
      userId: 'local_user',
      packageName: packageName,
      unlockSequence: nextSequence,
      requiredQuestionCount: requiredQuestions,
      assignedQuestionIds: [],
      solvedQuestionIds: [],
      status: 'in_progress',
      createdAt: DateTime.now(),
    );

    sessions.add(newSession);
    _saveUnlockSessions(sessions);
    return newSession;
  }

  Future<void> updateUnlockSession(UnlockSessionModel updatedSession) async {
    final sessions = getUnlockSessions();
    final index = sessions.indexWhere((s) => s.id == updatedSession.id);
    if (index != -1) {
      sessions[index] = updatedSession;
    } else {
      sessions.add(updatedSession);
    }
    await _saveUnlockSessions(sessions);
  }

  Future<void> _saveUnlockSessions(List<UnlockSessionModel> sessions) async {
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs.setString(_kUnlockSessionsKey, jsonEncode(jsonList));
  }

  // --- Restriction State Check ---

  bool isAppRestricted(String packageName) {
    final apps = getManagedApps();
    final app = apps.firstWhere(
      (a) => a.packageName == packageName,
      orElse: () => ManagedAppModel(
        id: '',
        userId: '',
        packageName: packageName,
        appName: 'Unknown',
        dailyLimitSeconds: 3600,
        protectionEnabled: false,
      ),
    );

    if (!app.protectionEnabled) return false;

    final usedSeconds = getTodayUsageSeconds(packageName);
    final limitExceeded = usedSeconds >= app.dailyLimitSeconds;

    if (!limitExceeded) return false;

    // Daily limit exhausted! Check if an unexpired reward is currently active
    final activeReward = getActiveReward(packageName);
    if (activeReward != null && !activeReward.isExpired) {
      return false; // Active reward grants temporary access
    }

    return true; // Restricted!
  }

  // --- Data Export & Privacy Controls ---

  Map<String, dynamic> exportAllData() {
    return {
      'managed_apps': getManagedApps().map((a) => a.toJson()).toList(),
      'reward_transactions': getRewardTransactions().map((r) => r.toJson()).toList(),
      'unlock_sessions': getUnlockSessions().map((s) => s.toJson()).toList(),
      'export_timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> clearAllData() async {
    await _prefs.remove(_kManagedAppsKey);
    await _prefs.remove(_kRewardTransactionsKey);
    await _prefs.remove(_kUnlockSessionsKey);
    await _prefs.remove(_kLastActiveDateKey);
  }
}
