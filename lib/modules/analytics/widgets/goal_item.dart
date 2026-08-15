import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/analytics_models.dart';

class GoalItem extends StatelessWidget {
  final GoalModel goal;
  final Function(double) onProgressChanged;
  final VoidCallback onDelete;

  const GoalItem({
    super.key,
    required this.goal,
    required this.onProgressChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (goal.completedValue / goal.targetValue).clamp(0.0, 1.0);
    final isCompleted = goal.status == 'COMPLETED' || progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [
          BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.goalTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Row(
                children: [
                  if (!isCompleted)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.brandPurple, size: 22),
                      onPressed: () {
                        onProgressChanged(goal.completedValue + 1);
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completed ${goal.completedValue.toInt()}/${goal.targetValue.toInt()}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.shade50 : AppColors.brandPurple.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: isCompleted ? Colors.green.shade700 : AppColors.brandPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade100,
              color: isCompleted ? Colors.green.shade500 : AppColors.brandPurple,
            ),
          )
        ],
      ),
    );
  }
}
