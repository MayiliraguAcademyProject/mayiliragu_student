import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'stat_column.dart';

class ProgressStatsCard extends StatelessWidget {
  final int articlesRead;
  final int quizzesAttempted;
  final int accuracy;

  const ProgressStatsCard({
    super.key,
    required this.articlesRead,
    required this.quizzesAttempted,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentDark, Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentDark.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.tealAccent, size: 18),
              SizedBox(width: 6),
              Text(
                "YOUR WEEKLY PREPARATION SCORE",
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatColumn(label: "Articles Read", value: "$articlesRead"),
              Container(width: 1, height: 35, color: Colors.white24),
              StatColumn(label: "MCQs Attempted", value: "$quizzesAttempted"),
              Container(width: 1, height: 35, color: Colors.white24),
              StatColumn(label: "Quiz Accuracy", value: "$accuracy%"),
            ],
          ),
        ],
      ),
    );
  }
}
