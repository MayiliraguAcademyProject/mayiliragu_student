import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'error_handler.dart';

class AppToast {
  AppToast._();

  static void success(String message, {String title = 'Success'}) {
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 13),
      ),
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 28,
      ),
      backgroundColor: AppColors.accentDark,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(40),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void error(String message, {String title = 'Error'}) {
    final cleanMessage = AppErrorHandler.getErrorMessage(message);

    Get.rawSnackbar(
      titleText: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        cleanMessage,
        style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 13),
      ),
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
      backgroundColor: AppColors.error,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(40),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void validation(String message, {String title = 'Validation'}) {
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
      icon: const Icon(
        Icons.warning_amber_outlined,
        color: AppColors.primary,
        size: 28,
      ),
      backgroundColor: AppColors.backgroundEnd,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      borderColor: AppColors.border.withAlpha(80),
      borderWidth: 1,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void info(
    String message, {
    String title = 'Info',
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 13),
      ),
      icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
      backgroundColor: AppColors.primary,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: duration,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(40),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void otp(
    String otp, {
    String title = 'Verification Code',
    Duration duration = const Duration(seconds: 10),
  }) {
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        'Your code is: $otp',
        style: AppTextStyles.body.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 1.2,
        ),
      ),
      icon: const Icon(Icons.vpn_key_outlined, color: Colors.amberAccent, size: 28),
      backgroundColor: AppColors.accentDark,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: duration,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withAlpha(50),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

