import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../constants/app_colors.dart';

class GuestAuthGuard {
  GuestAuthGuard._();

  static void showForceLoginSheet({String? featureName}) {
    if (Get.isBottomSheetOpen == true) return;

    final context = Get.context;
    final theme = context != null ? Theme.of(context) : null;
    final surfaceColor = theme?.colorScheme.surface ?? Colors.white;
    final onSurfaceColor = theme?.colorScheme.onSurface ?? Colors.black87;
    final onSurfaceVariantColor = theme?.colorScheme.onSurfaceVariant ?? Colors.black54;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline, color: AppColors.brandPurple, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              featureName != null ? 'Access $featureName' : 'Sign in to Continue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurfaceColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Join Mayiliragu Academy to access video lectures, interactive tests, bookmarks, and complete study materials.',
              style: TextStyle(
                fontSize: 14,
                color: onSurfaceVariantColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(Routes.REGISTER);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Create Free Account', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(Routes.LOGIN);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandPurple,
                  side: const BorderSide(color: AppColors.brandPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Sign In to Existing Account', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}