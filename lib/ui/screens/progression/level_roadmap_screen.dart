import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/progression_provider.dart';
import '../../widgets/glassmorphic_card.dart';

class LevelRoadmapScreen extends StatelessWidget {
  const LevelRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progression = context.watch<ProgressionProvider>();
    final currentLevel = progression.currentLevel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('1,000+ Level Progression'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status banner
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
                    child: Center(
                      child: Text(
                        '$currentLevel',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tier: ${progression.progress.currentDifficultyBand}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${progression.totalSolved} questions solved without repetition',
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

            // Mastered Topics
            const Text(
              'Topics Mastered',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: progression.topicsMastered.map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.secondary.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text(
                        topic,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // 1000+ Level Bands
            const Text(
              'Progression Roadmap (Levels 1 to 1000+)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...AppConstants.levelBands.entries.map((entry) {
              final bandName = entry.key;
              final range = entry.value;
              final minLvl = range[0];
              final maxLvl = range[1];

              final isCompleted = currentLevel > maxLvl;
              final isCurrent = currentLevel >= minLvl && currentLevel <= maxLvl;
              final isLocked = currentLevel < minLvl;

              Color accentColor;
              if (isCompleted) {
                accentColor = AppColors.success;
              } else if (isCurrent) {
                accentColor = AppColors.secondary;
              } else {
                accentColor = AppColors.surfaceBorder;
              }

              return GlassmorphicCard(
                margin: const EdgeInsets.only(bottom: 12),
                border: isCurrent
                    ? Border.all(color: AppColors.secondary, width: 1.5)
                    : null,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(30),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor, width: 1.5),
                      ),
                      child: Center(
                        child: Icon(
                          isCompleted
                              ? Icons.check
                              : (isCurrent ? Icons.bolt : Icons.lock_outline),
                          color: accentColor,
                          size: 20,
                        ),
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
                                bandName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isLocked
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withAlpha(40),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'CURRENT',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Levels $minLvl – $maxLvl',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
