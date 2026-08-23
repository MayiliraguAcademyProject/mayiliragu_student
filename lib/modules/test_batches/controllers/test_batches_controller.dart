import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/test_batch_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../shared/widgets/pdf_viewer_screen.dart';

class TestBatchesController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<TestBatchModel> testBatches = <TestBatchModel>[].obs;
  final Rxn<TestBatchModel> currentBatch = Rxn<TestBatchModel>();
  final RxBool isLoading = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxSet<String> expandedCategoryIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTestBatches();
  }

  Future<void> fetchTestBatches() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.dio.get(ApiConstants.testBatchesStudent);
      if (response.data != null && response.data['status'] == 'success') {
        final list = response.data['data'] as List;
        testBatches.value = list
            .map((json) => TestBatchModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Get.log('Error fetching test batches: $e');
      AppToast.error(AppErrorHandler.getErrorMessage(
        e,
        defaultMessage: AppStrings.failedToLoadTestBatches,
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBatchDetail(String batchId) async {
    isDetailLoading.value = true;
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.testBatchStudentDetail(batchId),
      );
      if (response.data != null && response.data['status'] == 'success') {
        final data = response.data['data'];
        final batch = TestBatchModel.fromJson(data as Map<String, dynamic>);
        currentBatch.value = batch;

        // Auto expand all categories by default
        expandedCategoryIds.clear();
        for (final cat in batch.categories) {
          expandedCategoryIds.add(cat.id);
        }
      }
    } catch (e) {
      Get.log('Error fetching test batch detail: $e');
      AppToast.error(AppErrorHandler.getErrorMessage(
        e,
        defaultMessage: 'Failed to load batch details.',
      ));
    } finally {
      isDetailLoading.value = false;
    }
  }

  void toggleCategory(String categoryId) {
    if (expandedCategoryIds.contains(categoryId)) {
      expandedCategoryIds.remove(categoryId);
    } else {
      expandedCategoryIds.add(categoryId);
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void openPdf(String? pdfUrl, {String? title}) {
    if (pdfUrl == null || pdfUrl.trim().isEmpty) {
      AppToast.error('PDF file is not available.');
      return;
    }

    Get.to(
      () => PdfViewerScreen(
        pdfUrl: pdfUrl,
        title: title ?? currentBatch.value?.title ?? 'Test Batch Document',
      ),
    );
  }
}
