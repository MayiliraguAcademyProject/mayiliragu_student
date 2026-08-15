import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/common_button.dart';
import '../../../../core/utils/toast_helper.dart';
import '../../dashboard/models/dashboard_model.dart';
import '../controllers/payment_controller.dart';

class PaymentQrView extends StatelessWidget {
  const PaymentQrView({super.key});

  @override
  Widget build(BuildContext context) {
    final banner = Get.arguments as BannerModel;
    final controller = Get.find<PaymentController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete QR Payment'),
        centerTitle: true,
      ),
      body: Obx(() {
        final settings = controller.paymentSettings.value;
        final isSettingsLoading = controller.isLoadingSettings.value;

        if (isSettingsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (settings == null || settings.qrImageUrl.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment QR Code Not Configured',
                    style: AppTextStyles.heading.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The administrator has not configured a UPI payment QR code yet. Please contact support to proceed with your enrollment.',
                    style: AppTextStyles.body.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        bool isOfferActive = false;
        final offerPrice = banner.offerPrice;
        final offerValidUntil = banner.offerValidUntil;
        if (offerPrice != null) {
          if (offerValidUntil == null) {
            isOfferActive = true;
          } else {
            isOfferActive = offerValidUntil.isAfter(DateTime.now());
          }
        }
        final payableAmount = isOfferActive ? offerPrice! : (banner.price ?? 0.0);
        final selectedImg = controller.selectedImagePath.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payable Details Card
              Card(
                elevation: 0,
                color: isDark ? Colors.grey[900] : const Color(0xFFFFF7EF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount to Pay:',
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${payableAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        'Product: ${banner.title}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // QR Display Area
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Scan UPI QR to Pay',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomNetworkImage(
                          imageUrl: settings.qrImageUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorWidget: const SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Custom Admin Instructions
              if (settings.instructions.isNotEmpty) ...[
                const Text(
                  'Instructions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Text(
                    settings.instructions,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Screenshot Picker Section
              const Text(
                'Upload Payment Receipt Screenshot',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),

              if (selectedImg == null)
                InkWell(
                  onTap: () => controller.selectScreenshot(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white30 : Colors.grey.shade300,
                        width: 1.5,
                        style: BorderStyle.values[1], // dashed/dotted
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Select payment screenshot',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: FileImage(File(selectedImg)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.white),
                          onPressed: () {
                            controller.selectedImagePath.value = null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              CommonButton(
                text: 'Upload & Submit Proof',
                isLoading: controller.isSubmitting.value,
                onPressed: () async {
                  if (selectedImg == null) {
                    AppToast.error('Please select a payment screenshot first');
                    return;
                  }
                  if (banner.linkType == null || banner.linkId == null) {
                    AppToast.error('Invalid product configuration. Please contact support.');
                    return;
                  }
                  final success = await controller.submitPayment(
                    linkType: banner.linkType!,
                    linkId: banner.linkId!,
                    amount: payableAmount,
                  );
                  if (success) {
                    Get.offNamed(Routes.PAYMENT_CONFIRMATION);
                  }
                },
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                height: 52,
                borderRadius: 16,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}
