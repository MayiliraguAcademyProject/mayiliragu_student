import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/analytics_controller.dart';
import '../widgets/readiness_gauge.dart';
import '../widgets/trend_chart.dart';
import 'subject_analysis_view.dart';
import 'goals_tracker_view.dart';

class AnalyticsDashboardView extends StatelessWidget {
  const AnalyticsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0.5,
        title: Text(
          'Performance Insights',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
      ),
      body: Obx(() {
        if (controller.isAnalyticsLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
        }

        final stats = controller.studentAnalytics.value;
        if (stats == null) {
          return Center(
            child: Text(
              "No analytics found. Start attempting tests!",
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchAllData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Readiness Gauge Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Column(
                    children: [
                      ReadinessGauge(score: stats.readinessScore),
                      const SizedBox(height: 16),
                      Text(
                        'TNPSC Exam Readiness Indicator',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Readiness represents your average accuracy across recent tests.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Streak and Study Hours Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        Icons.local_fire_department,
                        '${stats.learningStreak} Days',
                        'Learning Streak',
                        Colors.orange.shade50,
                        Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        Icons.access_time_filled,
                        '${stats.studyHours} Hours',
                        'Study Activity',
                        Colors.blue.shade50,
                        Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Historical Progress Trend Section
                _buildSectionHeader(context, 'Performance Trends'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: TrendChart(trends: controller.trendsList),
                ),
                const SizedBox(height: 24),

                // Nav Links to deep-dives
                _buildActionRow(
                  context,
                  Icons.bar_chart,
                  'Subject-wise Analysis',
                  'View accuracy stats for each subject & topic',
                  () => Get.to(() => const SubjectAnalysisView()),
                ),
                const SizedBox(height: 12),
                _buildActionRow(
                  context,
                  Icons.track_changes,
                  'My Target Goals',
                  'Create and update revision target checklists',
                  () => Get.to(() => const GoalsTrackerView()),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    IconData icon,
    String value,
    String title,
    Color bg,
    Color accent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.brandPurple.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_forward_ios, color: AppColors.brandPurple, size: 16),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Icon(icon, color: colorScheme.outline, size: 24),
          ],
        ),
      ),
    );
  }
}
