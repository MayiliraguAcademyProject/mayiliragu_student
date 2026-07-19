import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/test_solutions_controller.dart';
import '../../../core/utils/toast_helper.dart';
import '../models/question_model.dart';
import 'widgets/question_layouts.dart';


class TestSolutionsView extends GetView<TestSolutionsController> {
  const TestSolutionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3CC9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.testTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.filter_list, color: Colors.white),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0F3CC9)));
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchAttemptDetails(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3CC9)),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (controller.questions.isEmpty) {
          return const Center(child: Text('No questions found in this test.'));
        }

        return Column(
          children: [
            // Sub-Header: Filter Chips
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip(context, 'all', 'All (${controller.totalCount})'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'correct', 'Correct (${controller.correctCount})'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'wrong', 'Wrong (${controller.wrongCount})'),
                ],
              ),
            ),

            // Questions List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                itemCount: controller.filteredQuestions.length,
                itemBuilder: (context, index) {
                  final q = controller.filteredQuestions[index];
                  return _buildQuestionCard(context, q, index + 1);
                },
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildFilterChip(BuildContext context, String filterKey, String label) {
    return Obx(() {
      final bool isActive = controller.activeFilter.value == filterKey;
      final colorScheme = Theme.of(context).colorScheme;

      Color chipBg = colorScheme.surface;
      Color chipBorder = colorScheme.outline;
      Color textColor = colorScheme.onSurface;
      Widget? leadingIcon;

      if (isActive) {
        if (filterKey == 'correct') {
          chipBg = const Color(0xFFD1FAE5);
          chipBorder = const Color(0xFF10B981);
          textColor = const Color(0xFF065F46);
          leadingIcon = const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981));
        } else if (filterKey == 'wrong') {
          chipBg = const Color(0xFFEF4444);
          chipBorder = const Color(0xFFEF4444);
          textColor = Colors.white;
          leadingIcon = const Icon(Icons.cancel, size: 14, color: Colors.white);
        } else {
          // 'all'
          chipBg = const Color(0xFFECEEF5);
          chipBorder = const Color(0xFF0F3CC9);
          textColor = const Color(0xFF0F3CC9);
        }
      }

      return GestureDetector(
        onTap: () => controller.setFilter(filterKey),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: chipBg,
            border: Border.all(color: chipBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                leadingIcon,
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuestionCard(BuildContext context, Map<String, dynamic> q, int displayIndex) {
    final String qId = q['id']?.toString() ?? '';
    final ua = q['user_answer'];
    final bool isCorrect = ua != null && ua['is_correct'] == true;
    final bool isSkipped = ua == null;

    Color leftBarColor = const Color(0xFF9CA3AF); // Skipped: grey
    String statusText = 'SKIPPED';
    Color badgeBg = const Color(0xFFF3F4F6);
    Color badgeText = const Color(0xFF4B5563);
    IconData badgeIcon = Icons.info_outline;

    if (!isSkipped) {
      if (isCorrect) {
        leftBarColor = const Color(0xFF10B981); // Green
        statusText = 'CORRECT';
        badgeBg = const Color(0xFFD1FAE5);
        badgeText = const Color(0xFF065F46);
        badgeIcon = Icons.check_circle;
      } else {
        leftBarColor = const Color(0xFFEF4444); // Red
        statusText = 'INCORRECT';
        badgeBg = const Color(0xFFFEE2E2);
        badgeText = const Color(0xFF991B1B);
        badgeIcon = Icons.cancel;
      }
    }

    final String subjectId = q['subject_id'] ?? 'General Studies';
    final String subjectLabel = subjectId.replaceAll('sub_', '').toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: leftBarColor, width: 5),
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
          // Card Header: Subject & Status badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subjectLabel,
                      style: const TextStyle(
                        color: Color(0xFF0F3CC9),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, color: badgeText, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: badgeText,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Question Title
                Text(
                  'Question $displayIndex',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 12),

                // Map JSON map to QuestionModel for format-aware layout rendering
                () {
                  final questionModel = QuestionModel.fromJson(q);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Shared Context Passage or Caselet (RC / DI)
                      if (questionModel.sharedContextEn != null && questionModel.sharedContextEn!.isNotEmpty)
                        SharedContextBlock(question: questionModel),

                      // 2. Data Interpretation Structured Table
                      if (questionModel.tableData != null && questionModel.tableData!.isNotEmpty)
                        DiTableWidget(rows: questionModel.tableData!),

                      // 3. Question / Dataset Images Row
                      if (questionModel.images != null && questionModel.images!.isNotEmpty)
                        QuestionImagesRow(images: questionModel.images!),

                      if (questionModel.images != null && questionModel.images!.isNotEmpty)
                        const SizedBox(height: 12),

                      // 4. Question Text or Assertion-Reason Statements
                      if (questionModel.format == QuestionFormat.assertionReason)
                        AssertionReasonCard(question: questionModel)
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (questionModel.questionTextEn.isNotEmpty)
                              Text(
                                questionModel.questionTextEn,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  height: 1.4,
                                ),
                              ),
                            if (questionModel.questionTextEn.isNotEmpty &&
                                questionModel.questionTextTa != null &&
                                questionModel.questionTextTa!.isNotEmpty)
                              const SizedBox(height: 4),
                            if (questionModel.questionTextTa != null &&
                                questionModel.questionTextTa!.isNotEmpty)
                              Text(
                                questionModel.questionTextTa!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                          ],
                        ),
                    ],
                  );
                }(),
                const SizedBox(height: 12),

                // Options list or Fill-in-blank block
                if (q['type'] == 'fill_in_blank')
                  _buildFillInBlankBlock(context, q, ua)
                else
                  _buildOptionsBlock(q, ua),

                const SizedBox(height: 12),

                // Collapsible Explanation & Bookmarks Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      final bool isExpanded = controller.expandedExplanations[qId] ?? false;
                      final inactiveColor = Theme.of(context).colorScheme.onSurfaceVariant;
                      return TextButton.icon(
                        onPressed: () => controller.toggleExplanation(qId),
                        icon: Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: inactiveColor,
                          size: 18,
                        ),
                        label: Text(
                          isExpanded ? 'HIDE EXPLANATION' : 'VIEW EXPLANATION',
                          style: TextStyle(
                            color: inactiveColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }),
                    Obx(() {
                      final bool isSaved = controller.bookmarkedQuestions.contains(qId);
                      return GestureDetector(
                        onTap: () => controller.toggleBookmark(qId),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          Obx(() {
            final bool isExpanded = controller.expandedExplanations[qId] ?? false;
            if (!isExpanded) return const SizedBox.shrink();

            final explanationEn = q['explanation_en']?.toString();
            final explanationTa = q['explanation_ta']?.toString();

            if (explanationEn == null && explanationTa == null) {
              return const SizedBox.shrink();
            }

            final colorScheme = Theme.of(context).colorScheme;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: colorScheme.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'EXPLANATION / விளக்கம்',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (explanationEn != null) ...[
                    Text(
                      explanationEn,
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface, height: 1.4),
                    ),
                  ],
                  if (explanationEn != null && explanationTa != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Divider(color: colorScheme.outline, thickness: 0.5),
                    ),
                  if (explanationTa != null) ...[
                    Text(
                      explanationTa,
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface, height: 1.4),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionsBlock(Map<String, dynamic> q, dynamic ua) {
    var options = q['options'] as List?;
    if (options == null || options.isEmpty) {
      if (q['type'] == 'true_false') {
        options = [
          {'id': 'true', 'text': 'True'},
          {'id': 'false', 'text': 'False'}
        ];
      } else {
        options = [];
      }
    }

    final List<dynamic> selectedIds = ua != null ? (ua['selected_ids'] ?? []) : [];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final opt = options![index];
        final optId = opt['id']?.toString() ?? '';
        final optText = opt['text_en']?.toString() ?? opt['text_ta']?.toString() ?? opt['text']?.toString() ?? '';
        final optTextEn = opt['text_en']?.toString() ?? '';
        final optTextTa = opt['text_ta']?.toString() ?? '';

        // Check correct option
        bool isOptionCorrect = false;
        if (q['type'] == 'single_choice') {
          isOptionCorrect = q['correct_option_id'] == optId;
        } else if (q['type'] == 'multi_choice') {
          isOptionCorrect = (q['correct_option_ids'] as List?)?.contains(optId) ?? false;
        } else if (q['type'] == 'true_false') {
          isOptionCorrect = optText.toLowerCase() == q['correct_answer']?.toString().toLowerCase();
        }

        // Check if selected
        bool isOptionSelected = false;
        if (q['type'] == 'true_false') {
          final bool? userBool = ua?['boolean_answer'];
          if (userBool != null) {
            isOptionSelected = (userBool && optText.toLowerCase() == 'true') ||
                               (!userBool && optText.toLowerCase() == 'false');
          }
        } else {
          isOptionSelected = selectedIds.contains(optId);
        }

        final colorScheme = Theme.of(context).colorScheme;
        Color tileBg = colorScheme.surface;
        Color tileBorder = colorScheme.outline;
        Color textColor = colorScheme.onSurface;
        Widget? trailingWidget;

        if (isOptionCorrect) {
          tileBg = const Color(0xFFE8F8F0);
          tileBorder = const Color(0xFF10B981);
          textColor = const Color(0xFF065F46);
          trailingWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'CORRECT ANSWER',
                style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 6),
              Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
            ],
          );
        } else if (isOptionSelected) {
          tileBg = const Color(0xFFFEE2E2);
          tileBorder = const Color(0xFFEF4444);
          textColor = const Color(0xFF991B1B);
          trailingWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'YOUR ANSWER',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 6),
              Icon(Icons.cancel, color: Color(0xFFEF4444), size: 16),
            ],
          );
        }

        Color circleBg = Theme.of(context).colorScheme.surfaceContainerHighest;
        Color circleText = Theme.of(context).colorScheme.onSurfaceVariant;

        if (isOptionCorrect) {
          circleBg = const Color(0xFF10B981);
          circleText = Colors.white;
        } else if (isOptionSelected) {
          circleBg = const Color(0xFFEF4444);
          circleText = Colors.white;
        }

        final String prefix = String.fromCharCode(65 + index); // A, B, C, D...

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: tileBg,
            border: Border.all(color: tileBorder),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  prefix,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: circleText,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (optTextEn.isNotEmpty)
                      Text(
                        optTextEn,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    if (optTextEn.isNotEmpty && optTextTa.isNotEmpty)
                      const SizedBox(height: 2),
                    if (optTextTa.isNotEmpty)
                      Text(
                        optTextTa,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    if (optTextEn.isEmpty && optTextTa.isEmpty && optText.isNotEmpty)
                      Text(
                        optText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                  ],
                ),
              ),
              trailingWidget ?? const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFillInBlankBlock(BuildContext context, Map<String, dynamic> q, dynamic ua) {
    final List<dynamic>? acceptedList = q['accepted_answers'] as List?;
    final String correctAnswers = acceptedList != null
        ? acceptedList.map((a) => a['value']?.toString() ?? '').join(', ')
        : q['correct_answer']?.toString() ?? '';
    final userAnswer = ua?['text_answer'] ?? '(No answer)';
    final bool isCorrect = ua?['is_correct'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCorrect ? const Color(0xFFE8F8F0) : const Color(0xFFFEE2E2),
            border: Border.all(color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isCorrect ? 'YOUR ANSWER (CORRECT)' : 'YOUR ANSWER (INCORRECT)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                userAnswer,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (!isCorrect) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F0),
              border: Border.all(color: const Color(0xFF10B981)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'CORRECT ANSWER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  correctAnswers,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outline)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Analytics Button
          _buildBottomActionItem(
            context,
            icon: Icons.analytics_outlined,
            label: 'Analytics',
            onTap: () => Get.back(),
          ),

          // Review All Blue Capsule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3CC9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.list_alt, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Review All',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Share Button
          _buildBottomActionItem(
            context,
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {
              AppToast.success(
                'Performance scorecard link copied to clipboard.',
                title: 'Share Results',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
