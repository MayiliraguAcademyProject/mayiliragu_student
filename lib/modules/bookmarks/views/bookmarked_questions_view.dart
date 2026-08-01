import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bookmarked_questions_controller.dart';
import '../../tests/models/question_model.dart';
import '../../tests/views/widgets/question_layouts.dart';
import 'package:Mayiliragu/shared/widgets/custom_network_image.dart';

class BookmarkedQuestionsView extends GetView<BookmarkedQuestionsController> {
  const BookmarkedQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3CC9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Bookmarked Questions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0F3CC9)));
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchBookmarkedQuestions(),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3CC9)),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.questions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bookmark_border_outlined,
                    size: 64,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Bookmarks Yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Questions you bookmark during test reviews will appear here.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Page indicators / Header status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reviewing Saved Questions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${controller.currentPage.value + 1} of ${controller.questions.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            
            // Swipeable PageView
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.questions.length,
                onPageChanged: (index) {
                  controller.currentPage.value = index;
                },
                itemBuilder: (context, index) {
                  final q = controller.questions[index];
                  return _buildQuestionPage(context, q, index + 1);
                },
              ),
            ),
            
            // Bottom navigation buttons
            _buildBottomNav(context),
          ],
        );
      }),
    );
  }

  Widget _buildQuestionPage(BuildContext context, QuestionModel q, int displayIndex) {
    final colorScheme = Theme.of(context).colorScheme;
    final String qId = q.id;
    final String difficulty = q.difficulty.toUpperCase();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card (Difficulty & Bookmark remove icon)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          color: _getDifficultyColor(difficulty),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_remove, color: Colors.red),
                  onPressed: () => controller.toggleBookmark(qId),
                  tooltip: 'Remove Bookmark',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Question layouts: shared context passage / tables / images / assertion-reason
          if ((q.sharedContextEn != null && q.sharedContextEn!.isNotEmpty) ||
              (q.sharedContextTa != null && q.sharedContextTa!.isNotEmpty))
            SharedContextBlock(question: q),
          if (q.tableData != null && q.tableData!.isNotEmpty)
            DiTableWidget(rows: q.tableData!),
          if (q.images != null && q.images!.isNotEmpty)
            QuestionImagesRow(images: q.images!),
          if (q.images != null && q.images!.isNotEmpty)
            const SizedBox(height: 12),

          if (q.format == QuestionFormat.assertionReason)
            AssertionReasonCard(question: q)
          else ...[
            if (q.questionTextEn.isNotEmpty)
              Text(
                q.questionTextEn,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            if (q.questionTextEn.isNotEmpty &&
                q.questionTextTa != null &&
                q.questionTextTa!.isNotEmpty)
              const SizedBox(height: 6),
            if (q.questionTextTa != null &&
                q.questionTextTa!.isNotEmpty)
              Text(
                q.questionTextTa!,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
          ],
          
          const SizedBox(height: 20),
          
          // Options List
          if (q.type == QuestionType.fillInBlank)
            _buildFillInBlankBlock(context, q)
          else
            _buildOptionsBlock(context, q),
            
          const SizedBox(height: 24),
          
          // Persistent Explanation Card
          _buildExplanationCard(context, q),
        ],
      ),
    );
  }

  Widget _buildOptionsBlock(BuildContext context, QuestionModel q) {
    List<QuestionOption> options = q.options ?? [];
    if (options.isEmpty) {
      if (q.type == QuestionType.trueFalse) {
        options = [
          QuestionOption(id: 'true', label: 'A', textEn: 'True', textTa: 'மெய்', isCorrect: q.correctAnswer == true),
          QuestionOption(id: 'false', label: 'B', textEn: 'False', textTa: 'பொய்', isCorrect: q.correctAnswer == false),
        ];
      }
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final opt = options[index];
        final optTextEn = opt.textEn;
        final optTextTa = opt.textTa;

        final bool isOptionCorrect = opt.isCorrect;

        final colorScheme = Theme.of(context).colorScheme;
        Color tileBg = colorScheme.surface;
        Color tileBorder = colorScheme.outline;
        Color textColor = colorScheme.onSurface;
        Widget? trailingWidget;

        if (isOptionCorrect) {
          tileBg = const Color(0xFFE8F8F0);
          tileBorder = const Color(0xFF10B981);
          textColor = const Color(0xFF065F46);
          trailingWidget = const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16);
        }

        Color circleBg = colorScheme.surfaceContainerHighest;
        Color circleText = colorScheme.onSurfaceVariant;

        if (isOptionCorrect) {
          circleBg = const Color(0xFF10B981);
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: circleText,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (optTextEn.isNotEmpty)
                      Text(
                        optTextEn,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isOptionCorrect ? FontWeight.bold : FontWeight.normal,
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
                          color: isOptionCorrect ? const Color(0xFF047857) : colorScheme.onSurfaceVariant,
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

  Widget _buildFillInBlankBlock(BuildContext context, QuestionModel q) {
    final acceptedList = q.acceptedAnswers ?? [];
    final answersString = acceptedList.map((a) => a.value).join(', ');

    return Container(
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
          const Text(
            'CORRECT ANSWER(S):',
            style: TextStyle(color: Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            answersString,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(BuildContext context, QuestionModel q) {
    final colorScheme = Theme.of(context).colorScheme;
    final explanationEn = q.explanationEn;
    final explanationTa = q.explanationTa;
    final explanationImageUrl = q.explanationImageUrl;

    final hasExplanationContent = (explanationEn != null && explanationEn.isNotEmpty) ||
        (explanationTa != null && explanationTa.isNotEmpty) ||
        (explanationImageUrl != null && explanationImageUrl.isNotEmpty);

    final correctOpt = q.options?.firstWhereOrNull((o) => o.isCorrect);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.1),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasExplanationContent) ...[
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
            if (explanationEn != null && explanationEn.isNotEmpty) ...[
              Text(
                explanationEn,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface, height: 1.4),
              ),
            ],
            if (explanationEn != null && explanationEn.isNotEmpty && explanationTa != null && explanationTa.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Divider(color: colorScheme.outline, thickness: 0.5),
              ),
            if (explanationTa != null && explanationTa.isNotEmpty) ...[
              Text(
                explanationTa,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface, height: 1.4),
              ),
            ],
            if (explanationImageUrl != null && explanationImageUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomNetworkImage(
                  imageUrl: explanationImageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ],
          if (!hasExplanationContent) ...[
            if (correctOpt != null) ...[
              Text(
                'Correct Answer: Option ${correctOpt.id}${correctOpt.textEn.isNotEmpty ? ' - ${correctOpt.textEn}' : ''}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              'No detailed text explanation attached for this question.',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: controller.currentPage.value > 0 ? () => controller.previousPage() : null,
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0F3CC9),
              disabledBackgroundColor: colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          
          // Next button
          ElevatedButton.icon(
            onPressed: controller.currentPage.value < controller.questions.length - 1 ? () => controller.nextPage() : null,
            icon: const Icon(Icons.arrow_forward_ios, size: 14),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0F3CC9),
              disabledBackgroundColor: colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'EASY':
        return const Color(0xFF10B981);
      case 'HARD':
        return const Color(0xFFEF4444);
      case 'MEDIUM':
      default:
        return const Color(0xFFF59E0B);
    }
  }
}
