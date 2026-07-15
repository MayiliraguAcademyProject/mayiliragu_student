import 'package:dio/dio.dart' as dio_instance;
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class LessonRepository {
  final ApiClient _apiClient;

  LessonRepository(this._apiClient);

  Future<dio_instance.Response> getLessonById(String id) async {
    return await _apiClient.get(ApiConstants.lessonDetails(id));
  }

  Future<dio_instance.Response> updateProgress(String lessonId, int watchedSeconds) async {
    return await _apiClient.post(
      ApiConstants.updateProgress,
      data: {
        'lessonId': lessonId,
        'watchedSeconds': watchedSeconds,
      },
    );
  }

  Future<dio_instance.Response> markAsComplete(String lessonId) async {
    return await _apiClient.post(
      ApiConstants.markComplete,
      data: {
        'lessonId': lessonId,
      },
    );
  }

  Future<dio_instance.Response> logVideoDownload(String lessonId) async {
    return await _apiClient.post(ApiConstants.downloadLesson(lessonId));
  }

  Future<dio_instance.Response> getSignedVideoUrl(String lessonId) async {
    return await _apiClient.get(ApiConstants.signedVideoUrl(lessonId));
  }
}
