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

  Future<Response> register({
    required String name,
    required String email,
    required String password,
    String? mobileNumber,
  }) async {
    return await _apiClient.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'mobileNumber': mobileNumber,
      }..removeWhere((k, v) => v == null),
    );
  }

  Future<Response> verifyOtp({
    required String email,
    required String otp,
    String? deviceId,
    String? deviceName,
  }) async {
    return await _apiClient.post(
      ApiConstants.verifyOtp,
      data: {
        'email': email,
        'otp': otp,
        'deviceId': deviceId,
        'deviceName': deviceName,
      }..removeWhere((k, v) => v == null),
    );
  }

  Future<Response> resendOtp({required String email}) async {
    return await _apiClient.post(
      ApiConstants.resendOtp,
      data: {'email': email},
    );
  }

  Future<Response> guestLogin() async {
    return await _apiClient.post(ApiConstants.guest);
  }

  Future<Response> logout() async {
    return await _apiClient.post(ApiConstants.logout);
  }

  Future<Response> getStudentProfile(String userId) async {
    return await _apiClient.get('/enrollments/students/$userId/profile');
  }
}
