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

  Future<Response> guestLogin({
    required String name,
    required String phoneNumber,
    required String place,
    required String targetCourse,
    String studyMode = 'ONLINE',
  }) async {
    return await _apiClient.post(
      ApiConstants.guest,
      data: {
        'name': name.trim(),
        'phoneNumber': phoneNumber.trim(),
        'place': place.trim(),
        'targetCourse': targetCourse.trim(),
        'studyMode': studyMode,
      },
    );
  }

  Future<Response> logout() async {
    return await _apiClient.post(ApiConstants.logout);
  }

  Future<Response> getStudentProfile(String userId) async {
    return await _apiClient.get('/enrollments/students/$userId/profile');
  }

  Future<Response> forgotPassword({required String email}) async {
    return await _apiClient.post(
      ApiConstants.forgotPassword,
      data: {'email': email.trim()},
    );
  }

  Future<Response> forgotPasswordResendOtp({required String email}) async {
    return await _apiClient.post(
      ApiConstants.forgotPasswordResendOtp,
      data: {'email': email.trim()},
    );
  }

  Future<Response> forgotPasswordVerifyOtp({
    required String email,
    required String otp,
  }) async {
    return await _apiClient.post(
      ApiConstants.forgotPasswordVerifyOtp,
      data: {
        'email': email.trim(),
        'otp': otp.trim(),
      },
    );
  }

  Future<Response> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    return await _apiClient.post(
      ApiConstants.resetPassword,
      data: {
        'resetToken': resetToken,
        'newPassword': newPassword,
      },
    );
  }
}

