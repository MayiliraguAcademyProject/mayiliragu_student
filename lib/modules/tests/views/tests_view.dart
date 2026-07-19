import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/tests_controller.dart';
import '../models/test_model.dart';

class TestsView extends GetView<TestsController> {
  const TestsView({super.key});

  @override
  Widget build(BuildContext context) {
    // If the controller isn't initialized yet, get it
    final controller = Get.find<TestsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        title: Obx(() {
          if (controller.searchQuery.value.isNotEmpty || controller.searchQuery.value != '') {
            return _buildSearchAppBarTitle(context, controller);
          }
          return Text(
            'Practice Tests',
            style: AppTextStyles.heading.copyWith(fontSize: 22, color: Theme.of(context).colorScheme.onSurface),
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
                controller.updateSearch(' '); // triggers search input
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              // Filters dialog can be implemented here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Topic Wise / Subject Wise)
          _buildFilterTabs(controller),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.brandPurple),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => controller.fetchTests(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchTests(),
                color: AppColors.brandPurple,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Chips
                      _buildCategoryChips(controller),
                      const SizedBox(height: 20),

                      // Featured Card
                      _buildFeaturedCard(controller),
                      const SizedBox(height: 24),

                      // Tests List
                      _buildTestsList(controller),
                    ],
                  ),
                ),
              );
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
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        border: InputBorder.none,
      ),
      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _buildFilterTabs(TestsController controller) {
    return Builder(
      builder: (context) {
        return Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    context,
                    controller,
                    title: 'Topic Wise',
                    tab: FilterTab.topicWise,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    context,
                    controller,
                    title: 'Subject Wise',
                    tab: FilterTab.subjectWise,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildTabButton(BuildContext context, TestsController controller, {required String title, required FilterTab tab}) {
    return Obx(() {
      final isSelected = controller.activeTab.value == tab;
      final colorScheme = Theme.of(context).colorScheme;
      return GestureDetector(
        onTap: () => controller.switchTab(tab),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.brandPurple : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    });
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
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0F3CC9) : colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check, size: 14, color: Colors.white),
                        ]
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          ),
        );
      }
    );
  }

  Widget _buildFeaturedCard(TestsController controller) {
    if (controller.testsList.isEmpty) return const SizedBox.shrink();

    // Select the first available test as the featured one
    final featuredTest = controller.testsList.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3CC9), Color(0xFF1E60FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F3CC9),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'FEATURED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            featuredTest.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (featuredTest.description != null && featuredTest.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              featuredTest.description!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '${featuredTest.questionCount} Questions • ${featuredTest.duration} Min • ${featuredTest.totalMarks.toInt()} Marks',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_outline, color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${featuredTest.attemptsCount} attempts',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (featuredTest.hasAttempted) {
                    final args = Map<String, dynamic>.from(featuredTest.latestAttempt ?? {});
                    args['test_id'] = featuredTest.id;
                    args['test_title'] = featuredTest.title;
                    Get.toNamed('/test-results', arguments: args);
                  } else {
                    if (featuredTest.isSectioned) {
                      Get.toNamed(
                        '/test-sections',
                        arguments: featuredTest.id,
                      )?.then((_) => controller.fetchTests());
                    } else {
                      Get.toNamed(
                        '/test-runner',
                        arguments: featuredTest.id,
                      )?.then((_) => controller.fetchTests());
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F3CC9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Row(
                  children: [
                    Text(
                      featuredTest.hasAttempted ? 'Results' : 'Start Test',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      featuredTest.hasAttempted ? Icons.assessment_outlined : Icons.arrow_forward,
                      size: 14,
                      color: const Color(0xFF0F3CC9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestsList(TestsController controller) {
    if (controller.testsList.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          'No tests available in this category.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    if (controller.activeTab.value == FilterTab.subjectWise) {
      return _buildSubjectWiseList(controller);
    } else {
      return _buildTopicWiseList(controller);
    }
  }

  Widget _buildSubjectWiseList(TestsController controller) {
    final groups = controller.subjectWiseTests;
    if (groups.isEmpty) {
      return const Center(child: Text('No matching tests found.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.keys.length,
      itemBuilder: (context, index) {
        final subjectName = groups.keys.elementAt(index);
        final tests = groups[subjectName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                subjectName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ...tests.map((test) => _buildTestCard(context, test)),
          ],
        );
      },
    );
  }

  Widget _buildTopicWiseList(TestsController controller) {
    final groups = controller.topicWiseTests;
    if (groups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'No topic-wise tests found in this category.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.keys.length,
      itemBuilder: (context, index) {
        final subjectName = groups.keys.elementAt(index);
        final topics = groups[subjectName]!;
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                subjectName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              leading: const Icon(Icons.folder_open, color: AppColors.brandPurple),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: topics.keys.map((topicName) {
                final tests = topics[topicName]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.label_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            topicName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...tests.map((test) => _buildTestCard(context, test)),
                    const Divider(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestCard(BuildContext context, TestModel test) {
    // Generate difficulty colors
    Color diffBgColor = const Color(0xFFEBFDF2);
    Color diffTextColor = const Color(0xFF10B981);
    String difficultyText = 'EASY';

    // Simulate difficulty based on title/duration for realistic tags
    if (test.duration > 40 && test.duration <= 75) {
      diffBgColor = const Color(0xFFFFF3EC);
      diffTextColor = const Color(0xFFF97316);
      difficultyText = 'MEDIUM';
    } else if (test.duration > 75) {
      diffBgColor = const Color(0xFFFDF2F2);
      diffTextColor = const Color(0xFFEF4444);
      difficultyText = 'HARD';
    }

    final isProgressTest = test.title.toLowerCase().contains('history'); // Simulate progress for demo
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        test.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Bookmark action
                      },
                      child: const Icon(Icons.bookmark_border, color: Color(0xFFD1D5DB), size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: diffBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        difficultyText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: diffTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (test.subjectId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          controller.subjectNames[test.subjectId] ?? test.subjectId ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isProgressTest) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Progress',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        '67%',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.67,
                      minHeight: 6,
                      backgroundColor: Color(0xFFECEEF5),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${test.questionCount} Q • ${test.duration} Min',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        if (test.hasAttempted) {
                          final args = Map<String, dynamic>.from(test.latestAttempt ?? {});
                          args['test_id'] = test.id;
                          args['test_title'] = test.title;
                          Get.toNamed('/test-results', arguments: args);
                        } else {
                          if (test.isSectioned) {
                            Get.toNamed(
                              '/test-sections',
                              arguments: test.id,
                            )?.then((_) => controller.fetchTests());
                          } else {
                            Get.toNamed(
                              '/test-runner',
                              arguments: test.id,
                            )?.then((_) => controller.fetchTests());
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: test.hasAttempted
                            ? const Color(0xFF065F46)
                            : (isProgressTest ? Colors.white : const Color(0xFF0F3CC9)),
                        backgroundColor: test.hasAttempted
                            ? const Color(0xFFD1FAE5)
                            : (isProgressTest ? const Color(0xFFF97316) : Colors.transparent),
                        side: (isProgressTest || test.hasAttempted)
                            ? BorderSide.none
                            : const BorderSide(color: Color(0xFF0F3CC9), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                      child: Text(
                        test.hasAttempted
                            ? 'Results'
                            : (isProgressTest ? 'Resume' : 'Start'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
