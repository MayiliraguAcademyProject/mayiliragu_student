import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/test_runner_controller.dart';
import '../models/question_model.dart';
import 'widgets/question_layouts.dart';
import 'widgets/question_navigator_sheet.dart';
import 'widgets/submit_confirmation_dialog.dart';


class TestRunnerView extends GetView<TestRunnerController> {
  const TestRunnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirm = await _showExitConfirmation(context);
        if (confirm == true) {
          if (controller.activeSectionId != null) {
            controller.submitSectionOrTest();
          } else {
            controller.submitTest();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F3CC9), // Deep Blue Header
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final confirm = await _showExitConfirmation(context);
                  if (confirm == true) {
                    if (controller.activeSectionId != null) {
                      controller.submitSectionOrTest();
                    } else {
                      controller.submitTest();
                    }
                  }
                },
                icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 20),
                label: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Obx(() => Text(
                      controller.testTitle.value,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    )),
              ),
              Obx(() {
                final isRed = controller.remainingSeconds.value < 300; // Less than 5 mins remaining
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isRed ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        color: isRed ? const Color(0xFFDC2626) : const Color(0xFF1E60FF),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.formattedTime,
                        style: TextStyle(
                          color: isRed ? const Color(0xFFDC2626) : const Color(0xFF1E60FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            );
          }

          if (controller.questions.isEmpty) {
            return const Center(
              child: Text('No questions found in this test.'),
            );
          }

          final QuestionModel currentQuestion = controller.questions[controller.currentIndex.value];
          final ans = controller.userAnswers[currentQuestion.id];

          return Column(
            children: [
              // Secondary Status / Progress Bar
              _buildSecondaryStatusBar(),

              // Main Question Content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Info Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Q.${controller.currentIndex.value + 1} of ${controller.questions.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F3CC9),
                                ),
                              ),
                              Row(
                                children: [
                                  _buildDifficultyBadge(currentQuestion.difficulty),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      ans?.isFlagged == true ? Icons.bookmark : Icons.bookmark_border,
                                      color: ans?.isFlagged == true ? const Color(0xFFF97316) : Colors.grey,
                                      size: 24,
                                    ),
                                    onPressed: () => controller.toggleFlag(currentQuestion.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // Score info
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${currentQuestion.marksCorrect.toInt()} Marks',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                                ),
                              ),
                              if (currentQuestion.marksWrong > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '-${currentQuestion.marksWrong} Penalty',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 1. Shared Context Passage or Caselet (RC / DI)
                          if (currentQuestion.sharedContextEn != null && currentQuestion.sharedContextEn!.isNotEmpty)
                            SharedContextBlock(question: currentQuestion),

                          // 2. Data Interpretation Structured Table
                          if (currentQuestion.tableData != null && currentQuestion.tableData!.isNotEmpty)
                            DiTableWidget(rows: currentQuestion.tableData!),

                          // 3. Question / Dataset Images Row
                          if (currentQuestion.images != null && currentQuestion.images!.isNotEmpty)
                            QuestionImagesRow(images: currentQuestion.images!),

                          if (currentQuestion.images != null && currentQuestion.images!.isNotEmpty)
                            const SizedBox(height: 12),

                          // 4. Question Text or Assertion-Reason Statements
                          if (currentQuestion.format == QuestionFormat.assertionReason)
                            AssertionReasonCard(question: currentQuestion)
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (currentQuestion.questionTextEn.isNotEmpty)
                                  Text(
                                    currentQuestion.questionTextEn,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      height: 1.5,
                                    ),
                                  ),
                                if (currentQuestion.questionTextEn.isNotEmpty &&
                                    currentQuestion.questionTextTa != null &&
                                    currentQuestion.questionTextTa!.isNotEmpty)
                                  const SizedBox(height: 6),
                                if (currentQuestion.questionTextTa != null &&
                                    currentQuestion.questionTextTa!.isNotEmpty)
                                  Text(
                                    currentQuestion.questionTextTa!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 24),

                          // Choice options based on type

                          // Choice options based on type
                          _buildQuestionLayout(currentQuestion, ans),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Navigation bar
              _buildBottomNavigationBar(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDifficultyBadge(String diff) {
    Color bg = const Color(0xFFEBFDF2);
    Color txt = const Color(0xFF10B981);
    if (diff.toLowerCase() == 'medium') {
      bg = const Color(0xFFFFF3EC);
      txt = const Color(0xFFF97316);
    } else if (diff.toLowerCase() == 'hard') {
      bg = const Color(0xFFFDF2F2);
      txt = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        diff.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: txt),
      ),
    );
  }

  Widget _buildSecondaryStatusBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Answered: ${controller.countAnswered}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Text(
                'Flagged: ${controller.countFlagged}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ],
          ),
          Obx(() {
            if (controller.showAutoSavedBadge.value) {
              return Row(
                children: const [
                  Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Auto-saved',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                  ),
                ],
              );
            }
            if (controller.isSaving.value) {
              return Row(
                children: const [
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.grey),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Saving...',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionLayout(QuestionModel question, ans) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return SingleChoiceLayout(
          question: question,
          answer: ans,
          onOptionSelected: (optId) => controller.selectSingleChoiceOption(question.id, optId),
        );
      case QuestionType.multiChoice:
        return MultiChoiceLayout(
          question: question,
          answer: ans,
          onOptionToggled: (optId) => controller.toggleMultiChoiceOption(question.id, optId),
        );
      case QuestionType.trueFalse:
        return TrueFalseLayout(
          question: question,
          answer: ans,
          onAnswerChanged: (val) => controller.setBooleanAnswer(question.id, val),
        );
      case QuestionType.fillInBlank:
        return FillInBlankLayout(
          question: question,
          answer: ans,
          onAnswerChanged: (val) => controller.setTextAnswer(question.id, val),
        );
      case QuestionType.descriptive:
        return DescriptiveLayout(
          question: question,
          answer: ans,
          onAnswerChanged: (val) => controller.setDescriptiveText(question.id, val),
          onAttachmentChanged: (val) => controller.setAttachmentUrl(question.id, val),
        );
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => OutlinedButton(
                  onPressed: controller.currentIndex.value > 0 ? () => controller.previousQuestion() : null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Previous', style: TextStyle(color: Colors.black54)),
                )),
            IconButton(
              icon: const Icon(Icons.grid_on_rounded, color: Color(0xFF0F3CC9), size: 28),
              onPressed: () {
                Get.bottomSheet(
                  QuestionNavigatorSheet(controller: controller),
                  isScrollControlled: true,
                );
              },
            ),
            Obx(() {
              final isLast = controller.currentIndex.value == controller.questions.length - 1;
              return ElevatedButton(
                onPressed: () {
                  if (isLast) {
                    showDialog(
                      context: context,
                      builder: (context) => SubmitConfirmationDialog(
                        answeredCount: controller.countAnswered,
                        skippedCount: controller.countSkipped,
                        flaggedCount: controller.countFlagged,
                        totalCount: controller.questions.length,
                        onSubmit: () {
                          if (controller.activeSectionId != null) {
                            controller.submitSectionOrTest();
                          } else {
                            controller.submitTest();
                          }
                        },
                      ),
                    );
                  } else {
                    controller.nextQuestion();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast ? const Color(0xFF10B981) : const Color(0xFF0F3CC9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(isLast ? 'Submit' : 'Next >'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test?'),
        content: const Text(
          'Are you sure you want to exit? Your progress is auto-saved, but you will submit your test in its current state.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit & Exit'),
          ),
        ],
      ),
    );
  }
}
