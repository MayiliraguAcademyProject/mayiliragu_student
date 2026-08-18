import 'package:Mayiliragu/shared/widgets/common_button.dart';
import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:Mayiliragu/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
// import '../../../core/widgets/course_image.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_model.dart';
import '../../courses/views/course_detail_view.dart';
import '../../tests/controllers/tests_controller.dart';
import '../../../shared/widgets/custom_network_image.dart';
import '../../../core/utils/toast_helper.dart';

class DashboardHomeView extends GetView<DashboardController> {
  const DashboardHomeView({super.key});

  static const List<List<Color>> _quickActionGradients = [
    [Color(0xFFF97316), Color(0xFFEA580C)], // Orange
    [Color(0xFF22C55E), Color(0xFF16A34A)], // Green
    [Color(0xFF3B82F6), Color(0xFF2563EB)], // Blue
    [Color(0xFF8B5CF6), Color(0xFF7C3AED)], // Purple
    [Color(0xFFEC4899), Color(0xFFDB2777)], // Pink
    [Color(0xFF14B8A6), Color(0xFF0D9488)], // Teal
    [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
    [Color(0xFF06B6D4), Color(0xFF0891B2)], // Sky-Blue
    [Color(0xFF6366F1), Color(0xFF4F46E5)], // Deep-Purple
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CommonButton(
                    text: AppStrings.retry,
                    onPressed: controller.fetchDashboardData,
                    backgroundColor: AppColors.brandPurple,
                    fullWidth: false,
                  ),
                ],
              ),
            );
          }

          final data = controller.dashboardData.value;
          final userName = data?.profile?.name ?? 'Student';

          return RefreshIndicator(
            onRefresh: controller.fetchDashboardData,
            color: AppColors.brandPurple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header (Greeting & Notification)
                  _buildHeader(context, userName),
                  const SizedBox(height: 24),

                  // Banners Carousel
                  if (data?.banners != null && data!.banners.isNotEmpty) ...[
                    BannerCarousel(banners: data.banners),
                    const SizedBox(height: 24),
                  ],

                  // 2. Quick Actions Section
                  _buildSectionTitle(context, AppStrings.quickActions),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  /*
                  // 3. Courses Section
                  if (data?.allCourses != null &&
                      data!.allCourses.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle(context, 'Explore Courses'),
                        TextButton(
                          onPressed: () {
                            Get.toNamed(Routes.COURSES);
                          },
                          child: const Text(
                            AppStrings.viewAll,
                            style: TextStyle(
                              color: AppColors.brandPurple,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildEnrolledCoursesList(data.allCourses),
                    const SizedBox(height: 24),
                  ],
                  */

                  // 4. Continue Learning Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(context, AppStrings.continueLearning),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(Routes.COURSES);
                        },
                        child: const Text(
                          AppStrings.viewAll,
                          style: TextStyle(
                            color: AppColors.brandPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildContinueLearning(data?.continueLearning),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return AppStrings.goodMorning;
    } else if (hour < 17) {
      return AppStrings.goodAfternoon;
    } else {
      return AppStrings.goodEvening;
    }
  }

  // Header UI Component
  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_getGreeting()}$name 👋',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Obx(() {
          final notifyService = Get.find<NotificationService>();
          final count = notifyService.unreadCount.value;
          return Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 18,
                ),
                onPressed: () {
                  Get.toNamed(Routes.NOTIFICATIONS);
                },
              ),
              if (count > 0)
                Positioned(
                  right: 14,
                  top: 12,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                      // child:
                      //  Center(
                      //   child: Text(
                      //     '$count',
                      //     style: const TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 9,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  // Section Header Text Helper
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  // Quick Actions Section
  Widget _buildQuickActions() {
    return Obx(() {
      final actions = controller.dashboardData.value?.quickActions ?? [];
      if (actions.isEmpty) {
        return const SizedBox.shrink();
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return _buildGradientActionTile(
            index,
            action.icon,
            action.title,
            () {
              String targetRoute = action.route;
              if (targetRoute == '/quiz') {
                targetRoute = Routes.CURRENT_AFFAIRS;
              }

              if (targetRoute == '/tests') {
                controller.tabController.jumpToTab(1);
                if (Get.isRegistered<TestsController>()) {
                  Get.find<TestsController>().fetchTests();
                }
              } else if (targetRoute == '/demo-courses' ||
                  targetRoute == '/demo-class') {
                final demoCourses =
                    controller.dashboardData.value?.allCourses
                        .where((c) => c.isDemo)
                        .toList() ??
                    [];

                if (demoCourses.length == 1) {
                  Get.to(
                    () => CourseDetailView(courseId: demoCourses.first.id),
                  );
                } else {
                  Get.toNamed(Routes.COURSES, arguments: {'isDemoOnly': true});
                }
              } else {
                final isRegisteredRoute = AppPages.routes.any(
                  (page) => page.name == targetRoute,
                );
                if (isRegisteredRoute) {
                  Get.toNamed(targetRoute);
                } else {
                  AppToast.validation(
                    'The feature "${action.title}" is currently unavailable.',
                    title: 'Notice',
                  );
                }
              }
            },
          );
        },
      );
    });
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'video':
      case 'ondemand_video':
      case 'online videos':
      case 'online_videos':
        return Icons.ondemand_video;
      case 'bookopen':
      case 'menu_book':
      case 'study materials':
      case 'study_materials':
        return Icons.menu_book;
      case 'award':
      case 'quiz':
      case 'tests':
      case 'assignment_turned_in':
        return Icons.assignment_turned_in;
      case 'filetext':
      case 'newspaper':
      case 'current affairs':
      case 'current_affairs':
        return Icons.newspaper;
      case 'co_present':
      case 'live classes':
      case 'live_classes':
        return Icons.co_present;
      case 'shopping_cart':
      case 'book store':
      case 'book_store':
      case 'shopping_bag_outlined':
        return Icons.shopping_cart;
      case 'bookmark':
      case 'book mark':
      case 'book_mark':
        return Icons.bookmark;
      case 'notifications':
      case 'exam updates':
      case 'exam_updates':
        return Icons.notifications;
      case 'groups':
      case 'demo classes':
      case 'demo_classes':
      case 'play_circle_outline':
      case 'demo-class':
      case 'demo-courses':
        return Icons.groups;
      default:
        return Icons.link;
    }
  }

  Widget _buildIconWidget(String iconString) {
    final trimmed = iconString.trim();
    final isNetworkImage = trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.contains('/');

    if (isNetworkImage) {
      return CustomNetworkImage(
        imageUrl: trimmed,
        width: 30,
        height: 30,
        fit: BoxFit.contain,
        errorWidget: const Icon(
          Icons.link,
          color: Colors.white,
          size: 30,
        ),
      );
    } else {
      return Icon(
        _getIconData(trimmed),
        color: Colors.white,
        size: 30,
      );
    }
  }

  Widget _buildGradientActionTile(
    int index,
    String iconString,
    String title,
    VoidCallback onTap,
  ) {
    final gradientColors =
        _quickActionGradients[index % _quickActionGradients.length];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[1].withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconWidget(iconString),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Circle Number Badge
          // Positioned(
          //   top: 6,
          //   left: 6,
          //   child: Container(
          //     width: 18,
          //      height: 18,
          //     decoration: BoxDecoration(
          //       color: Colors.white.withValues(alpha: 0.25),
          //       shape: BoxShape.circle,
          //     ),
          //     child: Center(
          //       child: Text(
          //         '${index + 1}',
          //         style: const TextStyle(
          //           color: Colors.white,
          //           fontSize: 10,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  /*
  Widget _buildEnrolledCoursesList(List<EnrolledCourse> courses) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline, width: 1),
                ),
                child: InkWell(
                  onTap: () {
                    Get.to(() => CourseDetailView(courseId: course.id));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            color: AppColors.lightLavender,
                            image: course.thumbnail.isNotEmpty
                                ? DecorationImage(
                                    image: CourseImage.getProvider(
                                      course.thumbnail,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: course.thumbnail.isEmpty
                              ? const Center(
                                  child: Icon(
                                    Icons.book,
                                    color: AppColors.brandPurple,
                                    size: 32,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!course.isEnrolled) ...[
                              const SizedBox(height: 6),
                              if (course.enrollmentRequestStatus == 'PENDING')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.hourglass_empty_rounded, size: 12, color: Colors.amber.shade900),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Request Pending',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandPurple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shopping_bag_outlined, size: 12, color: AppColors.brandPurple),
                                      SizedBox(width: 4),
                                      Text(
                                        'Purchase Course',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.brandPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ] else ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${course.totalLessons} Lessons',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '${course.progressPercentage.toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brandPurple,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: course.progressPercentage / 100,
                                  backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.brandPurple,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }
  */

  // Continue Learning Section
  Widget _buildContinueLearning(ContinueLearning? contLearn) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        if (contLearn == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Center(
              child: Text(
                AppStrings.startLearningPrompt,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        final progress = contLearn.progress;
        final percentage = contLearn.progressPercentage;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: colorScheme.outline, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Graphic header area
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.architecture_outlined,
                          size: 150,
                          color: AppColors.brandPurple.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            contLearn.lessonTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress & action details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.overallProgress,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.brandPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: colorScheme.outline.withValues(
                          alpha: 0.2,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.brandPurple,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CommonButton(
                      text: AppStrings.resumeLesson,
                      onPressed: () {
                        Get.toNamed(
                          Routes.LESSON_DETAIL,
                          arguments: contLearn.lessonId,
                        );
                      },
                      height: 48,
                      backgroundColor: AppColors.brandPurple,
                      foregroundColor: Colors.white,
                      borderRadius: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || widget.banners.isEmpty) return;
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 16 / 14,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return GestureDetector(
                onTap: () async {
                  if (banner.linkType == 'COURSE' ||
                      banner.linkType == 'TEST') {
                    Get.toNamed(
                      Routes.BANNER_PRODUCT_DETAIL,
                      arguments: banner,
                    );
                  } else if (banner.linkUrl != null &&
                      banner.linkUrl!.trim().isNotEmpty) {
                    final link = banner.linkUrl!.trim();
                    final lower = link.toLowerCase();
                    if (lower == 'courses' || lower == '/courses') {
                      if (Get.isRegistered<DashboardController>()) {
                        Get.find<DashboardController>().tabController.jumpToTab(2);
                      }
                    } else if (lower == 'tests' || lower == '/tests') {
                      if (Get.isRegistered<DashboardController>()) {
                        Get.find<DashboardController>().tabController.jumpToTab(1);
                      }
                    } else if (lower == 'books' || lower == '/books' || lower == 'book-store') {
                      Get.toNamed(Routes.BOOK_STORE);
                    } else if (lower == 'current-affairs' || lower == '/current-affairs') {
                      Get.toNamed(Routes.CURRENT_AFFAIRS);
                    } else if (lower == 'study-materials' || lower == '/study-materials') {
                      Get.toNamed(Routes.STUDY_MATERIALS);
                    } else if (lower.startsWith('http://') || lower.startsWith('https://')) {
                      final uri = Uri.tryParse(link);
                      if (uri != null) {
                        try {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (_) {}
                      }
                    } else {
                      Get.to(() => CourseDetailView(courseId: link));
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        banner.imageUrl.startsWith('data:image')
                            ? Image.memory(
                                base64Decode(banner.imageUrl.split(',').last),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFE1BEE7),
                                          Color(0xFFCE93D8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : CustomNetworkImage(
                                imageUrl: banner.imageUrl,
                                fit: BoxFit.fill,
                                errorWidget: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFE1BEE7),
                                        Color(0xFFCE93D8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                        // Dark Gradient Overlay for title readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.2),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),

                        // Text Title
                        Positioned(
                          left: 16,
                          bottom: 16,
                          right: 16,
                          child: Text(
                            banner.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Page Indicators
          if (widget.banners.length > 1)
            Positioned(
              bottom: 12,
              right: 24,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.banners.length,
                  (index) => Container(
                    width: _currentPage == index ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
