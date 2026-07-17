import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/dashboard_controller.dart';
import 'dashboard_home_view.dart';
import '../../tests/views/tests_view.dart';
import '../../tests/controllers/tests_controller.dart';
import '../../courses/views/course_list_view.dart';
import '../../courses/controllers/course_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../profile/controllers/profile_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: controller.tabController,
      tabs: [
        PersistentTabConfig(
          screen: const DashboardHomeView(),
          item: ItemConfig(
            icon: const Icon(Icons.home_filled),
            title: AppStrings.tabHome,
          ),
        ),
        PersistentTabConfig(
          screen: const TestsView(),
          item: ItemConfig(
            icon: const Icon(Icons.assignment_outlined),
            title: AppStrings.tabTests,
          ),
        ),
        PersistentTabConfig(
          screen: const CourseListView(),
          item: ItemConfig(
            icon: const Icon(Icons.menu_book),
            title: AppStrings.tabLearn,
          ),
        ),
        // PersistentTabConfig(
        //   screen: const ProgressPlaceholderView(),
        //   item: ItemConfig(
        //     icon: const Icon(Icons.trending_up),
        //     title: AppStrings.tabProgress,
        //   ),
        // ),
        PersistentTabConfig(
          screen: const ProfileView(),
          item: ItemConfig(
            icon: const Icon(Icons.person),
            title: AppStrings.person,
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) => CustomNavBar(navBarConfig: navBarConfig),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  final NavBarConfig navBarConfig;

  const CustomNavBar({super.key, required this.navBarConfig});

  void _onTabChanged(int index) {
    switch (index) {
      case 0:
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchDashboardData();
        }
        break;
      case 1:
        if (Get.isRegistered<TestsController>()) {
          Get.find<TestsController>().fetchTests();
        }
        break;
      case 2:
        if (Get.isRegistered<CourseController>()) {
          Get.find<CourseController>().fetchCourses();
        }
        break;
      case 4:
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfile();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 72 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navBarConfig.items.map((item) {
          int index = navBarConfig.items.indexOf(item);
          bool isActive = navBarConfig.selectedIndex == index;
          return _buildNavBarItem(item, isActive, () {
            navBarConfig.onItemSelected(index);
            _onTabChanged(index);
          });
        }).toList(),
      ),
    );
  }

  Widget _buildNavBarItem(ItemConfig item, bool isActive, VoidCallback onTap) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.brandPurple,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: const IconThemeData(color: Colors.white, size: 20),
              child: item.icon,
            ),
            const SizedBox(width: 6),
            Text(
              item.title ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: const IconThemeData(color: Color(0xFF9093A3), size: 20),
              child: item.icon,
            ),
            const SizedBox(height: 4),
            Text(
              item.title ?? '',
              style: const TextStyle(
                color: Color(0xFF9093A3),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
