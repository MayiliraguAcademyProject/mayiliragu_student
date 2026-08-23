import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/pdf_viewer_screen.dart';
import '../models/current_affairs_models.dart';

class MonthlyMagazineCard extends StatelessWidget {
  final MonthlyMagazine magazine;

  const MonthlyMagazineCard({super.key, required this.magazine});

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
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  magazine.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        "${_getMonthName(magazine.month)} ${magazine.year}",
                        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.brandPurple, size: 26),
            tooltip: 'View Magazine',
            onPressed: () {
              if (magazine.pdfUrl.trim().isNotEmpty) {
                Get.to(
                  () => PdfViewerScreen(
                    pdfUrl: magazine.pdfUrl,
                    title: magazine.title,
                  ),
                );
              }
            },
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
