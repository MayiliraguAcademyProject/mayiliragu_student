import 'package:dio/dio.dart';

class AppErrorHandler {
  AppErrorHandler._();

  static String getErrorMessage(
    dynamic error, {
    String defaultMessage = 'An unexpected error occurred. Please try again.',
  }) {
    if (error == null) return defaultMessage;

    if (error is DioException) {
      final resData = error.response?.data;
      if (resData is Map) {
        if (resData['message'] != null &&
            resData['message'].toString().trim().isNotEmpty) {
          return resData['message'].toString().trim();
        }
        if (resData['error'] != null &&
            resData['error'].toString().trim().isNotEmpty) {
          return resData['error'].toString().trim();
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to the server. Please check your network.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Session expired. Please log in again.';
          } else if (statusCode == 403) {
            return 'Access denied. You do not have permission to access this content.';
          } else if (statusCode == 404) {
            return 'The requested content was not found.';
          } else if (statusCode != null && statusCode >= 500) {
            return 'Server is temporarily unavailable. Please try again later.';
          }
          return defaultMessage;
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return defaultMessage;
      }
    }

    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return str.replaceFirst('Exception: ', '');
    }
    if (str.contains('DioException') || str.contains('SocketException') || str.contains('HttpException')) {
      return 'Network connection error. Please try again.';
    }

    return str;
  }
}