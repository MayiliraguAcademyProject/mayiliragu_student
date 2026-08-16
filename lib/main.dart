import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_initializer.dart';
import 'core/controllers/user_session_controller.dart';

class ThemeController extends GetxController {
  final rxThemeMode = ThemeMode.light.obs;

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

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial session load if user is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<UserSessionController>()) {
        Get.find<UserSessionController>().loadSession();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Get.isRegistered<UserSessionController>()) {
        Get.find<UserSessionController>().loadSession();
      }
    }
  }

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
        initialRoute: widget.initialRoute,
        getPages: AppPages.routes,
      ),
    );
  }
}
