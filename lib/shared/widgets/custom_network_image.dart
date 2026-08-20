import 'package:Mayiliragu/core/constants/api_constants.dart';
import 'package:Mayiliragu/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Widget? placeholder;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget buildErrorFallback() {
      final fallback = errorWidget ?? Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[100],
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 24,
            color: isDark ? Colors.grey[650] : Colors.grey[400],
          ),
        ),
      );

      if (borderRadius != null) {
        return ClipRRect(
          borderRadius: borderRadius!,
          child: fallback,
        );
      }
      return fallback;
    }

    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return buildErrorFallback();
    }

    String resolvedUrl = trimmedUrl;
    if (!resolvedUrl.startsWith('http://') && !resolvedUrl.startsWith('https://')) {
      final base = ApiConstants.baseUrl;
      final serverRoot = base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
      resolvedUrl = '$serverRoot$trimmedUrl';
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: resolvedUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => placeholder ?? Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: borderRadius,
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.accent : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => buildErrorFallback(),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
