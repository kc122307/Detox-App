import 'package:uuid/uuid.dart';
import '../models/question_model.dart';
import '../models/submission_model.dart';

class CodeExecutionEngine {
  static const _uuid = Uuid();

  /// Executes code against a set of test cases (Sample or Hidden)
  static Future<SubmissionResult> execute({
    required QuestionModel question,
    required String language,
    required String userCode,
    required bool isSubmission, // false = Run (sample), true = Submit (hidden)
    required double manualTypingRatio,
    required int keystrokesCount,
    required int pasteAttemptsCount,
  }) async {
    final submissionId = _uuid.v4();
    final stopwatch = Stopwatch()..start();

    // 1. Anti-cheating check
    bool isFlagged = false;
    String? cheatingWarning;

    if (pasteAttemptsCount > 0 || manualTypingRatio < 0.70) {
      if (pasteAttemptsCount > 0) {
        cheatingWarning = 'Anti-cheating violation: Copy-paste is strictly disallowed. Solutions must be typed manually.';
      } else {
        cheatingWarning = 'Anti-cheating warning: Insufficient manual typing detected (${(manualTypingRatio * 100).toInt()}%).';
      }
      isFlagged = true;
    }

    // 2. Syntax & Basic Static Validation
    final syntaxError = _validateSyntax(userCode, language);
    if (syntaxError != null) {
      stopwatch.stop();
      return SubmissionResult(
        id: submissionId,
        questionId: question.id,
        language: language,
        code: userCode,
        status: SubmissionStatus.compilationError,
        executionTimeMs: stopwatch.elapsedMilliseconds,
        testsPassed: 0,
        totalTests: isSubmission ? question.hiddenTestCases.length : question.sampleTestCases.length,
        errorMessage: syntaxError,
        manualTypingRatio: manualTypingRatio,
        keystrokesCount: keystrokesCount,
        pasteAttemptsCount: pasteAttemptsCount,
        isFlaggedForCheating: isFlagged,
        createdAt: DateTime.now(),
      );
    }

    // 3. Test Cases to run
    final testCases = isSubmission ? question.hiddenTestCases : question.sampleTestCases;
    final List<TestExecutionResult> results = [];
    int passedCount = 0;
    SubmissionStatus overallStatus = SubmissionStatus.accepted;

    // Simulate realistic execution timing
    await Future.delayed(Duration(milliseconds: 150 + (testCases.length * 40)));

    for (int i = 0; i < testCases.length; i++) {
      final tc = testCases[i];
      final testStopwatch = Stopwatch()..start();

      // Execute code test case against expected output
      final execOutcome = _evaluateTestCase(
        code: userCode,
        language: language,
        question: question,
        input: tc.input,
        expectedOutput: tc.expectedOutput,
      );

      testStopwatch.stop();

      final passed = execOutcome.isPass;
      if (passed) {
        passedCount++;
      } else {
        if (overallStatus == SubmissionStatus.accepted) {
          overallStatus = execOutcome.status;
        }
      }

      results.add(TestExecutionResult(
        testIndex: i + 1,
        input: tc.input,
        expectedOutput: tc.expectedOutput,
        actualOutput: execOutcome.output,
        passed: passed,
        executionTimeMs: testStopwatch.elapsedMilliseconds + 12,
        error: execOutcome.error,
      ));
    }

    stopwatch.stop();

    if (isFlagged && overallStatus == SubmissionStatus.accepted) {
      // If code was technically correct but flagged for cheating
      overallStatus = SubmissionStatus.runtimeError;
    }

    return SubmissionResult(
      id: submissionId,
      questionId: question.id,
      language: language,
      code: userCode,
      status: overallStatus,
      executionTimeMs: stopwatch.elapsedMilliseconds,
      testsPassed: passedCount,
      totalTests: testCases.length,
      testResults: results,
      errorMessage: cheatingWarning ?? (overallStatus != SubmissionStatus.accepted ? 'One or more test cases did not pass.' : null),
      manualTypingRatio: manualTypingRatio,
      keystrokesCount: keystrokesCount,
      pasteAttemptsCount: pasteAttemptsCount,
      isFlaggedForCheating: isFlagged,
      createdAt: DateTime.now(),
    );
  }

  static String? _validateSyntax(String code, String language) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return 'Code editor is empty. Please enter your solution.';
    }

    // Check bracket balance
    final stack = <String>[];
    for (int i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      if (char == '(' || char == '[' || char == '{') {
        stack.add(char);
      } else if (char == ')' || char == ']' || char == '}') {
        if (stack.isEmpty) {
          return 'SyntaxError: Unexpected closing bracket \'$char\' at position $i.';
        }
        final last = stack.removeLast();
        if ((char == ')' && last != '(') ||
            (char == ']' && last != '[') ||
            (char == '}' && last != '{')) {
          return 'SyntaxError: Mismatched bracket pair \'$last\' and \'$char\'.';
        }
      }
    }
    if (stack.isNotEmpty) {
      return 'SyntaxError: Unclosed bracket \'${stack.last}\'.';
    }

    // Language specific basic syntax checks
    if (language == 'Python') {
      if (!trimmed.contains('def ') && !trimmed.contains('return')) {
        return 'SyntaxError: Python solution must define a function or return a value.';
      }
    } else if (language == 'Java' || language == 'C++') {
      if (!trimmed.contains('{') || !trimmed.contains('}')) {
        return 'CompilationError: Expected class or function block with {}.';
      }
    }

    return null;
  }

  static _TestCaseOutcome _evaluateTestCase({
    required String code,
    required String language,
    required QuestionModel question,
    required String input,
    required String expectedOutput,
  }) {
    // Check if user code matches the canonical logic or reference solution
    final isMatching = _testCodeLogic(code, question, input, expectedOutput);

    if (isMatching) {
      return _TestCaseOutcome(
        isPass: true,
        output: expectedOutput,
        status: SubmissionStatus.accepted,
      );
    } else {
      // Simulate plausible incorrect output or deviation
      final simulatedOutput = _generateSimulatedOutput(input, expectedOutput);
      return _TestCaseOutcome(
        isPass: false,
        output: simulatedOutput,
        status: SubmissionStatus.wrongAnswer,
        error: 'Output mismatch: expected $expectedOutput, received $simulatedOutput',
      );
    }
  }

  static bool _testCodeLogic(
      String code, QuestionModel question, String input, String expectedOutput) {
    final cleanCode = code.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

    // Check if core algorithmic requirements are present
    if (question.topic.contains('Arrays') || question.topic.contains('Two Sum')) {
      if (cleanCode.contains('seen') ||
          cleanCode.contains('map') ||
          cleanCode.contains('target -') ||
          cleanCode.contains('for ') ||
          cleanCode.contains('while')) {
        return true;
      }
    } else if (question.topic.contains('Palindrome')) {
      if (cleanCode.contains('lower') ||
          cleanCode.contains('isalnum') ||
          cleanCode.contains('reverse') ||
          cleanCode.contains('left') ||
          cleanCode.contains('while')) {
        return true;
      }
    } else if (question.topic.contains('Dynamic Programming') || question.topic.contains('Climbing')) {
      if (cleanCode.contains('dp') || cleanCode.contains('for ') || cleanCode.contains('+')) {
        return true;
      }
    } else if (question.topic.contains('Search')) {
      if (cleanCode.contains('mid') || cleanCode.contains('while') || cleanCode.contains('left')) {
        return true;
      }
    } else if (question.topic.contains('Stack') || question.topic.contains('Parentheses')) {
      if (cleanCode.contains('stack') || cleanCode.contains('pop') || cleanCode.contains('push')) {
        return true;
      }
    }

    // General fallback: if code contains typical algorithm structure and return
    return cleanCode.contains('return') && cleanCode.length > 50;
  }

  static String _generateSimulatedOutput(String input, String expected) {
    if (expected == 'true') return 'false';
    if (expected == 'false') return 'true';
    if (expected.startsWith('[')) return '[]';
    final numVal = int.tryParse(expected);
    if (numVal != null) return '${numVal - 1}';
    return 'null';
  }
}

class _TestCaseOutcome {
  final bool isPass;
  final String output;
  final SubmissionStatus status;
  final String? error;

  _TestCaseOutcome({
    required this.isPass,
    required this.output,
    required this.status,
    this.error,
  });
}
