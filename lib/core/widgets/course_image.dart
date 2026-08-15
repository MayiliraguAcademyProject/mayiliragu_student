import 'dart:convert';
import 'package:flutter/material.dart';
import '../../shared/widgets/custom_network_image.dart';

class CourseImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CourseImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  static ImageProvider getProvider(String imageUrl) {
    if (imageUrl.startsWith('data:image/') && imageUrl.contains('base64,')) {
      try {
        final base64String = imageUrl.split('base64,')[1].trim();
        return MemoryImage(base64Decode(base64String));
      } catch (_) {}
    }
    return NetworkImage(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return placeholder ?? _defaultPlaceholder();
    }

    if (imageUrl.startsWith('data:image/') && imageUrl.contains('base64,')) {
      try {
        final base64String = imageUrl.split('base64,')[1].trim();
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _defaultErrorWidget();
          },
        );
      } catch (e) {
        return errorWidget ?? _defaultErrorWidget();
      }
    }

    // Default to Network Image
    return CustomNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: placeholder,
      errorWidget: errorWidget ?? _defaultErrorWidget(),
    );
  }

  Widget _defaultPlaceholder() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          color: colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.image,
            color: colorScheme.onSurfaceVariant,
            size: 48,
          ),
        );
      }
    );
  }

  Widget _defaultErrorWidget() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          color: colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.broken_image,
            color: colorScheme.onSurfaceVariant,
            size: 48,
          ),
        );
      }
    );
  }
}
