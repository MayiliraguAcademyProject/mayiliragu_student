import 'package:get/get.dart';
import '../repositories/tests_repository.dart';
import '../../../core/utils/toast_helper.dart';

class TestResultsController extends GetxController {
  final TestsRepository _testsRepository = Get.find<TestsRepository>();

  TestResultsController();

  // States
  final testId = ''.obs;
  final attemptId = ''.obs;
  final testTitle = 'Practice Test'.obs;
  final score = 0.obs;
  final correctCount = 0.obs;
  final wrongCount = 0.obs;
  final skippedCount = 0.obs;
  final accuracy = 0.obs;
  final timeTakenFormatted = '0m'.obs;
  final rank = 0.obs;
  final passed = false.obs;

  final classAvg = 0.obs;
  final topScore = 0.obs;

  final subjectPerformance = <Map<String, dynamic>>[].obs;
  final sectionBreakdowns = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      testId.value = args['test_id'] ?? '';
      attemptId.value = args['id'] ?? args['attempt_id'] ?? '';
      testTitle.value = args['test_title'] ?? 'Practice Test';
      score.value = args['score'] ?? 0;
      correctCount.value = args['correct'] ?? 0;
      wrongCount.value = args['wrong'] ?? 0;
      skippedCount.value = args['skipped'] ?? 0;
      accuracy.value = args['accuracy'] ?? 0;
      passed.value = args['passed'] ?? false;
      rank.value = args['rank'] ?? 0;
      classAvg.value = args['class_avg'] ?? 0;
      topScore.value = args['top_score'] ?? 0;

      final int timeSeconds = args['time_taken'] ?? 0;
      timeTakenFormatted.value = _formatSeconds(timeSeconds);

      final List<dynamic>? subjPerf = args['subject_performance'];
      if (subjPerf != null) {
        subjectPerformance.assignAll(
          subjPerf.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      }

      final List<dynamic>? secList = args['sections'];
      if (secList != null) {
        sectionBreakdowns.assignAll(
          secList.map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      }

      if (attemptId.value.isNotEmpty) {
        fetchAttemptDetails(attemptId.value);
      }
    }
  }

  Future<void> fetchAttemptDetails(String id) async {
    try {
      isLoading.value = true;
      final response = await _testsRepository.getAttemptDetails(id);
      final data = response.data['data'] ?? response.data;
      if (data != null) {
        score.value = data['score'] ?? 0;
        correctCount.value = data['correct'] ?? 0;
        wrongCount.value = data['wrong'] ?? 0;
        skippedCount.value = data['skipped'] ?? 0;
        accuracy.value = data['accuracy'] ?? 0;
        passed.value = data['passed'] ?? false;
        rank.value = data['rank'] ?? 0;
        classAvg.value = data['class_avg'] ?? 0;
        topScore.value = data['top_score'] ?? 0;
        testTitle.value = data['test_title'] ?? testTitle.value;

        final int timeSeconds = data['time_taken'] ?? 0;
        timeTakenFormatted.value = _formatSeconds(timeSeconds);

        final List<dynamic>? subjPerf = data['subject_performance'];
        if (subjPerf != null) {
          subjectPerformance.assignAll(
            subjPerf.map((e) => Map<String, dynamic>.from(e)).toList(),
          );
        }

        final List<dynamic>? secList = data['sections'];
        if (secList != null) {
          sectionBreakdowns.assignAll(
            secList.map((e) => Map<String, dynamic>.from(e)).toList(),
          );
        }
      }
    } catch (e) {
      print('Error fetching attempt details: $e');
    } finally {
      isLoading.value = false;
    }
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
    if (testId.value.isNotEmpty) {
      // Clear navigation history and launch test runner
      Get.offNamed('/test-runner', arguments: testId.value);
    }
  }

  void viewSolutions() {
    if (attemptId.value.isNotEmpty) {
      Get.toNamed('/test-solutions', arguments: {
        'attempt_id': attemptId.value,
        'test_title': testTitle.value,
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
