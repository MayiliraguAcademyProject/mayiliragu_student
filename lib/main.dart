import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/network/api_client.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/video_download_service.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_config_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Core Services
  final storage = Get.put(SecureStorageService());
  Get.put(ApiClient());
  Get.put(AppConfigService());
  
  final downloadService = Get.put(VideoDownloadService());
  await downloadService.init();
  
  final notifications = Get.put(NotificationService());
  await notifications.initialize();

  final savedThemeMode = await storage.getThemeMode();
  final themeMode = savedThemeMode == 'dark'
      ? ThemeMode.dark
      : savedThemeMode == 'light'
          ? ThemeMode.light
          : ThemeMode.system;

  runApp(MyApp(initialRoute: AppPages.INITIAL, themeMode: themeMode));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final ThemeMode themeMode;
  const MyApp({super.key, required this.initialRoute, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Mayiliragu Academy",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
