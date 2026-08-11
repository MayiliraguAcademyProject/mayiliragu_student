import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class InfoBox extends StatelessWidget {
  final String title;
  final String content;
  final Color bg;
  final Color border;

  const InfoBox({
    super.key,
    required this.title,
    required this.content,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: border),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 11, height: 1.4, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
