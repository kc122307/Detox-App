class DailyUsageRecord {
  final String id;
  final String userId;
  final String packageName;
  final String usageDate; // YYYY-MM-DD
  final int totalUsedSeconds;
  final DateTime updatedAt;

  DailyUsageRecord({
    required this.id,
    required this.userId,
    required this.packageName,
    required this.usageDate,
    required this.totalUsedSeconds,
    required this.updatedAt,
  });

  DailyUsageRecord copyWith({
    String? id,
    String? userId,
    String? packageName,
    String? usageDate,
    int? totalUsedSeconds,
    DateTime? updatedAt,
  }) {
    return DailyUsageRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      packageName: packageName ?? this.packageName,
      usageDate: usageDate ?? this.usageDate,
      totalUsedSeconds: totalUsedSeconds ?? this.totalUsedSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_name': packageName,
      'usage_date': usageDate,
      'total_used_seconds': totalUsedSeconds,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DailyUsageRecord.fromJson(Map<String, dynamic> json) {
    return DailyUsageRecord(
      id: json['id'] as String,
      userId: (json['user_id'] ?? '') as String,
      packageName: json['package_name'] as String,
      usageDate: json['usage_date'] as String,
      totalUsedSeconds: (json['total_used_seconds'] as num?)?.toInt() ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
