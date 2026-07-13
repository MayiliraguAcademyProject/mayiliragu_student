import 'package:get/get.dart';
import '../repositories/tests_repository.dart';
import '../../../core/utils/toast_helper.dart';
import '../models/test_attempt_result_model.dart';

class TestResultsController extends GetxController {
  final TestsRepository _testsRepository = Get.find<TestsRepository>();

  TestResultsController();

  // Observable Result Model
  final Rxn<TestAttemptResultModel> result = Rxn<TestAttemptResultModel>();
  final isLoading = false.obs;

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
