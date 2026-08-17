import 'package:get/get.dart';
import '../../../core/utils/error_handler.dart';
import '../models/study_material_models.dart';
import '../repositories/study_materials_repository.dart';
import '../../../core/utils/toast_helper.dart';

class StudyMaterialsController extends GetxController {
  final StudyMaterialsRepository _repository;

  StudyMaterialsController(this._repository);

  // Loading states
  final isCategoriesLoading = false.obs;
  final isMaterialsLoading = false.obs;
  final isDetailLoading = false.obs;
  final isDownloading = false.obs;

  // Data lists
  final categoriesList = <MaterialCategory>[].obs;
  final materialsList = <StudyMaterial>[].obs;
  final bookmarksList = <StudyMaterial>[].obs;

  // Detail item
  final currentMaterial = Rxn<StudyMaterial>();

  // Filter/Search variables
  final selectedCategoryId = ''.obs;
  final searchQuery = ''.obs;

  // Error/Success messages
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchMaterials();
    fetchBookmarks();
  }

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;
      final response = await _repository.getCategories();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<MaterialCategory> loaded =
            data.map((item) => MaterialCategory.fromJson(item)).toList();
        categoriesList.assignAll(loaded);
      }
    } catch (e) {
      print('Categories load error: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchMaterials() async {
    try {
      isMaterialsLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getMaterials(
        categoryId: selectedCategoryId.value.isEmpty ? null : selectedCategoryId.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<StudyMaterial> loaded =
            data.map((item) => StudyMaterial.fromJson(item)).toList();
        materialsList.assignAll(loaded);
      } else {
        errorMessage.value = 'Failed to load study materials';
      }
    } catch (e) {
      errorMessage.value = AppErrorHandler.getErrorMessage(e);
    } finally {
      isMaterialsLoading.value = false;
    }
  }

  Future<void> fetchMaterialDetail(String id) async {
    try {
      isDetailLoading.value = true;
      errorMessage.value = '';
      currentMaterial.value = null;

      final response = await _repository.getMaterialById(id);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          currentMaterial.value = StudyMaterial.fromJson(data);
        }
      } else {
        errorMessage.value = 'Failed to load details';
      }
    } catch (e) {
      errorMessage.value = AppErrorHandler.getErrorMessage(e);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> toggleBookmark(String id) async {
    try {
      final response = await _repository.toggleBookmark(id);
      if (response.statusCode == 200) {
        // Toggle in materialsList local state
        final idx = materialsList.indexWhere((m) => m.id == id);
        if (idx != -1) {
          final m = materialsList[idx];
          materialsList[idx] = StudyMaterial(
            id: m.id,
            title: m.title,
            description: m.description,
            categoryId: m.categoryId,
            subjectId: m.subjectId,
            topicId: m.topicId,
            fileUrl: m.fileUrl,
            fileSize: m.fileSize,
            fileType: m.fileType,
            accessType: m.accessType,
            status: m.status,
            version: m.version,
            isBookmarked: !m.isBookmarked,
            createdAt: m.createdAt,
            category: m.category,
            versions: m.versions,
          );
        }

        // Toggle in current details item
        if (currentMaterial.value?.id == id) {
          final m = currentMaterial.value!;
          currentMaterial.value = StudyMaterial(
            id: m.id,
            title: m.title,
            description: m.description,
            categoryId: m.categoryId,
            subjectId: m.subjectId,
            topicId: m.topicId,
            fileUrl: m.fileUrl,
            fileSize: m.fileSize,
            fileType: m.fileType,
            accessType: m.accessType,
            status: m.status,
            version: m.version,
            isBookmarked: !m.isBookmarked,
            createdAt: m.createdAt,
            category: m.category,
            versions: m.versions,
          );
        }

        fetchBookmarks();
      }
    } catch (e) {
      print('Toggle bookmark error: $e');
    }
  }

  Future<void> fetchBookmarks() async {
    try {
      final response = await _repository.getBookmarkedMaterials();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<StudyMaterial> loaded = data.map((item) {
          final detail = item['material'];
          return StudyMaterial.fromJson({
            ...detail,
            'isBookmarked': true,
          });
        }).toList();
        bookmarksList.assignAll(loaded);
      }
    } catch (e) {
      print('Fetch bookmarks error: $e');
    }
  }

  Future<Map<String, dynamic>?> downloadMaterial(String id) async {
    try {
      isDownloading.value = true;
      final response = await _repository.downloadMaterial(id);
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        AppToast.error(response.data['message'] ?? 'Unable to download file', title: 'Download Failed');
      }
    } catch (e) {
      AppToast.error('Unable to initiate download: $e', title: 'Error');
    } finally {
      isDownloading.value = false;
    }
    return null;
  }
}
