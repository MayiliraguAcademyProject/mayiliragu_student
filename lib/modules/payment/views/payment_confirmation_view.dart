import '../../../../shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PaymentConfirmationView extends StatelessWidget {
  const PaymentConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success illustration container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Receipt Submitted!',
                style: AppTextStyles.heading.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Your payment verification screenshot has been uploaded. An administrator will verify your payment details and activate your course/test access shortly.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Navigation button
              CommonButton(
                  text: 'Go to Home',
                  onPressed: () {
                    // Navigate back to Dashboard home
                    Get.offAllNamed(Routes.DASHBOARD);
                  },
                  height: 52,
                  backgroundColor: AppColors.primary,
                  borderRadius: 16,
                )
            ],
          ),
        ),
      ),
    );
  }
}
