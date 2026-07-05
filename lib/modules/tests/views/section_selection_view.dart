import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/section_selection_controller.dart';
import '../models/test_model.dart';

class SectionSelectionView extends GetView<SectionSelectionController> {
  const SectionSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        title: Obx(() => Text(
              controller.test.value?.title ?? 'Test Sections',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                fontSize: 18,
              ),
            )),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F3CC9)),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.loadTestDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F3CC9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final test = controller.test.value;
        if (test == null || test.sections == null || test.sections!.isEmpty) {
          return const Center(
            child: Text('No sections configured for this test.'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F3CC9), Color(0xFF1E56FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F3CC9).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MULTI-SECTION EXAM',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    test.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  if (test.description != null && test.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      test.description!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildHeaderStat(Icons.help_outline, '${test.questionCount} Questions'),
                      const SizedBox(width: 16),
                      _buildHeaderStat(Icons.timer_outlined, '${test.duration} Minutes'),
                      const SizedBox(width: 16),
                      _buildHeaderStat(Icons.military_tech_outlined, 'Cutoff: ${test.cutoffMarks}%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Exam Sections Flow',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            ...test.sections!.map((section) {
              final idx = test.sections!.indexOf(section);
              final isLocked = controller.isSectionLocked(section);
              final isEnabled = controller.isSectionEnabled(section);
              
              return _buildSectionCard(section, idx, isLocked, isEnabled);
            }).toList(),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(TestSectionModel section, int index, bool isLocked, bool isEnabled) {
    Color cardBg = Colors.white;
    Color borderCol = const Color(0xFFE2E8F0);
    double opacity = 1.0;
    
    if (!isEnabled) {
      opacity = 0.55;
    }

    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3CC9).withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SECTION ${index + 1}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          section.name,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(isLocked, isEnabled),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionStat(Icons.quiz_outlined, '${section.questionCount} Questions'),
                  _buildSectionStat(Icons.hourglass_bottom_outlined, '${section.duration} Minutes'),
                  _buildSectionStat(Icons.check_circle_outline, 'Cutoff: ${section.cutoffMarks}'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!isEnabled || isLocked)
                      ? null
                      : () {
                          Get.toNamed(
                            '/test-runner',
                            arguments: {
                              'test_id': controller.testId,
                              'section_id': section.id,
                              'section_index': index,
                            },
                          )?.then((_) => controller.loadDraftState());
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked
                        ? const Color(0xFFE2E8F0)
                        : (isEnabled ? const Color(0xFF0F3CC9) : const Color(0xFF94A3B8)),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isLocked
                        ? 'Section Completed'
                        : (isEnabled ? 'Start Section' : 'Locked'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isLocked, bool isEnabled) {
    if (isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.check, color: Color(0xFF065F46), size: 12),
            SizedBox(width: 4),
            Text(
              'Completed',
              style: TextStyle(
                color: Color(0xFF065F46),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }
    
    if (!isEnabled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFF64748B), size: 12),
            SizedBox(width: 4),
            Text(
              'Locked',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.play_circle_outline, color: Color(0xFF2563EB), size: 12),
          SizedBox(width: 4),
          Text(
            'Ready',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
