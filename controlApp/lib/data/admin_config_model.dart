class AdminConfigModel {
  final bool isEnabled;
  final String devUrl;
  final String tiktokUrl;

  const AdminConfigModel({
    required this.isEnabled,
    required this.devUrl,
    required this.tiktokUrl,
  });

  factory AdminConfigModel.initial() {
    return const AdminConfigModel(
      isEnabled: false,
      devUrl: 'https://',
      tiktokUrl: 'https://',
    );
  }

  factory AdminConfigModel.fromMap(Map<dynamic, dynamic> map) {
    return AdminConfigModel(
      isEnabled: map['is_enabled'] as bool? ?? false,
      devUrl: map['dev_url'] as String? ?? 'https://',
      tiktokUrl: map['tiktok_url'] as String? ?? 'https://',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_enabled': isEnabled,
      'dev_url': devUrl,
      'tiktok_url': tiktokUrl,
    };
  }

  AdminConfigModel copyWith({
    bool? isEnabled,
    String? devUrl,
    String? tiktokUrl,
  }) {
    return AdminConfigModel(
      isEnabled: isEnabled ?? this.isEnabled,
      devUrl: devUrl ?? this.devUrl,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
    );
  }
}
