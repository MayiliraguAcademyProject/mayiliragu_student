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
  static const paymentSettingsPublic = '/payment-settings/public';
  static const paymentRequests = '/payment-requests';
  static const myPaymentRequests = '/payment-requests/my';
  static const liveStreams = '/live-streams';
  static const testimonials = '/testimonials';
  static const examUpdates = '/exam-updates';
}

