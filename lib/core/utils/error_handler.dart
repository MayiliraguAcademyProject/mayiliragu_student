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
          final msg = resData['message'].toString().trim();
          if (!_isRawTechnicalError(msg)) return msg;
        }
        if (resData['error'] != null &&
            resData['error'].toString().trim().isNotEmpty) {
          final errStr = resData['error'].toString().trim();
          if (!_isRawTechnicalError(errStr)) return errStr;
        }
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        return 'Session expired. Please log in again.';
      } else if (statusCode == 403) {
        return 'Access denied. You do not have permission to access this content.';
      } else if (statusCode == 404) {
        return 'The requested resource was not found.';
      } else if (statusCode == 502 || statusCode == 503 || statusCode == 504) {
        return 'Server is temporarily unavailable. Please try again shortly.';
      } else if (statusCode != null && statusCode >= 500) {
        return 'Server error occurred. Please try again later.';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to the server. Please check your network.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return defaultMessage;
      }
    }

    final str = error.toString();
    if (_isRawTechnicalError(str)) {
      if (str.contains('502') || str.contains('503') || str.contains('504')) {
        return 'Server is temporarily unavailable. Please try again shortly.';
      }
      if (str.contains('500')) {
        return 'Server error occurred. Please try again later.';
      }
      return 'Unable to connect to the server. Please check your network connection.';
    }

    if (str.startsWith('Exception: ')) {
      final clean = str.replaceFirst('Exception: ', '').trim();
      return _isRawTechnicalError(clean) ? defaultMessage : clean;
    }

    return str;
  }

  static bool _isRawTechnicalError(String text) {
    final lower = text.toLowerCase();
    return lower.contains('dioexception') ||
        lower.contains('socketexception') ||
        lower.contains('httpexception') ||
        lower.contains('handshakeexception') ||
        lower.contains('requestoptions') ||
        lower.contains('validatestatus') ||
        lower.contains('status code of 502') ||
        lower.contains('bad response') ||
        lower.contains('syntaxerror') ||
        lower.contains('formatexception') ||
        lower.contains('clientexception') ||
        lower.contains('<!doctype html') ||
        lower.contains('<html');
  }
}