import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/common_button.dart';
import '../../../../core/utils/toast_helper.dart';
import '../controllers/analytics_controller.dart';
import '../widgets/goal_item.dart';

class GoalsTrackerView extends StatelessWidget {
  const GoalsTrackerView({super.key});

  void _showAddGoalDialog(
    BuildContext context,
    AnalyticsController controller,
  ) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Set New Study Goal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Goal Title',
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'e.g. Attempt mock test series',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Value',
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'e.g. 5',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CommonButton(
            text: 'Add Goal',
            onPressed: () {
              final title = titleController.text.trim();
              final target = double.tryParse(targetController.text) ?? 0;
              if (title.isNotEmpty && target > 0) {
                controller.createGoal(title, target);
                Navigator.pop(context);
              } else {
                AppToast.error(
                  'Please fill valid title and numeric target',
                  title: 'Input Error',
                );
              }
            },
            backgroundColor: AppColors.brandPurple,
            foregroundColor: Colors.white,
            borderRadius: 12,
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Target Study Goals',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isGoalsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brandPurple),
          );
        }

        final goals = controller.goalsList;

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchGoals();
          },
          child: Column(
            children: [
              Expanded(
                child: goals.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              "No goals added yet. Set your first goal now!",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          return GoalItem(
                            goal: goal,
                            onProgressChanged: (newVal) {
                              controller.updateGoalProgress(goal.id, newVal);
                            },
                            onDelete: () {
                              controller.deleteGoal(goal.id);
                            },
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddGoalDialog(context, controller),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Create Custom Goal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
