class CourseDetailModel {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final bool isEnrolled;
  final bool isDemo;
  final String? enrollmentRequestStatus;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? availabilityStatus;
  final int? timeRemainingSeconds;
  final String? timeRemainingText;
  final bool isAvailableForStudy;
  final List<ModuleModel> modules;

  CourseDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    this.isEnrolled = true,
    this.isDemo = false,
    this.enrollmentRequestStatus,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.availabilityStatus,
    this.timeRemainingSeconds,
    this.timeRemainingText,
    this.isAvailableForStudy = true,
    required this.modules,
  });

  bool get isUpcoming =>
      availabilityStatus == 'upcoming' ||
      (startDate != null && DateTime.now().isBefore(startDate!));

  bool get isClosingSoon => availabilityStatus == 'closing_soon';

  bool get isExpired =>
      availabilityStatus == 'expired' ||
      (endDate != null && DateTime.now().isAfter(endDate!));

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    final modulesList = json['modules'] as List? ?? [];
    return CourseDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      isEnrolled: json['isEnrolled'] as bool? ?? true,
      isDemo: json['isDemo'] as bool? ?? false,
      enrollmentRequestStatus: json['enrollmentRequestStatus'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())?.toLocal()
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())?.toLocal()
          : null,
      availabilityStatus: json['availabilityStatus']?.toString(),
      timeRemainingSeconds: json['timeRemainingSeconds'] as int?,
      timeRemainingText: json['timeRemainingText']?.toString(),
      isAvailableForStudy: json['isAvailableForStudy'] as bool? ?? true,
      modules: modulesList
          .map((m) => ModuleModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ModuleModel {
  final String id;
  final String title;
  final List<TopicModel> topics;

  ModuleModel({
    required this.id,
    required this.title,
    required this.topics,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    final topicsList = json['topics'] as List? ?? [];
    List<TopicModel> parsedTopics = [];

    if (topicsList.isNotEmpty) {
      parsedTopics = topicsList
          .map((t) => TopicModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } else if (json['lessons'] != null && (json['lessons'] as List).isNotEmpty) {
      // Backward compatibility fallback: wrap legacy module lessons in a default topic
      final lessonsList = (json['lessons'] as List)
          .map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
          .toList();
      parsedTopics = [
        TopicModel(
          id: 'topic-${json['id']}',
          title: json['title']?.toString() ?? 'General',
          description: null,
          lessons: lessonsList,
        )
      ];
    }

    return ModuleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      topics: parsedTopics,
    );
  }
}

class TopicModel {
  final String id;
  final String title;
  final String? description;
  final List<LessonModel> lessons;

  TopicModel({
    required this.id,
    required this.title,
    this.description,
    required this.lessons,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    final lessonsList = json['lessons'] as List? ?? [];
    return TopicModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
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
  final List<VideoModel> videos;

  LessonModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.videos,
  });

  // Backward compatibility getters
  int get duration => totalDuration;
  bool get downloadEnabled => videos.any((v) => v.downloadEnabled);
  int get totalDuration => videos.fold(0, (sum, v) => sum + v.duration);
  bool get isLocked => videos.isNotEmpty && videos.every((v) => v.isLocked);
  bool get isCompleted => videos.isNotEmpty && videos.every((v) => v.progress?.completed == true);
  VideoProgressModel? get progress {
    if (videos.isEmpty) return null;
    final totalWatched = videos.fold(0, (sum, v) => sum + (v.progress?.watchedSeconds ?? 0));
    return VideoProgressModel(
      completed: isCompleted,
      watchedSeconds: totalWatched,
    );
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final videosList = json['videos'] as List? ?? [];
    List<VideoModel> parsedVideos = [];

    if (videosList.isNotEmpty) {
      parsedVideos = videosList
          .map((v) => VideoModel.fromJson(v as Map<String, dynamic>))
          .toList();
    } else if (json['driveFileId'] != null) {
      // Backward compatibility fallback for single video in lesson
      parsedVideos = [
        VideoModel(
          id: json['id']?.toString() ?? '',
          title: json['title']?.toString() ?? '',
          description: json['description']?.toString(),
          image: json['image']?.toString(),
          driveFileId: json['driveFileId']?.toString() ?? '',
          duration: json['duration'] as int? ?? 0,
          downloadEnabled: json['downloadEnabled'] as bool? ?? false,
          isLocked: json['isLocked'] as bool? ?? false,
          progress: json['progress'] != null
              ? VideoProgressModel.fromJson(json['progress'] as Map<String, dynamic>)
              : null,
        )
      ];
    }

    return LessonModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString(),
      videos: parsedVideos,
    );
  }
}

class VideoModel {
  final String id;
  final String title;
  final String? description;
  final String? image;
  final String driveFileId;
  final int duration;
  final bool downloadEnabled;
  final bool isLocked;
  final VideoProgressModel? progress;

  VideoModel({
    required this.id,
    required this.title,
    this.description,
    this.image,
    required this.driveFileId,
    required this.duration,
    required this.downloadEnabled,
    this.isLocked = false,
    this.progress,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      driveFileId: json['driveFileId']?.toString() ?? '',
      duration: json['duration'] as int? ?? 0,
      downloadEnabled: json['downloadEnabled'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      progress: json['progress'] != null
          ? VideoProgressModel.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VideoProgressModel {
  final bool completed;
  final int watchedSeconds;

  VideoProgressModel({
    required this.completed,
    required this.watchedSeconds,
  });

  factory VideoProgressModel.fromJson(Map<String, dynamic> json) {
    return VideoProgressModel(
      completed: json['completed'] as bool? ?? false,
      watchedSeconds: json['watchedSeconds'] as int? ?? 0,
    );
  }
}

typedef LessonProgressModel = VideoProgressModel;
