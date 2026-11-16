import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_utils.dart';
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

  @override
  Widget build(BuildContext context) {
    final usageProvider = context.watch<UsageTrackingProvider>();
    final apps = usageProvider.managedApps.where((app) {
      if (_searchQuery.isEmpty) return true;
      return app.appName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          app.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('App Limits & Protection'),
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
                hintText: 'Search applications or categories...',
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

          // Info banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GlassmorphicCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: AppColors.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Solving a coding challenge unlocks 20 additional minutes without resetting your daily baseline allowance.',
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
                        onToggleProtection: (val) {
                          usageProvider.toggleProtection(app.packageName, val);
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
}
