import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DifficultyBadge extends StatelessWidget {
  final int rating;
  final String band;

  const DifficultyBadge({
    super.key,
    required this.rating,
    required this.band,
  });

  Color _getColor() {
    switch (band.toLowerCase()) {
      case 'beginner':
        return AppColors.difficultyBeginner;
      case 'easy to intermediate':
      case 'easy':
        return AppColors.difficultyEasy;
      case 'intermediate':
        return AppColors.difficultyMedium;
      case 'intermediate to advanced':
      case 'advanced':
        return AppColors.difficultyHard;
      case 'expert':
      case 'very advanced':
        return AppColors.difficultyExpert;
      case 'master':
      default:
        return AppColors.difficultyMaster;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(120), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$band (Rating $rating/10)',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

