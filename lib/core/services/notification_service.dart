import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationType {
  limitApproaching,
  limitExhausted,
  challengeReminder,
  rewardUnlocked,
  rewardExpiring,
  goalCompleted,
  streakReminder,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final String? targetPackage;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.targetPackage,
  });
}

class NotificationService extends ChangeNotifier {
  static const _kNotificationsEnabled = 'pref_notifications_enabled';
  final SharedPreferences _prefs;
  final List<AppNotification> _notifications = [];

  NotificationService(this._prefs);

  static Future<NotificationService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationService(prefs);
  }

  bool get isEnabled => _prefs.getBool(_kNotificationsEnabled) ?? true;
  List<AppNotification> get recentNotifications => List.unmodifiable(_notifications);

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_kNotificationsEnabled, enabled);
    notifyListeners();
  }

  /// Sends a notification alert if enabled
  void dispatchNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? targetPackage,
  }) {
    if (!isEnabled) return;

    final notif = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
      targetPackage: targetPackage,
    );

    _notifications.insert(0, notif);
    if (_notifications.length > 50) {
      _notifications.removeLast();
    }
    notifyListeners();
  }

  // --- Convenience dispatchers ---

  void notifyLimitApproaching(String appName, int minutesRemaining) {
    dispatchNotification(
      title: '$appName: Limit Approaching',
      body: 'You have only $minutesRemaining minutes of allowance remaining today.',
      type: NotificationType.limitApproaching,
    );
  }

  void notifyLimitExhausted(String appName) {
    dispatchNotification(
      title: '$appName Limit Reached',
      body: 'Your daily screen-time allowance is exhausted. Solve a coding challenge to earn 20 minutes.',
      type: NotificationType.limitExhausted,
    );
  }

  void notifyRewardUnlocked(String appName) {
    dispatchNotification(
      title: '20 Minutes Unlocked! 🎉',
      body: 'Challenge accepted! You have earned 20 minutes of usage for $appName.',
      type: NotificationType.rewardUnlocked,
    );
  }

  void notifyRewardExpiring(String appName) {
    dispatchNotification(
      title: '$appName: Reward Expiring Soon',
      body: 'Your earned 20-minute session will expire in 2 minutes.',
      type: NotificationType.rewardExpiring,
    );
  }

  void notifyGoalCompleted(int problemsSolved) {
    dispatchNotification(
      title: 'Daily Coding Target Met! 🚀',
      body: 'You solved $problemsSolved problems today. Keep building your programming discipline!',
      type: NotificationType.goalCompleted,
    );
  }

  void notifyStreakReminder(int currentStreak) {
    dispatchNotification(
      title: 'Protect Your $currentStreak-Day Streak! 🔥',
      body: 'Solve at least one challenge today to keep your streak alive.',
      type: NotificationType.streakReminder,
    );
  }
}

