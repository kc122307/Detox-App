import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../../../data/models/managed_app_model.dart';
import '../../../providers/challenge_provider.dart';
import '../../../providers/progression_provider.dart';
import '../../../providers/usage_tracking_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glassmorphic_card.dart';
import '../coding/coding_challenge_screen.dart';
import '../settings/emergency_override_dialog.dart';

class RestrictionOverlayScreen extends StatelessWidget {
  final String packageName;

  const RestrictionOverlayScreen({
    super.key,
    required this.packageName,
  });

  @override
  Widget build(BuildContext context) {
    final usageProvider = context.watch<UsageTrackingProvider>();
    final progressionProvider = context.watch<ProgressionProvider>();

    final app = usageProvider.managedApps.firstWhere(
      (a) => a.packageName == packageName,
      orElse: () => ManagedAppModel(
        id: '',
        userId: '',
        packageName: packageName,
        appName: 'Application',
        dailyLimitSeconds: 3600,
      ),
    );

    final usedSeconds = usageProvider.todayUsage[packageName] ?? app.dailyLimitSeconds;
    final session = usageProvider.getActiveUnlockSession(packageName);
    final requiredQuestions = session.requiredQuestionCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Restriction Shield Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.restricted.withAlpha(35),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.restricted, width: 2),
                ),
                child: const Icon(Icons.lock, size: 42, color: AppColors.restricted),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                '${app.appName} Limit Reached',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withAlpha(80)),
                ),
                child: Text(
                  'If you want to use ${app.appName} for 15 minutes, you have to solve $requiredQuestions coding ${requiredQuestions == 1 ? "question" : "questions"}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats summary card
              GlassmorphicCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Time Spent Today:', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          TimeUtils.formatDuration(usedSeconds),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.surfaceBorder, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Configured Allowance:', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          '${app.dailyLimitMinutes} minutes',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.surfaceBorder, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Unlock Reward Duration:', style: TextStyle(color: AppColors.textSecondary)),
                        const Text(
                          '15 Minutes',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.surfaceBorder, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Required Challenges:', style: TextStyle(color: AppColors.textSecondary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$requiredQuestions ${requiredQuestions == 1 ? "Problem" : "Problems"}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daily Unlock #${session.unlockSequence} • Doubling rule: 1st=1, 2nd=2, 3rd=4, 4th=8 questions',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Level & Motivation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 18, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      'Your Coding Level: ${progressionProvider.currentLevel} (${progressionProvider.progress.currentDifficultyBand})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // CTA to Solve Coding Challenge
              CustomGradientButton(
                text: 'Solve $requiredQuestions ${requiredQuestions == 1 ? "Challenge" : "Challenges"} (Unlock 15m)',
                icon: Icons.code,
                onPressed: () {
                  final challengeProvider = context.read<ChallengeProvider>();
                  challengeProvider.prepareChallengeForApp(packageName);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => CodingChallengeScreen(
                        targetPackageName: packageName,
                        targetAppName: app.appName,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Emergency Override & Close Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => EmergencyOverrideDialog(
                          appName: app.appName,
                          packageName: packageName,
                        ),
                      );
                    },
                    child: const Text(
                      'Emergency Override',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      usageProvider.clearCurrentlyRestrictedApp();
                      Navigator.maybePop(context);
                    },
                    child: const Text(
                      'Return to Dashboard',
                      style: TextStyle(color: AppColors.secondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
