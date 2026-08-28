import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/controllers/user_session_controller.dart';
import '../../../../core/utils/toast_helper.dart';
import '../../../../core/utils/error_handler.dart';
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

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['email'] != null) {
      emailController.text = args['email'].toString();
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    debugPrint('[AUTH] Initiating student login for email: "$email"');

    if (email.isEmpty || password.isEmpty) {
      debugPrint('[AUTH] Validation failed: email or password field is empty');
      errorMessage.value = 'Please enter email and password';
      AppToast.validation('Please enter both email and password', title: 'Input Required');
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    String? deviceId;
    try {
      deviceId = await _storage.getOrCreateDeviceId();
      debugPrint('[AUTH] Retrieved device ID: $deviceId');

      debugPrint('[AUTH] Sending login POST request to ${ApiConstants.login} (Base URL: ${ApiConstants.baseUrl})...');
      final response = await _authRepository.login(
        email: email,
        password: password,
        deviceId: deviceId,
        deviceName: 'Mayiliragu Mobile App',
      );
      debugPrint('[AUTH] Login response received. HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        final accessToken = responseData['accessToken'] as String;
        final refreshToken = responseData['refreshToken'] as String;
        final userObj = responseData['user'] as Map<String, dynamic>?;
        final role = userObj?['role'] as String? ?? responseData['role'] as String? ?? '';

        debugPrint('[AUTH] Authentication successful. User ID: ${userObj?['id']}, Role: "$role"');

        if (!UserRole.fromString(role).isStudent) {
          debugPrint('[AUTH] Access denied: User role "$role" is not a Student account.');
          final deniedMsg = 'Access denied. Student account required.';
          errorMessage.value = deniedMsg;
          AppToast.error(deniedMsg, title: 'Access Denied');
          return;
        }

        debugPrint('[AUTH] Saving auth tokens to SecureStorage...');
        await _storage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          role: role,
        );
        debugPrint('[AUTH] Tokens persisted successfully.');

        // Sync FCM token
        if (Get.isRegistered<NotificationService>()) {
          debugPrint('[AUTH] Triggering FCM token sync with backend...');
          await Get.find<NotificationService>().syncToken();
          debugPrint('[AUTH] FCM token sync completed.');
        }

        emailController.clear();
        passwordController.clear();

        // Check student profile completion status using the returned profile in response
        bool isCompleted = false;
        final profileData = responseData['profile'];
        debugPrint('[AUTH] Evaluating student profile completion. Raw profile data: $profileData');
        if (profileData != null) {
          try {
            final profileModel = StudentProfileModel.fromJson(profileData);
            if (profileModel.gender != null &&
                profileModel.gender!.isNotEmpty &&
                profileModel.mobileNumber != null &&
                profileModel.mobileNumber!.isNotEmpty) {
              isCompleted = true;
            }
            debugPrint('[AUTH] Profile parsed successfully. isCompleted: $isCompleted (Gender: ${profileModel.gender}, Mobile: ${profileModel.mobileNumber})');
          } catch (e) {
            debugPrint('[AUTH] Error parsing profile completion on login: $e');
          }
        } else {
          debugPrint('[AUTH] No profile object included in login payload.');
        }

        if (Get.isRegistered<UserSessionController>()) {
          debugPrint('[AUTH] Reloading UserSessionController session state...');
          await Get.find<UserSessionController>().loadSession();
          debugPrint('[AUTH] UserSessionController loaded.');
        }

        AppToast.success('Welcome back to Mayiliragu Academy!', title: 'Login Successful');

        if (isCompleted) {
          debugPrint('[AUTH] Profile is complete. Storing onboarding status=true and routing to DASHBOARD.');
          await _storage.setIsOnboardingCompleted(true);
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          debugPrint('[AUTH] Profile incomplete. Storing onboarding status=false and routing to PROFILE_ONBOARDING.');
          await _storage.setIsOnboardingCompleted(false);
          Get.offAllNamed(Routes.PROFILE_ONBOARDING);
        }
      } else {
        final errorMsg = response.data['message']?.toString() ?? 'Login failed';
        debugPrint('[AUTH] Login unsuccessful with status ${response.statusCode}: $errorMsg');
        errorMessage.value = errorMsg;
        AppToast.error(errorMsg, title: 'Login Failed');
      }
    } catch (e, stackTrace) {
      debugPrint('[AUTH] Exception caught during login process: $e');
      if (e is DioException) {
        debugPrint('[AUTH] DioException Details:');
        debugPrint('  - Type: ${e.type}');
        debugPrint('  - Message: ${e.message}');
        debugPrint('  - Status Code: ${e.response?.statusCode}');
        debugPrint('  - Response Data: ${e.response?.data}');
        debugPrint('  - Request Path: ${e.requestOptions.path}');
        debugPrint('  - Request BaseUrl: ${e.requestOptions.baseUrl}');

        final resData = e.response?.data;
        if (resData is Map && resData['code'] == 'ACCOUNT_NOT_VERIFIED') {
          debugPrint('[AUTH] Account not verified. Redirecting to OTP verification screen for email: $email');
          final msg = resData['message']?.toString() ?? 'Please verify your email to activate your account.';
          errorMessage.value = msg;
          AppToast.validation(msg, title: 'Account Not Verified');
          Get.toNamed(
            Routes.OTP_VERIFICATION,
            arguments: {
              'email': email,
            },
          );
          return;
        }
        if (resData is Map && resData['code'] == 'DEVICE_BOUND_MISMATCH') {
          debugPrint('[AUTH] Device mismatch detected for deviceId: $deviceId');
          final msg = resData['message']?.toString() ??
              'This account is registered on another device. Contact support to transfer device.';
          errorMessage.value = msg;
          AppToast.error(msg, title: 'Device Mismatch');
          return;
        }

        final msg = AppErrorHandler.getErrorMessage(
          e,
          defaultMessage: 'Invalid email or password. Please try again.',
        );
        errorMessage.value = msg;
        AppToast.error(msg, title: 'Login Error');
      } else {
        debugPrint('[AUTH] Non-DioException encountered: $e\n$stackTrace');
        final msg = AppErrorHandler.getErrorMessage(
          e,
          defaultMessage: 'Invalid email or password',
        );
        errorMessage.value = msg;
        AppToast.error(msg, title: 'Login Error');
      }
    } finally {
      isLoading.value = false;
      debugPrint('[AUTH] Login flow finished. Loading state reset.');
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
}

