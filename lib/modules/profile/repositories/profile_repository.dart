import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<Response> getProfile() async {
    return await _apiClient.get(ApiConstants.profile);
  }

  Future<Response> updateName(String name) async {
    return await _apiClient.put(
      '${ApiConstants.profile}/name',
      data: {'name': name},
    );
  }

  Future<Response> changePassword(String currentPassword, String newPassword) async {
    return await _apiClient.put(
      '${ApiConstants.profile}/password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<Response> getStudentProfile(String userId) async {
    return await _apiClient.get('/enrollments/students/$userId/profile');
  }

  Future<Response> updateStudentProfile(String userId, Map<String, dynamic> data) async {
    return await _apiClient.put(
      '/enrollments/students/$userId/profile',
      data: data,
    );
  }

  Future<Response> deleteAccount() async {
    return await _apiClient.delete(ApiConstants.profile);
  }
}
