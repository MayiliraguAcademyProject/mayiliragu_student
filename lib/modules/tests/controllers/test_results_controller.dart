import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/tests_repository.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/services/secure_storage_service.dart';
import '../models/test_attempt_result_model.dart';
import '../views/widgets/test_feedback_dialog.dart';

class TestResultsController extends GetxController {
  final TestsRepository _testsRepository = Get.find<TestsRepository>();

  TestResultsController();

  // Observable Result Model
  final Rxn<TestAttemptResultModel> result = Rxn<TestAttemptResultModel>();
  final isLoading = false.obs;
  bool _hasPromptedFeedback = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      result.value = TestAttemptResultModel.fromJson(args);
      if (result.value != null && result.value!.attemptId.isNotEmpty) {
        fetchAttemptDetails(result.value!.attemptId);
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    _autoPromptFeedback();
  }

  Future<void> _autoPromptFeedback() async {
    if (_hasPromptedFeedback) return;
    _hasPromptedFeedback = true;

    final testId = result.value?.testId;
    if (testId == null || testId.isEmpty) return;

    if (Get.isRegistered<SecureStorageService>()) {
      final storage = Get.find<SecureStorageService>();
      final alreadyDone = await storage.hasCompletedTestFeedback(testId);
      if (alreadyDone) return;
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (Get.context != null) {
        showFeedbackDialog(Get.context!);
      }
    });
  }

  void showFeedbackDialog(BuildContext context) {
    TestFeedbackDialog.show(
      context,
      onSkip: () => markFeedbackCompleted(),
      onSubmit: (rating, suggestion) {
        submitFeedback(rating, suggestion);
      },
    );
  }

  Future<void> markFeedbackCompleted() async {
    final testId = result.value?.testId;
    if (testId != null && testId.isNotEmpty && Get.isRegistered<SecureStorageService>()) {
      final storage = Get.find<SecureStorageService>();
      await storage.markTestFeedbackCompleted(testId);
    }
  }

  Future<void> submitFeedback(int rating, String suggestion) async {
    final testId = result.value?.testId;
    if (testId == null || testId.isEmpty) return;

    await markFeedbackCompleted();

    try {
      final response = await _testsRepository.submitTestReview(testId, rating, suggestion);
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.success(
          'Thank you! Your $rating-star rating and feedback have been submitted.',
          title: 'Feedback Submitted',
        );
      }
    } catch (e) {
      print('Error submitting test review: $e');
    }
  }

  Future<void> fetchAttemptDetails(String id) async {
    try {
      isLoading.value = true;
      final response = await _testsRepository.getAttemptDetails(id);
      final data = response.data['data'] ?? response.data;
      if (data != null) {
        result.value = TestAttemptResultModel.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      print('Error fetching attempt details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String get timeTakenFormatted {
    if (result.value == null) return '0m';
    return _formatSeconds(result.value!.timeTaken);
  }

  String _formatSeconds(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    
    if (hours > 0) {
      final String minsStr = minutes.toString().padLeft(2, '0');
      return '${hours}h ${minsStr}m';
    }
    return '${minutes}m';
  }

  void retakeTest() {
    if (result.value != null && result.value!.testId.isNotEmpty) {
      // Clear navigation history and launch test runner
      Get.offNamed('/test-runner', arguments: result.value!.testId);
    }
  }

  void viewSolutions() {
    if (result.value != null && result.value!.attemptId.isNotEmpty) {
      Get.toNamed('/test-solutions', arguments: {
        'attempt_id': result.value!.attemptId,
        'test_title': result.value!.testTitle,
      });
    } else {
      AppToast.error(
        'Detailed solutions are not available for offline attempts.',
        title: 'Solutions Unavailable',
      );
    }
  }

  void detailedAnalysis() {
    AppToast.info(
      'Detailed analysis report is being generated.',
      title: 'Detailed Analysis',
    );
  }
}
