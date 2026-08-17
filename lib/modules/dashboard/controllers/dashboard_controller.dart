import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/error_handler.dart';
import '../repositories/dashboard_repository.dart';
import '../models/dashboard_model.dart';

import '../../tests/controllers/tests_controller.dart';
import '../../courses/controllers/course_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository;
  final SecureStorageService _storage = Get.find<SecureStorageService>();

  final tabController = PersistentTabController(initialIndex: 0);

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Strongly typed dashboard data model
  final dashboardData = Rxn<DashboardModel>();

  DashboardController(this._repository);

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    final index = tabController.index;
    switch (index) {
      case 0:
        fetchDashboardData();
        break;
      case 1:
        if (Get.isRegistered<TestsController>()) {
          Get.find<TestsController>().fetchTests();
        }
        break;
      case 2:
        if (Get.isRegistered<CourseController>()) {
          Get.find<CourseController>().fetchCourses();
        }
        break;
      case 3:
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfile();
        }
        break;
    }
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _repository.getStudentDashboard();
      
      UserProfile? profile;
      try {
        final profileResponse = await _repository.getStudentProfile();
        if (profileResponse.statusCode == 200) {
          final profileJson = profileResponse.data['data'] as Map<String, dynamic>?;
          if (profileJson != null) {
            profile = UserProfile.fromJson(profileJson);
          }
        }
      } catch (_) {
        // Suppress profile fetch error so dashboard still loads
      }

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        dashboardData.value = DashboardModel.fromJson(data, profile: profile);
      } else {
        errorMessage.value = response.data['message'] ?? 'Failed to load dashboard';
      }

      if (Get.isRegistered<NotificationService>()) {
        Get.find<NotificationService>().fetchUnreadCount();
      }
    } catch (e, stackTrace) {
      print('Error fetching dashboard: $e');
      print(stackTrace);
      errorMessage.value = AppErrorHandler.getErrorMessage(
        e,
        defaultMessage: 'Failed to load dashboard. Please check your network connection.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      if (Get.isRegistered<NotificationService>()) {
        await Get.find<NotificationService>().unregisterToken();
      }
      await _storage.clearAll();
    } catch (_) {}
    Get.offAllNamed(Routes.LOGIN);
  }

}
