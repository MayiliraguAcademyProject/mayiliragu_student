import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../../../core/utils/error_handler.dart';
import '../models/test_model.dart';
import '../models/category_model.dart';
import '../repositories/tests_repository.dart';

enum TestMode { subjectWise, testSeries }

class TestsController extends GetxController {
  final TestsRepository _repository;

  TestsController(this._repository);

  // Active Tab Mode
  final activeTestMode = TestMode.subjectWise.obs;

  // Separate observable test lists
  final subjectWiseTests = <TestModel>[].obs;
  final testSeriesTests = <TestModel>[].obs;

  // Separate loading & error observables
  final isLoadingSubjectWise = false.obs;
  final isLoadingTestSeries = false.obs;
  final errorSubjectWise = ''.obs;
  final errorTestSeries = ''.obs;

  // General loading property for backward compatibility
  bool get isLoading => activeTestMode.value == TestMode.subjectWise
      ? isLoadingSubjectWise.value
      : isLoadingTestSeries.value;

  String get errorMessage => activeTestMode.value == TestMode.subjectWise
      ? errorSubjectWise.value
      : errorTestSeries.value;

  // Subject-Wise category and sub-filters
  final selectedCategory = 'all'.obs;
  final selectedSubFilter = 'all'.obs;
  final selectedDifficulty = 'all'.obs; // 'all' | 'EASY' | 'MEDIUM' | 'HARD'

  // Folder-like hierarchy navigation
  final selectedFolderCategory = ''.obs; // ID of active category folder ('': root level)
  final selectedFolderSubject = ''.obs;  // ID of active subject folder ('': category level)
  final selectedFolderTopic = ''.obs;    // ID of active topic folder ('': subject level)

  // Search query
  final searchQuery = ''.obs;

  // Human-readable mapping configs loaded dynamically
  final subjectNames = <String, String>{}.obs;
  final topicNames = <String, String>{}.obs;
  final categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories().then((_) {
      fetchSubjectWiseTests();
      fetchTestSeriesTests();
    });
  }

  Future<void> fetchTests() async {
    await fetchCategories();
    await Future.wait([
      fetchSubjectWiseTests(),
      fetchTestSeriesTests(),
    ]);
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _repository.getCategories();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];

        final List<CategoryModel> loadedCategories = [
          CategoryModel(
            id: 'all',
            name: 'All Subjects',
            description: 'All Categories',
            subjects: [],
          ),
          ...data.map((item) => CategoryModel.fromJson(item)),
        ];

        final Map<String, String> loadedSubjects = {};
        final Map<String, String> loadedTopics = {};

        for (var cat in loadedCategories) {
          for (var sub in cat.subjects) {
            if (sub.id.isNotEmpty) {
              loadedSubjects[sub.id] = sub.name;
            }
            for (var top in sub.topics) {
              if (top.id.isNotEmpty) {
                loadedTopics[top.id] = top.name;
              }
            }
          }
        }

        categories.assignAll(loadedCategories);
        subjectNames.assignAll(loadedSubjects);
        topicNames.assignAll(loadedTopics);

        if (categories.isNotEmpty &&
            (selectedCategory.value.isEmpty ||
                !categories.any((c) => c.id == selectedCategory.value))) {
          final defaultCat = categories.firstWhere((c) => c.id != 'all',
              orElse: () => categories.first);
          selectedCategory.value = defaultCat.id;
        }
      }
    } catch (e) {
      errorSubjectWise.value = AppErrorHandler.getErrorMessage(e);
    }
  }

  Future<void> clearImageCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}
  }

  Future<void> fetchSubjectWiseTests() async {
    await clearImageCache();

    try {
      isLoadingSubjectWise.value = true;
      errorSubjectWise.value = '';

      final response = await _repository.getTests(
        testMode: 'SUBJECT_WISE',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<TestModel> loadedTests =
            data.map((item) => TestModel.fromJson(item)).toList();
        subjectWiseTests.assignAll(loadedTests);
      } else {
        errorSubjectWise.value = 'Failed to load subject-wise practice tests';
      }
    } catch (e) {
      errorSubjectWise.value = AppErrorHandler.getErrorMessage(e);
    } finally {
      isLoadingSubjectWise.value = false;
    }
  }

  Future<void> fetchTestSeriesTests() async {
    await clearImageCache();

    try {
      isLoadingTestSeries.value = true;
      errorTestSeries.value = '';

      final response = await _repository.getTests(
        testMode: 'TEST_SERIES',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<TestModel> loadedTests =
            data.map((item) => TestModel.fromJson(item)).toList();
        testSeriesTests.assignAll(loadedTests);
      } else {
        errorTestSeries.value = 'Failed to load test series mocks';
      }
    } catch (e) {
      errorTestSeries.value = AppErrorHandler.getErrorMessage(e);
    } finally {
      isLoadingTestSeries.value = false;
    }
  }

  Future<void> refreshActiveMode() async {
    if (activeTestMode.value == TestMode.subjectWise) {
      await fetchSubjectWiseTests();
    } else {
      await fetchTestSeriesTests();
    }
  }

  void switchMode(TestMode mode) {
    activeTestMode.value = mode;
    if (mode == TestMode.subjectWise && subjectWiseTests.isEmpty) {
      fetchSubjectWiseTests();
    } else if (mode == TestMode.testSeries && testSeriesTests.isEmpty) {
      fetchTestSeriesTests();
    }
  }

  // Folder Navigation Methods
  int getCategoryTestCount(String categoryId) {
    if (categoryId == 'all') {
      return subjectWiseTests.length;
    }
    return subjectWiseTests.where((t) => t.categoryId == categoryId).length;
  }

  int getSubjectTestCount(String subjectId) {
    return subjectWiseTests.where((t) => t.subjectId == subjectId).length;
  }

  int getTopicTestCount(String topicId) {
    return subjectWiseTests.where((t) => t.topicId == topicId).length;
  }

  void openCategoryFolder(String categoryId) {
    selectedFolderCategory.value = categoryId;
    selectedFolderSubject.value = '';
    selectedFolderTopic.value = '';
  }

  void openSubjectFolder(String subjectId) {
    selectedFolderSubject.value = subjectId;
    selectedFolderTopic.value = '';
  }

  void openTopicFolder(String topicId) {
    selectedFolderTopic.value = topicId;
  }

  void navigateFolderBack() {
    if (selectedFolderTopic.value.isNotEmpty) {
      selectedFolderTopic.value = '';
    } else if (selectedFolderSubject.value.isNotEmpty) {
      selectedFolderSubject.value = '';
    } else if (selectedFolderCategory.value.isNotEmpty) {
      selectedFolderCategory.value = '';
    }
  }

  void resetFolderNavigation() {
    selectedFolderCategory.value = '';
    selectedFolderSubject.value = '';
    selectedFolderTopic.value = '';
  }

  void selectCategory(String categoryId) {
    selectedCategory.value = categoryId;
    selectedSubFilter.value = 'all';
    openCategoryFolder(categoryId);
  }

  void selectSubFilter(String filterId) {
    selectedSubFilter.value = filterId;
  }

  void selectDifficulty(String difficulty) {
    selectedDifficulty.value = difficulty;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  // Get available sub-topic filter pills for current selected category based on actual tests
  List<Map<String, String>> get availableSubFilters {
    final List<Map<String, String>> filters = [
      {'id': 'all', 'name': 'All Topics'}
    ];

    final currentTests = selectedFolderCategory.value.isEmpty || selectedFolderCategory.value == 'all'
        ? subjectWiseTests
        : subjectWiseTests.where((t) => t.categoryId == selectedFolderCategory.value);

    final Set<String> seenIds = {'all'};

    for (var test in currentTests) {
      if (test.subjectId != null &&
          test.subjectId!.isNotEmpty &&
          !seenIds.contains(test.subjectId)) {
        final name = subjectNames[test.subjectId!] ?? '';
        if (name.isNotEmpty) {
          seenIds.add(test.subjectId!);
          filters.add({'id': test.subjectId!, 'name': name});
        }
      }

      if (test.topicId != null &&
          test.topicId!.isNotEmpty &&
          !seenIds.contains(test.topicId)) {
        final name = topicNames[test.topicId!] ?? '';
        if (name.isNotEmpty) {
          seenIds.add(test.topicId!);
          filters.add({'id': test.topicId!, 'name': name});
        }
      }
    }

    return filters;
  }

  // Filtered Subject-Wise tests (folder drilldown + difficulty chip + search)
  List<TestModel> get filteredSubjectWiseTests {
    var list = subjectWiseTests.toList();

    // If search is active, return all matching tests across folders
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      return list.where((test) {
        final title = test.title.toLowerCase();
        final desc = (test.description ?? '').toLowerCase();
        return title.contains(query) || desc.contains(query);
      }).toList();
    }

    // Apply folder level filtering
    if (selectedFolderCategory.value.isNotEmpty && selectedFolderCategory.value != 'all') {
      list = list.where((t) => t.categoryId == selectedFolderCategory.value).toList();
    }

    if (selectedFolderSubject.value.isNotEmpty) {
      list = list.where((t) => t.subjectId == selectedFolderSubject.value).toList();
    }

    if (selectedFolderTopic.value.isNotEmpty) {
      list = list.where((t) => t.topicId == selectedFolderTopic.value).toList();
    }

    // Apply difficulty filter
    if (selectedDifficulty.value != 'all') {
      final diff = selectedDifficulty.value.toUpperCase();
      list = list.where((t) {
        return (t.difficulty ?? '').toUpperCase() == diff;
      }).toList();
    }

    return list;
  }

  // Filtered Test Series tests (search query)
  List<TestModel> get filteredTestSeriesTests {
    var list = testSeriesTests.toList();

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      list = list.where((test) {
        final title = test.title.toLowerCase();
        final desc = (test.description ?? '').toLowerCase();
        return title.contains(query) || desc.contains(query);
      }).toList();
    }

    return list;
  }
}
