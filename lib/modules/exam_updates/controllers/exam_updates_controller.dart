import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/exam_update_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/toast_helper.dart';

class ExamUpdatesController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<ExamUpdateModel> examUpdates = <ExamUpdateModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExamUpdates();
  }

  Future<void> fetchExamUpdates() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.dio.get(ApiConstants.examUpdates);
      if (response.data != null && response.data['status'] == 'success') {
        final list = response.data['data'] as List;
        examUpdates.value = list
            .map((json) => ExamUpdateModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Get.log('Error fetching exam updates: $e');
      AppToast.error(AppErrorHandler.getErrorMessage(e, defaultMessage: AppStrings.failedToLoadExamUpdates));
    } finally {
      isLoading.value = false;
    }
  }
}
