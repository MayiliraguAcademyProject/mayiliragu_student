class TestBatchPaperModel {
  final String id;
  final String categoryId;
  final String title;
  final String fileUrl;
  final String fileName;
  final int? fileSize;
  final int order;
  final bool isEnabled;

  TestBatchPaperModel({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.fileUrl,
    required this.fileName,
    this.fileSize,
    this.order = 0,
    this.isEnabled = true,
  });

  factory TestBatchPaperModel.fromJson(Map<String, dynamic> json) {
    return TestBatchPaperModel(
      id: json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? json['category_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? json['file_url'] as String? ?? '',
      fileName: json['fileName'] as String? ?? json['file_name'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? json['file_size'] as int?,
      order: json['order'] as int? ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? json['is_enabled'] as bool? ?? true,
    );
  }
}

class TestBatchCategoryModel {
  final String id;
  final String batchId;
  final String name;
  final String? syllabus;
  final int order;
  final bool isEnabled;
  final List<TestBatchPaperModel> questionPapers;

  TestBatchCategoryModel({
    required this.id,
    required this.batchId,
    required this.name,
    this.syllabus,
    this.order = 0,
    this.isEnabled = true,
    this.questionPapers = const [],
  });

  factory TestBatchCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawPapers = json['questionPapers'] as List? ?? json['question_papers'] as List? ?? [];
    return TestBatchCategoryModel(
      id: json['id'] as String? ?? '',
      batchId: json['batchId'] as String? ?? json['batch_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      syllabus: json['syllabus'] as String?,
      order: json['order'] as int? ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? json['is_enabled'] as bool? ?? true,
      questionPapers: rawPapers
          .map((p) => TestBatchPaperModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TestBatchModel {
  final String id;
  final String title;
  final String? description;
  final String targetCategory;
  final String? schedulePdfUrl;
  final String? schedulePdfName;
  final String? omrPdfUrl;
  final String? omrPdfName;
  final int order;
  final bool isEnabled;
  final int totalCategories;
  final int totalQuestionPapers;
  final List<TestBatchCategoryModel> categories;
  final DateTime? createdAt;

  TestBatchModel({
    required this.id,
    required this.title,
    this.description,
    this.targetCategory = 'TNPSC',
    this.schedulePdfUrl,
    this.schedulePdfName,
    this.omrPdfUrl,
    this.omrPdfName,
    this.order = 0,
    this.isEnabled = true,
    this.totalCategories = 0,
    this.totalQuestionPapers = 0,
    this.categories = const [],
    this.createdAt,
  });

  factory TestBatchModel.fromJson(Map<String, dynamic> json) {
    final rawCats = json['categories'] as List? ?? [];
    return TestBatchModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      targetCategory: json['targetCategory'] as String? ?? json['target_category'] as String? ?? 'TNPSC',
      schedulePdfUrl: json['schedulePdfUrl'] as String? ?? json['schedule_pdf_url'] as String?,
      schedulePdfName: json['schedulePdfName'] as String? ?? json['schedule_pdf_name'] as String?,
      omrPdfUrl: json['omrPdfUrl'] as String? ?? json['omr_pdf_url'] as String?,
      omrPdfName: json['omrPdfName'] as String? ?? json['omr_pdf_name'] as String?,
      order: json['order'] as int? ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? json['is_enabled'] as bool? ?? true,
      totalCategories: json['totalCategories'] as int? ?? rawCats.length,
      totalQuestionPapers: json['totalQuestionPapers'] as int? ??
          rawCats.fold<int>(0, (sum, cat) => sum + ((cat['questionPapers'] as List?)?.length ?? 0)),
      categories: rawCats
          .map((c) => TestBatchCategoryModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}
