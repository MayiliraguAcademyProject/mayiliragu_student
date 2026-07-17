import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/analytics_controller.dart';

class SubjectAnalysisView extends StatelessWidget {
  const SubjectAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Subject Breakdowns',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: Obx(() {
        final subjects = controller.subjectAnalyticsList;
        final topics = controller.topicAnalyticsList;

        if (subjects.isEmpty) {
          return const Center(
            child: Text(
              "No subject analytics recorded. Attempt tests first!",
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subject Analytics',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final sub = subjects[index];
                  return _buildAnalysisCard(
                    sub.subjectName,
                    sub.accuracy,
                    'Average score: ${sub.averageScore.toStringAsFixed(1)} pts',
                  );
                },
              ),
              const SizedBox(height: 24),
              if (topics.isNotEmpty) ...[
                const Text(
                  'Topic Breakdown',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final top = topics[index];
                    return _buildAnalysisCard(
                      top.topicName,
                      top.accuracy,
                      'Average score: ${top.averageScore.toStringAsFixed(1)} pts',
                    );
                  },
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAnalysisCard(String name, double accuracy, String scoreInfo) {
    Color statusColor;
    String statusLabel;
    Color bgLight;

    if (accuracy >= 80) {
      statusColor = Colors.green.shade600;
      statusLabel = 'Strong';
      bgLight = Colors.green.shade50;
    } else if (accuracy >= 50) {
      statusColor = Colors.orange.shade700;
      statusLabel = 'Moderate';
      bgLight = Colors.orange.shade50;
    } else {
      statusColor = Colors.red.shade600;
      statusLabel = 'Weak';
      bgLight = Colors.red.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Accuracy: ${accuracy.toInt()}%',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              Text(
                scoreInfo,
                style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: accuracy / 100,
              minHeight: 5,
              backgroundColor: Colors.grey.shade100,
              color: statusColor,
            ),
          )
        ],
      ),
    );
  }
}
