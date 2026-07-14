import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';
import 'secure_storage_service.dart';
import 'notification_service.dart';
import 'video_download_service.dart';
import 'app_config_service.dart';
import 'internet_controller.dart';

class AppInitializer {
  static Future<ThemeMode> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint('--- APP CONFIG ---');
    debugPrint('Using API Base URL: ${ApiConstants.baseUrl}');
    debugPrint('------------------');

    // 2. Initialize Firebase & Error Handlers
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Pass uncaught framework errors to console
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    // Pass uncaught async errors to console
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrintStack(stackTrace: stack, label: error.toString());
      return true;
    };

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Initialize Core Services
    final storage = Get.put(SecureStorageService());
    Get.put(ApiClient());
    Get.put(AppConfigService());
    Get.put(InternetController(), permanent: true);

    final downloadService = Get.put(VideoDownloadService());
    await downloadService.init();

    final notifications = Get.put(NotificationService());
    await notifications.initialize();

    // 4. Load Theme Settings
    final savedThemeMode = await storage.getThemeMode();
    return savedThemeMode == 'dark'
        ? ThemeMode.dark
        : savedThemeMode == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
