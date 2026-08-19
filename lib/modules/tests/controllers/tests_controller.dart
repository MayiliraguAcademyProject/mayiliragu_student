import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../../../core/utils/error_handler.dart';
import '../models/test_model.dart';
import '../models/category_model.dart';
import '../repositories/tests_repository.dart';

enum FilterTab { topicWise, subjectWise }

class TestsController extends GetxController {
  final TestsRepository _repository;

  TestsController(this._repository);

  final isLoading = false.obs;
  final testsList = <TestModel>[].obs;
  final selectedCategory = ''.obs; // Loaded dynamically
  final activeTab = FilterTab.topicWise.obs; // Default: Topic Wise
  final errorMessage = ''.obs;

  // Search query
  final searchQuery = ''.obs;

  // Human-readable mapping configs loaded dynamically
  final subjectNames = <String, String>{}.obs;
  final topicNames = <String, String>{}.obs;

  final categories = <CategoryModel>[].obs;

  final selectedSubFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories().then((_) => fetchTests());
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _repository.getCategories();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        
        final List<CategoryModel> loadedCategories = [
          CategoryModel(
            id: 'all',
            name: 'All',
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
        
        if (categories.isNotEmpty && (selectedCategory.value.isEmpty || !categories.any((c) => c.id == selectedCategory.value))) {
          // Default to first real category if available (e.g. cat_quant) or 'all'
          final defaultCat = categories.firstWhere((c) => c.id != 'all', orElse: () => categories.first);
          selectedCategory.value = defaultCat.id;
        }
      }
    } catch (e) {
      errorMessage.value = AppErrorHandler.getErrorMessage(e);
    }
  }

  Future<void> fetchTests() async {
    try {
      // Clear image cache to refresh modified question assets
      await DefaultCacheManager().emptyCache();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _repository.getTests(categoryId: selectedCategory.value);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<TestModel> loadedTests = data.map((item) => TestModel.fromJson(item)).toList();
        testsList.assignAll(loadedTests);
      } else {
        errorMessage.value = 'Failed to load tests';
      }
    } catch (e) {
      errorMessage.value = AppErrorHandler.getErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String categoryId) {
    selectedCategory.value = categoryId;
    selectedSubFilter.value = 'all';
    fetchTests();
  }

  void selectSubFilter(String filterId) {
    selectedSubFilter.value = filterId;
  }

  void switchTab(FilterTab tab) {
    activeTab.value = tab;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  // Get available sub-topic filter pills for current selected category
  List<Map<String, String>> get availableSubFilters {
    final List<Map<String, String>> filters = [
      {'id': 'all', 'name': 'All Quizzes'}
    ];

    if (selectedCategory.value == 'all') {
      // Add all subjects
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

  // Get filtered tests matching category, sub-topic pill, and search query
  List<TestModel> get filteredDrillTests {
    var list = testsList.toList();

    // Apply sub-topic pill filter
    if (selectedSubFilter.value != 'all') {
      final filterId = selectedSubFilter.value;
      list = list.where((t) {
        return t.subjectId == filterId || t.topicId == filterId;
      }).toList();
    }

    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      list = list.where((test) {
        final title = test.title.toLowerCase();
        final desc = (test.description ?? '').toLowerCase();
        return title.contains(query) || desc.contains(query);
      }).toList();
    }

    return list;
  }

  // Subject-wise grouping: Map<SubjectName/ID, List<TestModel>>
  Map<String, List<TestModel>> get subjectWiseTests {
    final Map<String, List<TestModel>> groups = {};
    for (var test in filteredDrillTests) {
      // Include tests that have a subjectId
      final String subId = test.subjectId ?? 'General / Other';
      final String subName = subjectNames[subId] ?? subId;

      if (!groups.containsKey(subName)) {
        groups[subName] = [];
      }
      groups[subName]!.add(test);
    }
    return groups;
  }

  // Topic-wise grouping: Map<SubjectName, Map<TopicName, List<TestModel>>>
  Map<String, Map<String, List<TestModel>>> get topicWiseTests {
    final Map<String, Map<String, List<TestModel>>> groups = {};
    for (var test in filteredDrillTests) {
      final String subId = test.subjectId ?? 'general_other';
      final String subName = subjectNames[subId] ?? (test.subjectId == null ? 'General / Other' : subId);

      final String topId = test.topicId ?? 'general_other';
      final String topName = topicNames[topId] ?? (test.topicId == null ? 'General' : topId);

      if (!groups.containsKey(subName)) {
        groups[subName] = {};
      }
      if (!groups[subName]!.containsKey(topName)) {
        groups[subName]![topName] = [];
      }
      groups[subName]![topName]!.add(test);
    }
    return groups;
  }
}
