import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../models/payment_models.dart';
import '../repositories/payment_repository.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/utils/error_handler.dart';

class PaymentController extends GetxController {
  final PaymentRepository _repository;

  PaymentController(this._repository);

  final isLoadingSettings = false.obs;
  final isLoadingExisting = false.obs;
  final isSubmitting = false.obs;

  final paymentSettings = Rxn<PaymentSettingModel>();
  final existingRequest = Rxn<PaymentRequestModel>();
  final selectedImagePath = RxnString();

  Future<void> fetchPaymentSettings() async {
    try {
      isLoadingSettings.value = true;
      final response = await _repository.getPaymentSettings();
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          paymentSettings.value = PaymentSettingModel.fromJson(data);
        }
      }
    } catch (e) {
      print('Error fetching payment settings: $e');
    } finally {
      isLoadingSettings.value = false;
    }
  }

  Future<void> checkExistingRequest(String linkType, String linkId) async {
    try {
      isLoadingExisting.value = true;
      existingRequest.value = null;
      final response = await _repository.checkExistingRequest(
        linkType: linkType,
        linkId: linkId,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          existingRequest.value = PaymentRequestModel.fromJson(data.first);
        }
      }
    } catch (e) {
      print('Error checking existing payment requests: $e');
    } finally {
      isLoadingExisting.value = false;
    }
  }

  Future<void> selectScreenshot() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        selectedImagePath.value = result.files.single.path;
      }
    } catch (e) {
      AppToast.error('Failed to select screenshot');
    }
  }

  Future<bool> submitPayment({
    required String linkType,
    required String linkId,
    required double amount,
  }) async {
    if (selectedImagePath.value == null) {
      AppToast.error('Please select a payment screenshot first');
      return false;
    }

    try {
      isSubmitting.value = true;
      final response = await _repository.submitPaymentRequest(
        linkType: linkType,
        linkId: linkId,
        amount: amount,
        screenshotFile: File(selectedImagePath.value!),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        AppToast.success('Payment screenshot uploaded successfully!');
        // Refresh local request state
        await checkExistingRequest(linkType, linkId);
        selectedImagePath.value = null;
        return true;
      }
    } catch (e) {
      AppToast.error(AppErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to submit payment screenshot'), title: 'Submission Error');
    } finally {
      isSubmitting.value = false;
    }
    return false;
  }
}
