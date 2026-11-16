import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/submission_model.dart';
import '../../widgets/glassmorphic_card.dart';

class TestResultsSheet extends StatefulWidget {
  final SubmissionResult result;
  final VoidCallback? onContinue;

  const TestResultsSheet({
    super.key,
    required this.result,
    this.onContinue,
  });

  @override
  State<TestResultsSheet> createState() => _TestResultsSheetState();
}

class _TestResultsSheetState extends State<TestResultsSheet> {
  int _selectedCaseIndex = 0;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final isAccepted = result.isAccepted;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.surfaceBorder, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAccepted
                      ? AppColors.success.withAlpha(35)
                      : AppColors.error.withAlpha(35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAccepted ? AppColors.success : AppColors.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAccepted ? Icons.check_circle : Icons.error,
                      size: 16,
                      color: isAccepted ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      result.status.displayName,
                      style: TextStyle(
                        color: isAccepted ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${result.testsPassed} / ${result.totalTests} Passed',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${result.executionTimeMs} ms',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Error message callout if any
          if (result.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withAlpha(80)),
              ),
              child: Text(
                result.errorMessage!,
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Test Case selector tabs
          if (result.testResults.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(result.testResults.length, (index) {
                  final tc = result.testResults[index];
                  final isSelected = _selectedCaseIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(
                        tc.passed ? Icons.check : Icons.close,
                        size: 14,
                        color: tc.passed ? AppColors.success : AppColors.error,
                      ),
                      label: Text('Case ${index + 1}'),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withAlpha(60),
                      backgroundColor: AppColors.surfaceElevated,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCaseIndex = index);
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            // Selected test case details
            if (_selectedCaseIndex < result.testResults.length) ...[
              _buildCaseDetail(result.testResults[_selectedCaseIndex]),
            ],
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCaseDetail(TestExecutionResult tc) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Input:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            tc.input,
            style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppColors.textCode),
          ),
          const SizedBox(height: 10),
          const Text('Expected Output:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            tc.expectedOutput,
            style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppColors.success),
          ),
          const SizedBox(height: 10),
          const Text('Actual Output:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            tc.actualOutput,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: tc.passed ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

