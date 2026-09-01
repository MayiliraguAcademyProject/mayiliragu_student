import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../services/secure_storage_service.dart';
import '../models/notification_model.dart';
import '../../shared/widgets/pdf_viewer_screen.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final ApiClient _apiClient = Get.find<ApiClient>();
  final SecureStorageService _storage = Get.find<SecureStorageService>();

  Future<void> initialize() async {
    // 1. Request Permission
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Local Notifications Setup
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('launcher_icon');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClick(response.payload);
      },
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. Foreground Listening
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android?.smallIcon ?? 'launcher_icon',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 4. Background Click Handling
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data);
    });

    // 5. App opened from terminated state via notification click
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage.data);
    }

    // 6. Token refresh handler
    _fcm.onTokenRefresh.listen((token) async {
      await registerToken(token);
    });
  }

  void _handleNotificationClick(dynamic rawPayload) {
    if (rawPayload == null) return;

    if (rawPayload is Map) {
      final pdfUrl = rawPayload['pdfUrl'] as String?;
      final title = rawPayload['title'] as String? ?? 'Document';
      final route = rawPayload['route'] as String?;

      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        Get.to(() => PdfViewerScreen(pdfUrl: pdfUrl, title: title));
        return;
      }
      if (route != null && route.isNotEmpty) {
        Get.toNamed(route);
      }
      return;
    }

    if (rawPayload is String && rawPayload.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPayload);
        if (decoded is Map) {
          _handleNotificationClick(decoded);
          return;
        }
      } catch (_) {}

      // Fallback string payload
      if (rawPayload.startsWith('http://') || rawPayload.startsWith('https://')) {
        Get.to(() => PdfViewerScreen(pdfUrl: rawPayload, title: 'Document'));
      } else {
        Get.toNamed(rawPayload);
      }
    }
  }

  Future<void> syncToken() async {
    try {
      final token = await _storage.getAccessToken();
      if (token != null) {
        final fcmToken = await _fcm.getToken();
        if (fcmToken != null) {
          await registerToken(fcmToken);
        }
      }
    } catch (e) {
      print('FCM Token sync failed: $e');
    }
  }

  Future<void> registerToken(String fcmToken) async {
    try {
      final accessToken = await _storage.getAccessToken();
      if (accessToken == null) return; // Not logged in yet
      
      await _apiClient.post(
        ApiConstants.registerFcmToken,
        data: {
          'token': fcmToken,
          'deviceType': Platform.isAndroid ? 'ANDROID' : 'IOS',
        },
      );
      print('FCM Token registered successfully: $fcmToken');
    } catch (e) {
      print('Failed to register FCM token with backend: $e');
    }
  }

  Future<void> unregisterToken() async {
    try {
      final fcmToken = await _fcm.getToken();
      if (fcmToken != null) {
        await _apiClient.post(
          ApiConstants.unregisterFcmToken,
          data: {'token': fcmToken},
        );
        print('FCM Token unregistered successfully.');
      }
    } catch (e) {
      print('Failed to unregister FCM token: $e');
    }
  }

  // In-app notifications state
  final RxInt unreadCount = 0.obs;

  Future<List<NotificationModel>> fetchNotifications({int limit = 20, int offset = 0}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.notifications,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.data != null && response.data['status'] == 'success') {
        final List list = response.data['data'] ?? [];
        return list.map((e) => NotificationModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Failed to fetch notifications: $e');
    }
    return [];
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiClient.get(ApiConstants.notificationsUnreadCount);
      if (response.data != null && response.data['status'] == 'success') {
        unreadCount.value = response.data['data']['count'] ?? 0;
      }
    } catch (e) {
      print('Failed to fetch unread count: $e');
    }
  }

  Future<bool> markNotificationAsRead(String id) async {
    try {
      final response = await _apiClient.patch(ApiConstants.markNotificationRead(id));
      if (response.data != null && response.data['status'] == 'success') {
        await fetchUnreadCount(); // update local unread count
        return true;
      }
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
    return false;
  }
}
