enum QuestionType { singleChoice, multiChoice, trueFalse, fillInBlank, descriptive }

class QuestionOption {
  final String id;
  final String label;
  final String textEn;
  final String textTa;
  final bool isCorrect;

  QuestionOption({
    required this.id,
    required this.label,
    required this.textEn,
    required this.textTa,
    required this.isCorrect,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      textEn: json['text_en'] ?? '',
      textTa: json['text_ta'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }
}

class AcceptedAnswer {
  final String value;
  final bool caseSensitive;

  AcceptedAnswer({required this.value, required this.caseSensitive});

  factory AcceptedAnswer.fromJson(Map<String, dynamic> json) {
    return AcceptedAnswer(
      value: json['value'] ?? '',
      caseSensitive: json['case_sensitive'] ?? false,
    );
  }
}

class QuestionModel {
  final String id;
  final QuestionType type;
  final String questionTextEn;
  final String? questionTextTa;
  final String subjectId;
  final String topicId;
  final String difficulty;
  final String? explanationEn;
  final String? explanationTa;
  final double marksCorrect;
  final double marksWrong;
  final List<QuestionOption>? options;
  final bool? correctAnswer; // For True/False
  final List<AcceptedAnswer>? acceptedAnswers; // For Fill in Blank
  final String? hint;
  final String? modelAnswer;
  final int? wordLimit;
  final String? sectionId;

  QuestionModel({
    required this.id,
    required this.type,
    required this.questionTextEn,
    this.questionTextTa,
    required this.subjectId,
    required this.topicId,
    required this.difficulty,
    this.explanationEn,
    this.explanationTa,
    required this.marksCorrect,
    required this.marksWrong,
    this.options,
    this.correctAnswer,
    this.acceptedAnswers,
    this.hint,
    this.modelAnswer,
    this.wordLimit,
    this.sectionId,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    QuestionType type;
    switch (json['type']) {
      case 'single_choice':
        type = QuestionType.singleChoice;
        break;
      case 'multi_choice':
        type = QuestionType.multiChoice;
        break;
      case 'true_false':
        type = QuestionType.trueFalse;
        break;
      case 'descriptive':
        type = QuestionType.descriptive;
        break;
      case 'fill_in_blank':
      default:
        type = QuestionType.fillInBlank;
        break;
    }

    final marks = json['marks'] ?? {};
    final List<dynamic>? optList = json['options'];
    final List<dynamic>? ansList = json['accepted_answers'];

    return QuestionModel(
      id: json['id'] ?? '',
      type: type,
      questionTextEn: json['question_text_en'] ?? '',
      questionTextTa: json['question_text_ta'],
      subjectId: json['subject_id'] ?? '',
      topicId: json['topic_id'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      explanationEn: json['explanation_en'],
      explanationTa: json['explanation_ta'],
      marksCorrect: (marks['correct'] as num?)?.toDouble() ?? 1.0,
      marksWrong: (marks['wrong'] as num?)?.toDouble() ?? 0.0,
      options: optList?.map((o) => QuestionOption.fromJson(o)).toList(),
      correctAnswer: json['correct_answer'],
      acceptedAnswers: ansList?.map((a) => AcceptedAnswer.fromJson(a)).toList(),
      hint: json['hint'],
      modelAnswer: json['model_answer'],
      wordLimit: json['word_limit'] != null ? (json['word_limit'] as num).toInt() : null,
      sectionId: json['section_id'],
    );
  }
}
