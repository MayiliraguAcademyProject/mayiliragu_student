import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/models/testimonial_model.dart';
import '../../live_videos/views/live_video_player_view.dart';
import '../controllers/testimonials_controller.dart';
import 'shorts_video_player_view.dart';

class TestimonialsListView extends GetView<TestimonialsController> {
  const TestimonialsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundStartDark : AppColors.backgroundStart,
      appBar: AppBar(
        title: const Text(
          AppStrings.studentSuccessStories,
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

        final list = controller.testimonials;
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: isDark
                        ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noTestimonialsPosted,
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
            final testimonial = list[index];
            return _buildTestimonialCard(context, testimonial, isDark);
          },
        );
      }),
    );
  }

  Widget _buildTestimonialCard(
    BuildContext context,
    TestimonialModel testimonial,
    bool isDark,
  ) {
    final videoId = controller.getYoutubeVideoId(testimonial.videoUrl);
    final isShorts = testimonial.videoUrl.contains('/shorts/');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (videoId.isEmpty) {
            AppToast.validation(
              AppStrings.testimonialUrlParseError,
              title: AppStrings.unsupportedLink,
            );
            return;
          }

          if (isShorts) {
            Get.to(
              () => ShortsVideoPlayerView(
                videoId: videoId,
                title: testimonial.studentName,
                designation: testimonial.designation,
                description: testimonial.description,
              ),
            );
          } else {
            Get.to(
              () => LiveVideoPlayerView(
                videoId: videoId,
                title: testimonial.studentName,
                description: testimonial.description,
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Achievement
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (testimonial.avatarUrl != null &&
                      (testimonial.avatarUrl!.startsWith('http://') ||
                          testimonial.avatarUrl!.startsWith('https://')))
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: CachedNetworkImageProvider(testimonial.avatarUrl!),
                    )
                  else
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                      child: Icon(
                        Icons.person_outline,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testimonial.studentName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        if (testimonial.designation != null &&
                            testimonial.designation!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            testimonial.designation!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.accent : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Video Cover Image Stack
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (videoId.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: 'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? AppColors.borderDark : Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildThumbnailPlaceholder(isDark),
                    )
                  else
                    _buildThumbnailPlaceholder(isDark),

                  // Overlay Badge for Shorts
                  if (isShorts)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          AppStrings.shorts,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Play Button overlay
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Description Quote Box
            if (testimonial.description != null &&
                testimonial.description!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '"${testimonial.description}"',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.backgroundEndDark, AppColors.borderDark]
              : [AppColors.backgroundEnd, AppColors.border],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.video_library_rounded,
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
