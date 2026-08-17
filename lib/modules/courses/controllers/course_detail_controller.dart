import 'package:get/get.dart';
import '../../../core/utils/error_handler.dart';
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
      errorMessage.value = AppErrorHandler.getErrorMessage(e);
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
      final msg = AppErrorHandler.getErrorMessage(e, defaultMessage: 'Failed to submit enrollment request. Please try again.');
      AppToast.error(
        msg,
        title: 'Request Failed',
      );
      return false;
    } finally {
      isRequesting.value = false;
    }
  }

}
