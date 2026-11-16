import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ManualTypingIndicator extends StatelessWidget {
  final double manualTypingRatio;
  final int keystrokesCount;
  final int pasteAttemptsCount;
  final double typingProgress;

  const ManualTypingIndicator({
    super.key,
    required this.manualTypingRatio,
    required this.keystrokesCount,
    required this.pasteAttemptsCount,
    required this.typingProgress,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPasteAttempt = pasteAttemptsCount > 0;
    final int typingPercentage = (manualTypingRatio * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: hasPasteAttempt
            ? AppColors.error.withAlpha(25)
            : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasPasteAttempt ? AppColors.error.withAlpha(120) : AppColors.surfaceBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasPasteAttempt ? Icons.warning_amber_rounded : Icons.keyboard,
                size: 16,
                color: hasPasteAttempt ? AppColors.error : AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                hasPasteAttempt
                    ? 'Paste Blocked! Solutions must be typed manually.'
                    : 'Manual Typing Progress: $typingPercentage%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasPasteAttempt ? AppColors.error : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$keystrokesCount Keys',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: typingProgress,
              minHeight: 4,
              backgroundColor: AppColors.surfaceBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                hasPasteAttempt
                    ? AppColors.error
                    : (typingProgress > 0.8 ? AppColors.success : AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

