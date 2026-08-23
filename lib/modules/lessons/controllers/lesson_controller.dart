import 'dart:async';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:better_player_enhanced/better_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/video_download_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/toast_helper.dart';
import '../repositories/lesson_repository.dart';
import '../repositories/notes_repository.dart';

class LessonController extends GetxController {
  final LessonRepository _repository;
  final NotesRepository _notesRepository;

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final lessonData = Rxn<Map<String, dynamic>>();

  // Video playlist state
  final videos = <Map<String, dynamic>>[].obs;
  final currentVideoIndex = 0.obs;
  final activeVideoId = RxnString();

  // Tab index: 0 = Playlist, 1 = Notes
  final activeTabIndex = 0.obs;

  // Completion status for active video
  final isCompleted = false.obs;

  // Study notes list state
  final notes = <Map<String, dynamic>>[].obs;
  final isLoadingNotes = false.obs;

  BetterPlayerController? betterPlayerController;
  YoutubePlayerController? youtubeController;
  Timer? _youtubeSeekTimer;

  String? _currentLessonId;
  int _lastSyncedPosition = 0;
  int _latestPosition = 0;
  int maxWatchedSeconds = 0;

  LessonController(this._repository, this._notesRepository);

  Map<String, dynamic>? get currentVideo {
    if (videos.isEmpty || currentVideoIndex.value >= videos.length) {
      return null;
    }
    return videos[currentVideoIndex.value];
  }

  @override
  void onInit() {
    super.onInit();
    final String? lessonId = _extractLessonId();
    if (lessonId != null) {
      fetchLessonDetail(lessonId);
    } else {
      errorMessage.value = 'No lesson ID provided';
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Do not trigger duplicate fetch if already loading or loaded
    final String? lessonId = _extractLessonId();
    if (lessonId != null &&
        lessonId != _currentLessonId &&
        !isLoading.value &&
        lessonData.value == null) {
      fetchLessonDetail(lessonId);
    }
  }

  String? _extractLessonId() {
    if (Get.parameters['id'] != null && Get.parameters['id']!.isNotEmpty) {
      return Get.parameters['id'];
    }
    final args = Get.arguments;
    if (args == null) return null;
    if (args is String) return args.isNotEmpty ? args : null;
    if (args is Map) {
      return args['id']?.toString() ?? args['lessonId']?.toString();
    }
    return args.toString();
  }

  Future<void> fetchLessonDetail(String id) async {
    if (isLoading.value && _currentLessonId == id) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _currentLessonId = id;
      _lastSyncedPosition = 0;

      final response = await _repository.getLessonById(id);

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data['data']);
        lessonData.value = data;

        // Parse videos playlist
        final videosList = (data['videos'] as List? ?? [])
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList();

        if (videosList.isNotEmpty) {
          videos.value = videosList;
        } else if (data['driveFileId'] != null) {
          // Backward compatibility fallback: single video represented by lesson
          videos.value = [
            {
              'id': data['id'],
              'lessonId': data['id'],
              'title': data['title'] ?? 'Lecture Video',
              'driveFileId': data['driveFileId'],
              'duration': data['duration'] ?? 0,
              'downloadEnabled': data['downloadEnabled'] ?? false,
              'isLocked': data['isLocked'] ?? false,
              'progress': data['progress'],
            },
          ];
        } else {
          videos.value = [];
        }

        // Select first unlocked video (or index 0)
        int targetIdx = 0;
        final selectedVideoId = Get.parameters['videoId'];
        if (selectedVideoId != null) {
          final foundIdx = videos.indexWhere((v) => v['id'] == selectedVideoId);
          if (foundIdx != -1) targetIdx = foundIdx;
        }

        currentVideoIndex.value = targetIdx;
        if (videos.isNotEmpty) {
          await _loadVideo(targetIdx, autoPlay: false);
        }

        fetchNotes(id);
      } else {
        errorMessage.value = 'Failed to load lesson details';
      }
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        if (resData is Map && resData['message'] != null) {
          errorMessage.value = resData['message'].toString();
        } else if (e.response?.statusCode == 403) {
          errorMessage.value =
              'Access denied. Enrollment required to access this lesson.';
        } else {
          errorMessage.value = AppErrorHandler.getErrorMessage(
            e,
            defaultMessage: 'Failed to load lesson details. Please try again.',
          );
        }
      } else {
        errorMessage.value = AppErrorHandler.getErrorMessage(
          e,
          defaultMessage: 'Failed to load lesson details. Please try again.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectVideo(int index) async {
    if (index < 0 || index >= videos.length) return;
    if (index == currentVideoIndex.value &&
        (betterPlayerController != null || youtubeController != null)) {
      return;
    }

    // Check lock status
    final video = videos[index];
    if (video['isLocked'] == true) {
      AppToast.validation(
        'Please complete the previous video to unlock this lecture.',
        title: 'Video Locked',
      );
      return;
    }

    _syncProgressOnClose();
    currentVideoIndex.value = index;
    await _loadVideo(index, autoPlay: true);
  }

  Future<void> _loadVideo(int index, {bool autoPlay = false}) async {
    if (index >= videos.length) return;
    final video = videos[index];
    activeVideoId.value = video['id']?.toString();

    int startSeconds = 0;
    if (video['progress'] != null &&
        video['progress']['watchedSeconds'] != null) {
      startSeconds = video['progress']['watchedSeconds'] as int;
      _lastSyncedPosition = startSeconds;
    }
    _latestPosition = startSeconds;
    maxWatchedSeconds = startSeconds;

    if (video['progress'] != null && video['progress']['completed'] != null) {
      isCompleted.value = video['progress']['completed'] as bool;
    } else {
      isCompleted.value = false;
    }

    final driveFileId = video['driveFileId']?.toString() ?? '';
    await _initializeVideoPlayer(
      driveFileId,
      startSeconds: startSeconds,
      autoPlay: autoPlay,
    );
  }

  bool get isVideoPlayerSupported =>
      GetPlatform.isAndroid || GetPlatform.isIOS || GetPlatform.isWeb;

  static String? extractYoutubeId(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final clean = raw.trim();

    // Comprehensive YouTube URL matching patterns (including watch, live, shorts, embeds, v, etc.)
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|shorts|live)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );

    final match = regExp.firstMatch(clean);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    // If it's already a bare 11-character YouTube video ID
    final bareRegExp = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    if (bareRegExp.hasMatch(clean)) {
      return clean;
    }

    return null;
  }

  Future<void> _initializeVideoPlayer(
    String driveFileId, {
    int startSeconds = 0,
    bool autoPlay = false,
  }) async {
    if (!isVideoPlayerSupported) return;

    // Safely clean previous controllers and timers
    _youtubeSeekTimer?.cancel();
    _youtubeSeekTimer = null;
    try {
      youtubeController?.dispose();
    } catch (_) {}
    youtubeController = null;

    try {
      betterPlayerController?.dispose();
    } catch (_) {}
    betterPlayerController = null;

    final downloadService = Get.find<VideoDownloadService>();
    final isDownloadedOffline = downloadService.isDownloaded(
      _currentLessonId ?? '',
    );

    // Branch to YouTube if online and valid YouTube ID/URL is found
    final String? youtubeId = isDownloadedOffline
        ? null
        : extractYoutubeId(driveFileId);
    debugPrint(
      '[DEBUG_YOUTUBE] driveFileId: "$driveFileId", extracted youtubeId: "$youtubeId"',
    );

    if (youtubeId != null) {
      youtubeController = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: YoutubePlayerFlags(
          autoPlay: autoPlay,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: true,
          enableCaption: false,
          startAt: startSeconds,
          showLiveFullscreenButton: false,
          hideThumbnail: true,
        ),
      );

      _youtubeSeekTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (youtubeController == null) return;
        final currentPos = youtubeController!.value.position.inSeconds;
        final totalDuration = youtubeController!.metadata.duration.inSeconds;

        if (currentPos > 0) {
          // Restrict seeking forward beyond watched limit
          if (currentPos > maxWatchedSeconds + 3) {
            youtubeController!.seekTo(Duration(seconds: maxWatchedSeconds));
            AppToast.error('Skipping forward is restricted');
          } else {
            if (currentPos > maxWatchedSeconds) {
              maxWatchedSeconds = currentPos;
            }
            _latestPosition = currentPos;

            // Auto completion at 90%
            if (!isCompleted.value &&
                totalDuration > 0 &&
                currentPos >= (totalDuration * 0.9)) {
              isCompleted.value = true;
              _syncProgress(currentPos);
              _handleAutoAdvance();
            } else if ((currentPos - _lastSyncedPosition).abs() >= 30) {
              _syncProgress(currentPos);
            }
          }
        }
      });

      youtubeController!.addListener(() {
        if (youtubeController == null) return;
        if (youtubeController!.value.playerState == PlayerState.ended) {
          if (!isCompleted.value) {
            isCompleted.value = true;
            _syncProgress(_latestPosition);
          }
          _handleAutoAdvance();
        }
      });

      update();
      return;
    }

    // BetterPlayer path for legacy Drive videos or offline downloads
    final BetterPlayerDataSource dataSource;

    if (isDownloadedOffline) {
      final localPath = downloadService.getLocalVideoPath(
        _currentLessonId ?? '',
      );
      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        localPath!,
      );
    } else {
      String videoUrl = driveFileId;
      Map<String, String>? headers;

      if (driveFileId.isEmpty) {
        videoUrl =
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
      } else {
        String extractedId = driveFileId;
        final bool isGoogleDriveUrl = driveFileId.contains('drive.google.com');

        if (isGoogleDriveUrl) {
          final regExp1 = RegExp(r'/file/d/([a-zA-Z0-9-_]+)');
          final match1 = regExp1.firstMatch(driveFileId);
          if (match1 != null && match1.groupCount >= 1) {
            extractedId = match1.group(1)!;
          } else {
            final regExp2 = RegExp(r'[?&]id=([a-zA-Z0-9-_]+)');
            final match2 = regExp2.firstMatch(driveFileId);
            if (match2 != null && match2.groupCount >= 1) {
              extractedId = match2.group(1)!;
            }
          }
        }

        if (isGoogleDriveUrl || !driveFileId.startsWith('http')) {
          final token = await Get.find<SecureStorageService>().getAccessToken();
          final tokenQuery = (token != null && token.isNotEmpty)
              ? '?token=$token'
              : '';
          videoUrl =
              '${ApiConstants.baseUrl}/lessons/stream/$extractedId$tokenQuery';
          if (token != null) {
            headers = {'Authorization': 'Bearer $token'};
          }
        }
      }

      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        videoUrl,
        headers: headers,
      );
    }

    betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: autoPlay,
        looping: false,
        startAt: Duration(seconds: startSeconds),
        placeholder: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: true,
          enableProgressText: true,
          enableProgressBar: true,
          enableProgressBarDrag: true,
          enablePlayPause: true,
          enableMute: true,
          enableFullscreen: true,
          enablePlaybackSpeed: true,
          enableOverflowMenu: false,
          enableQualities: false,
          enableSubtitles: false,
          controlBarColor: Colors.black.withValues(alpha: 0.7),
          progressBarPlayedColor: AppColors.accent,
          progressBarHandleColor: AppColors.accent,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    betterPlayerController!.addEventsListener((BetterPlayerEvent event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        if (startSeconds > 0) {
          betterPlayerController!.seekTo(Duration(seconds: startSeconds));
        }
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        final videoPlayerController =
            betterPlayerController!.videoPlayerController;
        if (videoPlayerController != null) {
          final currentPos = videoPlayerController.value.position.inSeconds;
          final totalDuration =
              videoPlayerController.value.duration?.inSeconds ?? 0;

          if (currentPos > 0) {
            // Restrict seeking forward beyond watched limit
            if (currentPos > maxWatchedSeconds + 3) {
              betterPlayerController!.seekTo(
                Duration(seconds: maxWatchedSeconds),
              );
              AppToast.error('Skipping forward is restricted');
            } else {
              if (currentPos > maxWatchedSeconds) {
                maxWatchedSeconds = currentPos;
              }
              _latestPosition = currentPos;

              // Auto completion at 90%
              if (!isCompleted.value &&
                  totalDuration > 0 &&
                  currentPos >= (totalDuration * 0.9)) {
                isCompleted.value = true;
                _syncProgress(currentPos);
                _handleAutoAdvance();
              } else if ((currentPos - _lastSyncedPosition).abs() >= 30) {
                _syncProgress(currentPos);
              }
            }
          }
        }
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        if (!isCompleted.value) {
          isCompleted.value = true;
          _syncProgress(_latestPosition);
        }
        _handleAutoAdvance();
      }
    });
    update();
  }

  Future<void> _syncProgress(int currentPos) async {
    if (_currentLessonId == null) return;
    _lastSyncedPosition = currentPos;
    try {
      await _repository.updateProgress(
        lessonId: _currentLessonId,
        videoId: activeVideoId.value,
        watchedSeconds: currentPos,
      );
    } catch (e) {
      debugPrint('Failed to sync progress: $e');
    }
  }

  void _syncProgressOnClose() {
    if (_latestPosition > 0 && _latestPosition != _lastSyncedPosition) {
      _syncProgress(_latestPosition);
    }
  }

  Future<void> fetchNotes(String lessonId) async {
    try {
      isLoadingNotes.value = true;
      final response = await _notesRepository.getNotesByLesson(lessonId);
      if (response.statusCode == 200) {
        notes.value = List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    } finally {
      isLoadingNotes.value = false;
    }
  }

  Future<void> addNote(String content) async {
    if (_currentLessonId == null || content.trim().isEmpty) return;
    try {
      int currentPos = 0;
      if (betterPlayerController != null) {
        currentPos =
            betterPlayerController
                ?.videoPlayerController
                ?.value
                .position
                .inSeconds ??
            0;
      } else if (youtubeController != null) {
        currentPos = youtubeController?.value.position.inSeconds ?? 0;
      }
      final response = await _notesRepository.createNote(
        lessonId: _currentLessonId!,
        timestamp: currentPos,
        content: content.trim(),
      );
      if (response.statusCode == 201) {
        fetchNotes(_currentLessonId!);
        AppToast.success('Note added successfully!');
      }
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }

  Future<void> editNote(String id, String content) async {
    if (_currentLessonId == null || content.trim().isEmpty) return;
    try {
      final response = await _notesRepository.updateNote(
        id: id,
        content: content.trim(),
      );
      if (response.statusCode == 200) {
        fetchNotes(_currentLessonId!);
        AppToast.success('Note updated successfully!');
      }
    } catch (e) {
      debugPrint('Error editing note: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    if (_currentLessonId == null) return;
    try {
      final response = await _notesRepository.deleteNote(id);
      if (response.statusCode == 200) {
        fetchNotes(_currentLessonId!);
        AppToast.success('Note deleted successfully!');
      }
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }

  void seekToTimestamp(int seconds) {
    if (isVideoPlayerSupported) {
      if (betterPlayerController != null) {
        betterPlayerController!.seekTo(Duration(seconds: seconds));
        betterPlayerController!.play();
      } else if (youtubeController != null) {
        youtubeController!.seekTo(Duration(seconds: seconds));
        youtubeController!.play();
      }
    }
  }

  void seekBackward([int seconds = 10]) {
    if (isVideoPlayerSupported) {
      if (betterPlayerController != null) {
        final videoPlayerController =
            betterPlayerController!.videoPlayerController;
        if (videoPlayerController != null) {
          final currentPos = videoPlayerController.value.position.inSeconds;
          final targetPos = (currentPos - seconds).clamp(
            0,
            videoPlayerController.value.duration?.inSeconds ?? currentPos,
          );
          betterPlayerController!.seekTo(Duration(seconds: targetPos));
        }
      } else if (youtubeController != null) {
        final currentPos = youtubeController!.value.position.inSeconds;
        final targetPos = (currentPos - seconds).clamp(0, double.maxFinite.toInt());
        youtubeController!.seekTo(Duration(seconds: targetPos));
      }
    }
  }

  void seekForward([int seconds = 10]) {
    if (isVideoPlayerSupported) {
      if (betterPlayerController != null) {
        final videoPlayerController =
            betterPlayerController!.videoPlayerController;
        if (videoPlayerController != null) {
          final currentPos = videoPlayerController.value.position.inSeconds;
          final targetPos = currentPos + seconds;
          if (targetPos > maxWatchedSeconds + 3) {
            AppToast.error('Skipping forward is restricted');
          } else {
            betterPlayerController!.seekTo(Duration(seconds: targetPos));
          }
        }
      } else if (youtubeController != null) {
        final currentPos = youtubeController!.value.position.inSeconds;
        final targetPos = currentPos + seconds;
        if (targetPos > maxWatchedSeconds + 3) {
          AppToast.error('Skipping forward is restricted');
        } else {
          youtubeController!.seekTo(Duration(seconds: targetPos));
        }
      }
    }
  }

  Future<void> markLessonAsComplete() async {
    if (_currentLessonId == null) return;
    try {
      final response = await _repository.markAsComplete(
        lessonId: _currentLessonId,
        videoId: activeVideoId.value,
      );
      if (response.statusCode == 200) {
        isCompleted.value = true;
        AppToast.success('Video marked as complete!');
        _handleAutoAdvance();
      }
    } catch (e) {
      AppToast.error(
        AppErrorHandler.getErrorMessage(
          e,
          defaultMessage: 'Failed to mark video as complete',
        ),
      );
    }
  }

  void _handleAutoAdvance() {
    final nextIndex = currentVideoIndex.value + 1;
    if (nextIndex < videos.length) {
      final nextVideo = videos[nextIndex];
      if (nextVideo['isLocked'] != true) {
        selectVideo(nextIndex);
      }
    }
  }

  Future<void> startVideoDownload() async {
    final video = currentVideo;
    if (video == null) return;

    final downloadService = Get.find<VideoDownloadService>();
    final secureStorage = Get.find<SecureStorageService>();
    final customPath = await secureStorage.getDownloadDirPath();

    if (customPath == null || customPath.isEmpty) {
      final bool picked = await _promptAndSelectDownloadDirectory(
        downloadService,
      );
      if (!picked) {
        AppToast.error('Download cancelled. Please select a download folder.');
        return;
      }
    }

    final driveFileId = video['driveFileId']?.toString() ?? '';
    if (driveFileId.isEmpty) {
      AppToast.error('No video source file found.');
      return;
    }

    String videoUrl = driveFileId;
    Map<String, String>? headers;

    String extractedId = driveFileId;
    final bool isGoogleDriveUrl = driveFileId.contains('drive.google.com');

    if (isGoogleDriveUrl) {
      final regExp1 = RegExp(r'/file/d/([a-zA-Z0-9-_]+)');
      final match1 = regExp1.firstMatch(driveFileId);
      if (match1 != null && match1.groupCount >= 1) {
        extractedId = match1.group(1)!;
      } else {
        final regExp2 = RegExp(r'[?&]id=([a-zA-Z0-9-_]+)');
        final match2 = regExp2.firstMatch(driveFileId);
        if (match2 != null && match2.groupCount >= 1) {
          extractedId = match2.group(1)!;
        }
      }
    }

    if (isGoogleDriveUrl || !driveFileId.startsWith('http')) {
      final token = await Get.find<SecureStorageService>().getAccessToken();
      final tokenQuery = (token != null && token.isNotEmpty)
          ? '?token=$token'
          : '';
      videoUrl =
          '${ApiConstants.baseUrl}/lessons/stream/$extractedId$tokenQuery';
      if (token != null) {
        headers = {'Authorization': 'Bearer $token'};
      }
    }

    final vidId = video['id']?.toString() ?? _currentLessonId!;

    await downloadService.downloadVideo(
      vidId,
      videoUrl,
      headers: headers,
      onComplete: () async {
        try {
          await _repository.logVideoDownload(
            lessonId: _currentLessonId,
            videoId: vidId,
          );
        } catch (e) {
          debugPrint('Failed to log video download on backend: $e');
        }
        AppToast.success('Video downloaded successfully for offline viewing!');
        int startSecs = 0;
        if (betterPlayerController != null) {
          startSecs =
              betterPlayerController
                  ?.videoPlayerController
                  ?.value
                  .position
                  .inSeconds ??
              0;
        } else if (youtubeController != null) {
          startSecs = youtubeController?.value.position.inSeconds ?? 0;
        }
        betterPlayerController?.dispose();
        await _initializeVideoPlayer(driveFileId, startSeconds: startSecs);
        update();
      },
      onError: (err) {
        AppToast.error(
          AppErrorHandler.getErrorMessage(
            err,
            defaultMessage: 'Failed to download video',
          ),
        );
      },
    );
  }

  Future<void> deleteDownloadedVideo() async {
    final video = currentVideo;
    if (video == null) return;
    final vidId = video['id']?.toString() ?? _currentLessonId!;
    final downloadService = Get.find<VideoDownloadService>();
    await downloadService.deleteVideo(vidId);
    AppToast.info('Local offline video deleted successfully.');
    final driveFileId = video['driveFileId']?.toString() ?? '';
    int startSecs = 0;
    if (betterPlayerController != null) {
      startSecs =
          betterPlayerController
              ?.videoPlayerController
              ?.value
              .position
              .inSeconds ??
              0;
    } else if (youtubeController != null) {
      startSecs = youtubeController?.value.position.inSeconds ?? 0;
    }
    betterPlayerController?.dispose();
    await _initializeVideoPlayer(driveFileId, startSeconds: startSecs);
    update();
  }

  Future<bool> _promptAndSelectDownloadDirectory(
    VideoDownloadService downloadService,
  ) async {
    bool confirm = false;
    await Get.dialog(
      AlertDialog(
        title: const Text('Select Download Folder'),
        content: const Text(
          'To download lessons offline, please select a storage folder on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              confirm = true;
              Get.back();
            },
            child: const Text(
              'Choose Folder',
              style: TextStyle(
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (!confirm) return false;

    try {
      final String? selectedDirectory = await FilePicker.getDirectoryPath();
      if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
        final success = await downloadService.setCustomDownloadDirectory(
          selectedDirectory,
        );
        if (success) {
          AppToast.success('Download folder configured successfully!');
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error selecting download directory: $e');
    }
    return false;
  }

  @override
  void onClose() {
    _syncProgressOnClose();
    _youtubeSeekTimer?.cancel();
    _youtubeSeekTimer = null;
    if (isVideoPlayerSupported) {
      try {
        betterPlayerController?.dispose();
      } catch (_) {}
      betterPlayerController = null;
      try {
        youtubeController?.dispose();
      } catch (_) {}
      youtubeController = null;
    }
    _currentLessonId = null;
    lessonData.value = null;
    super.onClose();
  }
}
