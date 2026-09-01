import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/test_batch_model.dart';
import '../../../core/utils/toast_helper.dart';
import '../controllers/test_batches_controller.dart';

class TestBatchDetailView extends GetView<TestBatchesController> {
  const TestBatchDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackBatch = Get.arguments as TestBatchModel?;

    return Obx(() {
      final batch = controller.currentBatch.value ?? fallbackBatch;
      final title = batch?.title ?? AppStrings.testBatch;

      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundStartDark
            : AppColors.backgroundStart,
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          backgroundColor: isDark
              ? AppColors.backgroundStartDark
              : AppColors.backgroundStart,
          elevation: 0,
        ),
        body: controller.isDetailLoading.value && batch == null
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : batch == null
            ? const Center(child: Text('Batch information not found'))
            : _buildTabBody(context, batch, isDark),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardBgDark : AppColors.cardBg,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.selectedTabIndex.value,
            onTap: controller.changeTab,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today_rounded),
                label: AppStrings.schedule,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_outlined),
                activeIcon: Icon(Icons.quiz_rounded),
                label: 'Question Papers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined),
                activeIcon: Icon(Icons.description_rounded),
                label: AppStrings.omrSheet,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTabBody(
    BuildContext context,
    TestBatchModel batch,
    bool isDark,
  ) {
    switch (controller.selectedTabIndex.value) {
      case 0:
        return _buildScheduleTab(context, batch, isDark);
      case 1:
        return _buildQuestionPapersTab(context, batch, isDark);
      case 2:
        return _buildOmrTab(context, batch, isDark);
      default:
        return _buildScheduleTab(context, batch, isDark);
    }
  }

  // ================= TAB 0: SCHEDULE TAB ================= //
  Widget _buildScheduleTab(
    BuildContext context,
    TestBatchModel batch,
    bool isDark,
  ) {
    final scheduleUrl = batch.schedulePdfUrl;

    if (scheduleUrl == null || scheduleUrl.trim().isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.fetchBatchDetail(batch.id),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 64,
                      color: isDark
                          ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                          : AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Schedule Uploaded',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The test batch schedule has not been uploaded yet. Pull down to refresh.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchBatchDetail(batch.id),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      batch.targetCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    batch.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (batch.description != null &&
                      batch.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      batch.description!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Schedule PDF Action Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardBgDark : AppColors.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Color(0xFFEA580C),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Batch Schedule PDF',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              batch.schedulePdfName ?? 'Test_Schedule.pdf',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.openPdf(
                            scheduleUrl,
                            title: 'Schedule - ${batch.title}',
                          ),
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: const Text(
                            AppStrings.viewPdf,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB 1: QUESTION PAPERS TAB ================= //
  Widget _buildQuestionPapersTab(
    BuildContext context,
    TestBatchModel batch,
    bool isDark,
  ) {
    final categories = batch.categories;

    return RefreshIndicator(
      onRefresh: () => controller.fetchBatchDetail(batch.id),
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress & Stat Summary Cards
                  _buildBatchSummaryCard(context, batch, isDark),
                  const SizedBox(height: 16),

                  // Filter Chips
                  _buildFilterChips(isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          if (categories.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 64,
                        color: isDark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                            : AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Question Papers Yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Question papers will appear here once scheduled. Pull down to refresh.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            _buildCategoriesListSliver(context, categories, isDark),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // Summary Metrics Card
  Widget _buildBatchSummaryCard(
    BuildContext context,
    TestBatchModel batch,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Test Batch Overview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatTile(
                label: 'Total Tests',
                value: '${controller.totalPapersCount}',
                color: AppColors.primary,
                icon: Icons.assignment_outlined,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatTile(
                label: 'Available',
                value: '${controller.availablePapersCount}',
                color: const Color(0xFF2563EB),
                icon: Icons.lock_open_rounded,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatTile(
                label: 'Upcoming',
                value: '${controller.upcomingPapersCount}',
                color: const Color(0xFFD97706),
                icon: Icons.lock_clock_rounded,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatTile(
                label: 'Completed',
                value: '${controller.completedPapersCount}',
                color: const Color(0xFF059669),
                icon: Icons.check_circle_outline_rounded,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Filter Chips Row
  Widget _buildFilterChips(bool isDark) {
    return Obx(() {
      final currentFilter = controller.selectedPaperFilter.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChipItem(
              label: 'All (${controller.totalPapersCount})',
              isSelected: currentFilter == PaperFilterStatus.all,
              onTap: () => controller.setPaperFilter(PaperFilterStatus.all),
              activeColor: AppColors.primary,
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildFilterChipItem(
              label: 'Available (${controller.availablePapersCount})',
              isSelected: currentFilter == PaperFilterStatus.available,
              onTap: () =>
                  controller.setPaperFilter(PaperFilterStatus.available),
              activeColor: const Color(0xFF2563EB),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildFilterChipItem(
              label: 'Upcoming (${controller.upcomingPapersCount})',
              isSelected: currentFilter == PaperFilterStatus.upcoming,
              onTap: () =>
                  controller.setPaperFilter(PaperFilterStatus.upcoming),
              activeColor: const Color(0xFFD97706),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildFilterChipItem(
              label: 'Completed (${controller.completedPapersCount})',
              isSelected: currentFilter == PaperFilterStatus.completed,
              onTap: () =>
                  controller.setPaperFilter(PaperFilterStatus.completed),
              activeColor: const Color(0xFF059669),
              isDark: isDark,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChipItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? AppColors.cardBgDark : AppColors.cardBg),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  // Categories List Sliver with Filter Application
  Widget _buildCategoriesListSliver(
    BuildContext context,
    List<TestBatchCategoryModel> categories,
    bool isDark,
  ) {
    return Obx(() {
      final currentFilter = controller.selectedPaperFilter.value;

      // Filter categories that contain matching papers
      final filteredCategories = categories
          .map((cat) {
            final filteredPapers = cat.questionPapers.where((paper) {
              switch (currentFilter) {
                case PaperFilterStatus.available:
                  return !paper.isLocked && !paper.hasSubmittedOmr;
                case PaperFilterStatus.upcoming:
                  return paper.isLocked;
                case PaperFilterStatus.completed:
                  return paper.hasSubmittedOmr;
                case PaperFilterStatus.all:
                  return true;
              }
            }).toList();

            return MapEntry(cat, filteredPapers);
          })
          .where((entry) => entry.value.isNotEmpty)
          .toList();

      if (filteredCategories.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.filter_list_off_rounded,
                    size: 48,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No tests match this filter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try selecting a different filter tab.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final entry = filteredCategories[index];
            final category = entry.key;
            final matchingPapers = entry.value;

            return _buildCategoryAccordion(
              context,
              category,
              matchingPapers,
              index,
              isDark,
            );
          }, childCount: filteredCategories.length),
        ),
      );
    });
  }

  Widget _buildCategoryAccordion(
    BuildContext context,
    TestBatchCategoryModel category,
    List<TestBatchPaperModel> papers,
    int index,
    bool isDark,
  ) {
    return Obx(() {
      final isExpanded = controller.expandedCategoryIds.contains(category.id);
      final upcomingCount = category.questionPapers
          .where((p) => p.isLocked)
          .length;
      final availableCount = category.questionPapers
          .where((p) => !p.isLocked && !p.hasSubmittedOmr)
          .length;
      final completedCount = category.questionPapers
          .where((p) => p.hasSubmittedOmr)
          .length;

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBgDark : AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accordion Header
            InkWell(
              onTap: () => controller.toggleCategory(category.id),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (availableCount > 0)
                                _buildMiniBadge(
                                  text: '$availableCount Available',
                                  color: const Color(0xFF2563EB),
                                  isDark: isDark,
                                ),
                              if (upcomingCount > 0)
                                _buildMiniBadge(
                                  text: '$upcomingCount Scheduled',
                                  color: const Color(0xFFD97706),
                                  isDark: isDark,
                                ),
                              if (completedCount > 0)
                                _buildMiniBadge(
                                  text: '$completedCount Done',
                                  color: const Color(0xFF059669),
                                  isDark: isDark,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Content
            if (isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Syllabus Section
                    if (category.syllabus != null &&
                        category.syllabus!.trim().isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.backgroundStartDark.withValues(
                                  alpha: 0.6,
                                )
                              : AppColors.backgroundStart,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.accent
                                      : const Color(0xFFEA580C),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Syllabus Covered',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.accent
                                        : const Color(0xFFEA580C),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.syllabus!,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Papers List inside Category
                    ...papers.map(
                      (paper) =>
                          _buildQuestionPaperItem(context, paper, isDark),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildMiniBadge({
    required String text,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  bool _isAnswerKeyPaper(TestBatchPaperModel paper) {
    final combined = '${paper.title} ${paper.fileName}'.toLowerCase();
    return combined.contains('answer key') ||
        combined.contains('answer_key') ||
        combined.contains('answer-key') ||
        combined.contains('ans key') ||
        combined.contains('ans_key') ||
        combined.contains('ans-key') ||
        combined.contains('key.pdf') ||
        combined.contains(' key') ||
        combined.contains('விடை');
  }

  // ================= QUESTION PAPER ITEM BUILDER ================= //
  Widget _buildQuestionPaperItem(
    BuildContext context,
    TestBatchPaperModel paper,
    bool isDark,
  ) {
    final isKey = _isAnswerKeyPaper(paper);

    // Completely hide answer keys until unlocked after OMR submission
    if (isKey && paper.isLocked) {
      return const SizedBox.shrink();
    }

    if (paper.isLocked) {
      return _buildLockedPaperCard(context, paper, isDark);
    } else if (isKey) {
      return _buildAvailableAnswerKeyCard(context, paper, isDark);
    } else if (paper.hasSubmittedOmr) {
      return _buildCompletedPaperCard(context, paper, isDark);
    } else {
      return _buildAvailablePaperCard(context, paper, isDark);
    }
  }

  // 1. UPCOMING / LOCKED CARD
  Widget _buildLockedPaperCard(
    BuildContext context,
    TestBatchPaperModel paper,
    bool isDark, {
    bool isAnswerKey = false,
  }) {
    final formattedUnlock = _formatScheduledDateTime(paper.unlocksAt);
    final relativeUnlock = _formatRelativeTime(paper.unlocksAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2E2415).withValues(alpha: 0.4)
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFFD97706).withValues(alpha: 0.3)
              : const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isAnswerKey
                      ? Icons.key_off_rounded
                      : Icons.lock_clock_rounded,
                  size: 20,
                  color: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD97706,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAnswerKey
                                ? 'ANSWER KEY (LOCKED)'
                                : 'UPCOMING TEST',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                        if (relativeUnlock.isNotEmpty &&
                            paper.unlocksAt != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '($relativeUnlock)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      paper.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paper.fileName,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isAnswerKey
                      ? Icons.lock_outline_rounded
                      : Icons.event_available_rounded,
                  size: 14,
                  color: const Color(0xFFD97706),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAnswerKey
                        ? (paper.unlocksAt != null &&
                                  paper.unlocksAt!.isAfter(DateTime.now())
                              ? 'Unlocks with schedule: $formattedUnlock'
                              : 'Submit OMR for Question Paper to unlock Answer Key')
                        : 'Scheduled for: $formattedUnlock',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1.5 AVAILABLE ANSWER KEY CARD
  Widget _buildAvailableAnswerKeyCard(
    BuildContext context,
    TestBatchPaperModel paper,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.2)
            : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF059669).withValues(alpha: 0.3)
              : const Color(0xFFA7F3D0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.vpn_key_rounded,
                  size: 20,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ANSWER KEY (UNLOCKED)',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      paper.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            paper.fileName,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (paper.fileSize != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• ${_formatFileSize(paper.fileSize!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              if (paper.fileUrl != null && paper.fileUrl!.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () =>
                      controller.openPdf(paper.fileUrl, title: paper.title),
                  icon: const Icon(Icons.vpn_key_rounded, size: 14),
                  label: const Text(
                    'View Answer Key',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. AVAILABLE / UNLOCKED CARD
  Widget _buildAvailablePaperCard(
    BuildContext context,
    TestBatchPaperModel paper,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundStartDark.withValues(alpha: 0.6)
            : AppColors.backgroundStart,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'AVAILABLE NOW',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      paper.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            paper.fileName,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (paper.fileSize != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• ${_formatFileSize(paper.fileSize!)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (paper.fileUrl != null && paper.fileUrl!.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () =>
                      controller.openPdf(paper.fileUrl, title: paper.title),
                  icon: const Icon(Icons.visibility_outlined, size: 14),
                  label: const Text(
                    'View Question Paper',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: controller.isSubmittingOmr.value
                    ? null
                    : () => controller.submitOmr(paper.id),
                icon: const Icon(Icons.upload_file_rounded, size: 14),
                label: const Text(
                  'Submit OMR',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. COMPLETED / OMR SUBMITTED CARD
  Widget _buildCompletedPaperCard(
    BuildContext context,
    TestBatchPaperModel paper,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.25)
            : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF059669).withValues(alpha: 0.3)
              : const Color(0xFFA7F3D0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF059669,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'COMPLETED',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Score Chip
                        InkWell(
                          onTap: () => _showMarksDialog(context, paper, isDark),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.edit_note_rounded,
                                  size: 12,
                                  color: Color(0xFF2563EB),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  paper.totalMarks != null
                                      ? '${paper.totalMarks} Marks'
                                      : 'Enter Marks',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      paper.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      paper.fileName,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Action Buttons: Question Paper, Submitted OMR, Answer Key
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (paper.fileUrl != null && paper.fileUrl!.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () =>
                      controller.openPdf(paper.fileUrl, title: paper.title),
                  icon: const Icon(Icons.visibility_outlined, size: 13),
                  label: const Text(
                    'Question Paper',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

              if (paper.omrFileUrl != null && paper.omrFileUrl!.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => controller.openPdf(
                    paper.omrFileUrl,
                    title: 'My OMR - ${paper.title}',
                  ),
                  icon: const Icon(Icons.description_outlined, size: 13),
                  label: const Text(
                    'My OMR Sheet',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF059669),
                    side: const BorderSide(color: Color(0xFF059669)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

              if (paper.answerKeyAvailable)
                ElevatedButton.icon(
                  onPressed: () => controller.viewAnswerKey(
                    paper.id,
                    title: 'Answer Key - ${paper.title}',
                  ),
                  icon: const Icon(Icons.vpn_key_rounded, size: 13),
                  label: const Text(
                    'Answer Key',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMarksDialog(
    BuildContext context,
    TestBatchPaperModel paper,
    bool isDark,
  ) {
    final textController = TextEditingController(
      text: paper.totalMarks != null ? paper.totalMarks.toString() : '',
    );

    Get.dialog(
      Dialog(
        backgroundColor: isDark ? AppColors.cardBgDark : AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.score_outlined,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Enter Marks Obtained',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                paper.title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Total Marks (e.g. 150)',
                  hintText: 'Enter your score',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final val = int.tryParse(textController.text.trim());
                      if (val == null) {
                        AppToast.error('Please enter a valid numeric mark');
                        return;
                      }
                      Get.back();
                      controller.updateMarks(paper.id, val);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Marks'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TAB 2: OMR SHEET TAB ================= //
  Widget _buildOmrTab(BuildContext context, TestBatchModel batch, bool isDark) {
    final omrUrl = batch.omrPdfUrl;

    if (omrUrl == null || omrUrl.trim().isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.fetchBatchDetail(batch.id),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: isDark
                          ? AppColors.textSecondaryDark.withValues(alpha: 0.5)
                          : AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sample OMR Not Uploaded',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The official sample OMR practice sheet will be uploaded here soon. Pull down to refresh.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchBatchDetail(batch.id),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // OMR Banner Container
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'OFFICIAL OMR SHEET',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Practice Answer Sheet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    batch.omrPdfName ?? 'Sample_OMR_Sheet.pdf',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.openPdf(
                            omrUrl,
                            title: 'OMR Sheet - ${batch.title}',
                          ),
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text(
                            AppStrings.downloadPdf,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4F46E5),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Practice Guidelines Box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardBgDark : AppColors.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tips_and_updates_outlined,
                        size: 18,
                        color: Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OMR Shading Tips',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '• Print this official OMR sheet on standard A4 paper for mock test sessions.\n'
                    '• Use a Black or Blue Ballpoint pen only to shade your responses.\n'
                    '• Completely darken the corresponding bubble without spilling outside or leaving faint marks.\n'
                    '• Time yourself according to the real TNPSC exam duration to build speed and accuracy.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS: DATE & SIZE FORMATTING ================= //
  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _formatScheduledDateTime(DateTime? dt) {
    if (dt == null) return 'Scheduled Date';
    final local = dt.toLocal();
    final dayName = _dayNames[(local.weekday - 1).clamp(0, 6)];
    final monthName = _monthNames[(local.month - 1).clamp(0, 11)];
    final day = local.day.toString().padLeft(2, '0');
    final year = local.year;

    final hour24 = local.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';

    return '$dayName, $day $monthName $year • ${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  String _formatRelativeTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = dt.difference(now);

    if (diff.isNegative) return 'Now';

    if (diff.inDays > 0) {
      return 'In ${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'}';
    } else if (diff.inHours > 0) {
      return 'In ${diff.inHours} ${diff.inHours == 1 ? 'hr' : 'hrs'}';
    } else if (diff.inMinutes > 0) {
      return 'In ${diff.inMinutes} mins';
    } else {
      return 'Soon';
    }
  }

  String _formatFileSize(int bytes) {
    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }
}
