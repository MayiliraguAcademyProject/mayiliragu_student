import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = isDark
        ? [
            AppColors.backgroundStartDark,
            AppColors.accentDark,
            AppColors.backgroundEndDark,
          ]
        : [
            AppColors.backgroundStart,
            AppColors.secondary,
            AppColors.backgroundEnd,
          ];

    final textColorPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textColorSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

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
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
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
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.fetchCourseDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
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
                          color: textColorPrimary.withOpacity(0.85),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: isDark ? AppColors.backgroundStartDark : AppColors.backgroundStart,
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : AppColors.textPrimary,
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
              placeholder: const Icon(
                Icons.image,
                size: 80,
                color: AppColors.textSecondary,
              ),
              errorWidget: const Icon(
                Icons.broken_image,
                size: 80,
                color: AppColors.textSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final textColorPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textColorSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final cardBackgroundColor = isDark ? AppColors.cardBgDark : AppColors.cardBg;

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
            iconColor: AppColors.accent,
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
    final durationSeconds = lesson.duration;
    final durationMinutes = (durationSeconds / 60).toStringAsFixed(1);
    final isCompleted = lesson.progress?.completed == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final textColorPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textColorSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return ListTile(
      leading: Icon(
        isCompleted ? Icons.check_circle : Icons.play_circle_outline,
        color: isCompleted ? Colors.green : AppColors.accent,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          fontSize: 14,
          color: isCompleted ? textColorSecondary : textColorPrimary,
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Text(
        '$durationMinutes min',
        style: AppTextStyles.body.copyWith(
          fontSize: 12,
          color: textColorSecondary,
        ),
      ),
      onTap: () async {
        await Get.toNamed(Routes.LESSON_DETAIL, arguments: lesson.id);
        // Refresh details after returning from lesson detail using the tagged controller instance
        final controller = Get.find<CourseDetailController>(tag: courseId);
        controller.fetchCourseDetails();
      },
    );
  }
}
