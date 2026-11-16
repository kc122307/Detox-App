import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/time_utils.dart';
import '../../../data/platform/app_usage_bridge.dart';
import '../../../data/repositories/user_preferences_repository.dart';
import '../../../providers/progression_provider.dart';
import '../../widgets/glassmorphic_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _usagePermissionGranted = true;
  bool _accessibilityGranted = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final usage = await AppUsageBridge.hasUsagePermission();
    final access = await AppUsageBridge.hasAccessibilityPermission();
    if (mounted) {
      setState(() {
        _usagePermissionGranted = usage;
        _accessibilityGranted = access;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsRepo = context.watch<UserPreferencesRepository>();
    final progression = context.watch<ProgressionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings & Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            GlassmorphicCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prefsRepo.userName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Level ${progression.currentLevel} • ${progression.progress.currentDifficultyBand}',
                          style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Coding Preferences Section
            const Text(
              'Coding Preferences',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GlassmorphicCard(
              child: Column(
                children: [
                  // Language selection tile
                  ListTile(
                    title: const Text('Primary Language'),
                    subtitle: Text(prefsRepo.preferredLanguage),
                    trailing: DropdownButton<String>(
                      value: prefsRepo.preferredLanguage,
                      dropdownColor: AppColors.surfaceElevated,
                      underline: const SizedBox.shrink(),
                      items: AppConstants.supportedLanguages.map((l) {
                        return DropdownMenuItem(value: l, child: Text(l));
                      }).toList(),
                      onChanged: (newLang) {
                        if (newLang != null) {
                          prefsRepo.setPreferredLanguage(newLang);
                        }
                      },
                    ),
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  // Daily coding target tile
                  ListTile(
                    title: const Text('Daily Coding Goal'),
                    subtitle: Text('${prefsRepo.dailyCodingGoal} problems per day'),
                    trailing: DropdownButton<int>(
                      value: prefsRepo.dailyCodingGoal,
                      dropdownColor: AppColors.surfaceElevated,
                      underline: const SizedBox.shrink(),
                      items: [1, 2, 3, 4, 5].map((g) {
                        return DropdownMenuItem(value: g, child: Text('$g'));
                      }).toList(),
                      onChanged: (newGoal) {
                        if (newGoal != null) {
                          prefsRepo.setDailyCodingGoal(newGoal);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Schedule & Restrictions
            const Text(
              'Restriction & Reset Schedule',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GlassmorphicCard(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Daily Allowance Reset'),
                    subtitle: const Text('Resets everyday at midnight (00:00)'),
                    trailing: const Icon(Icons.schedule, color: AppColors.secondary),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Daily reset runs automatically at 00:00 local time.')),
                      );
                    },
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  ListTile(
                    title: const Text('Emergency Override Audit Log'),
                    subtitle: Text('${prefsRepo.getEmergencyLogs().length} bypasses recorded'),
                    trailing: const Icon(Icons.history, color: AppColors.textSecondary),
                    onTap: () => _showAuditLogSheet(context, prefsRepo),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // System Permissions Status
            const Text(
              'System Permissions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GlassmorphicCard(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Usage Stats Access'),
                    subtitle: Text(_usagePermissionGranted ? 'Granted' : 'Permission Required'),
                    trailing: Icon(
                      _usagePermissionGranted ? Icons.check_circle : Icons.error_outline,
                      color: _usagePermissionGranted ? AppColors.success : AppColors.error,
                    ),
                    onTap: AppUsageBridge.requestUsagePermission,
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  ListTile(
                    title: const Text('Accessibility Enforcement Service'),
                    subtitle: Text(_accessibilityGranted ? 'Active' : 'Disabled'),
                    trailing: Icon(
                      _accessibilityGranted ? Icons.check_circle : Icons.error_outline,
                      color: _accessibilityGranted ? AppColors.success : AppColors.error,
                    ),
                    onTap: AppUsageBridge.requestAccessibilityPermission,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy & Data
            const Text(
              'Privacy & Controls',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GlassmorphicCard(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Product Philosophy'),
                    subtitle: const Text(AppConstants.appPhilosophy),
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  ListTile(
                    title: const Text('Local Privacy Guarantee'),
                    subtitle: const Text('Usage statistics are stored locally on your device.'),
                    trailing: const Icon(Icons.shield, color: AppColors.success),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAuditLogSheet(BuildContext context, UserPreferencesRepository prefsRepo) {
    final logs = prefsRepo.getEmergencyLogs();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emergency Bypass Audit Log',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Full transparent history of all emergency unlocks.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              if (logs.isEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No emergency overrides logged. Excellent discipline!'),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (ctx, idx) {
                      final log = logs[idx];
                      return ListTile(
                        leading: const Icon(Icons.warning, color: AppColors.warning),
                        title: Text(log.reason),
                        subtitle: Text(TimeUtils.formatTimestamp(log.timestamp)),
                        trailing: Text('+${log.minutesGranted}m'),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
