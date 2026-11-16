enum SubmissionStatus {
  accepted,
  wrongAnswer,
  timeLimitExceeded,
  compilationError,
  runtimeError,
  idle,
  evaluating,
}

extension SubmissionStatusExtension on SubmissionStatus {
  String get displayName {
    switch (this) {
      case SubmissionStatus.accepted:
        return 'Accepted';
      case SubmissionStatus.wrongAnswer:
        return 'Wrong Answer';
      case SubmissionStatus.timeLimitExceeded:
        return 'Time Limit Exceeded';
      case SubmissionStatus.compilationError:
        return 'Compilation Error';
      case SubmissionStatus.runtimeError:
        return 'Runtime Error';
      case SubmissionStatus.evaluating:
        return 'Evaluating...';
      case SubmissionStatus.idle:
        return 'Ready';
    }
  }

  bool get isSuccess => this == SubmissionStatus.accepted;
}

class TestExecutionResult {
  final int testIndex;
  final String input;
  final String expectedOutput;
  final String actualOutput;
  final bool passed;
  final int executionTimeMs;
  final String? error;

  TestExecutionResult({
    required this.testIndex,
    required this.input,
    required this.expectedOutput,
    required this.actualOutput,
    required this.passed,
    required this.executionTimeMs,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'test_index': testIndex,
        'input': input,
        'expected_output': expectedOutput,
        'actual_output': actualOutput,
        'passed': passed,
        'execution_time_ms': executionTimeMs,
        'error': error,
      };

  factory TestExecutionResult.fromJson(Map<String, dynamic> json) => TestExecutionResult(
        testIndex: (json['test_index'] as num?)?.toInt() ?? 0,
        input: json['input'] as String? ?? '',
        expectedOutput: json['expected_output'] as String? ?? '',
        actualOutput: json['actual_output'] as String? ?? '',
        passed: json['passed'] as bool? ?? false,
        executionTimeMs: (json['execution_time_ms'] as num?)?.toInt() ?? 0,
        error: json['error'] as String?,
      );
}

class SubmissionResult {
  final String id;
  final String questionId;
  final String language;
  final String code;
  final SubmissionStatus status;
  final int executionTimeMs;
  final int testsPassed;
  final int totalTests;
  final List<TestExecutionResult> testResults;
  final String? errorMessage;
  final double manualTypingRatio;
  final int keystrokesCount;
  final int pasteAttemptsCount;
  final bool isFlaggedForCheating;
  final DateTime createdAt;

  SubmissionResult({
    required this.id,
    required this.questionId,
    required this.language,
    required this.code,
    required this.status,
    required this.executionTimeMs,
    required this.testsPassed,
    required this.totalTests,
    this.testResults = const [],
    this.errorMessage,
    this.manualTypingRatio = 1.0,
    this.keystrokesCount = 0,
    this.pasteAttemptsCount = 0,
    this.isFlaggedForCheating = false,
    required this.createdAt,
  });

  bool get isAccepted => status == SubmissionStatus.accepted && !isFlaggedForCheating;

  Map<String, dynamic> toJson() => {
        'id': id,
        'question_id': questionId,
        'language': language,
        'code': code,
        'status': status.name,
        'execution_time_ms': executionTimeMs,
        'tests_passed': testsPassed,
        'total_tests': totalTests,
        'test_results': testResults.map((e) => e.toJson()).toList(),
        'error_message': errorMessage,
        'manual_typing_ratio': manualTypingRatio,
        'keystrokes_count': keystrokesCount,
        'paste_attempts_count': pasteAttemptsCount,
        'is_flagged_for_cheating': isFlaggedForCheating,
        'created_at': createdAt.toIso8601String(),
      };
}

