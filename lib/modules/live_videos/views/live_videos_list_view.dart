import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/live_stream_model.dart';
import '../controllers/live_videos_controller.dart';
import 'live_video_player_view.dart';

class LiveVideosListView extends GetView<LiveVideosController> {
  const LiveVideosListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.brightness == Brightness.light
            ? AppColors.backgroundStart
            : AppColors.backgroundStartDark,
        appBar: AppBar(
          title: const Text(
            AppStrings.liveClasses,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: colorScheme.brightness == Brightness.light
              ? AppColors.backgroundStart
              : AppColors.backgroundStartDark,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: colorScheme.brightness == Brightness.light
                ? AppColors.textSecondary
                : AppColors.textSecondaryDark,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: AppStrings.liveNow),
              Tab(text: AppStrings.upcoming),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          return TabBarView(
            children: [
              _buildStreamList(context, controller.activeStreams, isLive: true),
              _buildStreamList(context, controller.upcomingStreams, isUpcoming: true),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStreamList(
    BuildContext context,
    List<LiveStreamModel> streams, {
    bool isLive = false,
    bool isUpcoming = false,
    bool isRecorded = false,
  }) {
    if (streams.isEmpty) {
      String message = AppStrings.noClassesAvailable;
      if (isLive) {
        message = AppStrings.noLiveClassesNow;
      } else if (isUpcoming) {
        message = AppStrings.noUpcomingClasses;
      } else if (isRecorded) {
        message = AppStrings.noRecordedClasses;
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_camera_back_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.brightness == Brightness.light
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : AppColors.textSecondaryDark.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.brightness == Brightness.light
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: streams.length,
      itemBuilder: (context, index) {
        final stream = streams[index];
        return _buildStreamCard(context, stream, isLive, isUpcoming, isRecorded);
      },
    );
  }

  Widget _buildStreamCard(
    BuildContext context,
    LiveStreamModel stream,
    bool isLive,
    bool isUpcoming,
    bool isRecorded,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final videoId = controller.getYoutubeVideoId(stream.youtubeUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (isUpcoming) {
            _showUpcomingAlert(context, stream);
            return;
          }
          if (videoId.isEmpty) {
            Get.snackbar(
              AppStrings.unsupportedLink,
              AppStrings.invalidVideoSourceUrl,
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }

          Get.to(
            () => LiveVideoPlayerView(
              videoId: videoId,
              title: stream.title,
              description: stream.description,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Stack
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (videoId.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: 'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildThumbnailPlaceholder(isDark),
                    )
                  else
                    _buildThumbnailPlaceholder(isDark),

                  // Overlay status tags & controls
                  if (isLive)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              AppStrings.live,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Play Button Overlay for Live & Recorded
                  if (!isUpcoming)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLive ? AppColors.error : AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    )
                  else
                    // Lock icon for upcoming videos
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_clock_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Card Body Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  if (stream.description != null && stream.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      stream.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 12),

                  // Footer containing scheduled time & real-time countdown info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDateTime(stream.scheduledStartTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (isUpcoming)
                        Obx(() {
                          return Text(
                            controller.getCountdown(stream.scheduledStartTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.backgroundEndDark, AppColors.borderDark]
              : [AppColors.backgroundEnd, AppColors.border],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.video_library_rounded,
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showUpcomingAlert(BuildContext context, LiveStreamModel stream) {
    final diff = stream.scheduledStartTime.difference(DateTime.now());
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    
    String timeRemaining = '$mins minutes';
    if (hours > 0) {
      timeRemaining = '$hours hours and $mins minutes';
    }

    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.cardBgDark : AppColors.cardBg,
          title: Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                AppStrings.classScheduled,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            '${AppStrings.classScheduledStartIn}$timeRemaining${AppStrings.pleaseWaitScheduledTime}',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                AppStrings.ok,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final String month = months[dateTime.month - 1];
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String hour = (dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour))
        .toString()
        .padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$day $month, $hour:$minute $period';
  }
}
