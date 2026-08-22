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
  final selectedCategory = ''.obs;
  final selectedSubFilter = 'all'.obs;
  final selectedDifficulty = 'all'.obs; // 'all' | 'EASY' | 'MEDIUM' | 'HARD'

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
        categoryId: selectedCategory.value,
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

  void selectCategory(String categoryId) {
    selectedCategory.value = categoryId;
    selectedSubFilter.value = 'all';
    fetchSubjectWiseTests();
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

  // Get available sub-topic filter pills for current selected category
  List<Map<String, String>> get availableSubFilters {
    final List<Map<String, String>> filters = [
      {'id': 'all', 'name': 'All Topics'}
    ];

    if (selectedCategory.value == 'all') {
      subjectNames.forEach((id, name) {
        filters.add({'id': id, 'name': name});
      });
      return filters;
    }

    final cat = categories.firstWhereOrNull((c) => c.id == selectedCategory.value);
    if (cat != null) {
      for (var sub in cat.subjects) {
        filters.add({'id': sub.id, 'name': sub.name});
        for (var top in sub.topics) {
          filters.add({'id': top.id, 'name': top.name});
        }
      }
    }
    return filters;
  }

  // Filtered Subject-Wise tests (category + sub-topic pill + difficulty chip + search)
  List<TestModel> get filteredSubjectWiseTests {
    var list = subjectWiseTests.toList();

    // Apply sub-topic pill filter
    if (selectedSubFilter.value != 'all') {
      final filterId = selectedSubFilter.value;
      list = list.where((t) {
        return t.subjectId == filterId || t.topicId == filterId;
      }).toList();
    }

    // Apply difficulty filter
    if (selectedDifficulty.value != 'all') {
      final diff = selectedDifficulty.value.toUpperCase();
      list = list.where((t) {
        return (t.difficulty ?? '').toUpperCase() == diff;
      }).toList();
    }

    // Apply search query
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
