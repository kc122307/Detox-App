class TestCase {
  final String input;
  final String expectedOutput;
  final bool isHidden;

  TestCase({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() => {
        'input': input,
        'expected_output': expectedOutput,
        'is_hidden': isHidden,
      };

  factory TestCase.fromJson(Map<String, dynamic> json) => TestCase(
        input: json['input'] as String,
        expectedOutput: json['expected_output'] as String,
        isHidden: json['is_hidden'] as bool? ?? false,
      );
}

class TestCaseExample {
  final String input;
  final String output;
  final String? explanation;

  TestCaseExample({
    required this.input,
    required this.output,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'input': input,
        'output': output,
        'explanation': explanation,
      };

  factory TestCaseExample.fromJson(Map<String, dynamic> json) => TestCaseExample(
        input: json['input'] as String,
        output: json['output'] as String,
        explanation: json['explanation'] as String?,
      );
}

class QuestionModel {
  final String id;
  final String canonicalProblemId;
  final String title;
  final String description;
  final int difficultyRating; // 1-10
  final String difficultyBand; // Beginner, Easy, Medium, Hard, Expert, Master
  final String topic;
  final String inputDescription;
  final String outputDescription;
  final List<String> constraints;
  final List<TestCaseExample> examples;
  final List<TestCase> sampleTestCases;
  final List<TestCase> hiddenTestCases;
  final Map<String, String> starterCode; // Language -> Starter code
  final Map<String, String> referenceSolutions; // Language -> Reference code
  final List<String> hints;
  final int timeLimitMs;
  final int memoryLimitMb;
  final String sourceMetadata;

  QuestionModel({
    required this.id,
    required this.canonicalProblemId,
    required this.title,
    required this.description,
    required this.difficultyRating,
    required this.difficultyBand,
    required this.topic,
    required this.inputDescription,
    required this.outputDescription,
    required this.constraints,
    required this.examples,
    required this.sampleTestCases,
    required this.hiddenTestCases,
    required this.starterCode,
    this.referenceSolutions = const {},
    this.hints = const [],
    this.timeLimitMs = 2000,
    this.memoryLimitMb = 128,
    this.sourceMetadata = 'Curated Interview Question',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'canonical_problem_id': canonicalProblemId,
        'title': title,
        'description': description,
        'difficulty_rating': difficultyRating,
        'difficulty_band': difficultyBand,
        'topic': topic,
        'input_description': inputDescription,
        'output_description': outputDescription,
        'constraints': constraints,
        'examples': examples.map((e) => e.toJson()).toList(),
        'sample_test_cases': sampleTestCases.map((e) => e.toJson()).toList(),
        'hidden_test_cases': hiddenTestCases.map((e) => e.toJson()).toList(),
        'starter_code': starterCode,
        'reference_solutions': referenceSolutions,
        'hints': hints,
        'time_limit_ms': timeLimitMs,
        'memory_limit_mb': memoryLimitMb,
        'source_metadata': sourceMetadata,
      };

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'] as String,
        canonicalProblemId: json['canonical_problem_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        difficultyRating: (json['difficulty_rating'] as num?)?.toInt() ?? 3,
        difficultyBand: json['difficulty_band'] as String? ?? 'Beginner',
        topic: json['topic'] as String? ?? 'Arrays',
        inputDescription: json['input_description'] as String? ?? '',
        outputDescription: json['output_description'] as String? ?? '',
        constraints: (json['constraints'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        examples: (json['examples'] as List<dynamic>?)
                ?.map((e) => TestCaseExample.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        sampleTestCases: (json['sample_test_cases'] as List<dynamic>?)
                ?.map((e) => TestCase.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        hiddenTestCases: (json['hidden_test_cases'] as List<dynamic>?)
                ?.map((e) => TestCase.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        starterCode: (json['starter_code'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v.toString()),
            ) ??
            {},
        referenceSolutions: (json['reference_solutions'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v.toString())) ??
            {},
        hints: (json['hints'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        timeLimitMs: (json['time_limit_ms'] as num?)?.toInt() ?? 2000,
        memoryLimitMb: (json['memory_limit_mb'] as num?)?.toInt() ?? 128,
        sourceMetadata: json['source_metadata'] as String? ?? 'Curated',
      );
}
