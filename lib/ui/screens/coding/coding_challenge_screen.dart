import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/challenge_provider.dart';
import '../../../providers/usage_tracking_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/difficulty_badge.dart';
import '../../widgets/glassmorphic_card.dart';
import 'code_editor_widget.dart';
import 'manual_typing_indicator.dart';
import 'test_results_sheet.dart';

class CodingChallengeScreen extends StatefulWidget {
  final String targetPackageName;
  final String targetAppName;

  const CodingChallengeScreen({
    super.key,
    required this.targetPackageName,
    required this.targetAppName,
  });

  @override
  State<CodingChallengeScreen> createState() => _CodingChallengeScreenState();
}

class _CodingChallengeScreenState extends State<CodingChallengeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _fontSize = 13.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final question = challengeProvider.currentQuestion;

    if (question == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Loading Challenge...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final session = context.watch<UsageTrackingProvider>().getActiveUnlockSession(widget.targetPackageName);
    final int currentStep = session.solvedQuestionIds.length + 1;
    final int totalRequired = session.requiredQuestionCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlocking ${widget.targetAppName}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              'Step $currentStep of $totalRequired • 20m Reward',
              style: const TextStyle(fontSize: 11, color: AppColors.secondary),
            ),
          ],
        ),
        actions: [
          // Language selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: challengeProvider.selectedLanguage,
                dropdownColor: AppColors.surfaceElevated,
                items: AppConstants.supportedLanguages.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(
                      lang,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (newLang) {
                  if (newLang != null) {
                    challengeProvider.setLanguage(newLang);
                  }
                },
              ),
            ),
          ),
          // Font size toggle
          IconButton(
            icon: const Icon(Icons.text_fields, size: 20),
            onPressed: () {
              setState(() {
                _fontSize = _fontSize == 13.0 ? 15.0 : (_fontSize == 15.0 ? 12.0 : 13.0);
              });
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.description, size: 18), text: 'Problem'),
            Tab(icon: Icon(Icons.code, size: 18), text: 'Code Editor'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Manual typing indicator banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ManualTypingIndicator(
              manualTypingRatio: challengeProvider.manualTypingRatio,
              keystrokesCount: challengeProvider.keystrokesCount,
              pasteAttemptsCount: challengeProvider.pasteAttemptsCount,
              typingProgress: challengeProvider.typingProgress,
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProblemDescription(question),
                _buildCodeEditorTab(challengeProvider, question),
              ],
            ),
          ),

          // Bottom Action Bar (Run & Submit)
          _buildBottomActionBar(challengeProvider),
        ],
      ),
    );
  }

  Widget _buildProblemDescription(dynamic question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Difficulty
          Text(
            question.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              DifficultyBadge(
                rating: question.difficultyRating,
                band: question.difficultyBand,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  question.topic,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Statement
          Text(
            question.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          // Examples
          const Text(
            'Examples:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...question.examples.map((ex) {
            return GlassmorphicCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Input: ${ex.input}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppColors.textCode),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Output: ${ex.output}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppColors.secondary),
                  ),
                  if (ex.explanation != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Explanation: ${ex.explanation}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 14),

          // Constraints
          const Text(
            'Constraints:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...question.constraints.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.secondary)),
                    Expanded(
                      child: Text(
                        c,
                        style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),

          // Hints Accordion
          if (question.hints.isNotEmpty) ...[
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text(
                  'Need a Hint?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary),
                ),
                children: question.hints
                    .map<Widget>((h) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Text(
                            '💡 $h',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeEditorTab(ChallengeProvider challengeProvider, dynamic question) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CodeEditorWidget(
        initialCode: challengeProvider.currentCode,
        language: challengeProvider.selectedLanguage,
        fontSize: _fontSize,
        onCodeChanged: (newCode) {
          challengeProvider.onCodeChanged(newCode);
        },
        onPasteAttempted: () {
          challengeProvider.registerPasteAttempt();
        },
      ),
    );
  }

  Widget _buildBottomActionBar(ChallengeProvider challengeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          // Run Button (Sample tests)
          Expanded(
            child: OutlinedButton(
              onPressed: challengeProvider.isEvaluating
                  ? null
                  : () async {
                      await challengeProvider.runSampleTests();
                      if (mounted && challengeProvider.lastResult != null) {
                        _showTestResultsModal(context, challengeProvider.lastResult!);
                      }
                    },
              child: const Text('Run Tests'),
            ),
          ),
          const SizedBox(width: 12),
          // Submit Button (Hidden tests & unlocks reward)
          Expanded(
            flex: 2,
            child: CustomGradientButton(
              text: 'Submit Solution',
              isLoading: challengeProvider.isEvaluating,
              onPressed: challengeProvider.isEvaluating
                  ? null
                  : () async {
                      final accepted = await challengeProvider.submitSolution(widget.targetPackageName);
                      if (mounted) {
                        if (challengeProvider.lastResult != null) {
                          _showTestResultsModal(
                            context,
                            challengeProvider.lastResult!,
                            onAccepted: accepted ? () => _handleAccepted(challengeProvider) : null,
                          );
                        }
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  void _showTestResultsModal(
    BuildContext context,
    dynamic result, {
    VoidCallback? onAccepted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TestResultsSheet(
        result: result,
        onContinue: onAccepted,
      ),
    );
  }

  void _handleAccepted(ChallengeProvider challengeProvider) {
    if (challengeProvider.requiresSecondQuestion) {
      // Step 1 completed, need step 2
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: 8),
              Text('Challenge 1 Accepted!'),
            ],
          ),
          content: const Text(
            'Great work! As this is a subsequent unlock today, exactly one more challenge is required to grant your 20 minutes.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            CustomGradientButton(
              text: 'Proceed to Question 2',
              onPressed: () {
                Navigator.pop(ctx);
                _tabController.animateTo(0); // Switch to problem statement
              },
            ),
          ],
        ),
      );
    } else if (challengeProvider.recentlyEarnedReward != null) {
      // 20 minutes unlocked!
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('🎉 20 Minutes Earned!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_open, color: AppColors.success, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'You have successfully unlocked 20 additional minutes for ${widget.targetAppName}!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
              ),
              const SizedBox(height: 8),
              const Text(
                'Earned through authentic manual code solving.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          actions: [
            CustomGradientButton(
              text: 'Return to Dashboard',
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close challenge screen
              },
            ),
          ],
        ),
      );
    }
  }
}

