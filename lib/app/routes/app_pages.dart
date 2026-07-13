import 'package:get/get.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/auth_view.dart';
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
  ];
}
