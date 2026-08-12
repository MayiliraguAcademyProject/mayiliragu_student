import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/course_repository.dart';

class CourseController extends GetxController {
  final CourseRepository _repository;

  CourseController(this._repository);

  final coursesList = <dynamic>[].obs;
  final isLoading = false.obs;
  final isLoadMore = false.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final limit = 10;
  final isDemoOnly = false.obs;
  final errorMessage = ''.obs;

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map && Get.arguments['isDemoOnly'] == true) {
      isDemoOnly.value = true;
    } else {
      isDemoOnly.value = false;
    }
    fetchCourses();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && !isLoadMore.value && hasMore.value) {
        loadMoreCourses();
      }
    }
  }

  Future<void> fetchCourses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentPage.value = 1;
      hasMore.value = true;

      final response = await _repository.getCourses(
        page: currentPage.value,
        limit: limit,
        isDemo: isDemoOnly.value ? true : null,
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final data = responseData['data'] as List<dynamic>;
        coursesList.assignAll(data);
        
        final meta = responseData['meta'];
        if (currentPage.value >= (meta['totalPages'] as num)) {
          hasMore.value = false;
        }
      } else {
        errorMessage.value = 'Failed to load courses';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreCourses() async {
    try {
      isLoadMore.value = true;
      currentPage.value++;

      final response = await _repository.getCourses(
        page: currentPage.value,
        limit: limit,
        isDemo: isDemoOnly.value ? true : null,
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final data = responseData['data'] as List<dynamic>;
        coursesList.addAll(data);
        
        final meta = responseData['meta'];
        if (currentPage.value >= (meta['totalPages'] as num)) {
          hasMore.value = false;
        }
      } else {
        currentPage.value--;
      }
    } catch (e) {
      currentPage.value--;
    } finally {
      isLoadMore.value = false;
    }
  }
}
