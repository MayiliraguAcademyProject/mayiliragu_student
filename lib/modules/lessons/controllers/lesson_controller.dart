import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:better_player_enhanced/better_player.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/video_download_service.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/utils/error_handler.dart';
import '../repositories/lesson_repository.dart';
import '../repositories/notes_repository.dart';

class LessonController extends GetxController {
  final LessonRepository _repository;
  final NotesRepository _notesRepository;

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final lessonData = Rxn<Map<String, dynamic>>();

  // Tab index: 0 = Notes, 1 = Resources
  final activeTabIndex = 0.obs;

  // Completion status
  final isCompleted = false.obs;

  // Study notes list state
  final notes = <Map<String, dynamic>>[].obs;
  final isLoadingNotes = false.obs;

  BetterPlayerController? betterPlayerController;

  String? _currentLessonId;
  int _lastSyncedPosition = 0;
  int _latestPosition = 0;
  int maxWatchedSeconds = 0;

  LessonController(this._repository, this._notesRepository);

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
    final String? lessonId = _extractLessonId();
    if (lessonId != null &&
        (lessonId != _currentLessonId || lessonData.value == null)) {
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
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _currentLessonId = id;
      _lastSyncedPosition = 0;

      final response = await _repository.getLessonById(id);

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data['data']);
        lessonData.value = data;

        int startSeconds = 0;
        if (data['progress'] != null &&
            data['progress']['watchedSeconds'] != null) {
          startSeconds = data['progress']['watchedSeconds'] as int;
          _lastSyncedPosition = startSeconds;
        }
        _latestPosition = startSeconds;
        maxWatchedSeconds = startSeconds;

        if (data['progress'] != null && data['progress']['completed'] != null) {
          isCompleted.value = data['progress']['completed'] as bool;
        }

        final driveFileId = data['driveFileId']?.toString() ?? '';
        await _initializeVideoPlayer(driveFileId, startSeconds: startSeconds);
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
          errorMessage.value = 'Access denied. Enrollment required to access this lesson.';
        } else {
          errorMessage.value = 'Failed to load lesson details. Please try again.';
        }
      } else {
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool get isVideoPlayerSupported =>
      GetPlatform.isAndroid || GetPlatform.isIOS || GetPlatform.isWeb;

  Future<void> _initializeVideoPlayer(
    String driveFileId, {
    int startSeconds = 0,
  }) async {
    if (!isVideoPlayerSupported) {
      return;
    }

    final downloadService = Get.find<VideoDownloadService>();
    final isDownloadedOffline = downloadService.isDownloaded(
      _currentLessonId ?? '',
    );
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
      // If the driveFileId is already a full URL (or for fallback test stream)
      String videoUrl = driveFileId;
      Map<String, String>? headers;

      if (driveFileId.isEmpty) {
        // Fallback test video stream if none provided
        videoUrl =
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
      } else {
        String extractedId = driveFileId;
        final bool isGoogleDriveUrl = driveFileId.contains('drive.google.com');

        if (isGoogleDriveUrl) {
          // Extract the file ID from Google Drive URL patterns:
          // 1. /file/d/FILE_ID/view...
          final regExp1 = RegExp(r'/file/d/([a-zA-Z0-9-_]+)');
          final match1 = regExp1.firstMatch(driveFileId);
          if (match1 != null && match1.groupCount >= 1) {
            extractedId = match1.group(1)!;
          } else {
            // 2. ?id=FILE_ID or &id=FILE_ID
            final regExp2 = RegExp(r'[?&]id=([a-zA-Z0-9-_]+)');
            final match2 = regExp2.firstMatch(driveFileId);
            if (match2 != null && match2.groupCount >= 1) {
              extractedId = match2.group(1)!;
            }
          }
        }

        if (isGoogleDriveUrl || !driveFileId.startsWith('http')) {
          // Use backend proxy streaming endpoint
          videoUrl = '${ApiConstants.baseUrl}/lessons/stream/$extractedId';
          final token = await Get.find<SecureStorageService>().getAccessToken();
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
        autoPlay: false,
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
          if (currentPos > 0) {
            if (currentPos > maxWatchedSeconds) {
              maxWatchedSeconds = currentPos;
            }
            _latestPosition = currentPos;
            if ((currentPos - _lastSyncedPosition).abs() >= 30) {
              _syncProgress(currentPos);
            }
          }
        }
      }
    });
  }

  Future<void> _syncProgress(int currentPos) async {
    if (_currentLessonId == null) return;
    _lastSyncedPosition = currentPos;
    try {
      await _repository.updateProgress(_currentLessonId!, currentPos);
    } catch (e) {
      debugPrint('Failed to sync progress: $e');
    }
  }

  void _syncProgressOnClose() {
    if (_currentLessonId != null &&
        _latestPosition > 0 &&
        _latestPosition != _lastSyncedPosition) {
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
      final currentPos =
          betterPlayerController
              ?.videoPlayerController
              ?.value
              .position
              .inSeconds ??
          0;
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
    if (isVideoPlayerSupported && betterPlayerController != null) {
      betterPlayerController!.seekTo(Duration(seconds: seconds));
      betterPlayerController!.play();
    }
  }

  void seekBackward([int seconds = 10]) {
    if (isVideoPlayerSupported && betterPlayerController != null) {
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
    }
  }

  void seekForward([int seconds = 10]) {
    if (isVideoPlayerSupported && betterPlayerController != null) {
      final videoPlayerController =
          betterPlayerController!.videoPlayerController;
      if (videoPlayerController != null) {
        final currentPos = videoPlayerController.value.position.inSeconds;
        final targetPos = currentPos + seconds;
        betterPlayerController!.seekTo(Duration(seconds: targetPos));
      }
    }
  }

  Future<void> markLessonAsComplete() async {
    if (_currentLessonId == null) return;
    try {
      final response = await _repository.markAsComplete(_currentLessonId!);
      if (response.statusCode == 200) {
        isCompleted.value = true;
        AppToast.success('Lesson marked as complete!');
      }
    } catch (e) {
      AppToast.error(AppErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to mark lesson as complete'));
    }
  }

  Future<void> startVideoDownload() async {
    if (_currentLessonId == null || lessonData.value == null) return;

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

    final driveFileId = lessonData.value!['driveFileId']?.toString() ?? '';
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
      videoUrl = '${ApiConstants.baseUrl}/lessons/stream/$extractedId';
      final token = await Get.find<SecureStorageService>().getAccessToken();
      if (token != null) {
        headers = {'Authorization': 'Bearer $token'};
      }
    }

    await downloadService.downloadVideo(
      _currentLessonId!,
      videoUrl,
      headers: headers,
      onComplete: () async {
        try {
          await _repository.logVideoDownload(_currentLessonId!);
        } catch (e) {
          debugPrint('Failed to log video download on backend: $e');
        }
        AppToast.success('Video downloaded successfully for offline viewing!');
        // Reload player with offline file source
        final startSecs =
            betterPlayerController
                ?.videoPlayerController
                ?.value
                .position
                .inSeconds ??
            0;
        betterPlayerController?.dispose();
        await _initializeVideoPlayer(driveFileId, startSeconds: startSecs);
        update();
      },
      onError: (err) {
        AppToast.error(AppErrorHandler.getErrorMessage(err, defaultMessage: 'Failed to download video'));
      },
    );
  }

  Future<void> deleteDownloadedVideo() async {
    if (_currentLessonId == null || lessonData.value == null) return;
    final downloadService = Get.find<VideoDownloadService>();
    await downloadService.deleteVideo(_currentLessonId!);
    AppToast.info('Local offline video deleted successfully.');
    // Reload player with network source
    final driveFileId = lessonData.value!['driveFileId']?.toString() ?? '';
    final startSecs =
        betterPlayerController
            ?.videoPlayerController
            ?.value
            .position
            .inSeconds ??
        0;
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
    if (isVideoPlayerSupported) {
      betterPlayerController?.dispose();
      betterPlayerController = null;
    }
    _currentLessonId = null;
    lessonData.value = null;
    super.onClose();
  }
}
