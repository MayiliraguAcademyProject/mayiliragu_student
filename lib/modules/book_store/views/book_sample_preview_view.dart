import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/toast_helper.dart';
import '../../../../shared/widgets/common_button.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../models/book_model.dart';
import 'book_checkout_view.dart';

class BookSamplePreviewView extends StatefulWidget {
  final BookModel book;
  final int initialPage;

  const BookSamplePreviewView({
    super.key,
    required this.book,
    this.initialPage = 0,
  });

  @override
  State<BookSamplePreviewView> createState() => _BookSamplePreviewViewState();
}

class _BookSamplePreviewViewState extends State<BookSamplePreviewView> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchPdfUrl(String pdfUrl) async {
    String fullUrl = pdfUrl;
    if (!pdfUrl.startsWith('http://') && !pdfUrl.startsWith('https://')) {
      final base = ApiConstants.baseUrl.replaceAll('/api', '');
      fullUrl = '$base$pdfUrl';
    }
    final uri = Uri.parse(fullUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppToast.error('Unable to open sample PDF', title: 'Error');
      }
    } catch (e) {
      AppToast.error('Could not open preview PDF', title: 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pages = widget.book.samplePages;
    final hasImages = pages.isNotEmpty;
    final hasPdf = widget.book.samplePdfUrl != null &&
        widget.book.samplePdfUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              hasImages
                  ? "Page ${_currentPage + 1} of ${pages.length}"
                  : "Sample Preview",
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (hasPdf)
            TextButton.icon(
              onPressed: () => _launchPdfUrl(widget.book.samplePdfUrl!),
              icon: const Icon(Icons.picture_as_pdf,
                  color: AppColors.brandPurple, size: 18),
              label: const Text(
                "Read PDF",
                style: TextStyle(
                  color: AppColors.brandPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Main Preview Area
          Expanded(
            child: hasImages
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CustomNetworkImage(
                                imageUrl: pages[index],
                                fit: BoxFit.contain,
                                errorWidget: Container(
                                  color: Colors.grey[900],
                                  child: const Center(
                                    child: Icon(Icons.broken_image,
                                        color: Colors.white38, size: 48),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf,
                              color: AppColors.brandPurple,
                              size: 56,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Sample Excerpt Available",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Preview the first chapters of '${widget.book.title}' in high quality PDF.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (hasPdf)
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _launchPdfUrl(widget.book.samplePdfUrl!),
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text("Open Sample PDF"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Bottom Thumbnail Strip (if multiple images)
          if (hasImages && pages.length > 1)
            Container(
              height: 72,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFF1E1E1E),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: pages.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = index == _currentPage;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.brandPurple
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CustomNetworkImage(
                          imageUrl: pages[index],
                          fit: BoxFit.cover,
                          errorWidget: Container(color: Colors.grey[800]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Sticky Bottom Checkout Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Physical Hard Copy",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          widget.book.priceHardCopy != null
                              ? "₹${widget.book.priceHardCopy}"
                              : "N/A",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CommonButton(
                      text: "Buy Now",
                      onPressed: widget.book.stockHardCopy <= 0
                          ? null
                          : () {
                              Get.to(() => BookCheckoutView(
                                    book: widget.book,
                                    format: 'HARD_COPY',
                                    quantity: 1,
                                  ));
                            },
                      backgroundColor: AppColors.brandPurple,
                      foregroundColor: Colors.white,
                      height: 48,
                      borderRadius: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
