import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../../../data/platform/app_usage_bridge.dart';
import '../../../providers/usage_tracking_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/glassmorphic_card.dart';
import 'app_limit_dialog.dart';

class AppManagementScreen extends StatefulWidget {
  const AppManagementScreen({super.key});

  @override
  State<AppManagementScreen> createState() => _AppManagementScreenState();
}

class _AppManagementScreenState extends State<AppManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyProtected = false;

  @override
  Widget build(BuildContext context) {
    final usageProvider = context.watch<UsageTrackingProvider>();
    final allApps = usageProvider.managedApps;
    final protectedCount = allApps.where((a) => a.protectionEnabled).length;

    final apps = allApps.where((app) {
      if (_showOnlyProtected && !app.protectionEnabled) return false;
      if (_searchQuery.isEmpty) return true;
      return app.appName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app.packageName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('App Limits & Detox'),
        actions: [
          IconButton(
            icon: usageProvider.isSyncingApps
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Rescan Installed Apps',
            onPressed: usageProvider.isSyncingApps
                ? null
                : () => usageProvider.syncInstalledApplications(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Summary Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search any installed app on your mobile...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter chips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('All Installed (${allApps.length})', !_showOnlyProtected, () {
                  setState(() => _showOnlyProtected = false);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Detox Switched ON ($protectedCount)', _showOnlyProtected, () {
                  setState(() => _showOnlyProtected = true);
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Permission Alert Banner if missing
          if (!usageProvider.arePermissionsGranted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GlassmorphicCard(
                padding: const EdgeInsets.all(12),
                border: Border.all(color: Colors.amber.withAlpha(160)),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Permissions Required to Count Screen Time',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Usage Access & Accessibility are needed to count screen time when an app opens and lock it after the limit.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withAlpha(220),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      onPressed: () => _showPermissionsDialog(context, usageProvider),
                      child: const Text('Grant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

          // Info banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GlassmorphicCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 20, color: AppColors.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Apps with switch OFF are completely free to use. Switch ON detox only for apps you wish to restrict.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withAlpha(220),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // App List
          Expanded(
            child: apps.isEmpty
                ? const Center(
                    child: Text(
                      'No matching applications found.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      final used = usageProvider.todayUsage[app.packageName] ?? 0;
                      final reward = usageProvider.activeRewards[app.packageName];
                      final isRestricted = usageProvider.restrictedStatus[app.packageName] ?? false;

                      return AppCard(
                        app: app,
                        usedSeconds: used,
                        activeReward: reward,
                        isRestricted: isRestricted,
                        onToggleProtection: (val) async {
                          await usageProvider.toggleProtection(app.packageName, val);
                          if (val && !usageProvider.arePermissionsGranted && context.mounted) {
                            _showPermissionsDialog(context, usageProvider);
                          }
                        },
                        onEditLimit: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AppLimitDialog(
                              appName: app.appName,
                              currentLimitMinutes: app.dailyLimitMinutes,
                              onSave: (newMinutes) {
                                usageProvider.updateAppLimit(app.packageName, newMinutes);
                              },
                            ),
                          );
                        },
                        onTap: () {
                          // Allow quick simulated usage test
                          _showAppDetailsBottomSheet(context, app, used, isRestricted);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAppDetailsBottomSheet(
    BuildContext context,
    dynamic app,
    int usedSeconds,
    bool isRestricted,
  ) {
    final usageProvider = context.read<UsageTrackingProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.appName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Package: ${app.packageName}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Today\'s Used Screen Time:'),
                  Text(
                    TimeUtils.formatDuration(usedSeconds),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Configured Daily Limit:'),
                  Text(
                    '${app.dailyLimitMinutes} minutes',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Quick Screen-Time Testing Controls:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Add 15 min usage
                        usageProvider.recordActiveUsage(app.packageName, 15 * 60);
                        Navigator.pop(ctx);
                      },
                      child: const Text('+15m Usage'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.restricted,
                        side: const BorderSide(color: AppColors.restricted),
                      ),
                      onPressed: () {
                        // Exceed limit immediately to test restriction & unlock challenge
                        usageProvider.setAppUsage(app.packageName, app.dailyLimitMinutes + 1);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Exhaust Limit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPermissionsDialog(BuildContext context, UsageTrackingProvider usageProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.security, color: AppColors.secondary),
            SizedBox(width: 10),
            Text('Permissions Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To count your screen time as soon as you open an app and lock it once your daily limit is exhausted, two permissions are needed:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.data_usage, color: AppColors.primaryLight),
              title: const Text('1. Usage Access Permission', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: const Text('Measures foreground screen-time accurately.', style: TextStyle(fontSize: 12)),
              trailing: ElevatedButton(
                onPressed: () async {
                  await AppUsageBridge.requestUsagePermission();
                  if (context.mounted) usageProvider.checkPermissions();
                },
                child: const Text('Open'),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.accessibility_new, color: AppColors.secondary),
              title: const Text('2. Accessibility Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: const Text('Locks the app and presents the coding unlock screen.', style: TextStyle(fontSize: 12)),
              trailing: ElevatedButton(
                onPressed: () async {
                  await AppUsageBridge.requestAccessibilityPermission();
                  if (context.mounted) usageProvider.checkPermissions();
                },
                child: const Text('Open'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              usageProvider.checkPermissions();
            },
            child: const Text('Done', style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(40) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

