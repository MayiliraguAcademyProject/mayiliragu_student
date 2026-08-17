import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../../app/routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository;

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final email = ''.obs;
  final resetToken = ''.obs;

  final isLoading = false.obs;
  final isResending = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final resendCountdown = 60.obs;

  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  Timer? _timer;

  ForgotPasswordController(this._authRepository);

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
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

  Future<void> sendOtp() async {
    final inputEmail = emailController.text.trim();
    if (inputEmail.isEmpty) {
      errorMessage.value = 'Please enter your registered email address.';
      return;
    }

    if (!GetUtils.isEmail(inputEmail)) {
      errorMessage.value = 'Please enter a valid email address.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _authRepository.forgotPassword(email: inputEmail);
      if (response.statusCode == 200) {
        email.value = inputEmail;
        otpController.clear();
        startCountdown(60);
        AppToast.success('Verification code sent to your email.');
        Get.toNamed(Routes.FORGOT_PASSWORD_OTP);
      } else {
        errorMessage.value = response.data['message'] ?? 'Failed to send verification code.';
      }
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['code'] == 'OTP_RESEND_TOO_SOON') {
          email.value = inputEmail;
          final retryAfter = resData['retryAfter'] ?? 60;
          startCountdown(retryAfter);
          Get.toNamed(Routes.FORGOT_PASSWORD_OTP);
          return;
        }
        if (resData is Map && resData['message'] != null) {
          errorMessage.value = resData['message'].toString();
        } else {
          errorMessage.value = 'No account found with this email address.';
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

    if (email.value.isEmpty) {
      errorMessage.value = 'Email address is missing. Please start again.';
      return;
    }

    isResending.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _authRepository.forgotPasswordResendOtp(email: email.value);
      if (response.statusCode == 200) {
        successMessage.value = 'A new verification code has been sent to your email.';
        AppToast.success('New verification code sent.');
        startCountdown(60);
      } else {
        errorMessage.value = response.data['message'] ?? 'Failed to resend verification code.';
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

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length != 6) {
      errorMessage.value = 'Please enter the 6-digit verification code.';
      return;
    }

    if (email.value.isEmpty) {
      errorMessage.value = 'Email address is missing. Please start again.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _authRepository.forgotPasswordVerifyOtp(
        email: email.value,
        otp: otp,
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        resetToken.value = responseData['resetToken'] as String;
        _timer?.cancel();
        newPasswordController.clear();
        confirmPasswordController.clear();
        AppToast.success('Code verified successfully.');
        Get.toNamed(Routes.RESET_PASSWORD);
      } else {
        errorMessage.value = response.data['message'] ?? 'Verification failed.';
      }
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['message'] != null) {
          errorMessage.value = resData['message'].toString();
        } else {
          errorMessage.value = 'Invalid or expired verification code.';
        }
      } else {
        errorMessage.value = 'An unexpected error occurred. Please try again.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      errorMessage.value = 'Please fill in both password fields.';
      return;
    }

    if (newPassword.length < 8) {
      errorMessage.value = 'Password must be at least 8 characters long.';
      return;
    }

    if (newPassword != confirmPassword) {
      errorMessage.value = 'Passwords do not match.';
      return;
    }

    if (resetToken.value.isEmpty) {
      errorMessage.value = 'Reset session has expired. Please start recovery again.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _authRepository.resetPassword(
        resetToken: resetToken.value,
        newPassword: newPassword,
      );

      if (response.statusCode == 200) {
        AppToast.success('Password updated successfully! Please log in.');
        
        // Navigate back to Login and pre-populate email
        final savedEmail = email.value;
        cleanUp();
        Get.offAllNamed(
          Routes.LOGIN,
          arguments: {'email': savedEmail},
        );
      } else {
        errorMessage.value = response.data['message'] ?? 'Failed to reset password.';
      }
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['message'] != null) {
          errorMessage.value = resData['message'].toString();
        } else {
          errorMessage.value = 'Failed to reset password. Please try again.';
        }
      } else {
        errorMessage.value = 'An unexpected error occurred. Please try again.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void cleanUp() {
    _timer?.cancel();
    emailController.clear();
    otpController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    email.value = '';
    resetToken.value = '';
    errorMessage.value = '';
    successMessage.value = '';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

