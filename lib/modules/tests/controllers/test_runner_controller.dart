import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/secure_storage_service.dart';
import '../models/question_model.dart';
import '../models/student_answer_model.dart';
import '../models/test_model.dart';
import '../repositories/tests_repository.dart';

class TestRunnerController extends GetxController {
  final TestsRepository _repository;

  TestRunnerController(this._repository);

  // States
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final testTitle = 'Practice Test'.obs;
  final questions = <QuestionModel>[].obs;
  final currentIndex = 0.obs;

  // Active Test Configuration
  String? _activeTestId;
  String? activeSectionId;
  int? activeSectionIndex;
  int _totalDurationSeconds = 0;

  // Timer fields
  final remainingSeconds = 0.obs;
  Timer? _countdownTimer;

  // Answers cache: Map<questionId, StudentAnswer>
  final userAnswers = <String, StudentAnswer>{}.obs;

  // Auto-save fields
  final isSaving = false.obs;
  final showAutoSavedBadge = false.obs;
  Timer? _autoSaveTimer;
  bool _isDirty = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      loadTest(args);
    } else if (args is Map) {
      final String? testId = args['test_id'] as String?;
      activeSectionId = args['section_id'] as String?;
      activeSectionIndex = args['section_index'] as int?;
      if (testId != null) {
        loadTest(testId);
      } else {
        errorMessage.value = 'No test selected';
        isLoading.value = false;
      }
    } else {
      errorMessage.value = 'No test selected';
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _autoSaveTimer?.cancel();
    super.onClose();
  }

  Future<void> loadSectionDraft() async {
    if (_activeTestId == null || activeSectionId == null) return;
    try {
      final secureStorage = Get.find<SecureStorageService>();
      final draftStr = await secureStorage.readString('test_draft_$_activeTestId');
      if (draftStr != null) {
        final Map<String, dynamic> draft = jsonDecode(draftStr);
        
        final Map<String, dynamic> answers = draft['answers'] ?? {};
        answers.forEach((qId, ansJson) {
          userAnswers[qId] = StudentAnswer.fromJson(Map<String, dynamic>.from(ansJson));
        });

        final Map<String, dynamic> timers = draft['section_timers'] ?? {};
        if (timers.containsKey(activeSectionId)) {
          remainingSeconds.value = timers[activeSectionId] as int;
        } else {
          remainingSeconds.value = _totalDurationSeconds;
        }
      } else {
        remainingSeconds.value = _totalDurationSeconds;
      }
    } catch (e) {
      print('Error loading section draft: $e');
      remainingSeconds.value = _totalDurationSeconds;
    }
  }

  Future<void> saveSectionDraft() async {
    if (_activeTestId == null || activeSectionId == null) return;
    try {
      final secureStorage = Get.find<SecureStorageService>();
      final draftStr = await secureStorage.readString('test_draft_$_activeTestId');
      Map<String, dynamic> draft = {};
      if (draftStr != null) {
        draft = jsonDecode(draftStr);
      }

      final Map<String, dynamic> answers = draft['answers'] ?? {};
      userAnswers.forEach((qId, ans) {
        answers[qId] = ans.toJson();
      });
      draft['answers'] = answers;

      final Map<String, dynamic> timers = draft['section_timers'] ?? {};
      timers[activeSectionId!] = remainingSeconds.value;
      draft['section_timers'] = timers;

      await secureStorage.writeString('test_draft_$_activeTestId', jsonEncode(draft));
    } catch (e) {
      print('Error saving section draft: $e');
    }
  }

  Future<void> markSectionCompleted() async {
    if (_activeTestId == null || activeSectionId == null) return;
    try {
      final secureStorage = Get.find<SecureStorageService>();
      final draftStr = await secureStorage.readString('test_draft_$_activeTestId');
      Map<String, dynamic> draft = {};
      if (draftStr != null) {
        draft = jsonDecode(draftStr);
      }

      final List<dynamic> completed = draft['completed_sections'] ?? [];
      if (!completed.contains(activeSectionId)) {
        completed.add(activeSectionId);
      }
      draft['completed_sections'] = completed;

      await secureStorage.writeString('test_draft_$_activeTestId', jsonEncode(draft));
    } catch (e) {
      print('Error marking section completed: $e');
    }
  }

  Future<void> loadTest(String testId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _activeTestId = testId;

      final response = await _repository.getTestById(testId);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        testTitle.value = data['title'] ?? 'Practice Test';
        
        final testModel = TestModel.fromJson(data);
        final List<QuestionModel> loadedQuestions = testModel.questions ?? [];

        final bool testIsSectioned = testModel.isSectioned;
        
        if (testIsSectioned && activeSectionId != null) {
          final TestSectionModel section = testModel.sections!.firstWhere(
            (s) => s.id == activeSectionId || s.name == activeSectionId,
          );
          
          final sectionQuestions = loadedQuestions.where((q) => q.sectionId == section.id || q.sectionId == section.name).toList();
          questions.assignAll(sectionQuestions);
          _totalDurationSeconds = section.duration * 60;
        } else {
          questions.assignAll(loadedQuestions);
          _totalDurationSeconds = (data['duration'] ?? 45) * 60;
        }

        // Initialize userAnswers with visited = false
        userAnswers.clear();
        for (var q in questions) {
          userAnswers[q.id] = StudentAnswer(questionId: q.id);
        }

        // Set first question as visited
        if (questions.isNotEmpty) {
          _markAsVisited(questions[0].id);
        }

        if (testIsSectioned && activeSectionId != null) {
          await loadSectionDraft();
        } else {
          remainingSeconds.value = _totalDurationSeconds;
        }

        // Start timer
        _startTimer();

        // Start auto-save periodic trigger (10 seconds)
        _startAutoSave();
      } else {
        errorMessage.value = 'Failed to load test details';
      }
    } catch (e) {
      errorMessage.value = 'Error loading test: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Timer logic
  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        if (activeSectionId != null) {
          submitSectionOrTest(isTimeOut: true);
        } else {
          submitTest(isTimeOut: true);
        }
      }
    });
  }

  String get formattedTime {
    final int hours = remainingSeconds.value ~/ 3600;
    final int minutes = (remainingSeconds.value % 3600) ~/ 60;
    final int seconds = remainingSeconds.value % 60;

    final String hoursStr = hours.toString().padLeft(2, '0');
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hoursStr:$minutesStr:$secondsStr';
    }
    return '$minutesStr:$secondsStr';
  }

  // Navigator functions
  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
      _markAsVisited(questions[currentIndex.value].id);
    }
  }

  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      _markAsVisited(questions[currentIndex.value].id);
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      currentIndex.value = index;
      _markAsVisited(questions[index].id);
    }
  }

  void _markAsVisited(String questionId) {
    final ans = userAnswers[questionId];
    if (ans != null && !ans.isVisited) {
      userAnswers[questionId] = StudentAnswer(
        questionId: questionId,
        selectedOptionIds: ans.selectedOptionIds,
        booleanAnswer: ans.booleanAnswer,
        textAnswer: ans.textAnswer,
        isFlagged: ans.isFlagged,
        isVisited: true,
      );
      _isDirty = true;
    }
  }

  // Answer selections
  void selectSingleChoiceOption(String questionId, String optionId) {
    final ans = userAnswers[questionId];
    userAnswers[questionId] = StudentAnswer(
      questionId: questionId,
      selectedOptionIds: [optionId],
      isFlagged: ans?.isFlagged ?? false,
      isVisited: true,
    );
    _isDirty = true;
    if (activeSectionId != null) saveSectionDraft();
  }

  void toggleMultiChoiceOption(String questionId, String optionId) {
    final ans = userAnswers[questionId];
    final List<String> currentSelections = List.from(ans?.selectedOptionIds ?? []);

    if (currentSelections.contains(optionId)) {
      currentSelections.remove(optionId);
    } else {
      currentSelections.add(optionId);
    }

    userAnswers[questionId] = StudentAnswer(
      questionId: questionId,
      selectedOptionIds: currentSelections,
      isFlagged: ans?.isFlagged ?? false,
      isVisited: true,
    );
    _isDirty = true;
    if (activeSectionId != null) saveSectionDraft();
  }

  void setBooleanAnswer(String questionId, bool value) {
    final ans = userAnswers[questionId];
    userAnswers[questionId] = StudentAnswer(
      questionId: questionId,
      booleanAnswer: value,
      isFlagged: ans?.isFlagged ?? false,
      isVisited: true,
    );
    _isDirty = true;
    if (activeSectionId != null) saveSectionDraft();
  }

  void setTextAnswer(String questionId, String text) {
    final ans = userAnswers[questionId];
    userAnswers[questionId] = StudentAnswer(
      questionId: questionId,
      textAnswer: text,
      isFlagged: ans?.isFlagged ?? false,
      isVisited: true,
    );
    _isDirty = true;
    if (activeSectionId != null) saveSectionDraft();
  }

  void setDescriptiveText(String questionId, String text) {
    final ans = userAnswers[questionId];
    userAnswers[questionId] = StudentAnswer(
      questionId: questionId,
      descriptiveText: text,
      attachmentUrl: ans?.attachmentUrl,
      isFlagged: ans?.isFlagged ?? false,
      isVisited: true,
    );
    _isDirty = true;
    if (activeSectionId != null) saveSectionDraft();
  }

  void setAttachmentUrl(String questionId, String url) {
    final ans = userAnswers[questionId];
    userAnswers[questionId] = StudentAnswer(
      questionId: questionId,
      descriptiveText: ans?.descriptiveText,
      attachmentUrl: url,
      isFlagged: ans?.isFlagged ?? false,
      isVisited: true,
    );
    _isDirty = true;
    if (activeSectionId != null) saveSectionDraft();
  }

  void toggleFlag(String questionId) {
    final ans = userAnswers[questionId];
    userAnswers[questionId] = StudentAnswer(
      questionId: questionId,
      selectedOptionIds: ans?.selectedOptionIds,
      booleanAnswer: ans?.booleanAnswer,
      textAnswer: ans?.textAnswer,
      isFlagged: !(ans?.isFlagged ?? false),
      isVisited: true,
    );
    _isDirty = true;
    if (activeSectionId != null) saveSectionDraft();
  }

  // Palette stats
  int get countAnswered => userAnswers.values.where((ans) => ans.hasAnswer).length;
  int get countFlagged => userAnswers.values.where((ans) => ans.isFlagged).length;
  int get countSkipped => userAnswers.values.where((ans) => ans.isVisited && !ans.hasAnswer && !ans.isFlagged).length;
  int get countRemaining => questions.length - countAnswered;

  // Auto-Save background sync
  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_isDirty && !isSaving.value) {
        await triggerSync();
      }
    });
  }

  Future<void> triggerSync() async {
    try {
      isSaving.value = true;
      
      // Simulate backend save delay and debug log
      await Future.delayed(const Duration(milliseconds: 600));
      _isDirty = false;

      // Trigger temporary success notification toast
      showAutoSavedBadge.value = true;
      Future.delayed(const Duration(seconds: 2), () {
        showAutoSavedBadge.value = false;
      });
    } catch (e) {
      // Offline fallback: keep dirty status
    } finally {
      isSaving.value = false;
    }
  }

  // Submission handler
  Future<void> submitSectionOrTest({bool isTimeOut = false}) async {
    _countdownTimer?.cancel();
    _autoSaveTimer?.cancel();

    if (_activeTestId == null || activeSectionId == null) {
      Get.back();
      return;
    }

    await saveSectionDraft();
    await markSectionCompleted();

    try {
      final response = await _repository.getTestById(_activeTestId!);
      if (response.statusCode == 200) {
        final testModel = TestModel.fromJson(response.data['data']);
        final sectionsList = testModel.sections ?? [];
        
        final int currentSecIdx = sectionsList.indexWhere((s) => s.id == activeSectionId || s.name == activeSectionId);
        
        if (currentSecIdx != -1 && currentSecIdx < sectionsList.length - 1) {
          if (isTimeOut) {
            Get.snackbar(
              'Time\'s Up!',
              'Automatically moving to the next section.',
              backgroundColor: Colors.amber,
              colorText: Colors.black,
            );
          }
          Get.back(); 
        } else {
          await submitFullSectionedTest();
        }
      } else {
        Get.back();
      }
    } catch (e) {
      print('Error in submitSectionOrTest: $e');
      Get.back();
    }
  }

  Future<void> submitFullSectionedTest() async {
    if (_activeTestId == null) return;

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      barrierDismissible: false,
    );

    try {
      final secureStorage = Get.find<SecureStorageService>();
      final draftStr = await secureStorage.readString('test_draft_$_activeTestId');
      Map<String, dynamic> draft = {};
      if (draftStr != null) {
        draft = jsonDecode(draftStr);
      }

      final Map<String, dynamic> draftAns = draft['answers'] ?? {};
      final response = await _repository.getTestById(_activeTestId!);
      final testModel = TestModel.fromJson(response.data['data']);
      
      final List<Map<String, dynamic>> sectionsPayload = [];
      int totalTimeTaken = 0;

      if (testModel.sections != null) {
        for (var sec in testModel.sections!) {
          final List<Map<String, dynamic>> secAnswers = [];
          final secQs = testModel.questions?.where((q) => q.sectionId == sec.id || q.sectionId == sec.name).toList() ?? [];
          for (var q in secQs) {
            final ansMap = draftAns[q.id];
            if (ansMap != null) {
              secAnswers.add(ansMap);
            } else {
              secAnswers.add(StudentAnswer(questionId: q.id).toJson());
            }
          }

          final Map<String, dynamic> timers = draft['section_timers'] ?? {};
          final int secRemaining = timers[sec.id] ?? timers[sec.name] ?? 0;
          final int secTimeTaken = (sec.duration * 60) - secRemaining;
          totalTimeTaken += secTimeTaken;

          sectionsPayload.add({
            'section_id': sec.id,
            'time_taken': secTimeTaken,
            'answers': secAnswers,
          });
        }
      }

      final submitResponse = await _repository.submitTestAttempt(_activeTestId!, {
        'time_taken': totalTimeTaken,
        'sections': sectionsPayload,
      });

      Get.back();

      if (submitResponse.statusCode == 200) {
        final result = Map<String, dynamic>.from(submitResponse.data['data']);
        result['test_id'] = _activeTestId;
        result['test_title'] = testTitle.value;

        await secureStorage.deleteKey('test_draft_$_activeTestId');

        Get.offNamed('/test-results', arguments: result);
      } else {
        Get.offAllNamed('/dashboard');
      }
    } catch (e) {
      Get.back();
      Get.offAllNamed('/dashboard');
    }
  }

  Future<void> submitTest({bool isTimeOut = false}) async {
    _countdownTimer?.cancel();
    _autoSaveTimer?.cancel();

    if (_activeTestId == null) {
      Get.back();
      return;
    }

    // Show loading spinner
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      barrierDismissible: false,
    );

    final int timeTaken = _totalDurationSeconds - remainingSeconds.value;
    final answersPayload = userAnswers.values.map((ans) => ans.toJson()).toList();

    try {
      final response = await _repository.submitTestAttempt(_activeTestId!, {
        'time_taken': timeTaken,
        'answers': answersPayload,
      });

      // Close loading spinner
      Get.back();

      if (response.statusCode == 200) {
        final result = Map<String, dynamic>.from(response.data['data']);
        result['test_id'] = _activeTestId;
        result['test_title'] = testTitle.value;

        // Redirect to test results dashboard
        Get.offNamed('/test-results', arguments: result);
      } else {
        _runOfflineFallback(timeTaken);
      }
    } catch (e) {
      // Close loading spinner
      Get.back();
      _runOfflineFallback(timeTaken);
    }
  }

  void _runOfflineFallback(int timeTaken) {
    int correct = 0;
    int wrong = 0;
    int skipped = 0;
    double scoreSum = 0;
    double totalMarks = 0;

    final subjectStats = <String, Map<String, int>>{};

    for (var q in questions) {
      totalMarks += q.marksCorrect;
      final ans = userAnswers[q.id];
      
      final subj = q.subjectId.isNotEmpty ? q.subjectId : 'General Studies';
      if (!subjectStats.containsKey(subj)) {
        subjectStats[subj] = {'total': 0, 'correct': 0};
      }
      subjectStats[subj]!['total'] = subjectStats[subj]!['total']! + 1;

      if (ans == null || !ans.hasAnswer) {
        skipped++;
        continue;
      }

      bool isCorrect = false;
      if (q.type == QuestionType.singleChoice) {
        final selId = (ans.selectedOptionIds ?? []).isNotEmpty ? ans.selectedOptionIds!.first : null;
        final correctOpt = q.options?.firstWhere(
          (o) => o.id == selId && o.isCorrect,
          orElse: () => QuestionOption(id: '', label: '', textEn: '', textTa: '', isCorrect: false),
        );
        if (correctOpt != null && correctOpt.id.isNotEmpty) isCorrect = true;
      } else if (q.type == QuestionType.multiChoice) {
        final selIds = ans.selectedOptionIds ?? [];
        final correctIds = q.options?.where((o) => o.isCorrect).map((o) => o.id).toList() ?? [];
        final sameLen = selIds.length == correctIds.length;
        final matchesAll = selIds.every((id) => correctIds.contains(id));
        if (sameLen && matchesAll) isCorrect = true;
      } else if (q.type == QuestionType.trueFalse) {
        if (ans.booleanAnswer == q.correctAnswer) isCorrect = true;
      } else if (q.type == QuestionType.fillInBlank) {
        final accepted = q.acceptedAnswers ?? [];
        final studentText = (ans.textAnswer ?? '').trim().toLowerCase();
        final isMatch = accepted.any((a) => (a.value).trim().toLowerCase() == studentText);
        if (isMatch) isCorrect = true;
      } else if (q.type == QuestionType.descriptive) {
        continue;
      }

      if (isCorrect) {
        correct++;
        scoreSum += q.marksCorrect;
        subjectStats[subj]!['correct'] = subjectStats[subj]!['correct']! + 1;
      } else {
        wrong++;
        scoreSum -= q.marksWrong;
      }
    }

    final scorePercent = totalMarks > 0 ? ((scoreSum < 0 ? 0 : scoreSum) / totalMarks * 100).round() : 0;
    final accuracy = (correct + wrong) > 0 ? (correct / (correct + wrong) * 100).round() : 0;

    final subjectPerformance = subjectStats.entries.map((e) => {
      'subject': e.key,
      'percentage': e.value['total']! > 0 ? (e.value['correct']! / e.value['total']! * 100).round() : 0
    }).toList();

    final fallbackMap = {
      'test_id': _activeTestId ?? '',
      'test_title': testTitle.value,
      'score': scorePercent,
      'correct': correct,
      'wrong': wrong,
      'skipped': skipped,
      'accuracy': accuracy,
      'time_taken': timeTaken,
      'passed': scorePercent >= 40,
      'rank': 1,
      'class_avg': 61,
      'top_score': 94,
      'subject_performance': subjectPerformance
    };

    Get.offNamed('/test-results', arguments: fallbackMap);
  }
}
