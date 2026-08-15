import 'package:dio/dio.dart' as dio_instance;
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class CourseRepository {
  final ApiClient _apiClient;

  CourseRepository(this._apiClient);

  Future<dio_instance.Response> getCourses({required int page, required int limit, bool? isDemo}) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (isDemo != null) {
      queryParams['isDemo'] = isDemo;
    }
    return await _apiClient.get(
      ApiConstants.courses,
      queryParameters: queryParams,
    );
  }

  Future<dio_instance.Response> getCourseById(String id) async {
    return await _apiClient.get('${ApiConstants.courses}/$id');
  }

  Future<dio_instance.Response> submitEnrollmentRequest(String courseId, {String? message}) async {
    return await _apiClient.post(
      '/enrollment-requests',
      data: {
        'courseId': courseId,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
  }
}
