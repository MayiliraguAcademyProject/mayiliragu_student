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
  // TAB 1: SUBJECT-WISE PRACTICE
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject selection chips (ExamCategories)
            _buildCategoryChips(controller),

            // Topic drill-down pills
            _buildSubTopicFilterPills(controller),
            const SizedBox(height: 12),

            // Difficulty filter row (All / Easy / Medium / Hard)
            _buildDifficultyFilterRow(controller),
            const SizedBox(height: 16),

            // Subject-Wise test cards list
            _buildSubjectWiseTestsList(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(TestsController controller) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.categories.map((cat) {
              final id = cat.id;
              final name = cat.name;
              return Obx(() {
                final isSelected = controller.selectedCategory.value == id;
                return GestureDetector(
                  onTap: () => controller.selectCategory(id),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0F3CC9) : colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : colorScheme.outline.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check, size: 12, color: Colors.white),
                        ]
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSubTopicFilterPills(TestsController controller) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Obx(() {
          final filters = controller.availableSubFilters;
          if (filters.length <= 1) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  final id = filter['id'] ?? 'all';
                  final name = filter['name'] ?? '';
                  final isSelected = controller.selectedSubFilter.value == id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(
                        name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
          );
        });
      },
    );
  }

  Widget _buildDifficultyFilterRow(TestsController controller) {
    final levels = [
      {'key': 'all', 'label': 'All Levels'},
      {'key': 'EASY', 'label': 'Easy', 'color': const Color(0xFF10B981)},
      {'key': 'MEDIUM', 'label': 'Medium', 'color': const Color(0xFFF59E0B)},
      {'key': 'HARD', 'label': 'Hard', 'color': const Color(0xFFEF4444)},
    ];

    return Obx(() {
      final current = controller.selectedDifficulty.value;
      return Row(
        children: levels.map((lvl) {
          final isSelected = current == lvl['key'];
          final lvlColor = lvl['color'] as Color?;
          return GestureDetector(
            onTap: () => controller.selectDifficulty(lvl['key'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? (lvlColor ?? const Color(0xFF0F3CC9)).withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (lvlColor ?? const Color(0xFF0F3CC9))
                      : Colors.grey.withValues(alpha: 0.25),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                lvl['label'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? (lvlColor ?? const Color(0xFF0F3CC9))
                      : Colors.grey.shade700,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildSubjectWiseTestsList(BuildContext context, TestsController controller) {
    return Obx(() {
      final tests = controller.filteredSubjectWiseTests;
      if (tests.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Icons.quiz_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No quizzes available for this combination yet.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              'Practice Quizzes (${tests.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          ...tests.map((test) => _buildSubjectWiseTestCard(context, controller, test)),
        ],
      );
    });
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
