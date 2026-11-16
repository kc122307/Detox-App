import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/time_utils.dart';
import '../../data/models/managed_app_model.dart';
import '../../data/models/reward_transaction_model.dart';
import 'glassmorphic_card.dart';

class AppCard extends StatelessWidget {
  final ManagedAppModel app;
  final int usedSeconds;
  final RewardTransactionModel? activeReward;
  final bool isRestricted;
  final ValueChanged<bool>? onToggleProtection;
  final VoidCallback? onEditLimit;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.app,
    required this.usedSeconds,
    this.activeReward,
    required this.isRestricted,
    this.onToggleProtection,
    this.onEditLimit,
    this.onTap,
  });

  IconData _getIconForApp(String iconIdentifier) {
    switch (iconIdentifier.toLowerCase()) {
      case 'youtube':
        return Icons.play_circle_fill;
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      case 'snapchat':
        return Icons.chat_bubble;
      case 'reddit':
        return Icons.forum;
      case 'twitter':
        return Icons.tag;
      case 'whatsapp':
        return Icons.message;
      case 'tiktok':
        return Icons.music_note;
      case 'netflix':
        return Icons.movie;
      default:
        return Icons.apps;
    }
  }

  Color _getColorForApp(String iconIdentifier) {
    switch (iconIdentifier.toLowerCase()) {
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'instagram':
        return const Color(0xFFE1306C);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'snapchat':
        return const Color(0xFFFFFC00);
      case 'reddit':
        return const Color(0xFFFF4500);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'tiktok':
        return const Color(0xFF00F2FE);
      case 'netflix':
        return const Color(0xFFE50914);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = app.dailyLimitSeconds > 0
        ? (usedSeconds / app.dailyLimitSeconds).clamp(0.0, 1.0)
        : 0.0;
    final bool hasActiveReward = activeReward != null && !activeReward!.isExpired;
    final iconColor = _getColorForApp(app.iconIdentifier);

    return GlassmorphicCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      border: isRestricted
          ? Border.all(color: AppColors.restricted.withAlpha(150), width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // App Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withAlpha(80), width: 1),
                ),
                child: Icon(
                  _getIconForApp(app.iconIdentifier),
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // App Title and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.appName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          app.category,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        if (hasActiveReward) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.unlocked.withAlpha(40),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock_open, size: 10, color: AppColors.unlocked),
                                const SizedBox(width: 4),
                                Text(
                                  'Reward: ${TimeUtils.formatDuration(activeReward!.remainingSeconds)} left',
                                  style: const TextStyle(
                                    color: AppColors.unlocked,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (isRestricted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.restricted.withAlpha(40),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.lock, size: 10, color: AppColors.restricted),
                                SizedBox(width: 4),
                                Text(
                                  'RESTRICTED',
                                  style: TextStyle(
                                    color: AppColors.restricted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Protection toggle switch
              Switch(
                value: app.protectionEnabled,
                onChanged: onToggleProtection,
                activeThumbColor: AppColors.primary,
                inactiveThumbColor: AppColors.textMuted,
                inactiveTrackColor: AppColors.surfaceBorder,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Linear usage progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                isRestricted
                    ? AppColors.restricted
                    : (progress > 0.85 ? AppColors.warning : AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Used: ${TimeUtils.formatDuration(usedSeconds)} / ${TimeUtils.formatDuration(app.dailyLimitSeconds)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: onEditLimit,
                child: Row(
                  children: [
                    Text(
                      'Limit: ${app.dailyLimitMinutes}m',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 12, color: AppColors.secondary),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
