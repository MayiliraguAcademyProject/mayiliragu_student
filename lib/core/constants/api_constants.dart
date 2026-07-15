import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => AppConfig.baseUrl;

  static const login = '/auth/login';
  static const logout = '/auth/logout';
  static const dashboard = '/dashboard/student';
  static const courses = '/courses';
  static const profile = '/profile';
  static const registerFcmToken = '/notifications/register-token';
  static const unregisterFcmToken = '/notifications/unregister-token';
  static const notifications = '/notifications';
  static const notificationsUnreadCount = '/notifications/unread-count';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // Lessons and playback HLS endpoints
  static String lessonDetails(String id) => '/lessons/$id';
  static const updateProgress = '/progress/update';
  static const markComplete = '/progress/complete';
  static String downloadLesson(String id) => '/lessons/$id/download';
  static String signedVideoUrl(String id) => '/lessons/$id/video-url';
  static String streamLesson(String id) => '/lessons/stream/$id';
}

