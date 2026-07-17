import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/current_affairs_models.dart';

class ImportantDateCard extends StatelessWidget {
  final ImportantDate date;

  const ImportantDateCard({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.calendar_month, color: AppColors.brandPurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date.titleEn,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                if (date.titleTa != null && date.titleTa!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    date.titleTa!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  "${date.date.day} ${_getMonthName(date.date.month)} ${date.date.year}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
            child: Text(
              date.type,
              style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int m) {
    const dates = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return (m >= 1 && m <= 12) ? dates[m - 1] : "$m";
  }
}
