import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/test_results_controller.dart';

class TestResultsView extends GetView<TestResultsController> {
  const TestResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3CC9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Mayiliragu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.timer_outlined, color: Colors.white),
          //   onPressed: () {},
          // ),
          // IconButton(
          //   icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(80.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F3CC9)),
              ),
            ),
          );
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Curved Deep Blue Header
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F3CC9),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Test Completed!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.testTitle.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Overlapping Circular Score Card
                  Positioned(
                    top: 85,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCircularProgressIndicator(),
                          const SizedBox(height: 14),
                          _buildPassFailBadge(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Spacing matching the overlapping card
              const SizedBox(height: 165),

              // Statistics Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildStatCard(
                      label: 'Correct',
                      value: '${controller.correctCount.value}',
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF10B981),
                      valColor: const Color(0xFF10B981),
                    ),
                    _buildStatCard(
                      label: 'Wrong',
                      value: '${controller.wrongCount.value}',
                      icon: Icons.cancel_outlined,
                      iconColor: const Color(0xFFEF4444),
                      valColor: const Color(0xFFEF4444),
                    ),
                    _buildStatCard(
                      label: 'Skipped',
                      value: '${controller.skippedCount.value}',
                      icon: Icons.skip_next_outlined,
                      iconColor: const Color(0xFF6B7280),
                      valColor: const Color(0xFF374151),
                    ),
                    _buildStatCard(
                      label: 'Accuracy',
                      value: '${controller.accuracy.value}%',
                      icon: Icons.track_changes_outlined,
                      iconColor: const Color(0xFF1E60FF),
                      valColor: const Color(0xFF1E60FF),
                    ),
                    _buildStatCard(
                      label: 'Time Taken',
                      value: controller.timeTakenFormatted.value,
                      icon: Icons.access_time_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      valColor: const Color(0xFF6D28D9),
                    ),
                    _buildStatCard(
                      label: 'Rank',
                      value: '#${controller.rank.value}',
                      icon: Icons.emoji_events_outlined,
                      iconColor: const Color(0xFFD97706),
                      valColor: const Color(0xFFB45309),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Subject Performance Section
              if (controller.subjectPerformance.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Text(
                    'SUBJECT PERFORMANCE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B5563),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.subjectPerformance.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final data = controller.subjectPerformance[index];
                        return _buildSubjectRow(
                          subjectName: data['subject'] ?? 'General Studies',
                          percentage: data['percentage'] ?? 0,
                          colorIndex: index,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.sectionBreakdowns.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Section Performance Breakdown',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...controller.sectionBreakdowns.map((sec) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildSectionRow(sec),
                        )).toList(),
                      ],
                    ),
                  );
                }),
              ],

              // Comparative Stats Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Row(
                    children: [
                      _buildCompareCol(
                        'Your Score',
                        '${controller.score.value}%',
                        const Color(0xFF1E60FF),
                      ),
                      _buildDivider(),
                      _buildCompareCol(
                        'Class Avg',
                        '${controller.classAvg.value}%',
                        const Color(0xFF4B5563),
                      ),
                      _buildDivider(),
                      _buildCompareCol(
                        'Top Score',
                        '${controller.topScore.value}%',
                        const Color(0xFFB45309),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Actions Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.viewSolutions(),
                        icon: const Icon(
                          Icons.assignment_turned_in_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'View Solutions & Explanations',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E60FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => controller.detailedAnalysis(),
                        icon: const Icon(
                          Icons.trending_up,
                          color: Color(0xFF0F3CC9),
                        ),
                        label: const Text(
                          'Detailed Analysis',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F3CC9),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF0F3CC9),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Retake test action
              Center(
                child: TextButton.icon(
                  onPressed: () => controller.retakeTest(),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.black54,
                    size: 20,
                  ),
                  label: const Text(
                    'Retake Test',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCircularProgressIndicator() {
    final double pct = controller.score.value / 100.0;

    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: pct,
            strokeWidth: 10,
            backgroundColor: const Color(0xFFEFF6FF),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E60FF)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${controller.score.value}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Text(
                  'OUT OF 100',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassFailBadge() {
    final bool isPassed = controller.passed.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isPassed ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isPassed ? 'PASS' : 'FAIL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPassed
                  ? const Color(0xFF065F46)
                  : const Color(0xFF991B1B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isPassed ? Icons.check_circle : Icons.cancel,
            color: isPassed ? const Color(0xFF065F46) : const Color(0xFF991B1B),
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color valColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectRow({
    required String subjectName,
    required int percentage,
    required int colorIndex,
  }) {
    // Curated tailored gradient colors for progress indicators
    final List<Color> colors = [
      const Color(0xFF78350F), // General Studies: Brown
      const Color(0xFF10B981), // Aptitude: Green
      const Color(0xFF0F3CC9), // English: Blue
      const Color(0xFF8B5CF6), // Other: Purple
    ];
    final Color barColor = colors[colorIndex % colors.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subjectName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100.0,
            minHeight: 8,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCompareCol(String label, String value, Color valColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 28, color: const Color(0xFFBFDBFE));
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false),
          _buildNavItem(Icons.assignment_outlined, 'Tests', true),
          _buildNavItem(Icons.school_outlined, 'Learn', false),
          _buildNavItem(Icons.trending_up, 'Progress', false),
          _buildNavItem(Icons.menu, 'More', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    final color = isActive ? const Color(0xFF0F3CC9) : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionRow(Map<String, dynamic> data) {
    final String name = data['name'] ?? 'Section';
    final double score = (data['score'] as num?)?.toDouble() ?? 0.0;
    final double totalMarks = (data['total_marks'] as num?)?.toDouble() ?? 0.0;
    final double cutoff = (data['cutoff_marks'] as num?)?.toDouble() ?? 0.0;
    final int correct = data['correct'] ?? 0;
    final int wrong = data['wrong'] ?? 0;
    final int skipped = data['skipped'] ?? 0;
    final bool isPassed = data['passed'] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPassed ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPassed ? 'Passed Cutoff' : 'Failed Cutoff',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionDetailCol('Score', '$score / ${totalMarks.toInt()}'),
              _buildSectionDetailCol('Cutoff', '$cutoff'),
              _buildSectionDetailCol('Correct', '$correct', color: const Color(0xFF10B981)),
              _buildSectionDetailCol('Wrong', '$wrong', color: const Color(0xFFEF4444)),
              _buildSectionDetailCol('Skipped', '$skipped', color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDetailCol(String label, String val, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
