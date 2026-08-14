import 'dart:convert';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/toast_helper.dart';
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
        AppToast.success(
          response.data['message'] ?? 'Enrollment request submitted successfully',
          title: 'Success',
        );
        return true;
      } else {
        AppToast.error(
          response.data['message'] ?? 'Failed to submit request',
          title: 'Request Failed',
        );
        return false;
      }
    } catch (e) {
      String msg = 'Failed to submit enrollment request. Please try again.';
      if (e is DioException && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          msg = data['message'] ?? msg;
        } else if (data is String) {
          try {
            final decoded = json.decode(data);
            if (decoded is Map) {
              msg = decoded['message'] ?? msg;
            }
          } catch (_) {}
        }
      } else {
        final errStr = e.toString();
        if (errStr.contains('already pending')) {
          msg = 'Enrollment request already pending for this course.';
        } else if (errStr.contains('Already enrolled')) {
          msg = 'You are already enrolled in this course.';
        } else {
          msg = errStr;
        }
      }
      AppToast.error(
        msg.replaceAll('Exception:', ''),
        title: 'Request Failed',
      );
      return false;
    } finally {
      isRequesting.value = false;
    }
  }

}
