import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/network/api_client.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/video_download_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Core Services
  final storage = Get.put(SecureStorageService());
  Get.put(ApiClient());
  
  final downloadService = Get.put(VideoDownloadService());
  await downloadService.init();
  
  final notifications = Get.put(NotificationService());
  await notifications.initialize();

  final token = await storage.getAccessToken();
  if (token != null) {
    // Sync FCM token if already logged in
    unawaited(notifications.syncToken());
  }

  final role = await storage.getUserRole();
  final hasSeenOnboarding = await storage.hasSeenOnboarding();
  final savedThemeMode = await storage.getThemeMode();
  final themeMode = savedThemeMode == 'dark'
      ? ThemeMode.dark
      : savedThemeMode == 'light'
          ? ThemeMode.light
          : ThemeMode.system;

  String initialRoute = Routes.ONBOARDING;
  if (hasSeenOnboarding) {
    if (token != null && role == 'STUDENT') {
      final onboardingCompleted = await storage.isOnboardingCompleted();
      initialRoute = onboardingCompleted ? Routes.DASHBOARD : Routes.PROFILE_ONBOARDING;
    } else {
      initialRoute = Routes.LOGIN;
    }
  }

  runApp(MyApp(initialRoute: initialRoute, themeMode: themeMode));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final ThemeMode themeMode;
  const MyApp({super.key, required this.initialRoute, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Education App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
