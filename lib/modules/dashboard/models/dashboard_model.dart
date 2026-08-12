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
  final bool isActive;
  final int order;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    required this.isActive,
    required this.order,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      linkUrl: json['linkUrl'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }
}

class EnrolledCourse {
  final String id;
  final String title;
  final String thumbnail;
  final int totalLessons;
  final double progressPercentage;
  final bool isEnrolled;
  final String? enrollmentRequestStatus;
  final bool isDemo;

  EnrolledCourse({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.totalLessons,
    required this.progressPercentage,
    this.isEnrolled = true,
    this.enrollmentRequestStatus,
    this.isDemo = false,
  });

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    return EnrolledCourse(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      totalLessons: json['totalLessons'] as int? ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      isEnrolled: json['isEnrolled'] as bool? ?? true,
      enrollmentRequestStatus: json['enrollmentRequestStatus'] as String?,
      isDemo: json['isDemo'] as bool? ?? false,
    );
  }
}

class ContinueLearning {
  final String lessonId;
  final String lessonTitle;
  final String courseId;
  final int watchedSeconds;
  final int duration;

  ContinueLearning({
    required this.lessonId,
    required this.lessonTitle,
    required this.courseId,
    required this.watchedSeconds,
    required this.duration,
  });

  double get progress => duration > 0 ? watchedSeconds / duration : 0.0;
  int get progressPercentage => (progress * 100).toInt();

  factory ContinueLearning.fromJson(Map<String, dynamic> json) {
    return ContinueLearning(
      lessonId: json['lessonId'] as String? ?? '',
      lessonTitle: json['lessonTitle'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      watchedSeconds: json['watchedSeconds'] as int? ?? 0,
      duration: json['duration'] as int? ?? 1,
    );
  }
}

class RecentlyWatched {
  final String lessonId;
  final String lessonTitle;
  final String lastViewedAt;

  RecentlyWatched({
    required this.lessonId,
    required this.lessonTitle,
    required this.lastViewedAt,
  });

  factory RecentlyWatched.fromJson(Map<String, dynamic> json) {
    return RecentlyWatched(
      lessonId: json['lessonId'] as String? ?? '',
      lessonTitle: json['lessonTitle'] as String? ?? '',
      lastViewedAt: json['lastViewedAt'] as String? ?? '',
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

  QuickActionModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    required this.isEnabled,
    required this.order,
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      route: json['route'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? json['is_enabled'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
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
    };
  }
}
