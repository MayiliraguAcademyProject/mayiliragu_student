import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:Mayiliragu/core/network/api_client.dart';
import 'package:Mayiliragu/core/services/secure_storage_service.dart';
import 'package:Mayiliragu/core/constants/api_constants.dart';

class MockSecureStorageService extends SecureStorageService {
  String? accessToken;
  String? refreshToken;
  String? role;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.role = role;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<String?> getUserRole() async => role;

  @override
  Future<void> clearAll() async {
    accessToken = null;
    refreshToken = null;
    role = null;
  }
}

void main() {
  test('End-to-End ApiClient Auto-Refresh Interceptor Test', () async {
    // 1. Authenticate with real server to get refresh token
    final baseDio = dio.Dio(dio.BaseOptions(baseUrl: ApiConstants.baseUrl));
    final loginResponse = await baseDio.post(
      ApiConstants.login,
      data: {'email': 'student@learning.com', 'password': 'student123'},
    );

    expect(loginResponse.statusCode, 200);
    final realRefreshToken = loginResponse.data['refreshToken'] as String;

    // 2. Set up Mock Secure Storage
    final mockStorage = MockSecureStorageService();
    mockStorage.accessToken = 'this_is_an_invalid_expired_token';
    mockStorage.refreshToken = realRefreshToken;
    mockStorage.role = 'STUDENT';

    Get.put<SecureStorageService>(mockStorage);

    // 3. Initialize ApiClient
    final apiClient = ApiClient();

    // 4. Request course list. The first request using 'invalid_expired_token' will return 401.
    // The interceptor must automatically call /auth/refresh using realRefreshToken,
    // get a new valid access token, save it to mockStorage, and retry the course request successfully.
    final coursesResponse = await apiClient.get(
      ApiConstants.courses,
      queryParameters: {'page': 1, 'limit': 10},
    );

    expect(coursesResponse.statusCode, 200);
    expect(coursesResponse.data['data'], isA<List>());

    // 5. Verify the token was indeed refreshed and saved in mockStorage
    expect(mockStorage.accessToken, isNot('this_is_an_invalid_expired_token'));
    expect(mockStorage.accessToken, isNotNull);

    print('Auto-refresh test passed successfully!');
    print('Original token was: this_is_an_invalid_expired_token');
    print('Refreshed token is: ${mockStorage.accessToken}');
  });
}
