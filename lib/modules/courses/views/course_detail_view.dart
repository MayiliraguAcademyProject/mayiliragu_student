import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/course_image.dart';
import '../../../shared/widgets/common_button.dart';
import '../repositories/course_repository.dart';
import '../../../core/utils/toast_helper.dart';
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
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            );
          }

          if (controller.errorMessage.isNotEmpty ||
              controller.courseData.value == null) {
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
                  CommonButton(
                    text: 'Retry',
                    onPressed: controller.fetchCourseDetails,
                    backgroundColor: theme.colorScheme.secondary,
                    fullWidth: false,
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
                      // Availability Schedule Banners
                      if (course.isUpcoming) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1E3A8A),
                                Color(0xFF2563EB),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.schedule_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Upcoming Course',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (course.timeRemainingText != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              course.timeRemainingText!,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course.startDate != null
                                          ? 'Scheduled release on ${course.startDate!.day}/${course.startDate!.month}/${course.startDate!.year} at ${course.startDate!.hour.toString().padLeft(2, '0')}:${course.startDate!.minute.toString().padLeft(2, '0')}. Video playback unlocks when the course begins.'
                                          : 'This course is launching soon! Curriculum is viewable below.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (course.isClosingSoon) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF92400E),
                                Color(0xFFD97706),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD97706).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.timer_outlined,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Closing Soon',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (course.timeRemainingText != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              course.timeRemainingText!,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Access to this course will close soon. Make sure to complete your lessons before the expiration date.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (course.isExpired) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_clock_rounded,
                                color: theme.colorScheme.error,
                                size: 28,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Course Expired',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'The scheduled access window for this course has ended.',
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

                      if (course.isDemo) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4CAF50).withValues(alpha: 0.15),
                                const Color(0xFF2E7D32).withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFF4CAF50,
                              ).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Free Demo Course',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'All lessons in this demo course are unlocked for free preview playback.',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 12,
                                        color: textColorPrimary.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (!course.isEnrolled && !course.isUpcoming) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.3,
                              ),
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
                                      'Enrollment Required',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Unlock full course access, video lessons, and materials.',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 12,
                                        color: textColorPrimary.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    _showPurchaseDialog(context, course),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  'Enroll',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Text(
                        'Course Overview',
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description.isNotEmpty
                            ? course.description
                            : 'No course description available.',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Curriculum Structure',
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColorPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildModulesList(context, course),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
      iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
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
      delegate: SliverChildBuilderDelegate((context, mIndex) {
        final module = modules[mIndex];
        final topics = module.topics;

        int moduleLessonsCount = 0;
        int moduleVideosCount = 0;
        for (var t in topics) {
          moduleLessonsCount += t.lessons.length;
          for (var l in t.lessons) {
            moduleVideosCount += l.videos.length;
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: mIndex == 0,
              shape: const Border(),
              collapsedShape: const Border(),
              leading: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'M${mIndex + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(
                module.title.isNotEmpty ? module.title : 'Module ${mIndex + 1}',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColorPrimary,
                ),
              ),
              subtitle: Text(
                '${topics.length} topics • $moduleLessonsCount lessons • $moduleVideosCount videos',
                style: AppTextStyles.body.copyWith(
                  fontSize: 11,
                  color: textColorSecondary,
                ),
              ),
              iconColor: theme.colorScheme.secondary,
              collapsedIconColor: textColorSecondary,
              children: topics.map<Widget>((topic) {
                return _buildTopicItem(context, topic, course);
              }).toList(),
            ),
          ),
        );
      }, childCount: modules.length),
    );
  }

  Widget _buildTopicItem(
    BuildContext context,
    TopicModel topic,
    CourseDetailModel course,
  ) {
    final theme = Theme.of(context);
    final textColorPrimary = theme.colorScheme.onSurface;
    final textColorSecondary = theme.colorScheme.onSurfaceVariant;
    final lessons = topic.lessons;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(
        //   color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        // ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Icon(
            Icons.folder_open_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            topic.title,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColorPrimary,
            ),
          ),
          subtitle: topic.description != null && topic.description!.isNotEmpty
              ? Text(
                  topic.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: textColorSecondary),
                )
              : Text(
                  '${lessons.length} lessons',
                  style: TextStyle(fontSize: 11, color: textColorSecondary),
                ),
          children: lessons
              .map<Widget>(
                (lesson) => _buildLessonItem(context, lesson, course),
              )
              .toList(),
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0:00';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLessonItem(
    BuildContext context,
    LessonModel lesson,
    CourseDetailModel course,
  ) {
    final title = lesson.title.isNotEmpty ? lesson.title : 'Untitled Lesson';
    final description = lesson.description;
    final durationSeconds = lesson.totalDuration;
    final durationMinutes = (durationSeconds / 60).toStringAsFixed(1);
    final watchedSeconds = lesson.progress?.watchedSeconds ?? 0;
    final isCompleted = lesson.isCompleted;
    final canPlayLesson = (course.isEnrolled || course.isDemo) && !course.isUpcoming;
    final isLocked = !canPlayLesson || (course.isEnrolled && lesson.isLocked);
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
    final videosCount = lesson.videos.length;
    final countLabel = '$videosCount ${videosCount == 1 ? 'video' : 'videos'}';

    if (!canPlayLesson) {
      subtitleText = '$countLabel • $durationMinutes min';
    } else if (isLocked) {
      subtitleText = '$countLabel • $durationMinutes min';
    } else if (isCompleted) {
      subtitleText = '$countLabel • $durationFormatted • Completed';
    } else if (watchedSeconds > 0) {
      subtitleText =
          '$countLabel • $watchedFormatted / $durationFormatted ($percentage%)';
    } else {
      subtitleText = '$countLabel • $durationFormatted';
    }

    final VoidCallback onItemTap = course.isUpcoming
        ? () {
            AppToast.validation(
              'This course is scheduled to start on ${course.startDate != null ? "${course.startDate!.day}/${course.startDate!.month}/${course.startDate!.year}" : "soon"}. Video playback will unlock once it starts.',
              title: 'Upcoming Course',
            );
          }
        : (!canPlayLesson
            ? () => _showPurchaseDialog(context, course)
            : (isLocked
                ? () {
                    AppToast.validation(
                      'Please watch and complete the previous lesson video to unlock.',
                      title: 'Lesson Locked',
                    );
                  }
                : () async {
                    await Get.toNamed(Routes.LESSON_DETAIL, arguments: lesson.id);
                    final controller = Get.find<CourseDetailController>(
                      tag: courseId,
                    );
                    controller.fetchCourseDetails();
                  }));

    return InkWell(
      onTap: onItemTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail Container
            Container(
              width: 120,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4),
                                size: 32,
                              ),
                            ),
                          ),
                  ),
                  if (isLocked)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  // Duration / Watched Badge
                  Positioned(
                    left: 6,
                    bottom:
                        (course.isEnrolled && !isLocked && progressFraction > 0)
                        ? 8
                        : 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
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
                        color: isCompleted
                            ? Colors.green
                            : const Color(0xFFE50914),
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
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: !course.isEnrolled
                          ? textColorPrimary
                          : (isLocked
                                ? textColorSecondary.withValues(alpha: 0.7)
                                : (isCompleted
                                      ? textColorSecondary
                                      : textColorPrimary)),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitleText,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 11,
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
                  if (!canPlayLesson) ...[
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
                            'Watch previous lesson video to unlock',
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
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
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
                    onPressed: () => Navigator.pop(context),
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
                    return CommonButton(
                      text: 'Request Access',
                      isLoading: controller.isRequesting.value,
                      onPressed: () async {
                        final success = await controller.requestEnrollment();
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          controller.fetchCourseDetails();
                        }
                      },
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
