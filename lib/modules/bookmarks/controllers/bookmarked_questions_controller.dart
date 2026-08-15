import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../tests/models/question_model.dart';
import '../../tests/repositories/tests_repository.dart';
import '../../../core/utils/toast_helper.dart';

class BookmarkedQuestionsController extends GetxController {
  final TestsRepository _repository;

  BookmarkedQuestionsController(this._repository);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final questions = <QuestionModel>[].obs;
  final currentPage = 0.obs;
  
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    fetchBookmarkedQuestions();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> fetchBookmarkedQuestions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _repository.getBookmarkedQuestions();
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        questions.assignAll(
          dataList.map((q) => QuestionModel.fromJson(Map<String, dynamic>.from(q))).toList(),
        );
      } else {
        errorMessage.value = 'Failed to load bookmarked questions';
      }
    } catch (e) {
      errorMessage.value = 'Error loading bookmarks: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBookmark(String questionId) async {
    try {
      final response = await _repository.toggleQuestionBookmark(questionId);
      if (response.statusCode == 200) {
        final bool isBookmarked = response.data['data']['isBookmarked'] ?? false;
        if (!isBookmarked) {
          final idx = questions.indexWhere((q) => q.id == questionId);
          if (idx != -1) {
            questions.removeAt(idx);
            AppToast.success('Question removed from saved list.', title: 'Bookmark Removed');
            
            if (questions.isEmpty) {
              currentPage.value = 0;
            } else if (currentPage.value >= questions.length) {
              currentPage.value = questions.length - 1;
              pageController.jumpToPage(currentPage.value);
            }
          }
        }
      }
    } catch (e) {
      AppToast.error('Failed to remove bookmark');
    }
  }

  void nextPage() {
    if (currentPage.value < questions.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

