import 'package:get/get.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/auth_view.dart';
import '../../modules/auth/bindings/register_binding.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/auth/bindings/otp_verification_binding.dart';
import '../../modules/auth/views/otp_verification_view.dart';
import '../../modules/auth/bindings/forgot_password_binding.dart';
import '../../modules/auth/views/forgot_password_view.dart';
import '../../modules/auth/views/forgot_password_otp_view.dart';
import '../../modules/auth/views/reset_password_view.dart';
import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/courses/bindings/course_binding.dart';
import '../../modules/courses/views/course_list_view.dart';
import '../../modules/lessons/bindings/lesson_binding.dart';
import '../../modules/lessons/views/lesson_detail_view.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/views/profile_view.dart';
import '../../modules/profile/views/profile_onboarding_view.dart';
import '../../modules/tests/bindings/test_runner_binding.dart';
import '../../modules/tests/views/test_runner_view.dart';
import '../../modules/tests/bindings/section_selection_binding.dart';
import '../../modules/tests/views/section_selection_view.dart';
import '../../modules/tests/bindings/test_results_binding.dart';
import '../../modules/tests/views/test_results_view.dart';
import '../../modules/tests/bindings/test_solutions_binding.dart';
import '../../modules/tests/views/test_solutions_view.dart';
import '../../modules/current_affairs/bindings/current_affairs_binding.dart';
import '../../modules/current_affairs/views/current_affairs_dashboard_view.dart';
import '../../modules/study_materials/bindings/study_materials_binding.dart';
import '../../modules/study_materials/views/study_material_dashboard_view.dart';
import '../../modules/analytics/bindings/analytics_binding.dart';
import '../../modules/analytics/views/analytics_dashboard_view.dart';
import '../../modules/book_store/bindings/book_store_binding.dart';
import '../../modules/book_store/views/book_store_dashboard_view.dart';
import '../../modules/notifications/views/notification_inbox_view.dart';
import '../../modules/bookmarks/bindings/bookmarked_questions_binding.dart';
import '../../modules/bookmarks/views/bookmarked_questions_view.dart';
import '../../modules/payment/bindings/payment_binding.dart';
import '../../modules/payment/views/banner_product_detail_view.dart';
import '../../modules/payment/views/payment_qr_view.dart';
import '../../modules/payment/views/payment_confirmation_view.dart';
import '../../modules/live_videos/bindings/live_videos_binding.dart';
import '../../modules/live_videos/views/live_videos_list_view.dart';
import '../../modules/testimonials/bindings/testimonials_binding.dart';
import '../../modules/testimonials/views/testimonials_list_view.dart';
import '../../modules/exam_updates/bindings/exam_updates_binding.dart';
import '../../modules/exam_updates/views/exam_updates_list_view.dart';
import '../../modules/test_batches/bindings/test_batches_binding.dart';
import '../../modules/test_batches/views/test_batches_list_view.dart';
import '../../modules/test_batches/views/test_batch_detail_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.OTP_VERIFICATION,
      page: () => const OtpVerificationView(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD_OTP,
      page: () => const ForgotPasswordOtpView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.COURSES,
      page: () => const CourseListView(),
      binding: CourseBinding(),
    ),
    GetPage(
      name: Routes.LESSON_DETAIL,
      page: () => const LessonDetailView(),
      binding: LessonBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.PROFILE_ONBOARDING,
      page: () => const ProfileOnboardingView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.TEST_RUNNER,
      page: () => const TestRunnerView(),
      binding: TestRunnerBinding(),
    ),
    GetPage(
      name: Routes.TEST_SECTIONS,
      page: () => const SectionSelectionView(),
      binding: SectionSelectionBinding(),
    ),
    GetPage(
      name: Routes.TEST_RESULTS,
      page: () => const TestResultsView(),
      binding: TestResultsBinding(),
    ),
    GetPage(
      name: Routes.TEST_SOLUTIONS,
      page: () => const TestSolutionsView(),
      binding: TestSolutionsBinding(),
    ),
    GetPage(
      name: Routes.CURRENT_AFFAIRS,
      page: () => const CurrentAffairsDashboardView(),
      binding: CurrentAffairsBinding(),
    ),
    GetPage(
      name: Routes.STUDY_MATERIALS,
      page: () => const StudyMaterialDashboardView(),
      binding: StudyMaterialsBinding(),
    ),
    GetPage(
      name: Routes.PERFORMANCE,
      page: () => const AnalyticsDashboardView(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: Routes.BOOK_STORE,
      page: () => const BookStoreDashboardView(),
      binding: BookStoreBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationInboxView(),
    ),
    GetPage(
      name: Routes.BOOKMARKS,
      page: () => const BookmarkedQuestionsView(),
      binding: BookmarkedQuestionsBinding(),
    ),
    GetPage(
      name: Routes.BANNER_PRODUCT_DETAIL,
      page: () => BannerProductDetailView(banner: Get.arguments),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: Routes.PAYMENT_QR,
      page: () => const PaymentQrView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: Routes.PAYMENT_CONFIRMATION,
      page: () => const PaymentConfirmationView(),
    ),
    GetPage(
      name: Routes.LIVE_VIDEOS,
      page: () => const LiveVideosListView(),
      binding: LiveVideosBinding(),
    ),
    GetPage(
      name: Routes.TESTIMONIALS,
      page: () => const TestimonialsListView(),
      binding: TestimonialsBinding(),
    ),
    GetPage(
      name: Routes.EXAM_UPDATES,
      page: () => const ExamUpdatesListView(),
      binding: ExamUpdatesBinding(),
    ),
    GetPage(
      name: Routes.TEST_BATCHES,
      page: () => const TestBatchesListView(),
      binding: TestBatchesBinding(),
    ),
    GetPage(
      name: Routes.TEST_BATCH_DETAIL,
      page: () => const TestBatchDetailView(),
      binding: TestBatchesBinding(),
    ),
  ];
}
