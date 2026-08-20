import 'package:get/get.dart';
import '../../../core/utils/error_handler.dart';
import '../models/current_affairs_models.dart';
import '../repositories/current_affairs_repository.dart';

class CurrentAffairsController extends GetxController {
  final CurrentAffairsRepository _repository;

  CurrentAffairsController(this._repository);

  // Loading states
  final isArticlesLoading = false.obs;
  final isDetailLoading = false.obs;
  final isQuizLoading = false.obs;
  final isMagazinesLoading = false.obs;
  final isSchemesLoading = false.obs;
  final isDatesLoading = false.obs;
  final isAnalyticsLoading = false.obs;

  // Data lists
  final articlesList = <CurrentAffair>[].obs;
  final bookmarksList = <CurrentAffair>[].obs;
  final magazinesList = <MonthlyMagazine>[].obs;
  final schemesList = <GovernmentScheme>[].obs;
  final datesList = <ImportantDate>[].obs;
  final quizzesList = <CurrentAffairQuiz>[].obs;

  // Selected details
  final currentArticle = Rxn<CurrentAffair>();
  final quizResults = Rxn<Map<String, dynamic>>();

  // Search & Filter parameters
  final selectedCategory = ''.obs;
  final selectedDate = ''.obs;
  final searchQuery = ''.obs;

  // Analytics
  final articlesReadCount = 0.obs;
  final quizzesAttemptedCount = 0.obs;
  final quizAccuracy = 0.obs;

  // Error messages
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
    fetchAnalytics();
  }

  // --- Daily Current Affairs ---
  Future<void> fetchArticles() async {
    try {
      isArticlesLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getCurrentAffairs(
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        date: selectedDate.value.isEmpty ? null : selectedDate.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<CurrentAffair> loaded = data.map((item) => CurrentAffair.fromJson(item)).toList();
        articlesList.assignAll(loaded);
      } else {
        errorMessage.value = 'Failed to load current affairs';
      }
    } catch (e) {
      errorMessage.value = AppErrorHandler.getErrorMessage(e);
    } finally {
      isArticlesLoading.value = false;
    }
  }

  Future<void> fetchArticleDetail(String id) async {
    try {
      isDetailLoading.value = true;
      errorMessage.value = '';
      currentArticle.value = null;

      final response = await _repository.getCurrentAffairById(id);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          currentArticle.value = CurrentAffair.fromJson(data);
          // Refresh analytics in background since a view was registered
          fetchAnalytics();
        }
      } else {
        errorMessage.value = 'Failed to load article details';
      }
    } catch (e) {
      errorMessage.value = AppErrorHandler.getErrorMessage(e);
    } finally {
      isDetailLoading.value = false;
    }
  }

  // --- Daily Practice Quizzes ---
  Future<void> fetchQuizzes(String articleId) async {
    try {
      isQuizLoading.value = true;
      quizzesList.clear();
      quizResults.value = null;

      final response = await _repository.getQuizzesByArticleId(articleId);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<CurrentAffairQuiz> loaded = data.map((item) => CurrentAffairQuiz.fromJson(item)).toList();
        quizzesList.assignAll(loaded);
      }
    } catch (e) {
      errorMessage.value = AppErrorHandler.getErrorMessage(e);
    } finally {
      isQuizLoading.value = false;
    }
  }

  Future<void> submitQuizAnswers(List<Map<String, dynamic>> submissions) async {
    try {
      isQuizLoading.value = true;
      final response = await _repository.submitQuizAnswers(submissions);

      if (response.statusCode == 200) {
        quizResults.value = response.data['data'];
        fetchAnalytics(); // Refresh progress stats
      }
    } catch (e) {
      errorMessage.value = AppErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to submit quiz.');
    } finally {
      isQuizLoading.value = false;
    }
  }

  // --- Bookmarks ---
  Future<void> toggleBookmark(String id) async {
    try {
      final response = await _repository.toggleBookmark(id);
      if (response.statusCode == 200) {
        // Find in feed and toggle bookmark state locally
        final index = articlesList.indexWhere((art) => art.id == id);
        if (index != -1) {
          final art = articlesList[index];
          articlesList[index] = CurrentAffair(
            id: art.id,
            titleEn: art.titleEn,
            titleTa: art.titleTa,
            summaryEn: art.summaryEn,
            summaryTa: art.summaryTa,
            contentEn: art.contentEn,
            contentTa: art.contentTa,
            examImportanceEn: art.examImportanceEn,
            examImportanceTa: art.examImportanceTa,
            keyFactsEn: art.keyFactsEn,
            keyFactsTa: art.keyFactsTa,
            prelimsNotesEn: art.prelimsNotesEn,
            prelimsNotesTa: art.prelimsNotesTa,
            mainsNotesEn: art.mainsNotesEn,
            mainsNotesTa: art.mainsNotesTa,
            videoUrl: art.videoUrl,
            category: art.category,
            publishedDate: art.publishedDate,
            isBookmarked: !art.isBookmarked,
            quizCount: art.quizCount,
          );
        }

        // Toggle in current detailed article if active
        if (currentArticle.value?.id == id) {
          final art = currentArticle.value!;
          currentArticle.value = CurrentAffair(
            id: art.id,
            titleEn: art.titleEn,
            titleTa: art.titleTa,
            summaryEn: art.summaryEn,
            summaryTa: art.summaryTa,
            contentEn: art.contentEn,
            contentTa: art.contentTa,
            examImportanceEn: art.examImportanceEn,
            examImportanceTa: art.examImportanceTa,
            keyFactsEn: art.keyFactsEn,
            keyFactsTa: art.keyFactsTa,
            prelimsNotesEn: art.prelimsNotesEn,
            prelimsNotesTa: art.prelimsNotesTa,
            mainsNotesEn: art.mainsNotesEn,
            mainsNotesTa: art.mainsNotesTa,
            videoUrl: art.videoUrl,
            category: art.category,
            publishedDate: art.publishedDate,
            isBookmarked: !art.isBookmarked,
            quizCount: art.quizCount,
          );
        }

        fetchBookmarks();
      }
    } catch (e) {
      print('Bookmark error: $e');
    }
  }

  Future<void> fetchBookmarks() async {
    try {
      final response = await _repository.getBookmarkedArticles();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<CurrentAffair> loaded = data.map((item) {
          final detail = item['currentAffair'];
          // bookmarks detail payload includes the child object
          return CurrentAffair.fromJson({
            ...detail,
            'isBookmarked': true,
          });
        }).toList();
        bookmarksList.assignAll(loaded);
      }
    } catch (e) {
      print('Fetch bookmarks error: $e');
    }
  }

  // --- Monthly Compilation Magazines ---
  Future<void> fetchMagazines() async {
    try {
      isMagazinesLoading.value = true;
      final response = await _repository.getMonthlyMagazines();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<MonthlyMagazine> loaded = data.map((item) => MonthlyMagazine.fromJson(item)).toList();
        magazinesList.assignAll(loaded);
      }
    } catch (e) {
      print('Magazines load error: $e');
    } finally {
      isMagazinesLoading.value = false;
    }
  }

  // --- Government Schemes ---
  Future<void> fetchSchemes({String? type}) async {
    try {
      isSchemesLoading.value = true;
      final response = await _repository.getGovernmentSchemes(type: type);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<GovernmentScheme> loaded = data.map((item) => GovernmentScheme.fromJson(item)).toList();
        schemesList.assignAll(loaded);
      }
    } catch (e) {
      print('Schemes load error: $e');
    } finally {
      isSchemesLoading.value = false;
    }
  }

  // --- Important Dates ---
  Future<void> fetchDates({String? type}) async {
    try {
      isDatesLoading.value = true;
      final response = await _repository.getImportantDates(type: type);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<ImportantDate> loaded = data.map((item) => ImportantDate.fromJson(item)).toList();
        datesList.assignAll(loaded);
      }
    } catch (e) {
      print('Dates load error: $e');
    } finally {
      isDatesLoading.value = false;
    }
  }

  // --- Analytics ---
  Future<void> fetchAnalytics() async {
    try {
      isAnalyticsLoading.value = true;
      final response = await _repository.getStudentAnalytics();
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? {};
        articlesReadCount.value = data['articlesReadCount'] ?? 0;
        quizzesAttemptedCount.value = data['quizzesAttemptedCount'] ?? 0;
        quizAccuracy.value = data['accuracy'] ?? 0;
      }
    } catch (e) {
      print('Analytics error: $e');
    } finally {
      isAnalyticsLoading.value = false;
    }
  }
}
