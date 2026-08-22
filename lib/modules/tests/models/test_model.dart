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
  final String? testMode;
  final String? courseId;
  final String? moduleId;
  final String? categoryId;
  final String? subjectId;
  final String? topicId;
  final String? difficulty;
  final bool isPublished;
  final int questionCount;
  final int attemptsCount;
  final bool hasAttempted;
  final Map<String, dynamic>? latestAttempt;
  final bool isSectioned;
  final int sectionsCount;
  final List<String> sectionNames;
  final bool isPaid;
  final bool isAllowed;
  final bool isLocked;
  final DateTime? scheduledAt;
  final List<TestSectionModel>? sections;
  final List<QuestionModel>? questions;

  TestModel({
    required this.id,
    required this.title,
    this.description,
    required this.duration,
    required this.cutoffMarks,
    required this.totalMarks,
    this.testMode,
    this.courseId,
    this.moduleId,
    this.categoryId,
    this.subjectId,
    this.topicId,
    this.difficulty,
    required this.isPublished,
    required this.questionCount,
    this.attemptsCount = 0,
    this.hasAttempted = false,
    this.latestAttempt,
    this.isSectioned = false,
    this.sectionsCount = 0,
    this.sectionNames = const [],
    this.isPaid = false,
    this.isAllowed = true,
    this.isLocked = false,
    this.scheduledAt,
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

    final bool parsedAllowed = json['is_allowed'] ?? json['can_access'] ?? (json['is_locked'] != null ? !json['is_locked'] : true);
    final bool parsedLocked = json['is_locked'] ?? !parsedAllowed;

    final List<String> parsedSectionNames = (json['section_names'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (parsedSections?.map((s) => s.name).toList() ?? []);

    final int parsedSectionsCount = json['sections_count'] ?? (parsedSections?.length ?? (json['sections'] as List<dynamic>?)?.length ?? 0);

    return TestModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'] ?? 0,
      cutoffMarks: (json['cutoff_marks'] as num?)?.toDouble() ?? 0.0,
      totalMarks: (json['total_marks'] as num?)?.toDouble() ?? 0.0,
      testMode: json['test_mode'] ?? json['testMode'],
      courseId: json['course_id'],
      moduleId: json['module_id'],
      categoryId: json['category_id'],
      subjectId: json['subject_id'],
      topicId: json['topic_id'],
      difficulty: json['difficulty'],
      isPublished: json['is_published'] ?? false,
      questionCount: json['question_count'] ?? parsedQuestions.length,
      attemptsCount: json['attempts_count'] ?? 0,
      hasAttempted: json['has_attempted'] ?? false,
      latestAttempt: json['latest_attempt'],
      isSectioned: json['is_sectioned'] ?? false,
      sectionsCount: parsedSectionsCount,
      sectionNames: parsedSectionNames,
      isPaid: json['is_paid'] ?? false,
      isAllowed: parsedAllowed,
      isLocked: parsedLocked,
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at'].toString()) : null,
      sections: parsedSections,
      questions: parsedQuestions,
    );
  }
}
