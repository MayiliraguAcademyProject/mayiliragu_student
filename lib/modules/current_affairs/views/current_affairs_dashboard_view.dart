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

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0.5,
        title: Text(
          'Current Affairs Hub',
          style: AppTextStyles.heading.copyWith(fontSize: 20, color: colorScheme.onSurface),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_outline, color: colorScheme.onSurface),
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
                  Text(
                    "Daily Updates",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Obx(() => Text(
                    "${controller.articlesList.length} articles",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 12),

              // Articles Feed
              _buildArticlesFeed(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(CurrentAffairsController controller) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
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
            decoration: InputDecoration(
              hintText: "Search articles, subjects, keywords...",
              hintStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
              prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: TextStyle(color: colorScheme.onSurface),
          ),
        );
      }
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
          final colorScheme = Theme.of(context).colorScheme;
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
                    color: active ? Colors.white : colorScheme.onSurfaceVariant,
                  ),
                ),
                selected: active,
                selectedColor: AppColors.brandPurple,
                backgroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: active ? AppColors.brandPurple : colorScheme.outline),
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

  Widget _buildArticlesFeed(BuildContext context, CurrentAffairsController controller) {
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
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.newspaper_outlined, size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                "No articles match your criteria.",
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Saved Articles",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
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
                          Icon(Icons.bookmark_outline, size: 40, color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text("No saved articles yet.", style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
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
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          art.category,
                          style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
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
