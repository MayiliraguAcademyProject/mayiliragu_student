import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../app/routes/app_routes.dart';
import '../constants/api_constants.dart';
import '../guards/guest_auth_guard.dart';
import '../services/secure_storage_service.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService _storage = Get.find<SecureStorageService>();
  bool _isRefreshing = false;
  final List<void Function(String? newToken, dynamic error)> _retryQueue = [];

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle Guest restricted mutations
          if (e.response?.statusCode == 403) {
            final resData = e.response?.data;
            if (resData is Map && resData['code'] == 'GUEST_RESTRICTED') {
              GuestAuthGuard.showForceLoginSheet();
              return handler.next(e);
            }
          }

          // Handle 401 Unauthorized -> Refresh Access Token & Retry
          if (e.response?.statusCode == 401) {
            final role = await _storage.getUserRole();
            if (role == 'GUEST') {
              await _storage.clearAll();
              Get.offAllNamed(Routes.LOGIN);
              return handler.next(e);
            }

            final requestPath = e.requestOptions.path.toLowerCase();
            final isAuthRoute = requestPath.contains('/auth/login') ||
                requestPath.contains('/auth/refresh') ||
                requestPath.contains('/auth/register') ||
                requestPath.contains('/auth/verify-otp') ||
                requestPath.contains('/auth/guest');

            if (!isAuthRoute) {
              if (_isRefreshing) {
                // Another request is already refreshing the token; queue this request
                final retryCompleter = Completer<Response>();
                _retryQueue.add((newToken, error) {
                  if (error != null) {
                    retryCompleter.completeError(error);
                  } else if (newToken != null) {
                    final newOptions = e.requestOptions;
                    newOptions.headers['Authorization'] = 'Bearer $newToken';
                    dio.fetch(newOptions).then(
                      (val) => retryCompleter.complete(val),
                      onError: (err) => retryCompleter.completeError(err),
                    );
                  } else {
                    retryCompleter.completeError(e);
                  }
                });

                try {
                  final response = await retryCompleter.future;
                  return handler.resolve(response);
                } catch (err) {
                  if (err is DioException) {
                    return handler.reject(err);
                  }
                  return handler.reject(
                    DioException(
                      requestOptions: e.requestOptions,
                      error: err,
                    ),
                  );
                }
              }

              _isRefreshing = true;

              try {
                final refreshToken = await _storage.getRefreshToken();
                if (refreshToken == null || refreshToken.isEmpty) {
                  _flushRetryQueue(null, e);
                  _isRefreshing = false;
                  await _storage.clearAll();
                  Get.offAllNamed(Routes.LOGIN);
                  return handler.next(e);
                }

                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: ApiConstants.baseUrl,
                    connectTimeout: const Duration(seconds: 10),
                    receiveTimeout: const Duration(seconds: 10),
                  ),
                );

                final refreshResponse = await refreshDio.post(
                  '/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );

                if (refreshResponse.statusCode == 200) {
                  final dynamic body = refreshResponse.data;
                  final dynamic responseData = (body is Map && body.containsKey('data')) ? body['data'] : body;

                  final String newAccessToken = responseData['accessToken']?.toString() ?? '';
                  final String newRefreshToken = responseData['refreshToken']?.toString() ?? refreshToken;
                  final String userRole = await _storage.getUserRole() ?? '';

                  if (newAccessToken.isNotEmpty) {
                    await _storage.saveTokens(
                      accessToken: newAccessToken,
                      refreshToken: newRefreshToken,
                      role: userRole,
                    );

                    // Resume all queued requests
                    _flushRetryQueue(newAccessToken, null);
                    _isRefreshing = false;

                    // Retry the failed original request with new token
                    final retryOptions = e.requestOptions;
                    retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                    try {
                      final retryResponse = await dio.fetch(retryOptions);
                      return handler.resolve(retryResponse);
                    } catch (retryErr) {
                      if (retryErr is DioException) {
                        return handler.reject(retryErr);
                      }
                      return handler.reject(
                        DioException(
                          requestOptions: retryOptions,
                          error: retryErr,
                        ),
                      );
                    }
                  }
                }

                // If response wasn't 200 or tokens empty
                throw Exception('Failed to refresh token: status ${refreshResponse.statusCode}');
              } catch (refreshErr) {
                _flushRetryQueue(null, refreshErr);
                _isRefreshing = false;
                await _storage.clearAll();
                Get.offAllNamed(Routes.LOGIN);
                return handler.next(e);
              }
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  void _flushRetryQueue(String? newToken, dynamic error) {
    for (final callback in _retryQueue) {
      callback(newToken, error);
    }
    _retryQueue.clear();
  }

  Future<bool> _shouldBlockGuestMutation(String path) async {
    if (path.startsWith('/auth') || path.startsWith(ApiConstants.login)) {
      return false;
    }
    final role = await _storage.getUserRole();
    return role == 'GUEST';
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    if (await _shouldBlockGuestMutation(path)) {
      GuestAuthGuard.showForceLoginSheet();
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'GUEST_RESTRICTED',
      );
    }
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    if (await _shouldBlockGuestMutation(path)) {
      GuestAuthGuard.showForceLoginSheet();
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'GUEST_RESTRICTED',
      );
    }
    return await dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    if (await _shouldBlockGuestMutation(path)) {
      GuestAuthGuard.showForceLoginSheet();
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'GUEST_RESTRICTED',
      );
    }
    return await dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    if (await _shouldBlockGuestMutation(path)) {
      GuestAuthGuard.showForceLoginSheet();
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.cancel,
        error: 'GUEST_RESTRICTED',
      );
    }
    return await dio.delete(path, data: data);
  }
}

