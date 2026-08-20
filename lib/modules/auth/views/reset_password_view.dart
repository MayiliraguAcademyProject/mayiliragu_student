import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/common_button.dart';
import '../controllers/forgot_password_controller.dart';

class ResetPasswordView extends GetView<ForgotPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.brandPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.vpn_key_rounded,
                      color: AppColors.brandPurple,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Set New Password',
                            style: AppTextStyles.heading.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a strong password of at least 8 characters for your student account.',
                            style: AppTextStyles.subheading.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // New Password label
                          Text(
                            'New Password',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // New Password field
                          Obx(
                            () => TextField(
                              key: const ValueKey('reset_new_password_field'),
                              controller: controller.newPasswordController,
                              obscureText: controller.obscureNewPassword.value,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  fontSize: 15,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.obscureNewPassword.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  onPressed: controller.toggleNewPasswordVisibility,
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceContainerHighest,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.brandPurple,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password label
                          Text(
                            'Confirm New Password',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Confirm Password field
                          Obx(
                            () => TextField(
                              key: const ValueKey('reset_confirm_password_field'),
                              controller: controller.confirmPasswordController,
                              obscureText: controller.obscureConfirmPassword.value,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  fontSize: 15,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_reset,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.obscureConfirmPassword.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  onPressed: controller.toggleConfirmPasswordVisibility,
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceContainerHighest,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.brandPurple,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Error Message Banner
                          Obx(() {
                            if (controller.errorMessage.value.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        controller.errorMessage.value,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Reset Password Button
                          Obx(() {
                            return CommonButton(
                              text: 'Reset Password',
                              isLoading: controller.isLoading.value,
                              onPressed: controller.resetPassword,
                              backgroundColor: AppColors.brandPurple,
                              foregroundColor: Colors.white,
                              height: 52,
                              borderRadius: 26,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
