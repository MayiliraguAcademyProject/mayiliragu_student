import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/course_repository.dart';
import '../models/course_detail_model.dart';

class CourseDetailController extends GetxController {
  final CourseRepository _repository;
  final String courseId;

  CourseDetailController(this._repository, this.courseId);

  final isLoading = true.obs;
  final isRequesting = false.obs;
  final errorMessage = ''.obs;
  final courseData = Rxn<CourseDetailModel>();

  @override
  void onInit() {
    super.onInit();
    fetchCourseDetails();
  }

  Future<void> fetchCourseDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _repository.getCourseById(courseId);

      if (response.statusCode == 200) {
        courseData.value = CourseDetailModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        errorMessage.value = 'Failed to load course details';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestEnrollment({String? message}) async {
    try {
      isRequesting.value = true;
      final response = await _repository.submitEnrollmentRequest(courseId, message: message);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Request Submitted 🎉',
          'Your enrollment request has been sent to the admin. You will get access once approved.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: Colors.grey.shade900,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return true;
      } else {
        Get.snackbar(
          'Request Failed',
          response.data['message'] ?? 'Failed to submit request',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      final msg = e.toString().contains('already pending')
          ? 'Enrollment request already pending for this course.'
          : (e.toString().contains('Already enrolled')
              ? 'You are already enrolled in this course.'
              : 'Failed to submit enrollment request. Please try again.');
      Get.snackbar(
        'Request Status',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.grey.shade900,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isRequesting.value = false;
    }
  }
}
