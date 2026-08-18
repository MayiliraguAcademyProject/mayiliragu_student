import 'package:get/get.dart';
import '../repositories/tests_repository.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/utils/error_handler.dart';

class TestSolutionsController extends GetxController {
  final TestsRepository _repository;

  TestSolutionsController(this._repository);

  // Arguments
  late final String attemptId;
  late final String testTitle;

  // States
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final attemptData = Rxn<Map<String, dynamic>>();
  final questions = <Map<String, dynamic>>[].obs;
  
  // Filter Tab: 'all', 'correct', 'wrong'
  final activeFilter = 'all'.obs;

  // Expandable Explanations map: questionId -> isExpanded
  final expandedExplanations = <String, bool>{}.obs;

  // Bookmark states
  final bookmarkedQuestions = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    attemptId = args?['attempt_id'] ?? '';
    testTitle = args?['test_title'] ?? 'Solutions';
    
    if (attemptId.isNotEmpty) {
      fetchAttemptDetails();
      fetchBookmarks();
    } else {
      errorMessage.value = 'Invalid attempt ID';
    }
  }

  Future<void> fetchBookmarks() async {
    try {
      final response = await _repository.getBookmarkedQuestions();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final ids = data.map((q) => q['id'].toString()).toSet();
        bookmarkedQuestions.assignAll(ids);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> fetchAttemptDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getAttemptDetails(attemptId);

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data['data'] ?? {});
        attemptData.value = data;
        
        final List<dynamic>? qList = data['questions'];
        if (qList != null) {
          questions.assignAll(
            qList.map((e) => Map<String, dynamic>.from(e)).toList(),
          );
        }
      } else {
        errorMessage.value = 'Failed to load solutions';
      }
    } catch (e) {
      errorMessage.value = AppErrorHandler.getErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    activeFilter.value = filter;
  }

  void toggleExplanation(String questionId) {
    final bool current = expandedExplanations[questionId] ?? false;
    expandedExplanations[questionId] = !current;
  }

  Future<void> toggleBookmark(String questionId) async {
    try {
      final response = await _repository.toggleQuestionBookmark(questionId);
      if (response.statusCode == 200) {
        final bool isBookmarked = response.data['data']['isBookmarked'] ?? false;
        if (isBookmarked) {
          bookmarkedQuestions.add(questionId);
          AppToast.success(
            'Question saved for review in your profile.',
            title: 'Question Bookmarked',
          );
        } else {
          bookmarkedQuestions.remove(questionId);
          AppToast.success(
            'Question removed from your saved list.',
            title: 'Bookmark Removed',
          );
        }
      }
    } catch (e) {
      AppToast.error('Failed to update bookmark');
    }
  }

  // Getters for counts
  int get totalCount => questions.length;
  
  int get correctCount {
    return questions.where((q) {
      final ua = q['user_answer'];
      return ua != null && ua['is_correct'] == true;
    }).length;
  }

  int get wrongCount {
    return questions.where((q) {
      final ua = q['user_answer'];
      return ua == null || ua['is_correct'] == false;
    }).length;
  }

  // Filtered list getter
  List<Map<String, dynamic>> get filteredQuestions {
    if (activeFilter.value == 'correct') {
      return questions.where((q) {
        final ua = q['user_answer'];
        return ua != null && ua['is_correct'] == true;
      }).toList();
    } else if (activeFilter.value == 'wrong') {
      return questions.where((q) {
        final ua = q['user_answer'];
        return ua == null || ua['is_correct'] == false;
      }).toList();
    }
    return questions;
  }
}
