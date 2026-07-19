import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../app/routes/app_routes.dart';
import '../constants/api_constants.dart';
import '../services/secure_storage_service.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService _storage = Get.find<SecureStorageService>();
  bool _isRefreshing = false;
  final List<void Function(String token)> _retryQueue = [];

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final requestPath = e.requestOptions.path;
            if (requestPath != ApiConstants.login && requestPath != '/auth/refresh') {
              if (_isRefreshing) {
                final retryCompleter = Completer<Response>();
                _retryQueue.add((token) {
                  e.requestOptions.headers['Authorization'] = 'Bearer $token';
                  dio.fetch(e.requestOptions).then(
                    (val) => retryCompleter.complete(val),
                    onError: (err) => retryCompleter.completeError(err),
                  );
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
                if (refreshToken != null) {
                  final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
                  final refreshResponse = await refreshDio.post(
                    '/auth/refresh',
                    data: {'refreshToken': refreshToken},
                  );

                  if (refreshResponse.statusCode == 200) {
                    final responseData = refreshResponse.data['data'];
                    final newAccessToken = responseData['accessToken'];
                    final newRefreshToken = responseData['refreshToken'];
                    final role = await _storage.getUserRole() ?? '';

                    await _storage.saveTokens(
                      accessToken: newAccessToken,
                      refreshToken: newRefreshToken,
                      role: role,
                    );

                    for (final callback in _retryQueue) {
                      callback(newAccessToken);
                    }
                    _retryQueue.clear();
                    _isRefreshing = false;

                    e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                    final retryResponse = await dio.fetch(e.requestOptions);
                    return handler.resolve(retryResponse);
                  }
                }
              } catch (err) {
                _retryQueue.clear();
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

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await dio.delete(path, data: data);
  }
}
