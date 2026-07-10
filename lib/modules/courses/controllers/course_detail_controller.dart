import 'package:get/get.dart';
import '../repositories/course_repository.dart';
import '../models/course_detail_model.dart';

class CourseDetailController extends GetxController {
  final CourseRepository _repository;
  final String courseId;

  CourseDetailController(this._repository, this.courseId);

  final isLoading = true.obs;
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
}
