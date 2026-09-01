import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => AppConfig.baseUrl;

  static const login = '/auth/login';
  static const logout = '/auth/logout';
  static const register = '/auth/register';
  static const verifyOtp = '/auth/verify-otp';
  static const resendOtp = '/auth/resend-otp';
  static const forgotPassword = '/auth/forgot-password';
  static const forgotPasswordResendOtp = '/auth/forgot-password/resend-otp';
  static const forgotPasswordVerifyOtp = '/auth/forgot-password/verify-otp';
  static const resetPassword = '/auth/reset-password';
  static const guest = '/auth/guest';
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
  static const testBatchesStudent = '/test-batches/student';
  static String testBatchStudentDetail(String id) => '/test-batches/student/$id';
  static String testBatchSubmitOmr(String paperId) => '/test-batches/question-papers/$paperId/omr-submission';
  static String testBatchUpdateMarks(String paperId) => '/test-batches/question-papers/$paperId/omr-submission/marks';
  static String testBatchAnswerKey(String paperId) => '/test-batches/question-papers/$paperId/answer-key';
}
