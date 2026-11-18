import 'dart:io';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../models/managed_app_model.dart';

class AppUsageBridge {
  static const MethodChannel _channel = MethodChannel('com.codetounlock/usage');

  /// Checks if UsageStats permission is granted
  static Future<bool> hasUsagePermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool result = await _channel.invokeMethod('hasUsagePermission');
      return result;
    } on MissingPluginException {
      return true; // Simulation mode
    } catch (_) {
      return false;
    }
  }

  /// Opens Android Settings for Usage Access
  static Future<void> requestUsagePermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } catch (_) {}
  }

  /// Checks if Accessibility Service is enabled
  static Future<bool> hasAccessibilityPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final bool result = await _channel.invokeMethod('hasAccessibilityPermission');
      return result;
    } on MissingPluginException {
      return true; // Simulation mode
    } catch (_) {
      return false;
    }
  }

  /// Opens Android Settings for Accessibility Services
  static Future<void> requestAccessibilityPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (_) {}
  }

  /// Retrieves list of installed applications
  static Future<List<ManagedAppModel>> getInstalledApplications() async {
    if (Platform.isAndroid) {
      try {
        final List<dynamic>? apps = await _channel.invokeMethod('getInstalledApps');
        if (apps != null && apps.isNotEmpty) {
          return apps.map((app) {
            final map = Map<String, dynamic>.from(app as Map);
            return ManagedAppModel(
              id: map['packageName'] as String,
              userId: 'local_user',
              packageName: map['packageName'] as String,
              appName: map['appName'] as String,
              dailyLimitSeconds: 3600,
              protectionEnabled: false,
              category: map['category'] as String? ?? 'General',
              iconIdentifier: map['appName'].toString().toLowerCase(),
            );
          }).toList();
        }
      } catch (_) {}
    }

    // High-fidelity curated default apps for testing & simulation
    return AppConstants.defaultTargetApps.map((target) {
      return ManagedAppModel(
        id: target['packageName'] as String,
        userId: 'local_user',
        packageName: target['packageName'] as String,
        appName: target['appName'] as String,
        dailyLimitSeconds: (target['defaultLimitMinutes'] as int) * 60,
        protectionEnabled: false,
        category: target['category'] as String,
        iconIdentifier: target['iconIdentifier'] as String,
      );
    }).toList();
  }

  /// Syncs active restrictions to native service
  static Future<void> updateActiveRestrictions({
    required List<String> restrictedPackages,
    required Map<String, int> activeRewardSeconds,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('updateActiveRestrictions', {
        'restrictedPackages': restrictedPackages,
        'activeRewards': activeRewardSeconds,
      });
    } catch (_) {}
  }
}

