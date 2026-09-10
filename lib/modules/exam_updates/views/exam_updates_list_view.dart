import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/exam_update_model.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../shared/widgets/image_viewer_screen.dart';
import '../../../shared/widgets/pdf_viewer_screen.dart';
import '../controllers/exam_updates_controller.dart';

class ExamUpdatesListView extends GetView<ExamUpdatesController> {
  const ExamUpdatesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundStartDark : AppColors.backgroundStart,
      appBar: AppBar(
        title: const Text(
          AppStrings.examUpdates,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.backgroundStartDark : AppColors.backgroundStart,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        final list = controller.examUpdates;
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noExamUpdates,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final update = list[index];
            return _buildUpdateCard(context, update, isDark);
          },
        );
      }),
    );
  }

  bool _isImage(String url) {
    final clean = url.toLowerCase().split('?').first;
    return clean.endsWith('.png') ||
        clean.endsWith('.jpg') ||
        clean.endsWith('.jpeg') ||
        clean.endsWith('.webp') ||
        clean.endsWith('.gif') ||
        clean.endsWith('.svg');
  }

  Widget _buildUpdateCard(
    BuildContext context,
    ExamUpdateModel update,
    bool isDark,
  ) {
    final isImg = _isImage(update.pdfUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openAttachment(update.pdfUrl, update.title),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon block
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isImg
                      ? Colors.teal.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isImg ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
                  color: isImg ? Colors.teal : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              
              // Text Content Block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            update.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isImg
                                ? Colors.teal.withValues(alpha: 0.1)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isImg ? 'IMAGE' : 'PDF',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isImg ? Colors.teal : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (update.description != null &&
                        update.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        update.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(update.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                            : AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAttachment(String url, String title) {
    if (url.trim().isEmpty) {
      AppToast.error('Attachment link is empty.');
      return;
    }

    if (_isImage(url)) {
      Get.to(
        () => ImageViewerScreen(
          imageUrl: url,
          title: title,
        ),
      );
    } else {
      Get.to(
        () => PdfViewerScreen(
          pdfUrl: url,
          title: title,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}

