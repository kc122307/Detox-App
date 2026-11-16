import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/time_utils.dart';

class CircularTimeIndicator extends StatelessWidget {
  final int usedSeconds;
  final int totalSeconds;
  final double size;
  final double strokeWidth;

  const CircularTimeIndicator({
    super.key,
    required this.usedSeconds,
    required this.totalSeconds,
    this.size = 180,
    this.strokeWidth = 14,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalSeconds > 0
        ? (usedSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;
    final int remainingSecs = totalSeconds - usedSeconds;
    final bool isExhausted = remainingSecs <= 0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.surfaceBorder),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation<Color>(
                isExhausted
                    ? AppColors.restricted
                    : (progress > 0.85 ? AppColors.warning : AppColors.primary),
              ),
            ),
          ),
          // Inner text content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TimeUtils.formatDuration(usedSeconds),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'of ${TimeUtils.formatDuration(totalSeconds)} limit',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isExhausted
                      ? AppColors.restricted.withAlpha(40)
                      : AppColors.success.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isExhausted
                      ? 'Limit Exhausted'
                      : '${TimeUtils.formatDuration(remainingSecs)} left',
                  style: TextStyle(
                    color: isExhausted ? AppColors.restricted : AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
