import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/current_affairs_controller.dart';
import '../models/current_affairs_models.dart';
import '../widgets/info_box.dart';
import '../widgets/video_banner.dart';
import '../widgets/quiz_question_card.dart';

class CurrentAffairDetailView extends StatefulWidget {
  final String articleId;

  const CurrentAffairDetailView({super.key, required this.articleId});

  @override
  State<CurrentAffairDetailView> createState() => _CurrentAffairDetailViewState();
}

class _CurrentAffairDetailViewState extends State<CurrentAffairDetailView> with SingleTickerProviderStateMixin {
  late TabController _bilingualTabController;
  final Map<String, String> _selectedAnswers = {}; // Map of quizId -> selectedOption
  final Set<String> _submittedQuizzes = {}; // Set of quizIds that have been submitted

  @override
  void initState() {
    super.initState();
    _bilingualTabController = TabController(length: 2, vsync: this);
    _bilingualTabController.addListener(() {
      if (!_bilingualTabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Fetch article details & quizzes
    final controller = Get.find<CurrentAffairsController>();
    controller.fetchArticleDetail(widget.articleId);
    controller.fetchQuizzes(widget.articleId);
  }

  @override
  void dispose() {
    _bilingualTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrentAffairsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Article Explanation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          Obx(() {
            final art = controller.currentArticle.value;
            if (art == null) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(
                art.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: art.isBookmarked ? AppColors.brandPurple : AppColors.textPrimary,
              ),
              onPressed: () => controller.toggleBookmark(art.id),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
        }

        final art = controller.currentArticle.value;
        if (art == null) {
          return const Center(child: Text("Article not found or deleted."));
        }

        final bool hasTamil = art.titleTa != null && art.titleTa!.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Selector Header (if Tamil content exists)
              if (hasTamil) ...[
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _bilingualTabController,
                    labelColor: AppColors.brandPurple,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.brandPurple,
                    labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: "English Description"),
                      Tab(text: "Tamil Description (தமிழ்)"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Main Article Content
              hasTamil
                  ? SizedBox(
                      height: 500,
                      child: TabBarView(
                        controller: _bilingualTabController,
                        children: [
                          _buildEnglishContent(art),
                          _buildTamilContent(art),
                        ],
                      ),
                    )
                  : _buildEnglishContent(art),

              const SizedBox(height: 20),

              // Video Explanation
              if (art.videoUrl != null && art.videoUrl!.isNotEmpty)
                VideoBanner(url: art.videoUrl!),

              const SizedBox(height: 30),

              // Practice Quiz Runner
              _buildPracticeQuizSection(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEnglishContent(CurrentAffair art) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            art.titleEn,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                child: Text(art.category, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Text(
                "${art.publishedDate.day}/${art.publishedDate.month}/${art.publishedDate.year}",
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            art.contentEn,
            style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),

          // Custom boxes using InfoBox widget
          if (art.examImportanceEn != null && art.examImportanceEn!.isNotEmpty)
            InfoBox(title: "Exam Importance & Facts", content: art.examImportanceEn!, bg: Colors.teal.shade50, border: Colors.teal),
          if (art.prelimsNotesEn != null && art.prelimsNotesEn!.isNotEmpty)
            InfoBox(title: "Prelims Highlights", content: art.prelimsNotesEn!, bg: Colors.blue.shade50, border: Colors.blue),
          if (art.mainsNotesEn != null && art.mainsNotesEn!.isNotEmpty)
            InfoBox(title: "Mains Practice Notes", content: art.mainsNotesEn!, bg: Colors.purple.shade50, border: Colors.purple),
        ],
      ),
    );
  }

  Widget _buildTamilContent(CurrentAffair art) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            art.titleTa ?? art.titleEn,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                child: Text(art.category, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            art.contentTa ?? "தமிழ் விளக்கம் இல்லை.",
            style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),

          // Custom boxes using InfoBox widget
          if (art.examImportanceTa != null && art.examImportanceTa!.isNotEmpty)
            InfoBox(title: "தேர்வு முக்கியத்துவம் & உண்மைகள்", content: art.examImportanceTa!, bg: Colors.teal.shade50, border: Colors.teal),
          if (art.prelimsNotesTa != null && art.prelimsNotesTa!.isNotEmpty)
            InfoBox(title: "பிலிம்ஸ் குறிப்புகள்", content: art.prelimsNotesTa!, bg: Colors.blue.shade50, border: Colors.blue),
          if (art.mainsNotesTa != null && art.mainsNotesTa!.isNotEmpty)
            InfoBox(title: "மெயின்ஸ் குறிப்புகள்", content: art.mainsNotesTa!, bg: Colors.purple.shade50, border: Colors.purple),
        ],
      ),
    );
  }

  Widget _buildPracticeQuizSection(CurrentAffairsController controller) {
    return Obx(() {
      if (controller.isQuizLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.quizzesList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Daily MCQ Challenge",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.quizzesList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, idx) {
              final quiz = controller.quizzesList[idx];

              // Load previous attempt if exists
              if (quiz.previousAttempt != null && !_submittedQuizzes.contains(quiz.id)) {
                _selectedAnswers[quiz.id] = quiz.previousAttempt!.selectedAnswer;
                _submittedQuizzes.add(quiz.id);
              }

              final isSubmitted = _submittedQuizzes.contains(quiz.id);
              final String? selected = _selectedAnswers[quiz.id];

              return QuizQuestionCard(
                quiz: quiz,
                index: idx,
                isSubmitted: isSubmitted,
                selectedOption: selected,
                showTamil: _bilingualTabController.index == 1,
                onOptionSelected: (opt) {
                  setState(() {
                    _selectedAnswers[quiz.id] = opt;
                  });
                },
                onSubmit: () {
                  if (selected != null) {
                    setState(() {
                      _submittedQuizzes.add(quiz.id);
                    });
                    controller.submitQuizAnswers([
                      {'quizId': quiz.id, 'selectedAnswer': selected}
                    ]);
                  }
                },
              );
            },
          ),
        ],
      );
    });
  }
}
