class ExamUpdateModel {
  final String id;
  final String title;
  final String? description;
  final String pdfUrl;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExamUpdateModel({
    required this.id,
    required this.title,
    this.description,
    required this.pdfUrl,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamUpdateModel.fromJson(Map<String, dynamic> json) {
    return ExamUpdateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      pdfUrl: json['pdfUrl'] as String,
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
      'pdfUrl': pdfUrl,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
