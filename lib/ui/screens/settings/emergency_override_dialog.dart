import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/user_preferences_repository.dart';
import '../../../providers/usage_tracking_provider.dart';
import '../../widgets/custom_button.dart';

class EmergencyOverrideDialog extends StatefulWidget {
  final String appName;
  final String packageName;

  const EmergencyOverrideDialog({
    super.key,
    required this.appName,
    required this.packageName,
  });

  @override
  State<EmergencyOverrideDialog> createState() => _EmergencyOverrideDialogState();
}

class _EmergencyOverrideDialogState extends State<EmergencyOverrideDialog> {
  final TextEditingController _reasonController = TextEditingController();
  int _overrideMinutes = 15;
  bool _confirmed = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Emergency Override',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Code to Unlock provides transparent emergency access so you are never locked out of vital communications or urgent tasks. All emergency overrides are logged in your permanent audit history.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Override Duration Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Temporary Duration:'),
                DropdownButton<int>(
                  value: _overrideMinutes,
                  dropdownColor: AppColors.surfaceElevated,
                  items: [5, 10, 15, 30].map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text('$m Minutes'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _overrideMinutes = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Mandatory Reason TextField
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason (e.g., urgent message, work task)...',
                labelText: 'Audit Justification (Required)',
              ),
            ),
            const SizedBox(height: 12),

            // Confirmation checkbox
            Row(
              children: [
                Checkbox(
                  value: _confirmed,
                  activeColor: AppColors.warning,
                  onChanged: (val) => setState(() => _confirmed = val ?? false),
                ),
                const Expanded(
                  child: Text(
                    'I acknowledge this bypass will be audited in my digital wellbeing log.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            CustomGradientButton(
              text: 'Confirm Emergency Bypass',
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFB45309)],
              ),
              onPressed: (!_confirmed || _reasonController.text.trim().isEmpty)
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      final prefsRepo = context.read<UserPreferencesRepository>();
                      final usageProvider = context.read<UsageTrackingProvider>();

                      // Record in audit log
                      await prefsRepo.recordEmergencyOverride(
                        _reasonController.text.trim(),
                        _overrideMinutes,
                      );

                      // Grant temporary emergency reward
                      await usageProvider.grantRewardForSession(
                        packageName: widget.packageName,
                        unlockSessionId: 'emergency_override',
                        challengeIds: ['override_audit_${DateTime.now().millisecondsSinceEpoch}'],
                      );

                      if (mounted) {
                        navigator.pop(); // Close dialog
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              '$_overrideMinutes minutes emergency access granted for ${widget.appName}.',
                            ),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
