class ManagedAppModel {
  final String id;
  final String userId;
  final String packageName;
  final String appName;
  final int dailyLimitSeconds;
  final bool protectionEnabled;
  final String category;
  final String iconIdentifier;

  ManagedAppModel({
    required this.id,
    required this.userId,
    required this.packageName,
    required this.appName,
    required this.dailyLimitSeconds,
    this.protectionEnabled = true,
    this.category = 'Productivity',
    this.iconIdentifier = 'app',
  });

  int get dailyLimitMinutes => (dailyLimitSeconds / 60).round();

  ManagedAppModel copyWith({
    String? id,
    String? userId,
    String? packageName,
    String? appName,
    int? dailyLimitSeconds,
    bool? protectionEnabled,
    String? category,
    String? iconIdentifier,
  }) {
    return ManagedAppModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      dailyLimitSeconds: dailyLimitSeconds ?? this.dailyLimitSeconds,
      protectionEnabled: protectionEnabled ?? this.protectionEnabled,
      category: category ?? this.category,
      iconIdentifier: iconIdentifier ?? this.iconIdentifier,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_name': packageName,
      'app_name': appName,
      'daily_limit_seconds': dailyLimitSeconds,
      'protection_enabled': protectionEnabled,
      'category': category,
      'icon_identifier': iconIdentifier,
    };
  }

  factory ManagedAppModel.fromJson(Map<String, dynamic> json) {
    return ManagedAppModel(
      id: json['id'] as String,
      userId: (json['user_id'] ?? '') as String,
      packageName: json['package_name'] as String,
      appName: json['app_name'] as String,
      dailyLimitSeconds: (json['daily_limit_seconds'] as num?)?.toInt() ?? 3600,
      protectionEnabled: json['protection_enabled'] as bool? ?? true,
      category: json['category'] as String? ?? 'Social',
      iconIdentifier: json['icon_identifier'] as String? ?? 'app',
    );
  }
}

