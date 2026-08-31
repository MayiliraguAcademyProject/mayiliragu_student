import 'package:Mayiliragu/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/course_image.dart';
import '../controllers/course_controller.dart';
import 'course_detail_view.dart';

class CourseListView extends GetView<CourseController> {
  const CourseListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isDemoOnly.value ? 'Demo Classes' : 'My Courses',
          style: AppTextStyles.heading.copyWith(
            fontSize: 20,
            color: colorScheme.onSurface,
          ),
        )),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    Theme.of(context).scaffoldBackgroundColor,
                    colorScheme.surfaceContainerHighest,
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    AppColors.backgroundStart,
                    AppColors.secondary,
                    AppColors.backgroundEnd,
                  ],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value && controller.coursesList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (controller.errorMessage.value.isNotEmpty && controller.coursesList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  CommonButton(
                  text: 'Retry',
                  onPressed: controller.fetchCourses,
                  backgroundColor: AppColors.accent,
                  fullWidth: false,
                ),
                ],
              ),
            );
          }

          if (controller.coursesList.isEmpty) {
            return Center(
              child: Text(
                controller.isDemoOnly.value ? 'No demo classes available.' : 'No courses available.',
                style: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchCourses,
            color: AppColors.accent,
            child: ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.coursesList.length + (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.coursesList.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  );
                }

                final course = controller.coursesList[index];
                return _buildCourseCard(context, course);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, dynamic course) {
    final title = course['title'] ?? 'No Title';
    final thumbnail = course['thumbnail'] ?? '';
    final totalLessons = course['totalLessons'] ?? 0;
    final isDemo = course['isDemo'] as bool? ?? false;
    final availabilityStatus = course['availabilityStatus']?.toString();
    final timeRemainingText = course['timeRemainingText']?.toString();
    final isUpcoming = availabilityStatus == 'upcoming';
    final isClosingSoon = availabilityStatus == 'closing_soon';
    final isExpired = availabilityStatus == 'expired';
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.to(
            () => CourseDetailView(courseId: course['id']),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CourseImage(
                    imageUrl: thumbnail,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isDemo)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_fill, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'DEMO COURSE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Availability Status Overlay Badge
                if (isUpcoming || isClosingSoon || isExpired)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isUpcoming
                              ? [const Color(0xFF1E40AF), const Color(0xFF3B82F6)]
                              : isClosingSoon
                                  ? [const Color(0xFFB45309), const Color(0xFFF59E0B)]
                                  : [const Color(0xFF475569), const Color(0xFF64748B)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUpcoming
                                ? Icons.schedule_rounded
                                : isClosingSoon
                                    ? Icons.timer_outlined
                                    : Icons.lock_clock_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isUpcoming
                                ? (timeRemainingText != null ? 'UPCOMING • $timeRemainingText' : 'UPCOMING')
                                : isClosingSoon
                                    ? (timeRemainingText != null ? 'CLOSING SOON • $timeRemainingText' : 'CLOSING SOON')
                                    : 'EXPIRED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (course['completionPercentage'] != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (course['completionPercentage'] as num).toDouble() / 100,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(course['completionPercentage'] as num).toStringAsFixed(0)}% Completed',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.video_library, color: AppColors.accent, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '$totalLessons Lessons',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, Colors.blueAccent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'View Course',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
