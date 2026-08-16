class TestimonialModel {
  final String id;
  final String studentName;
  final String? avatarUrl;
  final String? designation;
  final String videoUrl;
  final String? description;
  final int order;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  TestimonialModel({
    required this.id,
    required this.studentName,
    this.avatarUrl,
    this.designation,
    required this.videoUrl,
    this.description,
    required this.order,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    return TestimonialModel(
      id: json['id'] as String,
      studentName: json['studentName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      designation: json['designation'] as String?,
      videoUrl: json['videoUrl'] as String,
      description: json['description'] as String?,
      order: json['order'] as int? ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'avatarUrl': avatarUrl,
      'designation': designation,
      'videoUrl': videoUrl,
      'description': description,
      'order': order,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
