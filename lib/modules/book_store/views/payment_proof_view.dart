import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/toast_helper.dart';
import '../controllers/book_store_controller.dart';
import '../models/book_model.dart';
import '../../../../shared/widgets/custom_network_image.dart';

class PaymentProofView extends StatefulWidget {
  final BookOrderModel order;

  const PaymentProofView({super.key, required this.order});

  @override
  State<PaymentProofView> createState() => _PaymentProofViewState();
}

class _PaymentProofViewState extends State<PaymentProofView> {
  final controller = Get.find<BookStoreController>();
  String? _selectedImagePath;
  bool _isUploading = false;
  bool _isSuccess = false;

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImagePath = result.files.single.path;
        });
      }
    } catch (e) {
      AppToast.error('Failed to pick screenshot image: $e');
    }
  }

  Future<void> _uploadProof() async {
    if (_selectedImagePath == null) {
      AppToast.error('Please select a payment screenshot first');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final success = await controller.uploadPaymentScreenshot(
      widget.order.id,
      _selectedImagePath!,
    );

    setState(() {
      _isUploading = false;
    });

    if (success) {
      AppToast.success('Payment screenshot uploaded successfully!');
      setState(() {
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isSuccess) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Order Confirmed!',
                  style: AppTextStyles.heading.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your payment screenshot has been uploaded. Admin will verify your payment and update the status shortly.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to Bookstore dashboard
                      Get.back();
                      Get.back();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Back to Bookstore',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete QR Payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order details summary card
            Card(
              elevation: 0,
              color: isDark ? Colors.grey[900]! : const Color(0xFFF9F9FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.colorScheme.outline.withAlpha(40)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Payable Amount:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${widget.order.payableAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brandPurple,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Order ID: ${widget.order.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // QR Code Scan Box
            Center(
              child: Column(
                children: [
                  const Text(
                    'Scan QR to Pay via UPI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final qrUrl = controller.paymentQrUrl.value;
                    if (qrUrl.isEmpty) {
                      return Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'No payment QR set\nby Admin yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomNetworkImage(
                          imageUrl: qrUrl,
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
                    );
                  }),
                  const SizedBox(height: 16),
                  Text(
                    'Please make the payment of ₹${widget.order.payableAmount.toStringAsFixed(2)} then upload the payment receipt below.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Screenshot upload section
            const Text(
              'Upload Payment Screenshot',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),

            if (_selectedImagePath == null)
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? Colors.white30 : Colors.grey.shade300,
                      width: 1.5,
                      style: BorderStyle.values[1], // dashed
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
                        image: FileImage(File(_selectedImagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withAlpha(150),
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _selectedImagePath = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 36),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_selectedImagePath == null || _isUploading) ? null : _uploadProof,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Upload & Complete Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
