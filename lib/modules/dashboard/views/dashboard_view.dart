import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/dashboard_controller.dart';
import 'dashboard_home_view.dart';
import '../../tests/views/tests_view.dart';
import '../../courses/views/course_list_view.dart';
import '../../profile/views/profile_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = AppColors.brandPurple;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return PersistentTabView(
    
      controller: controller.tabController,
      backgroundColor: theme.colorScheme.surface,
      tabs: [
        PersistentTabConfig(
          screen: const DashboardHomeView(),
          item: ItemConfig(
            icon: const Icon(Icons.home_filled),
            title: AppStrings.tabHome,
            activeForegroundColor: activeColor,
            inactiveForegroundColor: inactiveColor,
          ),
        ),
        PersistentTabConfig(
          screen: const TestsView(),
          item: ItemConfig(
            icon: const Icon(Icons.assignment_outlined),
            title: AppStrings.tabTests,
            activeForegroundColor: activeColor,
            inactiveForegroundColor: inactiveColor,
          ),
        ),
        PersistentTabConfig(
          screen: const CourseListView(),
          item: ItemConfig(
            icon: const Icon(Icons.menu_book),
            title: AppStrings.tabLearn,
            activeForegroundColor: activeColor,
            inactiveForegroundColor: inactiveColor,
          ),
        ),
        PersistentTabConfig(
          screen: const ProfileView(),
          item: ItemConfig(
            icon: const Icon(Icons.person),
            title: AppStrings.person,
            activeForegroundColor: activeColor,
            inactiveForegroundColor: inactiveColor,
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style1BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
      ),
    );
  }
}
