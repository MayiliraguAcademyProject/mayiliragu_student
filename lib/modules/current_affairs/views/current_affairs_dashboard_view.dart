import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/current_affairs_controller.dart';
import '../widgets/progress_stats_card.dart';
import '../widgets/shortcut_card.dart';
import '../widgets/article_feed_card.dart';
import 'current_affair_detail_view.dart';
import 'magazines_view.dart';
import 'schemes_view.dart';
import 'dates_view.dart';

class CurrentAffairsDashboardView extends GetView<CurrentAffairsController> {
  const CurrentAffairsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrentAffairsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Current Affairs Hub',
          style: AppTextStyles.heading.copyWith(fontSize: 20, color: AppColors.textPrimary),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: AppColors.textPrimary),
            onPressed: () {
              controller.fetchBookmarks();
              _showBookmarksSheet(context, controller);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchArticles();
          await controller.fetchAnalytics();
        },
        color: AppColors.brandPurple,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              _buildSearchBar(controller),
              const SizedBox(height: 16),

              // Student Progress Stats
              Obx(() {
                if (controller.isAnalyticsLoading.value && controller.articlesReadCount.value == 0) {
                  return const SizedBox.shrink();
                }
                return ProgressStatsCard(
                  articlesRead: controller.articlesReadCount.value,
                  quizzesAttempted: controller.quizzesAttemptedCount.value,
                  accuracy: controller.quizAccuracy.value,
                );
              }),
              const SizedBox(height: 20),

              // Modules Shortcuts
              _buildShortcuts(context),
              const SizedBox(height: 20),

              // Category filters
              _buildCategoryFilters(controller),
              const SizedBox(height: 16),

              // Daily Feed section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daily Updates",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Obx(() => Text(
                    "${controller.articlesList.length} articles",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 12),

              // Articles Feed
              _buildArticlesFeed(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(CurrentAffairsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        onChanged: (val) {
          controller.searchQuery.value = val;
          controller.fetchArticles();
        },
        decoration: const InputDecoration(
          hintText: "Search articles, subjects, keywords...",
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildShortcuts(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ShortcutCard(
            title: "Magazines",
            subtitle: "Monthly compilations",
            icon: Icons.book_outlined,
            color: Colors.deepOrangeAccent,
            onTap: () => Get.to(() => const MagazinesView()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ShortcutCard(
            title: "Gov Schemes",
            subtitle: "Central & State schemes",
            icon: Icons.account_balance_outlined,
            color: Colors.teal,
            onTap: () => Get.to(() => const SchemesView()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ShortcutCard(
            title: "Important Dates",
            subtitle: "Exam calendar dates",
            icon: Icons.event_note_outlined,
            color: Colors.blueAccent,
            onTap: () => Get.to(() => const DatesView()),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(CurrentAffairsController controller) {
    final categories = [
      "All Category",
      "National Affairs",
      "International Relations",
      "Economy & Finance",
      "Science & Technology",
      "Environment & Climate",
      "Sports News",
      "Awards & Honors",
      "Government Schemes",
    ];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final active = (cat == "All Category" && controller.selectedCategory.value.isEmpty) ||
                (controller.selectedCategory.value == cat);
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: active ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                selected: active,
                selectedColor: AppColors.brandPurple,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: active ? AppColors.brandPurple : Colors.grey.shade200),
                onSelected: (selected) {
                  controller.selectedCategory.value = cat == "All Category" ? "" : cat;
                  controller.fetchArticles();
                },
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildArticlesFeed(CurrentAffairsController controller) {
    return Obx(() {
      if (controller.isArticlesLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.brandPurple),
          ),
        );
      }

      if (controller.articlesList.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.newspaper_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                "No articles match your criteria.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.articlesList.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final art = controller.articlesList[index];
          return ArticleFeedCard(
            article: art,
            onTap: () => Get.to(() => CurrentAffairDetailView(articleId: art.id)),
            onBookmarkTap: () => controller.toggleBookmark(art.id),
          );
        },
      );
    });
  }

  void _showBookmarksSheet(BuildContext context, CurrentAffairsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF9FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Saved Articles",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.bookmarksList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_outline, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text("No saved articles yet.", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: controller.bookmarksList.length,
                    itemBuilder: (context, index) {
                      final art = controller.bookmarksList[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.brandPurple.withValues(alpha: 0.08),
                          child: const Icon(Icons.newspaper, color: AppColors.brandPurple, size: 18),
                        ),
                        title: Text(
                          art.titleEn,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          art.category,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 16),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => CurrentAffairDetailView(articleId: art.id));
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
