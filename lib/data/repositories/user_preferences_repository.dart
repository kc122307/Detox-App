import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class EmergencyOverrideLog {
  final DateTime timestamp;
  final String reason;
  final int minutesGranted;

  EmergencyOverrideLog({
    required this.timestamp,
    required this.reason,
    required this.minutesGranted,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'reason': reason,
        'minutes_granted': minutesGranted,
      };

  factory EmergencyOverrideLog.fromJson(Map<String, dynamic> json) => EmergencyOverrideLog(
        timestamp: DateTime.parse(json['timestamp'] as String),
        reason: json['reason'] as String? ?? 'Emergency access',
        minutesGranted: (json['minutes_granted'] as num?)?.toInt() ?? 15,
      );
}

class UserPreferencesRepository {
  static const _kPreferredLanguage = 'pref_language';
  static const _kDailyCodingGoal = 'pref_daily_coding_goal';
  static const _kResetHour = 'pref_reset_hour';
  static const _kResetMinute = 'pref_reset_minute';
  static const _kOnboardingComplete = 'pref_onboarding_complete';
  static const _kUserGoals = 'pref_user_goals';
  static const _kEmergencyLogs = 'pref_emergency_logs';
  static const _kUserName = 'pref_user_name';

  final SharedPreferences _prefs;

  UserPreferencesRepository(this._prefs);

  static Future<UserPreferencesRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPreferencesRepository(prefs);
  }

  String get preferredLanguage =>
      _prefs.getString(_kPreferredLanguage) ?? AppConstants.defaultLanguage;

  Future<void> setPreferredLanguage(String lang) async {
    await _prefs.setString(_kPreferredLanguage, lang);
  }

  String get userName => _prefs.getString(_kUserName) ?? 'Developer';

  Future<void> setUserName(String name) async {
    await _prefs.setString(_kUserName, name);
  }

  int get dailyCodingGoal => _prefs.getInt(_kDailyCodingGoal) ?? 2;

  Future<void> setDailyCodingGoal(int goal) async {
    await _prefs.setInt(_kDailyCodingGoal, goal);
  }

  int get resetHour => _prefs.getInt(_kResetHour) ?? 0;
  int get resetMinute => _prefs.getInt(_kResetMinute) ?? 0;

  Future<void> setResetTime(int hour, int minute) async {
    await _prefs.setInt(_kResetHour, hour);
    await _prefs.setInt(_kResetMinute, minute);
  }

  bool get isOnboardingComplete => _prefs.getBool(_kOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_kOnboardingComplete, complete);
  }

  List<String> get selectedGoals {
    return _prefs.getStringList(_kUserGoals) ??
        [
          'Reduce social media usage',
          'Improve DSA skills',
          'Build daily coding consistency',
        ];
  }

  Future<void> setSelectedGoals(List<String> goals) async {
    await _prefs.setStringList(_kUserGoals, goals);
  }

  List<EmergencyOverrideLog> getEmergencyLogs() {
    final raw = _prefs.getString(_kEmergencyLogs);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => EmergencyOverrideLog.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> recordEmergencyOverride(String reason, int minutes) async {
    final logs = getEmergencyLogs();
    logs.add(EmergencyOverrideLog(
      timestamp: DateTime.now(),
      reason: reason,
      minutesGranted: minutes,
    ));
    await _prefs.setString(_kEmergencyLogs, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }
}

