import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SecureStorageService extends GetxService {
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userRoleKey = 'user_role';
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const _downloadDirPathKey = 'download_dir_path';

  Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: _hasSeenOnboardingKey);
    return value == 'true';
  }

  Future<void> setHasSeenOnboarding() async {
    await _storage.write(key: _hasSeenOnboardingKey, value: 'true');
  }

  Future<String?> getDownloadDirPath() async {
    return await _storage.read(key: _downloadDirPathKey);
  }

  Future<void> setDownloadDirPath(String path) async {
    await _storage.write(key: _downloadDirPathKey, value: path);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String role,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userRoleKey, value: role);
  }

  static const _themeModeKey = 'theme_mode';
  static const _isOnboardingCompletedKey = 'onboarding_completed';

  Future<String?> getThemeMode() async => await _storage.read(key: _themeModeKey);
  Future<void> setThemeMode(String mode) async => await _storage.write(key: _themeModeKey, value: mode);

  Future<bool> isOnboardingCompleted() async {
    final val = await _storage.read(key: _isOnboardingCompletedKey);
    return val == 'true';
  }
  Future<void> setIsOnboardingCompleted(bool completed) async {
    await _storage.write(key: _isOnboardingCompletedKey, value: completed.toString());
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);
  Future<String?> getUserRole() async => await _storage.read(key: _userRoleKey);

  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userRoleKey);
    await _storage.delete(key: _downloadDirPathKey);
    await _storage.delete(key: _themeModeKey);
    await _storage.delete(key: _isOnboardingCompletedKey);
  }

  Future<String?> readString(String key) async => await _storage.read(key: key);
  Future<void> writeString(String key, String value) async => await _storage.write(key: key, value: value);
  Future<void> deleteKey(String key) async => await _storage.delete(key: key);

  Future<bool> hasCompletedTestFeedback(String testId) async {
    final val = await _storage.read(key: 'test_feedback_$testId');
    return val == 'true';
  }

  Future<void> markTestFeedbackCompleted(String testId) async {
    await _storage.write(key: 'test_feedback_$testId', value: 'true');
  }

  static const _deviceIdKey = 'unique_device_id';

  Future<String> getOrCreateDeviceId() async {
    String? deviceId = await _storage.read(key: _deviceIdKey);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = 'MAYILIRAGU-DEV-${DateTime.now().millisecondsSinceEpoch}';
      await _storage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }
}
