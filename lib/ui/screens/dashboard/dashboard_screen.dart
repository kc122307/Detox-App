import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../../../providers/progression_provider.dart';
import '../../../providers/usage_tracking_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/circular_time_indicator.dart';
import '../../widgets/glassmorphic_card.dart';
import '../analytics/analytics_screen.dart';
import '../app_management/app_limit_dialog.dart';
import '../app_management/app_management_screen.dart';
import '../gamification/achievements_screen.dart';
import '../progression/level_roadmap_screen.dart';
import '../restriction/restriction_overlay_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usageProvider = context.watch<UsageTrackingProvider>();
    final progressionProvider = context.watch<ProgressionProvider>();

    // If an app is currently restricted, transition to restriction overlay
    if (usageProvider.currentlyRestrictedAppPackage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pkg = usageProvider.currentlyRestrictedAppPackage;
        if (pkg != null) {
          usageProvider.clearCurrentlyRestrictedApp();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => RestrictionOverlayScreen(packageName: pkg),
            ),
          );
        }
      });
    }

    final protectedApps = usageProvider.managedApps.where((a) => a.protectionEnabled).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top User Greeting & Level Row
              _buildHeader(context, progressionProvider),
              const SizedBox(height: 24),

              // Screen-time Overview Card with Circular Indicator
              _buildScreenTimeOverview(context, usageProvider),
              const SizedBox(height: 24),

              // Coding Progression Card
              _buildCodingProgressionCard(context, progressionProvider),
              const SizedBox(height: 24),

              // Quick Actions Row
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Managed Applications Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Managed Applications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const AppManagementScreen()),
                      );
                    },
                    child: const Text('Manage All', style: TextStyle(color: AppColors.secondary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (protectedApps.isEmpty) ...[
                GlassmorphicCard(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.apps, size: 40, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'No apps protected yet.',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Choose applications to restrict screen-time with coding unlocks.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (ctx) => const AppManagementScreen()),
                            );
                          },
                          child: const Text('Configure Apps'),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ...protectedApps.map((app) {
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
                      if (isRestricted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => RestrictionOverlayScreen(packageName: app.packageName),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const AppManagementScreen()),
                        );
                      }
                    },
                  );
                }),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProgressionProvider progression) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLight.withAlpha(100), width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                Row(
                  children: [
                    const Text(
                      'Developer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Lvl ${progression.currentLevel}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Streak badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${progression.currentStreak}d',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Settings button
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.textSecondary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScreenTimeOverview(BuildContext context, UsageTrackingProvider usage) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      gradient: AppColors.cardGlowGradient,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Screen Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Resets at 00:00',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CircularTimeIndicator(
            usedSeconds: usage.totalUsedSeconds,
            totalSeconds: usage.totalAllowedSeconds > 0 ? usage.totalAllowedSeconds : 3600,
            size: 190,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric(
                label: 'Total Used',
                value: TimeUtils.formatDuration(usage.totalUsedSeconds),
                color: AppColors.primary,
              ),
              Container(width: 1, height: 30, color: AppColors.surfaceBorder),
              _buildStatMetric(
                label: 'Total Allowance',
                value: TimeUtils.formatDuration(usage.totalAllowedSeconds),
                color: AppColors.textPrimary,
              ),
              Container(width: 1, height: 30, color: AppColors.surfaceBorder),
              _buildStatMetric(
                label: 'Remaining',
                value: TimeUtils.formatDuration(usage.totalRemainingSeconds),
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildCodingProgressionCard(BuildContext context, ProgressionProvider progression) {
    final progress = progression.progress;

    return GlassmorphicCard(
      padding: const EdgeInsets.all(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => const LevelRoadmapScreen()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.military_tech, color: AppColors.secondary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Level ${progress.currentLevel} • ${progress.currentDifficultyBand}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.levelProgress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progress.xp % progress.xpForNextLevel} / ${progress.xpForNextLevel} XP to Level ${progress.currentLevel + 1}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '${progress.totalSolved} Solved',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionTile(
          context,
          icon: Icons.map,
          label: '1,000+ Map',
          color: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const LevelRoadmapScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
        _buildActionTile(
          context,
          icon: Icons.bar_chart,
          label: 'Analytics',
          color: AppColors.secondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const AnalyticsScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
        _buildActionTile(
          context,
          icon: Icons.emoji_events,
          label: 'Badges',
          color: Colors.amber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const AchievementsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GlassmorphicCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
