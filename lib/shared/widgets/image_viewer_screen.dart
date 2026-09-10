import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import 'custom_network_image.dart';

class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String title;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    this.title = 'Image Viewer',
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _showAppBar = true;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      final matrix = Matrix4.identity()
        ..multiply(Matrix4.translationValues(-position.dx * 1.5, -position.dy * 1.5, 0.0))
        ..multiply(Matrix4.diagonal3Values(2.5, 2.5, 1.0));
      _transformationController.value = matrix;
    }
  }

  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.65),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              title: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  tooltip: 'Reset zoom',
                  onPressed: () {
                    _transformationController.value = Matrix4.identity();
                  },
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleAppBar,
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: _handleDoubleTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: InteractiveViewer(
            transformationController: _transformationController,
            clipBehavior: Clip.none,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.8,
            maxScale: 8.0,
            child: Center(
              child: CustomNetworkImage(
                imageUrl: widget.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                placeholder: Center(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
