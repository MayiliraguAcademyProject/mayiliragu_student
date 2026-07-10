import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../models/test_model.dart';
import '../repositories/tests_repository.dart';

enum FilterTab { topicWise, subjectWise }

class TestsController extends GetxController {
  final TestsRepository _repository;

  TestsController(this._repository);

  final isLoading = false.obs;
  final testsList = <TestModel>[].obs;
  final selectedCategory = 'cat_tnpsc'.obs; // Default: TNPSC
  final activeTab = FilterTab.topicWise.obs; // Default: Topic Wise
  final errorMessage = ''.obs;

  // Search query
  final searchQuery = ''.obs;

  // Human-readable mapping configs
  final Map<String, String> subjectNames = {
    'sub_polity': 'Indian Polity',
    'sub_aptitude': 'Quantitative Aptitude',
    'sub_english': 'General English',
    'sub_history': 'History',
    'sub_economics': 'Economics',
    'Polity': 'Indian Polity',
    'History': 'History',
    'Economics': 'Economics',
  };

  final Map<String, String> topicNames = {
    'top_rights': 'Fundamental Rights',
    'top_ratios': 'Ratios & Proportions',
    'top_tenses': 'Tenses & Active Voice',
  };

  final categories = [
    {'id': 'cat_tnpsc', 'name': 'TNPSC'},
    {'id': 'TNPSC_GROUP_2_4', 'name': 'TNPSC Group 2 & 4'},
    {'id': 'cat_upsc', 'name': 'UPSC'},
    {'id': 'cat_ssc', 'name': 'SSC'},
    {'id': 'cat_banking', 'name': 'Banking'},
    {'id': 'IBPS_PO', 'name': 'IBPS PO'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTests();
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
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String categoryId) {
    selectedCategory.value = categoryId;
    fetchTests();
  }

  void switchTab(FilterTab tab) {
    activeTab.value = tab;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  // Get filtered tests matching the search query
  List<TestModel> get _searchedTests {
    if (searchQuery.value.isEmpty) {
      return testsList;
    }
    final query = searchQuery.value.toLowerCase();
    return testsList.where((test) {
      final title = test.title.toLowerCase();
      final desc = (test.description ?? '').toLowerCase();
      return title.contains(query) || desc.contains(query);
    }).toList();
  }

  // Subject-wise grouping: Map<SubjectName/ID, List<TestModel>>
  Map<String, List<TestModel>> get subjectWiseTests {
    final Map<String, List<TestModel>> groups = {};
    for (var test in _searchedTests) {
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
    for (var test in _searchedTests) {
      // Include tests that have a topicId
      if (test.topicId == null || test.topicId!.isEmpty) continue;

      final String subId = test.subjectId ?? 'General / Other';
      final String subName = subjectNames[subId] ?? subId;

      final String topId = test.topicId!;
      final String topName = topicNames[topId] ?? topId;

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
