import 'package:get/get.dart';
import '../../../core/models/testimonial_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/toast_helper.dart';

class TestimonialsController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<TestimonialModel> testimonials = <TestimonialModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTestimonials();
  }

  Future<void> fetchTestimonials() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.dio.get(ApiConstants.testimonials);
      if (response.data != null && response.data['status'] == 'success') {
        final list = response.data['data'] as List;
        testimonials.value = list
            .map((json) => TestimonialModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Get.log('Error fetching testimonials: $e');
      AppToast.error(AppErrorHandler.getErrorMessage(e, defaultMessage: AppStrings.failedToLoadTestimonials));
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to extract YouTube Video or Shorts ID from URL
  String getYoutubeVideoId(String url) {
    if (url.isEmpty) return '';
    
    // Watch URL matching
    final watchRegExp = RegExp(r'[?&]v=([^&#]+)');
    final watchMatch = watchRegExp.firstMatch(url);
    if (watchMatch != null && watchMatch.group(1) != null) {
      return watchMatch.group(1)!;
    }

    // Short/Embed/Live/Shorts URL matching
    final generalRegExp = RegExp(r'(?:youtu\.be\/|embed\/|live\/|shorts\/|v\/)([^?&#]+)');
    final generalMatch = generalRegExp.firstMatch(url);
    if (generalMatch != null && generalMatch.group(1) != null) {
      return generalMatch.group(1)!;
    }

    return '';
  }
}
