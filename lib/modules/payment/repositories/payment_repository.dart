import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class PaymentRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<Response> getPaymentSettings() async {
    return await _apiClient.get(ApiConstants.paymentSettingsPublic);
  }

  Future<Response> checkExistingRequest({
    required String linkType,
    required String linkId,
  }) async {
    return await _apiClient.get(
      ApiConstants.myPaymentRequests,
      queryParameters: {
        'linkType': linkType,
        'linkId': linkId,
      },
    );
  }

  Future<Response> submitPaymentRequest({
    required String linkType,
    required String linkId,
    required double amount,
    required File screenshotFile,
  }) async {
    final fileName = screenshotFile.path.split('/').last;
    final formData = FormData.fromMap({
      'linkType': linkType,
      'linkId': linkId,
      'amount': amount,
      'file': await MultipartFile.fromFile(
        screenshotFile.path,
        filename: fileName,
      ),
    });

    return await _apiClient.post(
      ApiConstants.paymentRequests,
      data: formData,
    );
  }
}
