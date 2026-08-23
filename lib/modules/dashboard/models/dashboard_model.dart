import 'dart:convert';

class DashboardModel {
  final List<BannerModel> banners;
  final List<EnrolledCourse> allCourses;
  final List<EnrolledCourse> enrolledCourses;
  final ContinueLearning? continueLearning;
  final List<RecentlyWatched> recentlyWatched;
  final List<QuickActionModel> quickActions;
  final UserProfile? profile;

  DashboardModel({
    required this.banners,
    required this.allCourses,
    required this.enrolledCourses,
    this.continueLearning,
    required this.recentlyWatched,
    required this.quickActions,
    this.profile,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json, {UserProfile? profile}) {
    final bannersList = json['banners'] as List? ?? [];
    final List<BannerModel> banners = bannersList
        .map((b) => BannerModel.fromJson(b as Map<String, dynamic>))
        .toList();

    final allCoursesList = json['allCourses'] as List? ?? json['enrolledCourses'] as List? ?? [];
    final List<EnrolledCourse> all = allCoursesList
        .map((c) => EnrolledCourse.fromJson(c as Map<String, dynamic>))
        .toList();

    final enrolledList = json['enrolledCourses'] as List? ?? [];
    final List<EnrolledCourse> enrolled = enrolledList
        .map((c) => EnrolledCourse.fromJson(c as Map<String, dynamic>))
        .toList();

    ContinueLearning? contLearn;
    if (json['continueLearning'] != null) {
      contLearn = ContinueLearning.fromJson(json['continueLearning'] as Map<String, dynamic>);
    }

    final recentList = json['recentlyWatched'] as List? ?? [];
    final List<RecentlyWatched> recent = recentList
        .map((r) => RecentlyWatched.fromJson(r as Map<String, dynamic>))
        .toList();

    final actionsList = json['quickActions'] as List? ?? json['quick_actions'] as List? ?? [];
    final List<QuickActionModel> actions = actionsList
        .map((a) => QuickActionModel.fromJson(a as Map<String, dynamic>))
        .toList();

    return DashboardModel(
      banners: banners,
      allCourses: all,
      enrolledCourses: enrolled,
      continueLearning: contLearn,
      recentlyWatched: recent,
      quickActions: actions,
      profile: profile,
    );
  }
}

class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String? linkId;
  final String? linkType;
  final List<String>? curriculumJson;
  final String? curriculumPdfUrl;
  final String? curriculumPdfName;
  final String? planDescription;
  final double? price;
  final double? offerPrice;
  final DateTime? offerValidUntil;
  final int? validityDays;
  final bool isActive;
  final int order;
  final bool isDeleted;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.linkId,
    this.linkType,
    this.curriculumJson,
    this.curriculumPdfUrl,
    this.curriculumPdfName,
    this.planDescription,
    this.price,
    this.offerPrice,
    this.offerValidUntil,
    this.validityDays,
    required this.isActive,
    required this.order,
    this.isDeleted = false,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    List<String>? curriculum;
    if (json['curriculumJson'] != null) {
      try {
        final dynamic rawCurriculum = json['curriculumJson'];
        final dynamic parsed = rawCurriculum is String 
            ? jsonDecode(rawCurriculum) 
            : rawCurriculum;
        if (parsed is List) {
          curriculum = parsed
              .map((e) => e is Map ? (e['title'] ?? '').toString() : e.toString())
              .toList();
        }
      } catch (e) {
        print('Error parsing curriculumJson: $e');
      }
    }

    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      linkUrl: json['linkUrl']?.toString(),
      linkId: json['linkId']?.toString(),
      linkType: json['linkType']?.toString(),
      curriculumJson: curriculum,
      curriculumPdfUrl: json['curriculumPdfUrl']?.toString() ?? json['curriculum_pdf_url']?.toString(),
      curriculumPdfName: json['curriculumPdfName']?.toString() ?? json['curriculum_pdf_name']?.toString(),
      planDescription: json['planDescription']?.toString(),
      price: json['price'] is num 
          ? (json['price'] as num).toDouble() 
          : (json['price'] is String ? double.tryParse(json['price'] as String) : null),
      offerPrice: json['offerPrice'] is num 
          ? (json['offerPrice'] as num).toDouble() 
          : (json['offerPrice'] is String ? double.tryParse(json['offerPrice'] as String) : null),
      offerValidUntil: json['offerValidUntil'] != null 
          ? DateTime.tryParse(json['offerValidUntil'] as String) 
          : null,
      validityDays: json['validityDays'] is int
          ? json['validityDays'] as int
          : (json['validityDays'] is String ? int.tryParse(json['validityDays'] as String) : null),
      isActive: json['isActive'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

class EnrolledCourse {
  final String id;
  final String title;
  final String thumbnail;
  final bool isDemo;
  final int totalLessons;
  final int totalVideos;
  final double progressPercentage;
  final bool isEnrolled;
  final String? enrollmentRequestStatus;

  EnrolledCourse({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.isDemo = false,
    required this.totalLessons,
    this.totalVideos = 0,
    required this.progressPercentage,
    this.isEnrolled = true,
    this.enrollmentRequestStatus,
  });

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    return EnrolledCourse(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      isDemo: json['isDemo'] as bool? ?? false,
      totalLessons: json['totalLessons'] as int? ?? 0,
      totalVideos: json['totalVideos'] as int? ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      isEnrolled: json['isEnrolled'] as bool? ?? false,
      enrollmentRequestStatus: json['enrollmentRequestStatus']?.toString(),
    );
  }
}

class ContinueLearning {
  final String? videoId;
  final String lessonId;
  final String lessonTitle;
  final String? videoTitle;
  final String courseId;
  final int watchedSeconds;
  final int duration;

  ContinueLearning({
    this.videoId,
    required this.lessonId,
    required this.lessonTitle,
    this.videoTitle,
    required this.courseId,
    required this.watchedSeconds,
    required this.duration,
  });

  double get progress => duration > 0 ? watchedSeconds / duration : 0.0;
  int get progressPercentage => (progress * 100).toInt();

  factory ContinueLearning.fromJson(Map<String, dynamic> json) {
    return ContinueLearning(
      videoId: json['videoId']?.toString(),
      lessonId: json['lessonId']?.toString() ?? '',
      lessonTitle: json['lessonTitle']?.toString() ?? '',
      videoTitle: json['videoTitle']?.toString(),
      courseId: json['courseId']?.toString() ?? '',
      watchedSeconds: json['watchedSeconds'] as int? ?? 0,
      duration: json['duration'] as int? ?? 1,
    );
  }
}

class RecentlyWatched {
  final String? videoId;
  final String lessonId;
  final String lessonTitle;
  final String? videoTitle;
  final String lastViewedAt;

  RecentlyWatched({
    this.videoId,
    required this.lessonId,
    required this.lessonTitle,
    this.videoTitle,
    required this.lastViewedAt,
  });

  factory RecentlyWatched.fromJson(Map<String, dynamic> json) {
    return RecentlyWatched(
      videoId: json['videoId']?.toString(),
      lessonId: json['lessonId']?.toString() ?? '',
      lessonTitle: json['lessonTitle']?.toString() ?? '',
      videoTitle: json['videoTitle']?.toString(),
      lastViewedAt: json['lastViewedAt']?.toString() ?? '',
    );
  }
}

class UserProfile {
  final String name;
  final String email;

  UserProfile({
    required this.name,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class QuickActionModel {
  final String id;
  final String title;
  final String icon;
  final String route;
  final bool isEnabled;
  final int order;
  final String? createdAt;
  final String? updatedAt;

  QuickActionModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    required this.isEnabled,
    required this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      isEnabled: json['isEnabled'] as bool? ?? json['is_enabled'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'route': route,
      'isEnabled': isEnabled,
      'order': order,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

