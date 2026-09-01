import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../../app/routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  RegisterController(this._authRepository);

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty) {
      errorMessage.value = 'Please enter your full name';
      return;
    }

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }

    if (mobile.isNotEmpty && (mobile.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile))) {
      errorMessage.value = 'Mobile number must be a 10-digit number';
      return;
    }

    if (password.length < 8) {
      errorMessage.value = 'Password must be at least 8 characters long';
      return;
    }

    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        mobileNumber: mobile.isNotEmpty ? mobile : null,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final resData = response.data;
        final otp = (resData is Map && resData['data'] is Map && resData['data']['otp'] != null)
            ? resData['data']['otp'].toString()
            : (resData is Map && resData['otp'] != null)
                ? resData['otp'].toString()
                : null;

        // Navigate to OTP verification screen
        Get.toNamed(
          Routes.OTP_VERIFICATION,
          arguments: {
            'email': email,
            'name': name,
            'otp': otp,
          },
        );

        if (otp != null && otp.isNotEmpty) {
          AppToast.otp(otp, title: 'Your OTP Code');
        }
      } else {
        errorMessage.value = response.data['message'] ?? 'Registration failed. Please try again.';
      }
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['code'] == 'EMAIL_ALREADY_EXISTS') {
          errorMessage.value = 'An account with this email already exists. Please log in.';
        } else {
          errorMessage.value = AppErrorHandler.getErrorMessage(
            e,
            defaultMessage: 'Registration failed. Please check your details and try again.',
          );
        }
      } else {
        errorMessage.value = AppErrorHandler.getErrorMessage(
          e,
          defaultMessage: 'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

