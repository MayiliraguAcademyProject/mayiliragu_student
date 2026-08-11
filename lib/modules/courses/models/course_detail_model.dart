class CourseDetailModel {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final bool isEnrolled;
  final bool isDemo;
  final List<ModuleModel> modules;

  CourseDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    this.isEnrolled = true,
    this.isDemo = false,
    required this.modules,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    final modulesList = json['modules'] as List? ?? [];
    return CourseDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      isEnrolled: json['isEnrolled'] as bool? ?? true,
      isDemo: json['isDemo'] as bool? ?? false,
      modules: modulesList
          .map((m) => ModuleModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ModuleModel {
  final String id;
  final String title;
  final List<LessonModel> lessons;

  ModuleModel({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    final lessonsList = json['lessons'] as List? ?? [];
    return ModuleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      lessons: lessonsList
          .map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LessonModel {
  final String id;
  final String title;
  final String description;
  final String? image;
  final int duration;
  final bool downloadEnabled;
  final bool isLocked;
  final LessonProgressModel? progress;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.duration,
    required this.downloadEnabled,
    this.isLocked = false,
    this.progress,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString(),
      duration: json['duration'] as int? ?? 0,
      downloadEnabled: json['downloadEnabled'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      progress: json['progress'] != null
          ? LessonProgressModel.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LessonProgressModel {
  final bool completed;
  final int watchedSeconds;

  LessonProgressModel({
    required this.completed,
    required this.watchedSeconds,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      completed: json['completed'] as bool? ?? false,
      watchedSeconds: json['watchedSeconds'] as int? ?? 0,
    );
  }
}
