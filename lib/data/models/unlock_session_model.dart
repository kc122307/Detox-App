class UnlockSessionModel {
  final String id;
  final String userId;
  final String packageName;
  final int unlockSequence; // 1 = first exhaustion, 2 = second exhaustion, etc.
  final int requiredQuestionCount; // 1 for first, 2 for subsequent
  final List<String> assignedQuestionIds;
  final List<String> solvedQuestionIds;
  final String status; // 'in_progress', 'completed', 'abandoned'
  final DateTime createdAt;
  final DateTime? completedAt;

  UnlockSessionModel({
    required this.id,
    required this.userId,
    required this.packageName,
    required this.unlockSequence,
    required this.requiredQuestionCount,
    required this.assignedQuestionIds,
    required this.solvedQuestionIds,
    this.status = 'in_progress',
    required this.createdAt,
    this.completedAt,
  });

  bool get isReadyForReward => solvedQuestionIds.length >= requiredQuestionCount;

  UnlockSessionModel copyWith({
    String? id,
    String? userId,
    String? packageName,
    int? unlockSequence,
    int? requiredQuestionCount,
    List<String>? assignedQuestionIds,
    List<String>? solvedQuestionIds,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return UnlockSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      packageName: packageName ?? this.packageName,
      unlockSequence: unlockSequence ?? this.unlockSequence,
      requiredQuestionCount: requiredQuestionCount ?? this.requiredQuestionCount,
      assignedQuestionIds: assignedQuestionIds ?? this.assignedQuestionIds,
      solvedQuestionIds: solvedQuestionIds ?? this.solvedQuestionIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_name': packageName,
      'unlock_sequence': unlockSequence,
      'required_question_count': requiredQuestionCount,
      'assigned_question_ids': assignedQuestionIds,
      'solved_question_ids': solvedQuestionIds,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory UnlockSessionModel.fromJson(Map<String, dynamic> json) {
    return UnlockSessionModel(
      id: json['id'] as String,
      userId: (json['user_id'] ?? '') as String,
      packageName: json['package_name'] as String,
      unlockSequence: (json['unlock_sequence'] as num?)?.toInt() ?? 1,
      requiredQuestionCount: (json['required_question_count'] as num?)?.toInt() ?? 1,
      assignedQuestionIds: (json['assigned_question_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      solvedQuestionIds: (json['solved_question_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] as String? ?? 'in_progress',
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }
}
