import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/test_batch_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../shared/widgets/pdf_viewer_screen.dart';

enum PaperFilterStatus {
  all,
  available,
  upcoming,
  completed,
}

class TestBatchesController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<TestBatchModel> testBatches = <TestBatchModel>[].obs;
  final Rxn<TestBatchModel> currentBatch = Rxn<TestBatchModel>();
  final RxBool isLoading = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxBool isSubmittingOmr = false.obs;
  final RxInt selectedTabIndex = 0.obs;
  final RxSet<String> expandedCategoryIds = <String>{}.obs;
  final Rx<PaperFilterStatus> selectedPaperFilter = PaperFilterStatus.all.obs;

  int get totalPapersCount {
    final batch = currentBatch.value;
    if (batch == null) return 0;
    return batch.categories.fold<int>(
      0,
      (sum, cat) => sum + cat.questionPapers.length,
    );
  }

  int get availablePapersCount {
    final batch = currentBatch.value;
    if (batch == null) return 0;
    return batch.categories.fold<int>(
      0,
      (sum, cat) =>
          sum +
          cat.questionPapers
              .where((p) => !p.isLocked && !p.hasSubmittedOmr)
              .length,
    );
  }

  int get upcomingPapersCount {
    final batch = currentBatch.value;
    if (batch == null) return 0;
    return batch.categories.fold<int>(
      0,
      (sum, cat) => sum + cat.questionPapers.where((p) => p.isLocked).length,
    );
  }

  int get completedPapersCount {
    final batch = currentBatch.value;
    if (batch == null) return 0;
    return batch.categories.fold<int>(
      0,
      (sum, cat) =>
          sum + cat.questionPapers.where((p) => p.hasSubmittedOmr).length,
    );
  }

  void setPaperFilter(PaperFilterStatus filter) {
    selectedPaperFilter.value = filter;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTestBatches();
  }

  Future<void> fetchTestBatches({bool isPullToRefresh = false}) async {
    if (!isPullToRefresh && testBatches.isEmpty) {
      isLoading.value = true;
    }
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

        // By default, all category expansion tiles are closed
        expandedCategoryIds.clear();
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

  Future<void> submitOmr(String paperId) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (file == null || file.path == null) {
        return;
      }

      final filePath = file.path!;
      final fileName = file.name;

      isSubmittingOmr.value = true;

      final formData = FormData.fromMap({
        'pdf': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiClient.dio.post(
        ApiConstants.testBatchSubmitOmr(paperId),
        data: formData,
      );

      if (response.data != null && response.data['status'] == 'success') {
        AppToast.success('OMR submitted successfully.');
        if (currentBatch.value != null) {
          await fetchBatchDetail(currentBatch.value!.id);
        }
      }
    } catch (e) {
      Get.log('Error submitting OMR: $e');
      AppToast.error(AppErrorHandler.getErrorMessage(
        e,
        defaultMessage: 'Failed to submit OMR sheet.',
      ));
    } finally {
      isSubmittingOmr.value = false;
    }
  }

  Future<void> updateMarks(String paperId, int marks) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiConstants.testBatchUpdateMarks(paperId),
        data: {'totalMarks': marks},
      );

      if (response.data != null && response.data['status'] == 'success') {
        AppToast.success('Marks updated successfully.');
        if (currentBatch.value != null) {
          await fetchBatchDetail(currentBatch.value!.id);
        }
      }
    } catch (e) {
      Get.log('Error updating marks: $e');
      AppToast.error(AppErrorHandler.getErrorMessage(
        e,
        defaultMessage: 'Failed to update marks.',
      ));
    }
  }

  Future<void> viewAnswerKey(String paperId, {String? title}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.testBatchAnswerKey(paperId),
      );

      if (response.data != null && response.data['status'] == 'success') {
        final answerKeyUrl = response.data['data']?['answerKeyUrl'] as String?;
        if (answerKeyUrl == null || answerKeyUrl.isEmpty) {
          AppToast.error('Answer key is not available yet.');
          return;
        }

        openPdf(answerKeyUrl, title: title ?? 'Answer Key');
      }
    } catch (e) {
      Get.log('Error fetching answer key: $e');
      AppToast.error(AppErrorHandler.getErrorMessage(
        e,
        defaultMessage: 'Submit your OMR first to access the answer key.',
      ));
    }
  }

  void toggleCategory(String categoryId) {
    if (expandedCategoryIds.contains(categoryId)) {
      expandedCategoryIds.remove(categoryId);
    } else {
      expandedCategoryIds.add(categoryId);
    }
    expandedCategoryIds.refresh();
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
