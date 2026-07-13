class SubjectPerformanceModel {
  final String subject;
  final int percentage;

  SubjectPerformanceModel({
    required this.subject,
    required this.percentage,
  });

  factory SubjectPerformanceModel.fromJson(Map<String, dynamic> json) {
    return SubjectPerformanceModel(
      subject: json['subject'] ?? 'General Studies',
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class SectionBreakdownModel {
  final String sectionId;
  final String name;
  final int scoreRaw;
  final int totalMarks;
  final int cutoffMarks;
  final bool cutoffMet;
  final int correct;
  final int wrong;
  final int skipped;
  final int accuracy;
  final List<SubjectPerformanceModel> subjectPerformance;

  SectionBreakdownModel({
    required this.sectionId,
    required this.name,
    required this.scoreRaw,
    required this.totalMarks,
    required this.cutoffMarks,
    required this.cutoffMet,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.accuracy,
    required this.subjectPerformance,
  });

  factory SectionBreakdownModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? subjPerf = json['subject_performance'];
    return SectionBreakdownModel(
      sectionId: json['section_id'] ?? '',
      name: json['name'] ?? '',
      scoreRaw: (json['score_raw'] as num?)?.toInt() ?? 0,
      totalMarks: (json['total_marks'] as num?)?.toInt() ?? 0,
      cutoffMarks: (json['cutoff_marks'] as num?)?.toInt() ?? 0,
      cutoffMet: json['cutoff_met'] ?? false,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      wrong: (json['wrong'] as num?)?.toInt() ?? 0,
      skipped: (json['skipped'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toInt() ?? 0,
      subjectPerformance: subjPerf != null
          ? subjPerf.map((e) => SubjectPerformanceModel.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
    );
  }
}

class TestAttemptResultModel {
  final String testId;
  final String attemptId;
  final String testTitle;
  final int score;
  final int scoreRaw;
  final int totalMarks;
  final int correct;
  final int wrong;
  final int skipped;
  final int accuracy;
  final int timeTaken;
  final bool passed;
  final int rank;
  final int classAvg;
  final int topScore;
  final List<SubjectPerformanceModel> subjectPerformance;
  final List<SectionBreakdownModel> sections;

  TestAttemptResultModel({
    required this.testId,
    required this.attemptId,
    required this.testTitle,
    required this.score,
    required this.scoreRaw,
    required this.totalMarks,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.accuracy,
    required this.timeTaken,
    required this.passed,
    required this.rank,
    required this.classAvg,
    required this.topScore,
    required this.subjectPerformance,
    required this.sections,
  });

  factory TestAttemptResultModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? subjPerf = json['subject_performance'];
    final List<dynamic>? secList = json['sections'];

    return TestAttemptResultModel(
      testId: json['test_id'] ?? '',
      attemptId: json['id'] ?? json['attempt_id'] ?? '',
      testTitle: json['test_title'] ?? 'Practice Test',
      score: (json['score'] as num?)?.toInt() ?? 0,
      scoreRaw: (json['score_raw'] as num?)?.toInt() ?? 0,
      totalMarks: (json['total_marks'] as num?)?.toInt() ?? 0,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      wrong: (json['wrong'] as num?)?.toInt() ?? 0,
      skipped: (json['skipped'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toInt() ?? 0,
      timeTaken: (json['time_taken'] as num?)?.toInt() ?? 0,
      passed: json['passed'] ?? false,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      classAvg: (json['class_avg'] as num?)?.toInt() ?? 0,
      topScore: (json['top_score'] as num?)?.toInt() ?? 0,
      subjectPerformance: subjPerf != null
          ? subjPerf.map((e) => SubjectPerformanceModel.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
      sections: secList != null
          ? secList.map((e) => SectionBreakdownModel.fromJson(Map<String, dynamic>.from(e))).toList()
          : [],
    );
  }
}
