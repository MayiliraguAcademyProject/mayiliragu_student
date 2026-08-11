import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Response> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  }) async {
    return await _apiClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
        'deviceId': deviceId,
        'deviceName': deviceName,
      }..removeWhere((k, v) => v == null),
    );
  }

  Future<Response> logout() async {
    return await _apiClient.post(ApiConstants.logout);
  }

  Future<Response> getStudentProfile(String userId) async {
    return await _apiClient.get('/enrollments/students/$userId/profile');
  }
}
