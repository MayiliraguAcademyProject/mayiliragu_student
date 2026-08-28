import 'package:Mayiliragu/modules/tests/models/category_model.dart';
import 'package:Mayiliragu/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/controllers/user_session_controller.dart';
import '../widgets/premium_gate_sheet.dart';
import '../widgets/scheduled_test_sheet.dart';
import '../controllers/tests_controller.dart';
import '../models/test_model.dart';

class TestsView extends GetView<TestsController> {
  const TestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TestsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        title: Obx(() {
          if (controller.searchQuery.value.isNotEmpty) {
            return _buildSearchAppBarTitle(context, controller);
          }
          return Text(
            'Tests & Assessments',
            style: AppTextStyles.heading.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          );
        }),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              if (controller.searchQuery.value.isNotEmpty) {
                controller.updateSearch('');
              } else {
                controller.updateSearch(' ');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Mode Switcher Tabs
          _buildModeTabs(controller),

          // Tab Content
          Expanded(
            child: Obx(() {
              if (controller.activeTestMode.value == TestMode.subjectWise) {
                return _buildSubjectWiseTab(context, controller);
              } else {
                return _buildTestSeriesTab(context, controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAppBarTitle(BuildContext context, TestsController controller) {
    return TextField(
      autofocus: true,
      onChanged: (value) => controller.updateSearch(value),
      decoration: InputDecoration(
        hintText: 'Search tests...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        border: InputBorder.none,
      ),
      style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
    );
  }

  // Top Mode Switcher Tabs: Subject-Wise Practice vs Test Series
  Widget _buildModeTabs(TestsController controller) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildModeTabButton(
                    context,
                    controller,
                    title: 'Subject-Wise Practice',
                    icon: Icons.menu_book_rounded,
                    mode: TestMode.subjectWise,
                  ),
                ),
                Expanded(
                  child: _buildModeTabButton(
                    context,
                    controller,
                    title: 'Test Series',
                    icon: Icons.assignment_rounded,
                    mode: TestMode.testSeries,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeTabButton(
    BuildContext context,
    TestsController controller, {
    required String title,
    required IconData icon,
    required TestMode mode,
  }) {
    return Obx(() {
      final isSelected = controller.activeTestMode.value == mode;
      final colorScheme = Theme.of(context).colorScheme;
      return GestureDetector(
        onTap: () => controller.switchMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF0F3CC9) : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF0F3CC9) : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==========================================
  // TAB 1: SUBJECT-WISE PRACTICE (FOLDER-BASED)
  // ==========================================
  Widget _buildSubjectWiseTab(BuildContext context, TestsController controller) {
    if (controller.isLoadingSubjectWise.value) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0F3CC9)),
      );
    }

    if (controller.errorSubjectWise.value.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.errorSubjectWise.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 12),
              CommonButton(
                text: 'Retry',
                onPressed: () => controller.fetchSubjectWiseTests(),
                backgroundColor: const Color(0xFF0F3CC9),
                foregroundColor: Colors.white,
                borderRadius: 8,
                fullWidth: false,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchSubjectWiseTests(),
      color: const Color(0xFF0F3CC9),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Obx(() {
          final isSearching = controller.searchQuery.value.trim().isNotEmpty;
          final activeFolder = controller.selectedFolderCategory.value;

          // If search is active, show flat matching results across all folders
          if (isSearching) {
            return _buildSearchResultsView(context, controller);
          }

          // If no folder is selected, show the root Subject Folders Grid
          if (activeFolder.isEmpty) {
            return _buildRootFoldersView(context, controller);
          }

          // If a category folder is open, show folder contents (subtopics + tests)
          return _buildInsideFolderView(context, controller, activeFolder);
        }),
      ),
    );
  }

  // --- LEVEL 0: ROOT SUBJECT FOLDERS VIEW ---
  Widget _buildRootFoldersView(BuildContext context, TestsController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    final realCategories = controller.categories.where((c) => c.id != 'all').toList();
    final totalTests = controller.subjectWiseTests.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject Folders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Select a subject folder to practice chapter-wise tests',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3CC9).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$totalTests Total Tests',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F3CC9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (realCategories.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Text(
              'No subject categories configured yet.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: realCategories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cat = realCategories[index];
              final testCount = controller.getCategoryTestCount(cat.id);
              final subjectCount = cat.subjects.length;

              return _buildFolderCard(
                context: context,
                title: cat.name,
                subtitle: subjectCount > 0
                    ? '$subjectCount Subjects • $testCount Tests'
                    : '$testCount Practice Tests Available',
                testCount: testCount,
                iconData: _getCategoryIcon(cat.name),
                gradientColors: _getCategoryGradient(index),
                onTap: () => controller.openCategoryFolder(cat.id),
              );
            },
          ),
      ],
    );
  }

  // --- LEVEL 1: INSIDE A SUBJECT FOLDER ---
  Widget _buildInsideFolderView(
    BuildContext context,
    TestsController controller,
    String categoryId,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentCat = controller.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(id: categoryId, name: 'Subject', description: '', subjects: []),
    );

    final tests = controller.filteredSubjectWiseTests;
    final totalInCat = controller.getCategoryTestCount(categoryId);
    final availableSubFilters = controller.availableSubFilters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation Breadcrumbs Bar
        InkWell(
          onTap: () => controller.navigateFolderBack(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded, size: 18, color: const Color(0xFF0F3CC9)),
                const SizedBox(width: 6),
                Text(
                  'Back to Subjects',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F3CC9),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Active Folder Title Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F3CC9), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F3CC9).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentCat.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalInCat Practice Tests',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Sub-Topic Pills (if multiple topics exist)
        if (availableSubFilters.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableSubFilters.map((f) {
                final id = f['id'] ?? 'all';
                final name = f['name'] ?? '';
                final isSelected = controller.selectedSubFilter.value == id;
                final subCount = id == 'all'
                    ? totalInCat
                    : (controller.getSubjectTestCount(id) > 0
                        ? controller.getSubjectTestCount(id)
                        : controller.getTopicTestCount(id));

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      subCount > 0 ? '$name ($subCount)' : name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0F3CC9),
                    backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF0F3CC9) : colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        controller.selectSubFilter(id);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Tests List
        if (tests.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.quiz_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No quizzes available in this folder yet.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildSubjectWiseTestCard(context, controller, tests[index]);
            },
          ),
      ],
    );
  }

  // --- SEARCH RESULTS VIEW ---
  Widget _buildSearchResultsView(BuildContext context, TestsController controller) {
    final tests = controller.filteredSubjectWiseTests;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results (${tests.length})',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (tests.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Text(
              'No tests matching "${controller.searchQuery.value}"',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildSubjectWiseTestCard(context, controller, tests[index]);
            },
          ),
      ],
    );
  }

  // --- FOLDER CARD COMPONENT ---
  Widget _buildFolderCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required int testCount,
    required IconData iconData,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gradient Folder Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),

            // Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Test Count Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: testCount > 0
                    ? const Color(0xFF0F3CC9).withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                testCount == 1 ? '1 Test' : '$testCount Tests',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: testCount > 0 ? const Color(0xFF0F3CC9) : Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('quant') || lower.contains('math') || lower.contains('arithmetic')) {
      return Icons.calculate_rounded;
    }
    if (lower.contains('reason') || lower.contains('logic') || lower.contains('puzzle')) {
      return Icons.psychology_rounded;
    }
    if (lower.contains('english') || lower.contains('verbal') || lower.contains('grammar')) {
      return Icons.menu_book_rounded;
    }
    if (lower.contains('general') || lower.contains('awareness') || lower.contains('current')) {
      return Icons.public_rounded;
    }
    if (lower.contains('tamil') || lower.contains('language')) {
      return Icons.translate_rounded;
    }
    return Icons.folder_rounded;
  }

  List<Color> _getCategoryGradient(int index) {
    final palettes = [
      [const Color(0xFF0F3CC9), const Color(0xFF3B82F6)], // Blue
      [const Color(0xFF7C3AED), const Color(0xFFA855F7)], // Purple
      [const Color(0xFF059669), const Color(0xFF10B981)], // Emerald
      [const Color(0xFFD97706), const Color(0xFFF59E0B)], // Amber
      [const Color(0xFFDC2626), const Color(0xFFEF4444)], // Red
      [const Color(0xFF0891B2), const Color(0xFF06B6D4)], // Cyan
    ];
    return palettes[index % palettes.length];
  }

  Widget _buildSubjectWiseTestCard(
    BuildContext context,
    TestsController controller,
    TestModel test,
  ) {
    final isUserPremium = Get.isRegistered<UserSessionController>()
        ? Get.find<UserSessionController>().isPremium.value
        : false;
    final isLocked = test.isLocked || (test.isPaid && !isUserPremium);
    final isScheduled = _isScheduled(test);
    final colorScheme = Theme.of(context).colorScheme;

    // Difficulty Level badge
    Color diffBg = const Color(0xFFEBFDF2);
    Color diffColor = const Color(0xFF10B981);
    String diffLabel = (test.difficulty ?? 'EASY').toUpperCase();

    if (diffLabel == 'MEDIUM' || (test.duration > 30 && test.duration <= 60)) {
      diffBg = const Color(0xFFFEF3C7);
      diffColor = const Color(0xFFD97706);
      diffLabel = 'MEDIUM';
    } else if (diffLabel == 'HARD' || test.duration > 60) {
      diffBg = const Color(0xFFFEE2E2);
      diffColor = const Color(0xFFDC2626);
      diffLabel = 'HARD';
    }

    return GestureDetector(
      onTap: () => _handleTestTap(context, controller, test),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isScheduled || isLocked)
              ? colorScheme.surface.withValues(alpha: 0.75)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: diffBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        diffLabel,
                        style: TextStyle(
                          color: diffColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (test.isPaid) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                      '${test.duration} Mins',
                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              test.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),

            if (test.description != null && test.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                test.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Bottom metadata & Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${test.questionCount} Questions',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (test.hasAttempted && test.latestAttempt != null) ...[
                      const Text(' • ', style: TextStyle(color: Colors.grey)),
                      Text(
                        'Score: ${test.latestAttempt!['score'] ?? 0}/${test.totalMarks.toInt()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: (test.latestAttempt!['passed'] ?? false)
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ],
                ),
                CommonButton(
                  text: isScheduled
                      ? 'Opens ${_formatScheduleDate(test.scheduledAt!)}'
                      : (isLocked
                          ? 'Unlock'
                          : (test.hasAttempted ? 'Review' : 'Start Quiz')),
                  onPressed: () => _handleTestTap(context, controller, test),
                  backgroundColor: isScheduled
                      ? const Color(0xFF0D9488)
                      : (isLocked
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF0F3CC9)),
                  foregroundColor: Colors.white,
                  borderRadius: 8,
                  fullWidth: false,
                  suffixIcon: Icon(
                    isScheduled
                        ? Icons.schedule_outlined
                        : (isLocked
                            ? Icons.lock_outline
                            : (test.hasAttempted
                                ? Icons.assessment_outlined
                                : Icons.arrow_forward)),
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: TEST SERIES HUB
  // ==========================================
  Widget _buildTestSeriesTab(BuildContext context, TestsController controller) {
    if (controller.isLoadingTestSeries.value) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0F3CC9)),
      );
    }

    if (controller.errorTestSeries.value.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.errorTestSeries.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 12),
              CommonButton(
                text: 'Retry',
                onPressed: () => controller.fetchTestSeriesTests(),
                backgroundColor: const Color(0xFF0F3CC9),
                foregroundColor: Colors.white,
                borderRadius: 8,
                fullWidth: false,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchTestSeriesTests(),
      color: const Color(0xFF0F3CC9),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner description
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF581C87), Color(0xFF7E22CE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E22CE).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Full-Length Mock Test Series',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Simulate full exam conditions with multi-section timers & national rankings.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tests List
            Obx(() {
              final testSeries = controller.filteredTestSeriesTests;
              if (testSeries.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'Full Mock Tests Coming Soon',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'New comprehensive test series are being curated.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Mock Series (${testSeries.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...testSeries.map((test) => _buildTestSeriesCard(context, controller, test)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSeriesCard(
    BuildContext context,
    TestsController controller,
    TestModel test,
  ) {
    final isUserPremium = Get.isRegistered<UserSessionController>()
        ? Get.find<UserSessionController>().isPremium.value
        : false;
    final isLocked = test.isLocked || (test.isPaid && !isUserPremium);
    final isScheduled = _isScheduled(test);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _handleTestTap(context, controller, test),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: (isScheduled || isLocked)
              ? colorScheme.surface.withValues(alpha: 0.75)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'FULL MOCK EXAM',
                        style: TextStyle(
                          color: Color(0xFF7E22CE),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (test.isPaid) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time_filled, size: 14, color: Color(0xFF7E22CE)),
                    const SizedBox(width: 4),
                    Text(
                      '${test.duration} Mins Total',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7E22CE),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              test.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),

            if (test.description != null && test.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                test.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            // Section breakdown chips (e.g. Quant · Reasoning · English)
            if (test.sectionNames.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: test.sectionNames.map((name) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // Bottom stats & action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${test.sectionsCount > 0 ? '${test.sectionsCount} Sections • ' : ''}${test.questionCount} Qs (${test.totalMarks.toInt()} Marks)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (test.hasAttempted && test.latestAttempt != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: (test.latestAttempt!['passed'] ?? false)
                                  ? const Color(0xFFEBFDF2)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (test.latestAttempt!['passed'] ?? false) ? 'PASSED' : 'FAILED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: (test.latestAttempt!['passed'] ?? false)
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Score: ${test.latestAttempt!['score'] ?? 0}/${test.totalMarks.toInt()}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                CommonButton(
                  text: isScheduled
                      ? 'Opens ${_formatScheduleDate(test.scheduledAt!)}'
                      : (isLocked
                          ? 'Unlock'
                          : (test.hasAttempted ? 'Results' : 'Start Exam')),
                  onPressed: () => _handleTestTap(context, controller, test),
                  backgroundColor: isScheduled
                      ? const Color(0xFF0D9488)
                      : (isLocked
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF7E22CE)),
                  foregroundColor: Colors.white,
                  borderRadius: 10,
                  fullWidth: false,
                  suffixIcon: Icon(
                    isScheduled
                        ? Icons.schedule_outlined
                        : (isLocked
                            ? Icons.lock_outline
                            : (test.hasAttempted
                                ? Icons.analytics_outlined
                                : Icons.arrow_forward)),
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================
  bool _isScheduled(TestModel test) {
    if (test.scheduledAt == null) return false;
    return test.scheduledAt!.toLocal().isAfter(DateTime.now());
  }

  void _handleTestTap(BuildContext context, TestsController controller, TestModel test) {
    final isUserPremium = Get.isRegistered<UserSessionController>()
        ? Get.find<UserSessionController>().isPremium.value
        : false;
    final isLocked = test.isLocked || (test.isPaid && !isUserPremium);
    final isScheduled = _isScheduled(test);

    if (isScheduled) {
      ScheduledTestSheet.show(context, testTitle: test.title, scheduledAt: test.scheduledAt!);
      return;
    }

    if (isLocked) {
      PremiumGateSheet.show(context);
      return;
    }

    if (test.hasAttempted) {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          final colorScheme = Theme.of(ctx).colorScheme;
          return Container(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + MediaQuery.of(ctx).viewPadding.bottom),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  test.title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have already attempted this assessment. Choose an option:',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (test.isSectioned) {
                        Get.toNamed('/test-sections', arguments: test.id)?.then((_) => controller.refreshActiveMode());
                      } else {
                        Get.toNamed('/test-runner', arguments: test.id)?.then((_) => controller.refreshActiveMode());
                      }
                    },
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                    label: const Text('Retake Test', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F3CC9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      final args = Map<String, dynamic>.from(test.latestAttempt ?? {});
                      args['test_id'] = test.id;
                      args['test_title'] = test.title;
                      Get.toNamed('/test-results', arguments: args);
                    },
                    icon: const Icon(Icons.analytics_outlined, color: Color(0xFF0F3CC9)),
                    label: const Text('View Detailed Analytics', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3CC9))),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      if (test.isSectioned) {
        Get.toNamed('/test-sections', arguments: test.id)?.then((_) => controller.refreshActiveMode());
      } else {
        Get.toNamed('/test-runner', arguments: test.id)?.then((_) => controller.refreshActiveMode());
      }
    }
  }

  String _formatScheduleDate(DateTime dt) {
    final local = dt.toLocal();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[local.month - 1]} ${local.day}';
  }
}
