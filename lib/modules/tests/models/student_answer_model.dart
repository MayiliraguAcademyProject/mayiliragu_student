class StudentAnswer {
  final String questionId;
  List<String>? selectedOptionIds; // For single/multi choice
  bool? booleanAnswer;             // For true/false
  String? textAnswer;              // For fill in blank
  String? descriptiveText;          // For essay/descriptive
  String? attachmentUrl;            // For handwritten scan/photo
  bool isFlagged;                  // Flagged for review
  bool isVisited;                  // Visited state

  StudentAnswer({
    required this.questionId,
    this.selectedOptionIds,
    this.booleanAnswer,
    this.textAnswer,
    this.descriptiveText,
    this.attachmentUrl,
    this.isFlagged = false,
    this.isVisited = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_option_ids': selectedOptionIds,
      'boolean_answer': booleanAnswer,
      'text_answer': textAnswer,
      'descriptive_text': descriptiveText,
      'attachment_url': attachmentUrl,
      'is_flagged': isFlagged,
    };
  }

  factory StudentAnswer.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? optIds = json['selected_option_ids'];
    return StudentAnswer(
      questionId: json['question_id'] ?? '',
      selectedOptionIds: optIds?.cast<String>(),
      booleanAnswer: json['boolean_answer'],
      textAnswer: json['text_answer'],
      descriptiveText: json['descriptive_text'],
      attachmentUrl: json['attachment_url'],
      isFlagged: json['is_flagged'] ?? false,
      isVisited: json['is_visited'] ?? true,
    );
  }

  // Helper to check if any answer is filled
  bool get hasAnswer {
    if (selectedOptionIds != null && selectedOptionIds!.isNotEmpty) return true;
    if (booleanAnswer != null) return true;
    if (textAnswer != null && textAnswer!.trim().isNotEmpty) return true;
    if (descriptiveText != null && descriptiveText!.trim().isNotEmpty) return true;
    if (attachmentUrl != null && attachmentUrl!.trim().isNotEmpty) return true;
    return false;
  }
}
