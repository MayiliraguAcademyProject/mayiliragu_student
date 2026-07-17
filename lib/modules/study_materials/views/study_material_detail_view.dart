import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../controllers/study_materials_controller.dart';
import '../widgets/version_item.dart';
import '../../../../core/utils/toast_helper.dart';

class StudyMaterialDetailView extends StatefulWidget {
  final String materialId;

  const StudyMaterialDetailView({super.key, required this.materialId});

  @override
  State<StudyMaterialDetailView> createState() => _StudyMaterialDetailViewState();
}

class _StudyMaterialDetailViewState extends State<StudyMaterialDetailView> {
  @override
  void initState() {
    super.initState();
    Get.find<StudyMaterialsController>().fetchMaterialDetail(widget.materialId);
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<void> _handleDownload(String id) async {
    final controller = Get.find<StudyMaterialsController>();
    final result = await controller.downloadMaterial(id);
    if (result != null) {
      final fileUrl = result['fileUrl'] as String;
      String fullUrl = fileUrl;
      if (!fileUrl.startsWith('http://') && !fileUrl.startsWith('https://')) {
        // Dynamically get domain base from active ApiConstants.baseUrl
        final base = ApiConstants.baseUrl.replaceAll('/api', '');
        fullUrl = '$base$fileUrl';
      }
      final uri = Uri.parse(fullUrl);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        AppToast.error('Could not launch download URL', title: 'Error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudyMaterialsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Resource Detail',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          Obx(() {
            final mat = controller.currentMaterial.value;
            if (mat == null) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(
                mat.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: mat.isBookmarked ? AppColors.brandPurple : AppColors.textPrimary,
              ),
              onPressed: () => controller.toggleBookmark(mat.id),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
        }

        final mat = controller.currentMaterial.value;
        if (mat == null) {
          return const Center(child: Text("Study material not found or deleted."));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Material Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.brandPurple.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            mat.category?.name ?? 'General',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandPurple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            mat.accessType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      mat.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (mat.description != null && mat.description!.isNotEmpty) ...[
                      Text(
                        mat.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildMetaRow(Icons.sd_storage_outlined, "File Size", _formatFileSize(mat.fileSize)),
                    const SizedBox(height: 10),
                    _buildMetaRow(Icons.insert_drive_file_outlined, "File Type", mat.fileType.toUpperCase()),
                    const SizedBox(height: 10),
                    _buildMetaRow(Icons.calendar_today_outlined, "Published Date",
                        "${mat.createdAt.day}/${mat.createdAt.month}/${mat.createdAt.year}"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: controller.isDownloading.value ? null : () => _handleDownload(mat.id),
                      icon: controller.isDownloading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.download_for_offline_outlined, color: Colors.white),
                      label: Text(
                        controller.isDownloading.value ? "Authorizing..." : "View Resource",
                        style:  TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  )),

              const SizedBox(height: 32),

              // Version history title
              if (mat.versions.isNotEmpty) ...[
                const Text(
                  "Version History Archives",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mat.versions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final ver = mat.versions[index];
                    return VersionItem(
                      version: ver,
                      onDownloadTap: () => _handleDownload(mat.id), // Directs to material secure download
                    );
                  },
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
