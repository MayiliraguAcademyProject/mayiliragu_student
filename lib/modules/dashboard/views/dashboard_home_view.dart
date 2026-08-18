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
import '../../courses/controllers/course_controller.dart';
import '../../tests/controllers/tests_controller.dart';
import '../../../shared/widgets/custom_network_image.dart';
import '../../../core/utils/toast_helper.dart';

class QuickActionPalette {
  final List<Color> gradient;
  final Color badgeColor;

  const QuickActionPalette({
    required this.gradient,
    required this.badgeColor,
  });
}

class DashboardHomeView extends GetView<DashboardController> {
  const DashboardHomeView({super.key});

  static final List<QuickActionPalette> _defaultPalettes = [
    const QuickActionPalette(
      gradient: [Color(0xFF7C3AED), Color(0xFF6D28D9)], // Purple
      badgeColor: Color(0xFF6D28D9),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFF2563EB), Color(0xFF1D4ED8)], // Blue
      badgeColor: Color(0xFF1D4ED8),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFF22C55E), Color(0xFF15803D)], // Green
      badgeColor: Color(0xFF15803D),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFF6366F1), Color(0xFF4338CA)], // Indigo
      badgeColor: Color(0xFF4338CA),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFFFF6B35), Color(0xFFE64A19)], // Orange
      badgeColor: Color(0xFFE64A19),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
      badgeColor: Color(0xFFD97706),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFF0D9488), Color(0xFF0F766E)], // Teal
      badgeColor: Color(0xFF0F766E),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFFE11D48), Color(0xFFBE123C)], // Rose
      badgeColor: Color(0xFFBE123C),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFF8B5CF6), Color(0xFF7C3AED)], // Violet
      badgeColor: Color(0xFF7C3AED),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFF0284C7), Color(0xFF0369A1)], // Sky
      badgeColor: Color(0xFF0369A1),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFFEC4899), Color(0xFFDB2777)], // Pink
      badgeColor: Color(0xFFDB2777),
    ),
    const QuickActionPalette(
      gradient: [Color(0xFF14B8A6), Color(0xFF0D9488)], // Cyan-Teal
      badgeColor: Color(0xFF0D9488),
    ),
  ];

  QuickActionPalette _getPaletteForAction(QuickActionModel action, int index) {
    final route = action.route.toLowerCase();
    if (route.contains('current-affairs') || route.contains('quiz')) {
      return const QuickActionPalette(
        gradient: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        badgeColor: Color(0xFF6D28D9),
      );
    } else if (route.contains('study-materials')) {
      return const QuickActionPalette(
        gradient: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        badgeColor: Color(0xFF1D4ED8),
      );
    } else if (route.contains('tests')) {
      return const QuickActionPalette(
        gradient: [Color(0xFF22C55E), Color(0xFF15803D)],
        badgeColor: Color(0xFF15803D),
      );
    } else if (route.contains('demo')) {
      return const QuickActionPalette(
        gradient: [Color(0xFF6366F1), Color(0xFF4338CA)],
        badgeColor: Color(0xFF4338CA),
      );
    } else if (route.contains('course') || route.contains('video')) {
      return const QuickActionPalette(
        gradient: [Color(0xFFFF6B35), Color(0xFFE64A19)],
        badgeColor: Color(0xFFE64A19),
      );
    } else if (route.contains('bookmark')) {
      return const QuickActionPalette(
        gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
        badgeColor: Color(0xFFD97706),
      );
    } else if (route.contains('book')) {
      return const QuickActionPalette(
        gradient: [Color(0xFF0D9488), Color(0xFF0F766E)],
        badgeColor: Color(0xFF0F766E),
      );
    } else if (route.contains('live')) {
      return const QuickActionPalette(
        gradient: [Color(0xFFE11D48), Color(0xFFBE123C)],
        badgeColor: Color(0xFFBE123C),
      );
    } else if (route.contains('testimonial')) {
      return const QuickActionPalette(
        gradient: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        badgeColor: Color(0xFF7C3AED),
      );
    } else if (route.contains('exam') || route.contains('notification')) {
      return const QuickActionPalette(
        gradient: [Color(0xFF0284C7), Color(0xFF0369A1)],
        badgeColor: Color(0xFF0369A1),
      );
    }
    return _defaultPalettes[index % _defaultPalettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundStartDark : AppColors.backgroundStart,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1C1917),
                    Color(0xFF0C0A09),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFF7A00), // Vibrant Sunburst Orange
                    Color(0xFFF97316), // Radiant Warm Orange
                    Color(0xFFEA580C), // Core Brand Orange
                    Color(0xFFC2410C), // Rich Ember Orange
                  ],
                  stops: [0.0, 0.35, 0.70, 1.0],
                ),
        ),
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDark ? AppColors.accent : Colors.white,
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CommonButton(
                        text: AppStrings.retry,
                        onPressed: controller.fetchDashboardData,
                        backgroundColor: isDark ? AppColors.accent : Colors.white,
                        foregroundColor: isDark ? Colors.white : const Color(0xFFEA580C),
                        fullWidth: false,
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = controller.dashboardData.value;

            return RefreshIndicator(
              onRefresh: controller.fetchDashboardData,
              color: isDark ? AppColors.accent : const Color(0xFFEA580C),
              backgroundColor: isDark ? AppColors.cardBgDark : Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // 1. Hero Branded Header with App Bar & Banner Carousel
                    _buildHeroHeader(context, data?.banners),

                    // 2. Rounded Card Container
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardBgDark : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : const Color(0x18000000),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Actions Title
                          Text(
                            AppStrings.quickActions,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          // Feature Grid with Numbered Badges
                          _buildFeatureGrid(context),

                          const SizedBox(height: 20),

                          // Continue Learning Section
                          if (data?.continueLearning != null) ...[
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionTitle(
                                  context,
                                  AppStrings.continueLearning,
                                ),
                                TextButton(
                                  onPressed: () {
                                    controller.tabController.jumpToTab(2);
                                  },
                                  child: Text(
                                    AppStrings.viewAll,
                                    style: TextStyle(
                                      color: isDark ? AppColors.accent : const Color(0xFFEA580C),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildContinueLearning(data?.continueLearning),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // Hero Branded Header UI Component with Banner
  Widget _buildHeroHeader(BuildContext context, List<BannerModel>? banners) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.backgroundStart,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Top row with App Logo & Name on left, and Notification Bell on right
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset("assets/images/app_logo.png", height: 40),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  final notifyService = Get.find<NotificationService>();
                  final count = notifyService.unreadCount.value;
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                            size: 22,
                          ),
                          onPressed: () {
                            Get.toNamed(Routes.NOTIFICATIONS);
                          },
                        ),
                        if (count > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 8,
                                minHeight: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Banner Carousel inside Hero area
          if (banners != null && banners.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BannerCarousel(banners: banners),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  // Feature Grid UI Component (dynamic from backend QuickActionModel)
  Widget _buildFeatureGrid(BuildContext context) {
    return Obx(() {
      final backendActions = (controller.dashboardData.value?.quickActions ?? [])
          .where((a) => a.isEnabled)
          .toList();

      if (backendActions.isEmpty) {
        return const SizedBox.shrink();
      }

      // Sort by order ascending
      backendActions.sort((a, b) => a.order.compareTo(b.order));

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 14,
          childAspectRatio: 0.73,
        ),
        itemCount: backendActions.length,
        itemBuilder: (context, index) {
          final action = backendActions[index];
          final palette = _getPaletteForAction(action, index);
          final title = _formatTitle(action.title);

          return _buildBrandedTile(
            context,
            index: index,
            title: title,
            icon: action.icon,
            gradientColors: palette.gradient,
            badgeColor: palette.badgeColor,
            onTap: () => _handleActionTap(action.route, action.title),
          );
        },
      );
    });
  }

  String _formatTitle(String title) {
    final cleaned = title.trim();
    if (cleaned.contains('-')) {
      final parts = cleaned.split('-');
      return parts.map((p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '').join('\n');
    }
    if (cleaned.contains(' ') && !cleaned.contains('\n')) {
      final parts = cleaned.split(' ');
      if (parts.length == 2) {
        return '${parts[0]}\n${parts[1]}';
      }
    }
    return cleaned;
  }

  // Individual Feature Tile UI Component
  Widget _buildBrandedTile(
    BuildContext context, {
    required int index,
    required String title,
    required dynamic icon,
    required List<Color> gradientColors,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: gradientColors[0].withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Squircle with glossy gradient and white icon
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[1].withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: icon is IconData
                  ? Icon(icon, color: Colors.white, size: 32)
                  : _buildIconWidget(icon.toString()),
            ),
          ),

          const SizedBox(height: 6),

          // 2. Circular Number Badge
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // 3. Title Label (2-line centered bold)
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  void _handleActionTap(String targetRoute, String title) {
    final route = targetRoute.trim().toLowerCase();

    // 1. Tests Tab
    if (route == '/tests' || route == 'tests' || route == '/online-tests' || route == 'online-tests') {
      controller.tabController.jumpToTab(1);
      if (Get.isRegistered<TestsController>()) {
        Get.find<TestsController>().fetchTests();
      }
      return;
    }

    // 2. Courses / Online Videos Tab
    if (route == '/courses' || route == 'courses' || route == '/online-videos' || route == 'online-videos') {
      controller.tabController.jumpToTab(2);
      if (Get.isRegistered<CourseController>()) {
        Get.find<CourseController>().fetchCourses();
      }
      return;
    }

    // 3. Demo Courses
    if (route == '/demo-courses' || route == '/demo-class' || route == 'demo-courses' || route == 'demo-class') {
      final demoCourses = controller.dashboardData.value?.allCourses
              .where((c) => c.isDemo)
              .toList() ??
          [];

      if (demoCourses.length == 1) {
        Get.to(() => CourseDetailView(courseId: demoCourses.first.id));
      } else {
        Get.toNamed(Routes.COURSES, arguments: {'isDemoOnly': true});
      }
      return;
    }

    // 4. Current Affairs / Quiz
    if (route == '/current-affairs' || route == 'current-affairs' || route == '/quiz' || route == 'quiz') {
      Get.toNamed(Routes.CURRENT_AFFAIRS);
      return;
    }

    // 5. Study Materials
    if (route == '/study-materials' || route == 'study-materials') {
      Get.toNamed(Routes.STUDY_MATERIALS);
      return;
    }

    // 6. Bookmarks
    if (route == '/bookmarks' || route == 'bookmarks') {
      Get.toNamed(Routes.BOOKMARKS);
      return;
    }

    // 7. Book Store
    if (route == '/book-store' || route == 'book-store' || route == '/books' || route == 'books') {
      Get.toNamed(Routes.BOOK_STORE);
      return;
    }

    // 8. Live Videos / Streams
    if (route == '/live-videos' || route == 'live-videos' || route == '/live-streams' || route == 'live-streams') {
      Get.toNamed(Routes.LIVE_VIDEOS);
      return;
    }

    // 9. Testimonials
    if (route == '/testimonials' || route == 'testimonials') {
      Get.toNamed(Routes.TESTIMONIALS);
      return;
    }

    // 10. Exam Updates
    if (route == '/exam-updates' || route == 'exam-updates') {
      Get.toNamed(Routes.EXAM_UPDATES);
      return;
    }

    // 11. Notifications
    if (route == '/notifications' || route == 'notifications') {
      Get.toNamed(Routes.NOTIFICATIONS);
      return;
    }

    // 12. Performance / Analytics
    if (route == '/performance' || route == 'performance' || route == '/analytics' || route == 'analytics') {
      Get.toNamed(Routes.PERFORMANCE);
      return;
    }

    // 13. Any registered GetPage route
    final normalizedRoute = targetRoute.startsWith('/') ? targetRoute : '/$targetRoute';
    final isRegistered = AppPages.routes.any((page) => page.name == normalizedRoute || page.name == targetRoute);
    if (isRegistered) {
      Get.toNamed(isRegistered ? normalizedRoute : targetRoute);
      return;
    }

    // Fallback notice
    AppToast.validation(
      'The feature "${title.replaceAll('\n', ' ')}" is currently unavailable.',
      title: 'Notice',
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

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_')) {
      case 'video':
      case 'ondemand_video':
      case 'online_videos':
      case 'courses':
        return Icons.ondemand_video_rounded;
      case 'filetext':
      case 'file_text':
      case 'bookopen':
      case 'menu_book':
      case 'study_materials':
        return Icons.menu_book_rounded;
      case 'award':
      case 'quiz':
      case 'tests':
      case 'online_tests':
      case 'assignment_turned_in':
        return Icons.assignment_turned_in_rounded;
      case 'newspaper':
      case 'current_affairs':
        return Icons.newspaper_rounded;
      case 'co_present':
      case 'live_classes':
      case 'live_videos':
      case 'live_tv':
      case 'live':
        return Icons.live_tv_rounded;
      case 'shopping_cart':
      case 'book_store':
      case 'bookstore':
      case 'books':
      case 'shopping_bag_outlined':
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'bookmark':
      case 'bookmarks':
      case 'book_mark':
        return Icons.bookmark_rounded;
      case 'notifications':
      case 'exam_updates':
      case 'exam_update':
      case 'update':
        return Icons.notifications_active_rounded;
      case 'groups':
      case 'demo_classes':
      case 'demo_class':
      case 'demo_courses':
      case 'play_circle_outline':
      case 'play_circle':
        return Icons.play_circle_outline_rounded;
      case 'analytics':
      case 'performance':
      case 'trending_up':
      case 'leaderboard':
        return Icons.trending_up_rounded;
      case 'reviews':
      case 'reviews_24dp':
      case 'testimonial':
      case 'testimonials':
      case 'rate_review':
        return Icons.rate_review_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }

  Widget _buildIconWidget(String iconString) {
    final trimmed = iconString.trim();
    final isNetworkImage =
        trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.contains('/');

    if (isNetworkImage) {
      return CustomNetworkImage(
        imageUrl: trimmed,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        errorWidget: const Icon(
          Icons.widgets_rounded,
          color: Colors.white,
          size: 32,
        ),
      );
    } else {
      return Icon(_getIconData(trimmed), color: Colors.white, size: 32);
    }
  }

  // Continue Learning Section
  Widget _buildContinueLearning(ContinueLearning? contLearn) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final colorScheme = Theme.of(context).colorScheme;
        if (contLearn == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBgDark : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : colorScheme.outline,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                AppStrings.startLearningPrompt,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : colorScheme.onSurfaceVariant,
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
            color: isDark ? AppColors.cardBgDark : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : const Color(0x05000000),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark ? AppColors.borderDark : colorScheme.outline,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Graphic header area
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF292524), Color(0xFF1C1917)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFFFF3E5), Color(0xFFFFEDD5)],
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
                          color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.8),
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
                              color: isDark ? AppColors.textPrimaryDark : colorScheme.onSurface,
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
                            color: isDark ? AppColors.textSecondaryDark : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.accent : AppColors.primary,
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
                        backgroundColor: (isDark ? AppColors.borderDark : colorScheme.outline).withValues(
                          alpha: 0.3,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.accent : AppColors.primary,
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
                      backgroundColor: isDark ? AppColors.accent : AppColors.primary,
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
                        Get.find<DashboardController>().tabController.jumpToTab(
                          2,
                        );
                      }
                    } else if (lower == 'tests' || lower == '/tests') {
                      if (Get.isRegistered<DashboardController>()) {
                        Get.find<DashboardController>().tabController.jumpToTab(
                          1,
                        );
                      }
                    } else if (lower == 'books' ||
                        lower == '/books' ||
                        lower == 'book-store') {
                      Get.toNamed(Routes.BOOK_STORE);
                    } else if (lower == 'current-affairs' ||
                        lower == '/current-affairs') {
                      Get.toNamed(Routes.CURRENT_AFFAIRS);
                    } else if (lower == 'study-materials' ||
                        lower == '/study-materials') {
                      Get.toNamed(Routes.STUDY_MATERIALS);
                    } else if (lower.startsWith('http://') ||
                        lower.startsWith('https://')) {
                      final uri = Uri.tryParse(link);
                      if (uri != null) {
                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
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
