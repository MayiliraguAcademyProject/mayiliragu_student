import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:better_player_enhanced/better_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
                ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Note',
                    style: TextStyle(color: Colors.white),
                  ),
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
        border: Border.all(color: colorScheme.outline, width: 1),
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
                  onTap: () => controller.seekToTimestamp(
                    note['timestamp'] as int? ?? 0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatDuration(note['timestamp'] as int? ?? 0),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showNoteBottomSheet(
                        context,
                        noteId: note['id']?.toString(),
                        initialContent: note['content']?.toString(),
                      );
                    } else if (val == 'delete') {
                      _showDeleteConfirmation(
                        context,
                        note['id']?.toString() ?? '',
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              note['content'] ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_alt_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No study notes yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create notes at specific video timestamps to easily recall key concepts during revision.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _showNoteBottomSheet(context),
              icon: Icon(Icons.add, size: 18, color: colorScheme.primary),
              label: Text(
                'Add Your First Note',
                style: TextStyle(
                  fontSize: 14,
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
          return YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: controller.youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: const Color(0xFF0D47A1),
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
              if (controller.youtubeController == null) {
                return _buildScaffold(context, controller, player);
              }
              return ValueListenableBuilder<YoutubePlayerValue>(
                valueListenable: controller.youtubeController!,
                builder: (context, value, child) {
                  final playerWithOverlay = Stack(
                    children: [
                      player,
                      // Cover/prevent clicking the YouTube share/more actions button (top-right corner)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {}, // Intercept gestures
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(
                            width: 70,
                            height: 60,
                          ),
                        ),
                      ),
                    ],
                  );
                  return _buildScaffold(context, controller, playerWithOverlay);
                },
              );
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
            final lesson = controller.lessonData.value;
            if (lesson == null || lesson['downloadEnabled'] != true) {
              return const SizedBox.shrink();
            }
            final driveFileId = lesson['driveFileId']?.toString() ?? '';
            if (LessonController.extractYoutubeId(driveFileId) != null) {
              return const SizedBox.shrink();
            }
            final lessonId = lesson['id']?.toString() ?? '';
            final downloadService = Get.find<VideoDownloadService>();

            return Obx(() {
              final isDownloaded = downloadService.isDownloaded(lessonId);
              final isDownloading =
                  downloadService.isDownloading[lessonId] ?? false;
              final progress =
                  downloadService.downloadProgress[lessonId] ?? 0.0;

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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.errorMessage.value,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final String? lessonId =
                            Get.parameters['id'] ?? Get.arguments?.toString();
                        if (lessonId != null) {
                          controller.fetchLessonDetail(lessonId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                      ),
                      child: const Text('Retry'),
                    ),
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

              // Title and Add New note button row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Personal Study Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showNoteBottomSheet(context),
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Add New',
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              // Notes List with Draft card appended at the bottom
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingNotes.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  final notesCount = controller.notes.length;
                  if (notesCount == 0) {
                    return _buildEmptyNotesState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: notesCount,
                    itemBuilder: (context, index) {
                      final note = controller.notes[index];
                      return _buildNoteCard(context, note);
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outline, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isComp ? null : () => controller.markLessonAsComplete(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isComp ? Colors.green : colorScheme.primary,
                  disabledBackgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isComp ? 'Lesson Completed ✓' : 'Mark Lesson as Complete',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
