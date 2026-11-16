import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../../../providers/progression_provider.dart';
import '../../../providers/usage_tracking_provider.dart';
import '../../widgets/glassmorphic_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usageProvider = context.watch<UsageTrackingProvider>();
    final progressionProvider = context.watch<ProgressionProvider>();

    final savedMinutes = progressionProvider.calculateSavedMinutes(usageProvider.totalUsedSeconds);
    final acceptanceRate = (progressionProvider.acceptanceRate * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistics & Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Saved Banner
            GlassmorphicCard(
              gradient: AppColors.primaryGradient,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.hourglass_top, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Verified Screen Time Saved',
                        style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${savedMinutes ~/ 60}h ${savedMinutes % 60}m',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Calculated strictly from reduced social media screen-time versus baseline (3h) plus focused coding problem-solving time.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(210),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Coding Performance Metrics Row
            const Text(
              'Coding Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetricCard(
                  'Solved',
                  '${progressionProvider.totalSolved}',
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
                const SizedBox(width: 12),
                _buildMetricCard(
                  'Acceptance',
                  '$acceptanceRate%',
                  Icons.show_chart,
                  AppColors.secondary,
                ),
                const SizedBox(width: 12),
                _buildMetricCard(
                  'Streak',
                  '${progressionProvider.currentStreak}d',
                  Icons.local_fire_department,
                  Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Screen-Time Chart Section
            const Text(
              'Weekly Screen Time Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GlassmorphicCard(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 120,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'Today'];
                            final idx = val.toInt();
                            if (idx >= 0 && idx < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  days[idx],
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _makeBarGroup(0, 45, false),
                      _makeBarGroup(1, 60, false),
                      _makeBarGroup(2, 35, false),
                      _makeBarGroup(3, 50, false),
                      _makeBarGroup(4, 30, false),
                      _makeBarGroup(5, 40, false),
                      _makeBarGroup(6, (usageProvider.totalUsedSeconds / 60).clamp(5, 110), true),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Application Usage Breakdown
            const Text(
              'Per-App Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...usageProvider.managedApps.where((a) => a.protectionEnabled).map((app) {
              final used = usageProvider.todayUsage[app.packageName] ?? 0;
              final percent = app.dailyLimitSeconds > 0
                  ? (used / app.dailyLimitSeconds).clamp(0.0, 1.0)
                  : 0.0;

              return GlassmorphicCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        app.appName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percent >= 1.0 ? AppColors.restricted : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      TimeUtils.formatDuration(used),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static BarChartGroupData _makeBarGroup(int x, double y, bool isToday) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isToday ? AppColors.secondary : AppColors.primary.withAlpha(120),
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
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
        ),
      ),
    );
  }
}
