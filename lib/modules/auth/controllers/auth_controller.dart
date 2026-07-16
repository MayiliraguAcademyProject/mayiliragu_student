import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../app/routes/app_routes.dart';
import '../repositories/auth_repository.dart';
import '../../../shared/models/student_profile_model.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final SecureStorageService _storage = Get.find<SecureStorageService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final obscurePassword = true.obs;

  AuthController(this._authRepository);

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter email and password';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );
      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        final accessToken = responseData['accessToken'] as String;
        final refreshToken = responseData['refreshToken'] as String;
        final role = responseData['user']['role'] as String;

        if (role != 'STUDENT') {
          errorMessage.value = 'Access denied. Student account required.';
          return;
        }

        await _storage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          role: role,
        );

        // Sync FCM token
        if (Get.isRegistered<NotificationService>()) {
          await Get.find<NotificationService>().syncToken();
        }

        emailController.clear();
        passwordController.clear();

        // Check student profile completion status using the returned profile in response
        bool isCompleted = false;
        final profileData = responseData['profile'];
        if (profileData != null) {
          try {
            final profileModel = StudentProfileModel.fromJson(profileData);
            if (profileModel.gender != null &&
                profileModel.gender!.isNotEmpty &&
                profileModel.mobileNumber != null &&
                profileModel.mobileNumber!.isNotEmpty) {
              isCompleted = true;
            }
          } catch (e) {
            debugPrint('Error parsing profile completion on login: $e');
          }
        }

        if (isCompleted) {
          await _storage.setIsOnboardingCompleted(true);
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          await _storage.setIsOnboardingCompleted(false);
          Get.offAllNamed(Routes.PROFILE_ONBOARDING);
        }
      } else {
        errorMessage.value = response.data['message'] ?? 'Login failed';
      }
    } catch (e) {
      errorMessage.value = 'Invalid email or password';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      if (Get.isRegistered<NotificationService>()) {
        await Get.find<NotificationService>().unregisterToken();
      }
      await _authRepository.logout();
    } catch (_) {}
    await _storage.clearAll();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
