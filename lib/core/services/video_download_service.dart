import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_lib;
import '../network/api_client.dart';
import 'secure_storage_service.dart';

class VideoDownloadService extends GetxService {
  late String _manifestPath;
  late String _baseOfflinePath;
  final Map<String, String> _manifest = {};

  // Observable download progress map: lessonId -> progress (0.0 to 1.0)
  final downloadProgress = <String, double>{}.obs;
  // Observable downloading state map: lessonId -> bool
  final isDownloading = <String, bool>{}.obs;

  Future<VideoDownloadService> init() async {
    try {
      final secureStorage = Get.find<SecureStorageService>();
      final customPath = await secureStorage.getDownloadDirPath();
      if (customPath != null && customPath.isNotEmpty && await Directory(customPath).exists()) {
        _baseOfflinePath = customPath;
      } else {
        final docDir = await getApplicationDocumentsDirectory();
        _baseOfflinePath = path_lib.join(docDir.path, 'offline_videos');
      }
      final downloadDir = Directory(_baseOfflinePath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      _manifestPath = path_lib.join(_baseOfflinePath, 'downloads_manifest.json');
      await _loadManifest();
    } catch (e) {
      debugPrint('Error initializing VideoDownloadService: $e');
    }
    return this;
  }

  Future<bool> setCustomDownloadDirectory(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _baseOfflinePath = path;
      _manifestPath = path_lib.join(_baseOfflinePath, 'downloads_manifest.json');
      _manifest.clear();
      await _loadManifest();
      final secureStorage = Get.find<SecureStorageService>();
      await secureStorage.setDownloadDirPath(path);
      return true;
    } catch (e) {
      debugPrint('Error setting custom download directory: $e');
      return false;
    }
  }

  Future<void> _loadManifest() async {
    try {
      final file = File(_manifestPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonMap = json.decode(content) as Map<String, dynamic>;
        jsonMap.forEach((key, value) {
          // If it was stored as an absolute path, normalize to basename (filename)
          final pathStr = value.toString();
          final filename = path_lib.basename(pathStr);
          _manifest[key] = filename;
        });
        await _saveManifest();
      }
    } catch (e) {
      debugPrint('Error loading downloads manifest: $e');
    }
  }

  Future<void> _saveManifest() async {
    try {
      final file = File(_manifestPath);
      await file.writeAsString(json.encode(_manifest));
    } catch (e) {
      debugPrint('Error saving downloads manifest: $e');
    }
  }

  bool isDownloaded(String lessonId) {
    if (!_manifest.containsKey(lessonId)) return false;
    final filename = _manifest[lessonId]!;
    final filePath = path_lib.join(_baseOfflinePath, filename);
    final file = File(filePath);
    return file.existsSync();
  }

  String? getLocalVideoPath(String lessonId) {
    if (!isDownloaded(lessonId)) return null;
    final filename = _manifest[lessonId]!;
    return path_lib.join(_baseOfflinePath, filename);
  }

  Future<bool> downloadVideo(
    String lessonId,
    String videoUrl, {
    Map<String, String>? headers,
    required VoidCallback onComplete,
    required Function(String error) onError,
  }) async {
    if (isDownloading[lessonId] == true) return false;

    isDownloading[lessonId] = true;
    downloadProgress[lessonId] = 0.0;

    try {
      final filename = '$lessonId.mp4';
      final localFilePath = path_lib.join(_baseOfflinePath, filename);

      await Get.find<ApiClient>().dio.download(
        videoUrl,
        localFilePath,
        options: dio_lib.Options(headers: headers),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress[lessonId] = progress;
          }
        },
      );

      // Verify file downloaded successfully and is not empty
      final file = File(localFilePath);
      if (await file.exists() && await file.length() > 0) {
        _manifest[lessonId] = filename;
        await _saveManifest();
        onComplete();
        return true;
      } else {
        throw Exception('Downloaded file is empty or missing');
      }
    } catch (e) {
      debugPrint('Error downloading video: $e');
      onError(e.toString());
      return false;
    } finally {
      isDownloading[lessonId] = false;
      downloadProgress.remove(lessonId);
    }
  }

  Future<void> deleteVideo(String lessonId) async {
    try {
      if (_manifest.containsKey(lessonId)) {
        final filename = _manifest[lessonId]!;
        final filePath = path_lib.join(_baseOfflinePath, filename);
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
        _manifest.remove(lessonId);
        await _saveManifest();
      }
    } catch (e) {
      debugPrint('Error deleting video: $e');
    }
  }
}
