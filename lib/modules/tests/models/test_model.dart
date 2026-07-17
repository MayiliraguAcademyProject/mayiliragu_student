import 'question_model.dart';

class TestSectionModel {
  final String id;
  final String name;
  final int order;
  final int duration;
  final double cutoffMarks;
  final double totalMarks;
  final int questionCount;
  final List<QuestionModel>? questions;

  TestSectionModel({
    required this.id,
    required this.name,
    required this.order,
    required this.duration,
    required this.cutoffMarks,
    required this.totalMarks,
    this.questionCount = 0,
    this.questions,
  });

  factory TestSectionModel.fromJson(Map<String, dynamic> json, List<QuestionModel> allQuestions) {
    final String secId = json['id'] ?? '';
    final String secName = json['name'] ?? '';
    final sectionQuestions = allQuestions.where((q) => q.sectionId == secId || q.sectionId == secName).toList();
    return TestSectionModel(
      id: secId,
      name: secName,
      order: json['order'] ?? 0,
      duration: json['duration'] ?? 0,
      cutoffMarks: (json['cutoff_marks'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (json['total_marks'] as num?)?.toDouble() ?? 0.0,
      questionCount: sectionQuestions.isNotEmpty ? sectionQuestions.length : (json['question_count'] ?? 0),
      questions: sectionQuestions,
    );
  }
}

class TestModel {
  final String id;
  final String title;
  final String? description;
  final int duration; // in minutes
  final double cutoffMarks;
  final double totalMarks;
  final String? courseId;
  final String? moduleId;
  final String? categoryId;
  final String? subjectId;
  final String? topicId;
  final bool isPublished;
  final int questionCount;
  final int attemptsCount;
  final bool hasAttempted;
  final Map<String, dynamic>? latestAttempt;
  final bool isSectioned;
  final List<TestSectionModel>? sections;
  final List<QuestionModel>? questions;

  TestModel({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
    required this.cutoffMarks,
    required this.totalMarks,
    this.courseId,
    this.moduleId,
    this.categoryId,
    this.subjectId,
    this.topicId,
    required this.isPublished,
    required this.questionCount,
    this.attemptsCount = 0,
    this.hasAttempted = false,
    this.latestAttempt,
    this.isSectioned = false,
    this.sections,
    this.questions,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? qList = json['questions'];
    final List<QuestionModel> parsedQuestions = qList != null
        ? qList.map((q) => QuestionModel.fromJson(q)).toList()
        : [];

    final List<dynamic>? secList = json['sections'];
    final List<TestSectionModel>? parsedSections = secList?.map((s) => TestSectionModel.fromJson(s, parsedQuestions)).toList();

    return TestModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      cutoffMarks: (json['cutoff_marks'] as num).toDouble(),
      totalMarks: (json['total_marks'] as num).toDouble(),
      courseId: json['course_id'],
      moduleId: json['module_id'],
      categoryId: json['category_id'],
      subjectId: json['subject_id'],
      topicId: json['topic_id'],
      isPublished: json['is_published'] ?? false,
      questionCount: json['question_count'] ?? 0,
      attemptsCount: json['attempts_count'] ?? 0,
      hasAttempted: json['has_attempted'] ?? false,
      latestAttempt: json['latest_attempt'],
      isSectioned: json['is_sectioned'] ?? false,
      sections: parsedSections,
      questions: parsedQuestions,
    );
  }
}
