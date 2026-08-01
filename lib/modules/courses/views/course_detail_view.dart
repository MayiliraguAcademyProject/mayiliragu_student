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
                .map<Widget>((lesson) => _buildLessonItem(context, lesson))
                .toList(),
          ),
        );
      }, childCount: modules.length),
    );
  }

  Widget _buildLessonItem(BuildContext context, LessonModel lesson) {
    final title = lesson.title.isNotEmpty ? lesson.title : 'Untitled Lesson';
    final description = lesson.description;
    final durationSeconds = lesson.duration;
    final durationMinutes = (durationSeconds / 60).toStringAsFixed(1);
    final watchedSeconds = lesson.progress?.watchedSeconds ?? 0;
    final isCompleted = lesson.progress?.completed == true;
    final isLocked = lesson.isLocked;
    final theme = Theme.of(context);
    
    final progressFraction = isCompleted
        ? 1.0
        : (durationSeconds > 0
            ? (watchedSeconds / durationSeconds).clamp(0.0, 1.0)
            : 0.0);
    final percentage = (progressFraction * 100).round();

    final textColorPrimary = theme.colorScheme.onSurface;
    final textColorSecondary = theme.colorScheme.onSurfaceVariant;

    Widget leadingIcon;
    if (isLocked) {
      leadingIcon = Icon(
        Icons.lock_outline_rounded,
        color: Colors.grey.shade400,
        size: 22,
      );
    } else if (isCompleted) {
      leadingIcon = const Icon(
        Icons.check_circle_rounded,
        color: Colors.green,
        size: 22,
      );
    } else if (progressFraction > 0) {
      leadingIcon = SizedBox(
        width: 26,
        height: 26,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progressFraction,
              strokeWidth: 2.5,
              color: theme.colorScheme.secondary,
              backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
            ),
            Icon(
              Icons.play_arrow_rounded,
              color: theme.colorScheme.secondary,
              size: 16,
            ),
          ],
        ),
      );
    } else {
      leadingIcon = Icon(
        Icons.play_circle_fill_rounded,
        color: theme.colorScheme.secondary,
        size: 24,
      );
    }

    String trailingText;
    if (isLocked) {
      trailingText = '$durationMinutes min';
    } else if (isCompleted) {
      trailingText = '$durationMinutes min';
    } else if (watchedSeconds > 0) {
      final watchedMin = (watchedSeconds / 60).toStringAsFixed(1);
      trailingText = '$watchedMin / $durationMinutes min ($percentage%)';
    } else {
      trailingText = '$durationMinutes min';
    }

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          leading: leadingIcon,
          title: Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: isLocked ? FontWeight.normal : FontWeight.w600,
              color: isLocked
                  ? textColorSecondary.withValues(alpha: 0.6)
                  : (isCompleted ? textColorSecondary : textColorPrimary),
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: isLocked
                        ? textColorSecondary.withValues(alpha: 0.5)
                        : textColorSecondary,
                  ),
                ),
              ],
              if (isLocked) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Watch previous lesson to unlock',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: Text(
            trailingText,
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              fontWeight: progressFraction > 0 && !isCompleted ? FontWeight.w600 : FontWeight.normal,
              color: isLocked ? textColorSecondary.withValues(alpha: 0.5) : textColorSecondary,
            ),
          ),
          onTap: isLocked
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
                  // Refresh details after returning from lesson detail using the tagged controller instance
                  final controller = Get.find<CourseDetailController>(tag: courseId);
                  controller.fetchCourseDetails();
                },
        ),
        if (!isLocked && progressFraction > 0)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 6.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progressFraction,
                minHeight: 3.5,
                backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                color: isCompleted ? Colors.green : theme.colorScheme.secondary,
              ),
            ),
          ),
      ],
    );
  }
}
