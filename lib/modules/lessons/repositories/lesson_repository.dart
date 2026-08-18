import 'package:dio/dio.dart' as dio_instance;
import '../../../core/network/api_client.dart';

class LessonRepository {
  final ApiClient _apiClient;

  LessonRepository(this._apiClient);

  Future<dio_instance.Response> getLessonById(String id) async {
    return await _apiClient.get('/lessons/$id');
  }

  Future<dio_instance.Response> getVideoById(String id) async {
    return await _apiClient.get('/videos/$id');
  }

  Future<dio_instance.Response> updateProgress({
    String? lessonId,
    String? videoId,
    required int watchedSeconds,
  }) async {
    final Map<String, dynamic> body = {
      'watchedSeconds': watchedSeconds,
    };
    if (lessonId != null) body['lessonId'] = lessonId;
    if (videoId != null) body['videoId'] = videoId;

    return await _apiClient.post(
      '/progress/update',
      data: body,
    );
  }

  Future<dio_instance.Response> markAsComplete({
    String? lessonId,
    String? videoId,
  }) async {
    final Map<String, dynamic> body = {};
    if (lessonId != null) body['lessonId'] = lessonId;
    if (videoId != null) body['videoId'] = videoId;

    return await _apiClient.post(
      '/progress/complete',
      data: body,
    );
  }

  Future<dio_instance.Response> logVideoDownload({
    String? lessonId,
    String? videoId,
  }) async {
    if (videoId != null) {
      return await _apiClient.post('/videos/$videoId/download');
    }
    return await _apiClient.post('/lessons/$lessonId/download');
  }
}
