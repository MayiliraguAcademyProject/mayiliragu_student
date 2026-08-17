import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/controllers/user_session_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../repositories/auth_repository.dart';
import '../../../shared/models/student_profile_model.dart';
import '../../../../core/enums/user_role.dart';
import '../widgets/guest_intake_bottom_sheet.dart';

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
      final deviceId = await _storage.getOrCreateDeviceId();

      final response = await _authRepository.login(
        email: email,
        password: password,
        deviceId: deviceId,
        deviceName: 'Mayiliragu Mobile App',
      );
      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        final accessToken = responseData['accessToken'] as String;
        final refreshToken = responseData['refreshToken'] as String;
        final role = responseData['user']['role'] as String;

        if (!UserRole.fromString(role).isStudent) {
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

        if (Get.isRegistered<UserSessionController>()) {
          await Get.find<UserSessionController>().loadSession();
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
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['code'] == 'ACCOUNT_NOT_VERIFIED') {
          // Navigate to OTP verification screen with pre-filled email
          Get.toNamed(
            Routes.OTP_VERIFICATION,
            arguments: {
              'email': email,
            },
          );
          errorMessage.value = resData['message'] ?? 'Please verify your email to activate your account.';
          return;
        }
        if (resData is Map && resData['code'] == 'DEVICE_BOUND_MISMATCH') {
          errorMessage.value = resData['message'] ??
              'This account is registered on another device. Contact support to transfer device.';
          return;
        }
        errorMessage.value = (resData is Map && resData['message'] != null)
            ? resData['message'].toString()
            : 'Invalid email or password';
      } else {
        errorMessage.value = 'Invalid email or password';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void enterGuestMode() {
    final context = Get.context;
    if (context != null) {
      GuestIntakeBottomSheet.show(
        context,
        onSubmit: submitGuestIntake,
      );
    }
  }

  Future<void> submitGuestIntake({
    required String name,
    required String phoneNumber,
    required String place,
    required String targetCourse,
    required String studyMode,
  }) async {
    try {
      final response = await _authRepository.guestLogin(
        name: name,
        phoneNumber: phoneNumber,
        place: place,
        targetCourse: targetCourse,
        studyMode: studyMode,
      );
      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        final accessToken = responseData['accessToken'] as String;
        final role = responseData['role'] as String? ?? UserRole.guest.value;

        await _storage.saveTokens(
          accessToken: accessToken,
          refreshToken: '',
          role: role,
        );

        if (Get.isRegistered<UserSessionController>()) {
          await Get.find<UserSessionController>().loadSession();
        }

        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }

        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to enter guest mode');
      }
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['message'] != null) {
          throw Exception(resData['message'].toString());
        }
      }
      throw Exception('Unable to enter guest mode. Please check connection.');
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
