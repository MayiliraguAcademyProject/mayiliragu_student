import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/course_image.dart';
import '../repositories/course_repository.dart';
import '../models/course_detail_model.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/course_detail_controller.dart';

class CourseDetailView extends StatelessWidget {
  final String courseId;

  const CourseDetailView({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    // Dynamically put the controller tagged with courseId
    final controller = Get.put(
      CourseDetailController(Get.find<CourseRepository>(), courseId),
      tag: courseId,
    );

    final theme = Theme.of(context);

    final gradientColors = [
      theme.colorScheme.surface,
      theme.colorScheme.surfaceContainerHighest,
    ];

    final textColorPrimary = theme.colorScheme.onSurface;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: theme.colorScheme.secondary),
            );
          }

          if (controller.errorMessage.isNotEmpty || controller.courseData.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.isNotEmpty 
                        ? controller.errorMessage.value 
                        : 'Course details not found.',
                    style: AppTextStyles.body.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.fetchCourseDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final course = controller.courseData.value!;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, course),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!course.isEnrolled) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: theme.colorScheme.secondary,
                                size: 28,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Course Access Restricted',
                                      style: AppTextStyles.heading.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'You are browsing in preview mode. Tap any lesson or button below to request full access.',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 12,
                                        color: textColorPrimary.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Text(
                        'About this Course',
                        style: AppTextStyles.subheading.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description.isNotEmpty ? course.description : 'No description provided.',
                        style: AppTextStyles.body.copyWith(
                          color: textColorPrimary.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Course Content',
                        style: AppTextStyles.subheading.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              _buildModulesList(context, course),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final course = controller.courseData.value;
        if (course == null || course.isEnrolled) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () => _showPurchaseDialog(context, course),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Request Access to Course',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, CourseDetailModel course) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      iconTheme: IconThemeData(
        color: theme.colorScheme.onSurface,
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          course.title,
          style: AppTextStyles.heading.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              const Shadow(
                offset: Offset(0, 1),
                blurRadius: 4,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CourseImage(
              imageUrl: course.thumbnail,
              fit: BoxFit.cover,
              placeholder: Icon(
                Icons.image,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              errorWidget: Icon(
                Icons.broken_image,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesList(BuildContext context, CourseDetailModel course) {
    final modules = course.modules;
    final theme = Theme.of(context);
    
    final textColorPrimary = theme.colorScheme.onSurface;
    final textColorSecondary = theme.colorScheme.onSurfaceVariant;
    final cardBackgroundColor = theme.colorScheme.surface;

    if (modules.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'No modules available.', 
            style: AppTextStyles.body.copyWith(color: textColorSecondary),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final module = modules[index];
        final lessons = module.lessons;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text(
              module.title.isNotEmpty ? module.title : 'Module ${index + 1}',
              style: AppTextStyles.heading.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColorPrimary,
              ),
            ),
            subtitle: Text(
              '${lessons.length} lessons',
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: textColorSecondary,
              ),
            ),
            iconColor: theme.colorScheme.secondary,
            collapsedIconColor: textColorSecondary,
            children: lessons
                .map<Widget>((lesson) => _buildLessonItem(context, lesson, course))
                .toList(),
          ),
        );
      }, childCount: modules.length),
    );
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0:00';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLessonItem(BuildContext context, LessonModel lesson, CourseDetailModel course) {
    final title = lesson.title.isNotEmpty ? lesson.title : 'Untitled Lesson';
    final description = lesson.description;
    final durationSeconds = lesson.duration;
    final durationMinutes = (durationSeconds / 60).toStringAsFixed(1);
    final watchedSeconds = lesson.progress?.watchedSeconds ?? 0;
    final isCompleted = lesson.progress?.completed == true;
    final isLocked = !course.isEnrolled || lesson.isLocked;
    final theme = Theme.of(context);
    
    final progressFraction = isCompleted
        ? 1.0
        : (durationSeconds > 0
            ? (watchedSeconds / durationSeconds).clamp(0.0, 1.0)
            : 0.0);
    final percentage = (progressFraction * 100).round();

    final textColorPrimary = theme.colorScheme.onSurface;
    final textColorSecondary = theme.colorScheme.onSurfaceVariant;

    final watchedFormatted = _formatDuration(watchedSeconds);
    final durationFormatted = _formatDuration(durationSeconds);

    String subtitleText;
    if (!course.isEnrolled) {
      subtitleText = '$durationMinutes min';
    } else if (isLocked) {
      subtitleText = '$durationMinutes min';
    } else if (isCompleted) {
      subtitleText = '$durationFormatted • Completed';
    } else if (watchedSeconds > 0) {
      subtitleText = '$watchedFormatted / $durationFormatted ($percentage%)';
    } else {
      subtitleText = '$durationFormatted min';
    }

    final VoidCallback onItemTap = !course.isEnrolled
        ? () => _showPurchaseDialog(context, course)
        : (isLocked
            ? () {
                Get.snackbar(
                  'Lesson Locked',
                  'Please watch and complete the previous lesson to unlock this video.',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  backgroundColor: Colors.grey.shade900,
                  colorText: Colors.white,
                  icon: const Icon(Icons.lock, color: Colors.amber),
                  duration: const Duration(seconds: 2),
                );
              }
            : () async {
                await Get.toNamed(Routes.LESSON_DETAIL, arguments: lesson.id);
                final controller = Get.find<CourseDetailController>(tag: courseId);
                controller.fetchCourseDetails();
              });

    return InkWell(
      onTap: onItemTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail Container matching reference UI
            Container(
              width: 135,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Image or fallback design
                  Positioned.fill(
                    child: (lesson.image != null && lesson.image!.isNotEmpty)
                        ? CourseImage(
                            imageUrl: lesson.image!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.surfaceContainerHighest,
                                  theme.colorScheme.surfaceContainerHigh,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_outline_rounded,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                size: 36,
                              ),
                            ),
                          ),
                  ),
                  if (isLocked)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                  // Duration / Watched Badge on Thumbnail (bottom-left)
                  Positioned(
                    left: 6,
                    bottom: (course.isEnrolled && !isLocked && progressFraction > 0) ? 8 : 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        watchedSeconds > 0
                            ? '$watchedFormatted / $durationFormatted'
                            : durationFormatted,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Bottom-Right Red Play Badge / Status Badge
                  // Positioned(
                  //   bottom: (course.isEnrolled && !isLocked && progressFraction > 0) ? 8 : 6,
                  //   right: 6,
                  //   child: Container(
                  //     width: 24,
                  //     height: 24,
                  //     decoration: BoxDecoration(
                  //       color: isCompleted
                  //           ? Colors.green
                  //           : (isLocked
                  //               ? Colors.black.withValues(alpha: 0.6)
                  //               : const Color(0xFFE50914)),
                  //       shape: BoxShape.circle,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withValues(alpha: 0.3),
                  //           blurRadius: 4,
                  //           offset: const Offset(0, 1),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Icon(
                  //       isCompleted
                  //           ? Icons.check_rounded
                  //           : (isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded),
                  //       color: Colors.white,
                  //       size: 14,
                  //     ),
                  //   ),
                  // ),
                
                
                  // Bottom Progress Bar inside Thumbnail
                  if (course.isEnrolled && !isLocked && progressFraction > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: progressFraction,
                        minHeight: 3.5,
                        backgroundColor: Colors.black38,
                        color: isCompleted ? Colors.green : const Color(0xFFE50914),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right Side Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: !course.isEnrolled
                                ? textColorPrimary
                                : (isLocked
                                    ? textColorSecondary.withValues(alpha: 0.7)
                                    : (isCompleted ? textColorSecondary : textColorPrimary)),
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            height: 1.25,
                          ),
                        ),
                      ),
                      // IconButton(
                      //   padding: const EdgeInsets.all(4),
                      //   constraints: const BoxConstraints(),
                      //   icon: Icon(
                      //     Icons.more_vert_rounded,
                      //     size: 18,
                      //     color: textColorSecondary,
                      //   ),
                      //   onPressed: () {
                      //     _showLessonOptionsBottomSheet(context, lesson, course);
                      //   },
                      // ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleText,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: textColorSecondary,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 11,
                        color: textColorSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  if (!course.isEnrolled) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 12,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Purchase required to play',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ] else if (isLocked) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 12,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Watch previous lesson to unlock',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (progressFraction > 0) ...[
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isCompleted ? 'Completed' : 'Watched',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: textColorSecondary,
                              ),
                            ),
                            Text(
                              '$watchedFormatted / $durationFormatted ($percentage%)',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isCompleted ? Colors.green : theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progressFraction,
                            minHeight: 4,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: isCompleted ? Colors.green : const Color(0xFFE50914),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showPurchaseDialog(BuildContext context, CourseDetailModel course) {
    final theme = Theme.of(context);
    final controller = Get.find<CourseDetailController>(tag: courseId);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_person_rounded,
                    color: theme.colorScheme.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchase Required',
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Request access to watch video lessons.',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Course: ${course.title}',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              course.description.isNotEmpty
                  ? course.description
                  : 'Get full access to all video lessons and learning materials in this course.',
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: controller.isRequesting.value
                          ? null
                          : () async {
                              final success = await controller.requestEnrollment();
                              if (success) {
                                Get.back();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isRequesting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Request Access'),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
