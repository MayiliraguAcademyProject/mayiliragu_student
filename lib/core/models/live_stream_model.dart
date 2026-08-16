class LiveStreamModel {
  final String id;
  final String title;
  final String? description;
  final String youtubeUrl;
  final DateTime scheduledStartTime;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  LiveStreamModel({
    required this.id,
    required this.title,
    this.description,
    required this.youtubeUrl,
    required this.scheduledStartTime,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      youtubeUrl: json['youtubeUrl'] as String,
      scheduledStartTime: DateTime.parse(json['scheduledStartTime'] as String),
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'youtubeUrl': youtubeUrl,
      'scheduledStartTime': scheduledStartTime.toIso8601String(),
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
