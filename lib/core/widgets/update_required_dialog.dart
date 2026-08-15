import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../../shared/widgets/common_button.dart';
import '../utils/toast_helper.dart';

class UpdateRequiredDialog extends StatelessWidget {
  final String requiredVersion;
  final String apkDownloadUrl;
  final String? releaseNotes;

  const UpdateRequiredDialog({
    super.key,
    required this.requiredVersion,
    required this.apkDownloadUrl,
    required this.releaseNotes,
  });

  Future<void> _handleDownload() async {
    final Uri url = Uri.parse(apkDownloadUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $apkDownloadUrl';
      }
    } catch (e) {
      AppToast.error(
        'Could not open download browser. Please copy link manually: $apkDownloadUrl',
        title: 'Update Link Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.system_update_alt_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Update Required',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: colorScheme.onSurface),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A newer version of Mayiliragu Academy (v$requiredVersion) is required to continue. Please download the update.',
              style: TextStyle(fontSize: 14, height: 1.4, color: colorScheme.onSurface),
            ),
            if (releaseNotes != null && releaseNotes!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                "What's New:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outline),
                ),
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Text(
                    releaseNotes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Note: Please enable "Install from Unknown Sources" if prompted during installation.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          CommonButton(
            text: 'Download Update',
            onPressed: _handleDownload,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            height: 48,
            borderRadius: 12,
            icon: const Icon(Icons.download_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
