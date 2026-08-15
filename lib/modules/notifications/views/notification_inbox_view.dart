import 'package:Mayiliragu/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/notification_inbox_controller.dart';

class NotificationInboxView extends GetView<NotificationInboxController> {
  const NotificationInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationInboxController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brandPurple),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
                const SizedBox(height: 12),
                CommonButton(
                  text: 'Retry',
                  onPressed: () => controller.fetchNotifications(isRefresh: true),
                  backgroundColor: AppColors.brandPurple,
                  fullWidth: false,
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 48, color: colorScheme.onSurfaceVariant),
                const SizedBox(height: 12),
                Text(
                  'No notifications yet',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.brandPurple,
          onRefresh: () => controller.fetchNotifications(isRefresh: true),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!controller.isMoreLoading.value &&
                  controller.hasMore.value &&
                  scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                controller.fetchNotifications();
              }
              return true;
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: controller.notifications.length + (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.brandPurple, strokeWidth: 2),
                    ),
                  );
                }

                final notification = controller.notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: notification.isRead ? colorScheme.surface : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notification.isRead ? colorScheme.outline : AppColors.brandPurple.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x03000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    onTap: () => controller.markAsRead(notification),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!notification.isRead)
                          Container(
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.brandPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead ? FontWeight.bold : FontWeight.w900,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.body,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(notification.sentAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
