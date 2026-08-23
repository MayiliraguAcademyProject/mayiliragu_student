import 'package:Mayiliragu/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:better_player_enhanced/better_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/guards/guest_auth_guard.dart';
import '../controllers/lesson_controller.dart';
import '../../../core/services/video_download_service.dart';

class LessonDetailView extends GetView<LessonController> {
  const LessonDetailView({super.key});

  String formatDuration(int seconds) {
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hrs > 0) {
      return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  void _showNoteBottomSheet(
    BuildContext context, {
    String? noteId,
    String? initialContent,
  }) {
    final textController = TextEditingController(text: initialContent);
    final colorScheme = Theme.of(context).colorScheme;
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              noteId == null ? 'Add Personal Note' : 'Edit Personal Note',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type your study note here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                CommonButton(
                  text: 'Save Note',
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      if (noteId == null) {
                        controller.addNote(text);
                      } else {
                        controller.editNote(noteId, text);
                      }
                      Get.back();
                    }
                  },
                  backgroundColor: colorScheme.primary,
                  borderRadius: 10,
                  fullWidth: false,
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              controller.deleteNote(id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Map<String, dynamic> note) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    final timestamp = note['timestamp'] as int? ?? 0;
                    controller.seekToTimestamp(timestamp);
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatDuration(note['timestamp'] as int? ?? 0),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _showNoteBottomSheet(
                          context,
                          noteId: note['id'],
                          initialContent: note['content'],
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.red,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          _showDeleteConfirmation(context, note['id']),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note['content'] ?? '',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotesState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_alt_outlined,
                size: 36,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No study notes yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create notes at specific video timestamps to easily recall key concepts during revision.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _showNoteBottomSheet(context),
              icon: Icon(Icons.add, size: 18, color: colorScheme.primary),
              label: Text(
                'Add Your First Note',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LessonController>(
      builder: (controller) {
        if (controller.youtubeController != null) {
          final currentKey = controller.activeVideoId.value ?? controller.youtubeController!.initialVideoId;
          return YoutubePlayerBuilder(
            key: ValueKey('yt_builder_$currentKey'),
            player: YoutubePlayer(
              key: ValueKey('yt_player_$currentKey'),
              controller: controller.youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: const Color(0xFF0D47A1),
              // Hide channel name, title bar and share icon in the overlay
              topActions: const [],
              bottomActions: [
                const SizedBox(width: 8),
                CurrentPosition(),
                const SizedBox(width: 8),
                ProgressBar(isExpanded: true),
                const SizedBox(width: 8),
                RemainingDuration(),
                const PlaybackSpeedButton(),
                const FullScreenButton(),
              ],
            ),
            builder: (context, player) {
              // Wrap in a Stack to cover the YouTube watermark logo
              final playerWithOverlay = Stack(
                children: [
                  player,
                  // Cover the YouTube watermark (bottom-right corner)
                 
                ],
              );
              return _buildScaffold(context, controller, playerWithOverlay);
            },
          );
        } else {
          final Widget betterPlayerWidget = controller.betterPlayerController != null
              ? AspectRatio(
                  aspectRatio: 16 / 9,
                  child: BetterPlayer(
                    controller: controller.betterPlayerController!,
                  ),
                )
              : const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                );
          return _buildScaffold(context, controller, betterPlayerWidget);
        }
      },
    );
  }

  Widget _buildScaffold(BuildContext context, LessonController controller, Widget playerWidget) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: 24,
            color: colorScheme.primary,
          ),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final data = controller.lessonData.value;
          return Text(
            data?['title'] ?? 'Lesson Playback',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }),
        actions: [
          Obx(() {
            final video = controller.currentVideo;
            if (video == null || video['downloadEnabled'] != true) {
              return const SizedBox.shrink();
            }
            final driveFileId = video['driveFileId']?.toString() ?? '';
            if (LessonController.extractYoutubeId(driveFileId) != null) {
              return const SizedBox.shrink();
            }
            final videoId = video['id']?.toString() ?? '';
            final downloadService = Get.find<VideoDownloadService>();

            return Obx(() {
              final isDownloaded = downloadService.isDownloaded(videoId);
              final isDownloading =
                  downloadService.isDownloading[videoId] ?? false;
              final progress = downloadService.downloadProgress[videoId] ?? 0.0;

              if (isDownloading) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                );
              }

              if (isDownloaded) {
                return IconButton(
                  icon: const Icon(
                    Icons.offline_pin_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Offline Video Actions'),
                        content: const Text(
                          'Choose an action for this downloaded video.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Get.back();
                              await controller.deleteDownloadedVideo();
                              controller.startVideoDownload();
                            },
                            child: Text(
                              'Redownload',
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.deleteDownloadedVideo();
                              Get.back();
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: 'Delete offline video',
                );
              }

              return IconButton(
                icon: Icon(
                  Icons.file_download_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                onPressed: () => controller.startVideoDownload(),
                tooltip: 'Download video offline',
              );
            });
          }),
        ],
        backgroundColor: colorScheme.surface,
        elevation: 0.5,
      ),
      body: Container(
        color: colorScheme.surface,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            final isRestricted =
                controller.errorMessage.value.toLowerCase().contains(
                  'access denied',
                ) ||
                controller.errorMessage.value.toLowerCase().contains(
                  'enrollment required',
                ) ||
                controller.errorMessage.value.toLowerCase().contains(
                  'restricted',
                );

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isRestricted
                            ? AppColors.brandPurple.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRestricted
                            ? Icons.lock_outline_rounded
                            : Icons.error_outline_rounded,
                        color: isRestricted
                            ? AppColors.brandPurple
                            : AppColors.error,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isRestricted
                          ? 'Access Restricted'
                          : 'Unable to Load Lesson',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      style: AppTextStyles.body.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (isRestricted) ...[
                      CommonButton(
                        text: 'Sign In / Unlock Full Course',
                        onPressed: () {
                          GuestAuthGuard.showForceLoginSheet(
                            featureName: 'this lesson',
                          );
                        },
                        backgroundColor: AppColors.brandPurple,
                        foregroundColor: Colors.white,
                        borderRadius: 24,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Go Back'),
                      ),
                    ] else ...[
                      CommonButton(
                        text: 'Retry',
                        onPressed: () {
                          final String? lessonId =
                              Get.parameters['id'] ?? Get.arguments?.toString();
                          if (lessonId != null) {
                            controller.fetchLessonDetail(lessonId);
                          }
                        },
                        backgroundColor: colorScheme.primary,
                        fullWidth: false,
                        borderRadius: 24,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          final lesson = controller.lessonData.value;
          if (lesson == null) {
            return Center(
              child: Text(
                'No lesson details found.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          final activeVid = controller.currentVideo;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Player Region
              if (controller.isVideoPlayerSupported)
                playerWidget
              else
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Text(
                        'Video playback not supported',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),

              // Active Video Title Header
              if (activeVid != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeVid['title'] ?? 'Lecture Video',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (activeVid['description'] != null &&
                          (activeVid['description'] as String).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            activeVid['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              const Divider(height: 1),

              // Notes Section Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Obx(
                          () => Text(
                            'Study Notes (${controller.notes.length})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => _showNoteBottomSheet(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Add Note',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Notes Content Area
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingNotes.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }
                  if (controller.notes.isEmpty) {
                    return _buildEmptyNotesState(context);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: controller.notes.length,
                    itemBuilder: (context, idx) {
                      return _buildNoteCard(context, controller.notes[idx]);
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value ||
            controller.errorMessage.value.isNotEmpty ||
            controller.lessonData.value == null) {
          return const SizedBox.shrink();
        }
        final isComp = controller.isCompleted.value;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: CommonButton(
              text: isComp ? 'Video Completed ✓' : 'Mark Video as Complete',
              onPressed: isComp
                  ? null
                  : () => controller.markLessonAsComplete(),
              height: 50,
              backgroundColor: isComp ? Colors.green : colorScheme.primary,
              borderRadius: 25,
            ),
          ),
        );
      }),
    );
  }
}
