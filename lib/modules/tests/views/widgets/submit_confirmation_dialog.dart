import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';

class SubmitConfirmationDialog extends StatelessWidget {
  final int answeredCount;
  final int skippedCount;
  final int flaggedCount;
  final int totalCount;
  final VoidCallback onSubmit;

  const SubmitConfirmationDialog({
    super.key,
    required this.answeredCount,
    required this.skippedCount,
    required this.flaggedCount,
    required this.totalCount,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final hasSkippedOrFlagged = skippedCount > 0 || flaggedCount > 0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      title: Row(
        children: [
          Icon(
            hasSkippedOrFlagged ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
            color: hasSkippedOrFlagged ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
            size: 28,
          ),
          const SizedBox(width: 10),
          const Text(
            'Confirm Submission',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Here is a summary of your test progress. Are you sure you want to submit?',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF10B981),
            label: 'Answered',
            count: answeredCount,
            bgColor: const Color(0xFFECFDF5),
            textColor: const Color(0xFF065F46),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            icon: Icons.error_outline,
            iconColor: const Color(0xFFEF4444),
            label: 'Skipped / Unanswered',
            count: skippedCount,
            bgColor: const Color(0xFFFEF2F2),
            textColor: const Color(0xFF991B1B),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            icon: Icons.bookmark_border,
            iconColor: const Color(0xFFF59E0B),
            label: 'Flagged for Review',
            count: flaggedCount,
            bgColor: const Color(0xFFFFFBEB),
            textColor: const Color(0xFF92400E),
          ),
          if (hasSkippedOrFlagged) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFFB45309), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Warning: You have skipped or flagged questions. You will not be able to change your answers after submitting.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  onSubmit();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSkippedOrFlagged ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required int count,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
