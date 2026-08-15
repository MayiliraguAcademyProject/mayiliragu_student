import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/test_runner_controller.dart';
import '../../../../shared/widgets/common_button.dart';
import '../../models/question_model.dart';
import '../../models/student_answer_model.dart';

class QuestionNavigatorSheet extends StatelessWidget {
  final TestRunnerController controller;

  const QuestionNavigatorSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question Navigator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // States Legend Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLegendItem(context, 'Not Visited', colorScheme.surfaceContainerHighest, colorScheme.onSurfaceVariant, null),
                const SizedBox(width: 10),
                _buildLegendItem(context, 'Answered', const Color(0xFF1E60FF), Colors.white, null),
                const SizedBox(width: 10),
                _buildLegendItem(context, 'Flagged', const Color(0xFFF97316), Colors.white, null),
                const SizedBox(width: 10),
                _buildLegendItem(context, 'Ans + Flag', const Color(0xFF7C3AED), Colors.white, null),
                const SizedBox(width: 10),
                _buildLegendItem(context, 'Skipped', colorScheme.surface, const Color(0xFFEF4444), Border.all(color: const Color(0xFFEF4444), width: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Questions Grid
          Flexible(
            child: Obx(() {
              final qList = controller.questions;
              return GridView.builder(
                shrinkWrap: true,
                itemCount: qList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final q = qList[index];
                  final ans = controller.userAnswers[q.id];
                  return _buildCircle(context, index, q, ans);
                },
              );
            }),
          ),
          const SizedBox(height: 24),

          // Statistics Text Summary
          Obx(() {
            final answered = controller.countAnswered;
            final remaining = controller.countRemaining;
            final flagged = controller.countFlagged;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: colorScheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Answered: $answered | Flagged: $flagged | Remaining: $remaining unanswered.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),

          // Submission Action
          Obx(() {
            return CommonButton(
              text: 'Submit Test — ${controller.countAnswered}/${controller.questions.length} Answered',
              onPressed: () {
                Get.back(); // close bottom sheet
                controller.submitTest();
              },
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              height: 48,
              borderRadius: 12,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color bg, Color text, Border? border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }

  Widget _buildCircle(BuildContext context, int index, QuestionModel q, StudentAnswer? ans) {
    final colorScheme = Theme.of(context).colorScheme;
    Color bgColor = colorScheme.surfaceContainerHighest; // Default Grey (Not Visited)
    Color textColor = colorScheme.onSurfaceVariant;
    Border? border;

    if (ans != null && ans.isVisited) {
      if (ans.isFlagged) {
        if (ans.hasAnswer) {
          bgColor = const Color(0xFF7C3AED); // Purple
          textColor = Colors.white;
        } else {
          bgColor = const Color(0xFFF97316); // Orange
          textColor = Colors.white;
        }
      } else {
        if (ans.hasAnswer) {
          bgColor = const Color(0xFF1E60FF); // Blue
          textColor = Colors.white;
        } else {
          // Visited but no answer and not flagged -> Skipped -> Red Outline
          bgColor = colorScheme.surface;
          textColor = const Color(0xFFEF4444);
          border = Border.all(color: const Color(0xFFEF4444), width: 1.5);
        }
      }
    }

    final isCurrent = index == controller.currentIndex.value;
    if (isCurrent) {
      // Bold dark blue outline around current question circle
      border = Border.all(
        color: const Color(0xFF0F3CC9),
        width: 3.0,
      );
    }

    return GestureDetector(
      onTap: () {
        controller.jumpToQuestion(index);
        Get.back(); // close bottom sheet
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
