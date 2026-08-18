import 'package:get/get.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/error_handler.dart';

class NotificationInboxController extends GetxController {
  final NotificationService _notificationService = Get.find<NotificationService>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;

  final int _pageSize = 20;
  int _currentOffset = 0;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(isRefresh: true);
  }

  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (isLoading.value || isMoreLoading.value) return;

    if (isRefresh) {
      _currentOffset = 0;
      hasMore.value = true;
      isLoading.value = true;
    } else {
      if (!hasMore.value) return;
      isMoreLoading.value = true;
    }

    errorMessage.value = '';

    try {
      final list = await _notificationService.fetchNotifications(
        limit: _pageSize,
        offset: _currentOffset,
      );

      if (isRefresh) {
        notifications.clear();
      }

      notifications.addAll(list);

      if (list.length < _pageSize) {
        hasMore.value = false;
      } else {
        _currentOffset += _pageSize;
      }
    } catch (e) {
      errorMessage.value = AppErrorHandler.getErrorMessage(
        e,
        defaultMessage: 'Failed to load notifications. Please try again.',
      );
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    
    final success = await _notificationService.markNotificationAsRead(notification.id);
    if (success) {
      final index = notifications.indexWhere((element) => element.id == notification.id);
      if (index != -1) {
        final current = notifications[index];
        notifications[index] = NotificationModel(
          id: current.id,
          campaignId: current.campaignId,
          studentId: current.studentId,
          status: current.status,
          sentAt: current.sentAt,
          isRead: true,
          readAt: DateTime.now(),
          title: current.title,
          body: current.body,
        );
      }
    }
  }
}
