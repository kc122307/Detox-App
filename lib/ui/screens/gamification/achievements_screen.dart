import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/progression_provider.dart';
import '../../widgets/glassmorphic_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  IconData _getIconForAchievement(String icon) {
    switch (icon) {
      case 'terminal':
        return Icons.terminal;
      case 'shield_check':
        return Icons.verified_user;
      case 'fire':
        return Icons.local_fire_department;
      case 'compass':
        return Icons.explore;
      case 'trophy':
        return Icons.emoji_events;
      case 'crown':
        return Icons.workspace_premium;
      case 'military_tech':
        return Icons.military_tech;
      case 'diamond':
        return Icons.diamond;
      case 'star':
        return Icons.stars;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progression = context.watch<ProgressionProvider>();
    final achievements = progression.achievements;
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalXpFromAchievements = achievements
        .where((a) => a.isUnlocked)
        .fold(0, (acc, a) => acc + a.xpReward);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievements & Badges'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Banner
            GlassmorphicCard(
              gradient: AppColors.primaryGradient,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$unlockedCount of ${achievements.length} Unlocked',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+$totalXpFromAchievements XP Earned from achievements',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(220),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'All Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...achievements.map((ach) {
              final isUnlocked = ach.isUnlocked;
              final iconData = _getIconForAchievement(ach.icon);

              return GlassmorphicCard(
                margin: const EdgeInsets.only(bottom: 12),
                border: isUnlocked
                    ? Border.all(color: Colors.amber.withAlpha(120), width: 1.5)
                    : null,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? Colors.amber.withAlpha(35)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isUnlocked ? Colors.amber : AppColors.surfaceBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        iconData,
                        color: isUnlocked ? Colors.amber : AppColors.textMuted,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ach.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${ach.xpReward} XP',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ach.description,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: ach.percentComplete,
                                    minHeight: 5,
                                    backgroundColor: AppColors.surfaceBorder,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isUnlocked ? Colors.amber : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${ach.progress} / ${ach.maxProgress}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
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
}
