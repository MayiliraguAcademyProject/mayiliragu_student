class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? iconName;
  final List<SubjectModel> subjects;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.iconName,
    required this.subjects,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconName: json['iconName']?.toString(),
      subjects: (json['subjects'] as List? ?? [])
          .map((s) => SubjectModel.fromJson(s))
          .toList(),
    );
  }
}

class SubjectModel {
  final String id;
  final String name;
  final String categoryId;
  final List<TopicModel> topics;

  SubjectModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.topics,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      topics: (json['topics'] as List? ?? [])
          .map((t) => TopicModel.fromJson(t))
          .toList(),
    );
  }
}

class TopicModel {
  final String id;
  final String name;
  final String subjectId;

  TopicModel({
    required this.id,
    required this.name,
    required this.subjectId,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subjectId: json['subjectId']?.toString() ?? '',
    );
  }
}
