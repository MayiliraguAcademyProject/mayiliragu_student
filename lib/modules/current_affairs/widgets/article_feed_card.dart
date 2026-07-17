import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/current_affairs_models.dart';

class ArticleFeedCard extends StatelessWidget {
  final CurrentAffair article;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const ArticleFeedCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.category,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandPurple,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: article.isBookmarked ? AppColors.brandPurple : AppColors.textSecondary,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: onBookmarkTap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              article.titleEn,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            if (article.titleTa != null && article.titleTa!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                article.titleTa!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              article.summaryEn,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      "${article.publishedDate.day}/${article.publishedDate.month}/${article.publishedDate.year}",
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (article.quizCount > 0)
                  Row(
                    children: [
                      const Icon(Icons.help_outline, size: 12, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        "${article.quizCount} Quiz MCQs",
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
