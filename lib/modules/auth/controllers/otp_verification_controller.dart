import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/controllers/user_session_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../repositories/auth_repository.dart';
import '../../../shared/models/student_profile_model.dart';

class OtpVerificationController extends GetxController {
  final AuthRepository _authRepository;
  final SecureStorageService _storage = Get.find<SecureStorageService>();

  final otpController = TextEditingController();
  final email = ''.obs;
  final name = ''.obs;

  final isLoading = false.obs;
  final isResending = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final resendCountdown = 60.obs;

  Timer? _timer;

  OtpVerificationController(this._authRepository);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      email.value = args['email'] ?? '';
      name.value = args['name'] ?? '';
    }
    startCountdown();
  }

  void startCountdown([int seconds = 60]) {
    _timer?.cancel();
    resendCountdown.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      errorMessage.value = 'Please enter the 6-digit verification code';
      return;
    }

    if (email.value.isEmpty) {
      errorMessage.value = 'Email address is missing. Please try registering again.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final deviceId = await _storage.getOrCreateDeviceId();
      final response = await _authRepository.verifyOtp(
        email: email.value,
        otp: otp,
        deviceId: deviceId,
        deviceName: 'Mayiliragu Mobile App',
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        final accessToken = responseData['accessToken'] as String;
        final refreshToken = responseData['refreshToken'] as String;
        final role = responseData['user']['role'] as String;

        await _storage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          role: role,
        );

        // Sync FCM token
        if (Get.isRegistered<NotificationService>()) {
          await Get.find<NotificationService>().syncToken();
        }

        // Check student profile completion status
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
            debugPrint('Error parsing profile completion on OTP verify: $e');
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
        errorMessage.value = response.data['message'] ?? 'Verification failed';
      }
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['message'] != null) {
          errorMessage.value = resData['message'].toString();
        } else {
          errorMessage.value = 'Invalid or expired verification code';
        }
      } else {
        errorMessage.value = 'An unexpected error occurred. Please try again.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (resendCountdown.value > 0 || isResending.value) return;

    isResending.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _authRepository.resendOtp(email: email.value);
      if (response.statusCode == 200) {
        successMessage.value = 'A new verification code has been sent to your email.';
        final resData = response.data;
        final otp = (resData is Map && resData['data'] is Map && resData['data']['otp'] != null)
            ? resData['data']['otp'].toString()
            : (resData is Map && resData['otp'] != null)
                ? resData['otp'].toString()
                : null;

        if (otp != null && otp.isNotEmpty) {
          AppToast.otp(otp, title: 'New OTP Code');
        } else {
          AppToast.success('New verification code sent.');
        }

        startCountdown(60);
      } else {
        errorMessage.value = response.data['message'] ?? 'Failed to resend code';
      }
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['code'] == 'OTP_RESEND_TOO_SOON') {
          final retryAfter = resData['retryAfter'] ?? 60;
          startCountdown(retryAfter);
          errorMessage.value = resData['message'] ?? 'Please wait before requesting another code.';
        } else if (resData is Map && resData['message'] != null) {
          errorMessage.value = resData['message'].toString();
        } else {
          errorMessage.value = 'Failed to resend code. Please try again.';
        }
      } else {
        errorMessage.value = 'Failed to resend code. Please try again.';
      }
    } finally {
      isResending.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

