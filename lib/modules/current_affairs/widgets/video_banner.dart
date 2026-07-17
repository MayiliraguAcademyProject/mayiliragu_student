import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class VideoBanner extends StatelessWidget {
  final String url;

  const VideoBanner({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          // launch successful
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.video_library, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Video Discussion Available",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.red),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Click to launch and watch faculty analysis.",
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
