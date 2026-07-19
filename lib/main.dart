import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_initializer.dart';

class ThemeController extends GetxController {
  final rxThemeMode = ThemeMode.system.obs;

  ThemeController(ThemeMode initial) {
    rxThemeMode.value = initial;
  }

  void changeThemeMode(ThemeMode mode) {
    rxThemeMode.value = mode;
    Get.changeThemeMode(mode);
  }
}

void main() async {
  final ThemeMode initialTheme = await AppInitializer.init();
  Get.put(ThemeController(initialTheme));
  runApp(const MyApp(initialRoute: AppPages.INITIAL));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: "Mayiliragu Academy",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.rxThemeMode.value,
        initialRoute: initialRoute,
        getPages: AppPages.routes,
      ),
    );
  }
}
