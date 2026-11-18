class RewardTransactionModel {
  final String id;
  final String userId;
  final String packageName;
  final String unlockSessionId;
  final List<String> challengeIds;
  final int durationSeconds; // 900 for 15 mins
  final DateTime grantedAt;
  final DateTime expiresAt;
  final String status; // 'active', 'expired', 'revoked'

  RewardTransactionModel({
    required this.id,
    required this.userId,
    required this.packageName,
    required this.unlockSessionId,
    required this.challengeIds,
    this.durationSeconds = 900,
    required this.grantedAt,
    required this.expiresAt,
    this.status = 'active',
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get remainingSeconds {
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_name': packageName,
      'unlock_session_id': unlockSessionId,
      'challenge_ids': challengeIds,
      'duration_seconds': durationSeconds,
      'granted_at': grantedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': isExpired ? 'expired' : status,
    };
  }

  factory RewardTransactionModel.fromJson(Map<String, dynamic> json) {
    return RewardTransactionModel(
      id: json['id'] as String,
      userId: (json['user_id'] ?? '') as String,
      packageName: json['package_name'] as String,
      unlockSessionId: (json['unlock_session_id'] ?? '') as String,
      challengeIds: (json['challenge_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 900,
      grantedAt: DateTime.parse(json['granted_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      status: json['status'] as String? ?? 'active',
    );
  }
}

