import 'package:dio/dio.dart' as dio_instance;
import '../../../core/network/api_client.dart';

class TestsRepository {
  final ApiClient _apiClient;

  TestsRepository(this._apiClient);

  Future<dio_instance.Response> getTests({
    String? categoryId,
    String? subjectId,
    String? topicId,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (subjectId != null && subjectId.isNotEmpty) {
      queryParams['subjectId'] = subjectId;
    }
    if (topicId != null && topicId.isNotEmpty) {
      queryParams['topicId'] = topicId;
    }

    return await _apiClient.get(
      '/tests',
      queryParameters: queryParams,
    );
  }

  Future<dio_instance.Response> getTestById(String testId) async {
    return await _apiClient.get('/tests/$testId');
  }

  Future<dio_instance.Response> submitTestAttempt(String testId, Map<String, dynamic> payload) async {
    return await _apiClient.post('/tests/$testId/submit', data: payload);
  }

  Future<dio_instance.Response> getAttemptDetails(String attemptId) async {
    return await _apiClient.get('/tests/attempts/$attemptId');
  }

  Future<dio_instance.Response> getCategories() async {
    return await _apiClient.get('/tests/categories');
  }
}
