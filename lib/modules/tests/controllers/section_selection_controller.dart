import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/services/secure_storage_service.dart';
import '../models/test_model.dart';
import '../repositories/tests_repository.dart';

class SectionSelectionController extends GetxController {
  final TestsRepository _repository;
  final SecureStorageService _storage = Get.find<SecureStorageService>();

  SectionSelectionController(this._repository);

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final test = Rxn<TestModel>();

  // Attempt State
  final completedSections = <String>{}.obs;
  final sectionTimers = <String, int>{}.obs;
  final draftAnswers = <String, Map<String, dynamic>>{}.obs; // Map<questionId, answerJson>

  late String testId;

  @override
  void onInit() {
    super.onInit();
    testId = Get.arguments as String;
    loadTestDetails();
  }

  Future<void> loadTestDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getTestById(testId);
      if (response.statusCode == 200) {
        test.value = TestModel.fromJson(response.data['data']);
        await loadDraftState();
      } else {
        errorMessage.value = 'Failed to load test details';
      }
    } catch (e) {
      errorMessage.value = 'Error loading test: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDraftState() async {
    try {
      final draftStr = await _storage.readString('test_draft_$testId');
      if (draftStr != null) {
        final Map<String, dynamic> draft = jsonDecode(draftStr);
        final List<dynamic> completed = draft['completed_sections'] ?? [];
        completedSections.assignAll(completed.cast<String>());

        final Map<String, dynamic> timers = draft['section_timers'] ?? {};
        sectionTimers.assignAll(timers.map((key, value) => MapEntry(key, value as int)));

        final Map<String, dynamic> answers = draft['answers'] ?? {};
        draftAnswers.assignAll(answers.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value))));
      } else {
        completedSections.clear();
        sectionTimers.clear();
        draftAnswers.clear();
      }
    } catch (e) {
      print('Error loading draft state: $e');
    }
  }

  Future<void> saveDraftState() async {
    try {
      final draft = {
        'completed_sections': completedSections.toList(),
        'section_timers': sectionTimers,
        'answers': draftAnswers,
      };
      await _storage.writeString('test_draft_$testId', jsonEncode(draft));
    } catch (e) {
      print('Error saving draft state: $e');
    }
  }

  Future<void> clearDraftState() async {
    try {
      await _storage.deleteKey('test_draft_$testId');
      completedSections.clear();
      sectionTimers.clear();
      draftAnswers.clear();
    } catch (e) {
      print('Error clearing draft state: $e');
    }
  }

  bool isSectionLocked(TestSectionModel section) {
    return completedSections.contains(section.id) || completedSections.contains(section.name);
  }

  bool isSectionEnabled(TestSectionModel section) {
    if (test.value == null) return false;
    final index = test.value!.sections?.indexOf(section) ?? -1;
    if (index == 0) return true;
    
    final prevSection = test.value!.sections![index - 1];
    return isSectionLocked(prevSection);
  }
}
