import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/toast_helper.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top center branding
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.brandPurple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x335A00EC),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Mayiliragu LMS', style: AppTextStyles.heading),
                        const SizedBox(height: 8),
                        Text('Secure Sign In', style: AppTextStyles.subheading),
                        const SizedBox(height: 32),

                        // Email input label
                        const Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6E7191),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email field
                        TextField(
                          controller: controller.emailController,
                          style: const TextStyle(
                            color: Color(0xFF0F0F0F),
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'student@learning.com',
                            hintStyle: const TextStyle(
                              color: Color(0xFFB0B3C7),
                              fontSize: 15,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF9093A3),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FD),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFECEEF5),
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
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Password input label
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6E7191),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Password field
                        Obx(
                          () => TextField(
                            controller: controller.passwordController,
                            obscureText: controller.obscurePassword.value,
                            style: const TextStyle(
                              color: Color(0xFF0F0F0F),
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: const TextStyle(
                                color: Color(0xFFB0B3C7),
                                fontSize: 15,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF9093A3),
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF9093A3),
                                  size: 20,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8F9FD),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFECEEF5),
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

                        // Forgot Password button
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: TextButton(
                        //     onPressed: () {
                        //       AppToast.info(
                        //         'Please contact the administrator to reset your password.',
                        //         title: 'Forgot Password',
                        //       );
                        //     },
                        //     child: const Text(
                        //       'Forgot Password?',
                        //       style: TextStyle(
                        //         color: AppColors.brandPurple,
                        //         fontSize: 13,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 8),

                        // Error message
                        Obx(() {
                          if (controller.errorMessage.value.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Center(
                              child: Text(
                                controller.errorMessage.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: Obx(() {
                            return ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandPurple,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.brandPurple
                                    .withAlpha(153),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                                elevation: 0,
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Footer: New student register text
              ],
            ),
          ),
        ),
      ),
    );
  }
}
