import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../core/enums/batch_type.dart';
import '../../../core/constants/app_colors.dart';

class BatchPreferenceSection extends StatelessWidget {
  final ProfileController controller;

  const BatchPreferenceSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    final batchOptions = [
      _BatchOption(
        type: BatchType.regular,
        title: 'Regular Batch',
        subtitle: 'Weekday Full-Time (Mon–Sat)',
        description: 'Comprehensive daytime sessions with daily tests, discussions & mentorship.',
        icon: Icons.school_rounded,
        accentColor: AppColors.primary,
      ),
      _BatchOption(
        type: BatchType.weekend,
        title: 'Weekend Batch',
        subtitle: 'Saturday & Sunday Only',
        description: 'Specially designed for working professionals and college students.',
        icon: Icons.weekend_rounded,
        accentColor: Colors.deepPurple,
      ),
      _BatchOption(
        type: BatchType.evening,
        title: 'Evening Batch',
        subtitle: 'Weekday After-Hours Sessions',
        description: 'Convenient post-work schedule covering syllabus with full faculty support.',
        icon: Icons.nights_stay_rounded,
        accentColor: Colors.orange.shade800,
      ),
    ];

    return Obx(() {
      final selected = controller.selectedBatchType.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'SELECT YOUR ATTENDANCE BATCH',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose the schedule that best matches your daily routine. You can consult faculty if you ever need to change your batch.',
            style: TextStyle(
              fontSize: 12,
              color: onSurfaceColor.withAlpha(160),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ...batchOptions.map((option) {
            final isSelected = selected == option.type;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: InkWell(
                onTap: () {
                  controller.selectedBatchType.value = option.type;
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? option.accentColor.withAlpha(20)
                        : onSurfaceColor.withAlpha(10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? option.accentColor
                          : onSurfaceColor.withAlpha(30),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: option.accentColor.withAlpha(30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? option.accentColor
                              : option.accentColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          option.icon,
                          color: isSelected ? Colors.white : option.accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  option.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? option.accentColor
                                        : onSurfaceColor,
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? option.accentColor
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? option.accentColor
                                          : onSurfaceColor.withAlpha(80),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? option.accentColor.withAlpha(220)
                                    : onSurfaceColor.withAlpha(140),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              option.description,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: onSurfaceColor.withAlpha(180),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

class _BatchOption {
  final BatchType type;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;

  const _BatchOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
