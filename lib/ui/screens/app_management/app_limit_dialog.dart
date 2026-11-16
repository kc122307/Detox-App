import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';

class AppLimitDialog extends StatefulWidget {
  final String appName;
  final int currentLimitMinutes;
  final ValueChanged<int> onSave;

  const AppLimitDialog({
    super.key,
    required this.appName,
    required this.currentLimitMinutes,
    required this.onSave,
  });

  @override
  State<AppLimitDialog> createState() => _AppLimitDialogState();
}

class _AppLimitDialogState extends State<AppLimitDialog> {
  late int _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.currentLimitMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set ${widget.appName} Limit',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Once this allowance is exhausted, solving coding challenges will be required to unlock 20-minute sessions.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Big duration display
            Center(
              child: Text(
                '$_selectedMinutes Minutes',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Minute slider
            Slider(
              value: _selectedMinutes.toDouble(),
              min: 10,
              max: 180,
              divisions: 34, // 5 min increments
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() => _selectedMinutes = val.round());
              },
            ),

            // Quick preset chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [15, 30, 45, 60, 90, 120].map((mins) {
                final isSelected = _selectedMinutes == mins;
                return ChoiceChip(
                  label: Text('${mins}m'),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withAlpha(60),
                  backgroundColor: AppColors.surfaceElevated,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMinutes = mins);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            CustomGradientButton(
              text: 'Save Limit',
              onPressed: () {
                widget.onSave(_selectedMinutes);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

