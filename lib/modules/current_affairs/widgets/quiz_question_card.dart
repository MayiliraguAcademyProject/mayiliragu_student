import 'package:Mayiliragu/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/current_affairs_models.dart';

class QuizQuestionCard extends StatelessWidget {
  final CurrentAffairQuiz quiz;
  final int index;
  final bool isSubmitted;
  final String? selectedOption;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback onSubmit;
  final bool showTamil;

  const QuizQuestionCard({
    super.key,
    required this.quiz,
    required this.index,
    required this.isSubmitted,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.onSubmit,
    this.showTamil = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasTamilQuestion = quiz.questionTa != null && quiz.questionTa!.isNotEmpty;
    final questionText = (showTamil && hasTamilQuestion) ? quiz.questionTa! : quiz.questionEn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Q${index + 1}. $questionText",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ...['A', 'B', 'C', 'D'].map((opt) {
            final isSelected = selectedOption == opt;
            final isCorrect = quiz.correctAnswer == opt;

            Color optionBg = Colors.white;
            Color optionBorder = Colors.grey.shade200;
            IconData? statusIcon;

            if (isSubmitted) {
              if (isCorrect) {
                optionBg = Colors.green.shade50;
                optionBorder = Colors.green;
                statusIcon = Icons.check_circle;
              } else if (isSelected) {
                optionBg = Colors.red.shade50;
                optionBorder = Colors.red;
                statusIcon = Icons.cancel;
              }
            } else if (isSelected) {
              optionBg = AppColors.brandPurple.withValues(alpha: 0.08);
              optionBorder = AppColors.brandPurple;
            }

            final optionIndex = ['A', 'B', 'C', 'D'].indexOf(opt);
            final hasTamilOptions = quiz.optionsTa != null && quiz.optionsTa!.isNotEmpty;
            final optionText = optionIndex < quiz.optionsEn.length
                ? ((showTamil && hasTamilOptions && optionIndex < quiz.optionsTa!.length)
                    ? quiz.optionsTa![optionIndex]
                    : quiz.optionsEn[optionIndex])
                : '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: isSubmitted ? null : () => onOptionSelected(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: optionBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: optionBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "$opt. $optionText",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (statusIcon != null)
                        Icon(statusIcon, color: optionBorder, size: 16),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (!isSubmitted && selectedOption != null) ...[
            const SizedBox(height: 12),
            CommonButton(
                  text: "Submit Answer",
                  onPressed: onSubmit,
                  backgroundColor: AppColors.brandPurple,
                  foregroundColor: Colors.white,
                  borderRadius: 12,
                ),
          ],
          if (isSubmitted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Explanation:",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.amber),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ((showTamil && quiz.explanationTa != null && quiz.explanationTa!.isNotEmpty)
                        ? quiz.explanationTa!
                        : (quiz.explanationEn ?? "No explanation available.")),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
