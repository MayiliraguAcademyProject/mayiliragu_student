import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/common_button.dart';
import '../controllers/book_store_controller.dart';
import 'book_checkout_view.dart';
import 'book_sample_preview_view.dart';
import '../../../../shared/widgets/custom_network_image.dart';

class BookDetailView extends StatefulWidget {
  final String bookId;

  const BookDetailView({super.key, required this.bookId});

  @override
  State<BookDetailView> createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  final controller = Get.find<BookStoreController>();
  String selectedFormat = 'HARD_COPY';
  int quantity = 1;
  late final PageController _carouselPageController;
  int _currentCarouselIndex = 0;
  Timer? _autoScrollTimer;
  int _lastAutoScrollCount = 0;

  @override
  void initState() {
    super.initState();
    _carouselPageController = PageController(viewportFraction: 0.88);
    controller.fetchBookDetail(widget.bookId);
  }

  void _startAutoScroll(int totalCount) {
    if (totalCount <= 1 || _lastAutoScrollCount == totalCount) return;
    _lastAutoScrollCount = totalCount;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_carouselPageController.hasClients || !mounted) return;
      final nextIndex = (_currentCarouselIndex + 1) % totalCount;
      _carouselPageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _carouselPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(
          AppStrings.bookDetails,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          Obx(() {
            final book = controller.currentBook.value;
            if (book == null) return const SizedBox.shrink();
            return IconButton(
              icon: Icon(
                book.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: book.isBookmarked
                    ? AppColors.brandPurple
                    : colorScheme.onSurface,
              ),
              onPressed: () => controller.toggleBookmark(book.id),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brandPurple),
          );
        }

        final book = controller.currentBook.value;
        if (book == null) {
          return const Center(child: Text("Book not found."));
        }

        final hasHard = book.priceHardCopy != null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image or Sample Pages Carousel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colorScheme.outline.withAlpha(50)),
                ),
                child: Column(
                  children: [
                    if (book.samplePages.isNotEmpty) ...[
                      // Carousel Slider with Cover + Sample Pages
                      Builder(
                        builder: (context) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _startAutoScroll(1 + book.samplePages.length);
                          });
                          return Column(
                            children: [
                              SizedBox(
                                height: 240,
                                child: PageView.builder(
                                  controller: _carouselPageController,
                                  itemCount: 1 + book.samplePages.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentCarouselIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final isCover = index == 0;
                                    final imageUrl = isCover
                                        ? book.thumbnailUrl
                                        : book.samplePages[index - 1];

                                    return GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => BookSamplePreviewView(
                                            book: book,
                                            initialPage: isCover
                                                ? 0
                                                : index - 1,
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                        ),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 240,
                                                child: CustomNetworkImage(
                                                  imageUrl: imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorWidget: Icon(
                                                    Icons.book,
                                                    size: 80,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Badge on top right
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: isCover
                                                      ? AppColors.brandPurple
                                                      : Colors.black.withValues(
                                                          alpha: 0.75,
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isCover
                                                          ? Icons.auto_stories
                                                          : Icons.menu_book,
                                                      size: 11,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      isCover
                                                          ? "Cover"
                                                          : "Sample P.$index",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Fullscreen tap hint on bottom
                                            Positioned(
                                              bottom: 10,
                                              right: 10,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.6),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.fullscreen,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Carousel Indicator Dots
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  1 + book.samplePages.length,
                                  (dotIndex) {
                                    final isActive =
                                        _currentCarouselIndex == dotIndex;
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      width: isActive ? 18 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.brandPurple
                                            : colorScheme.outline.withAlpha(80),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ] else ...[
                      // Single Cover (when no sample images found)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomNetworkImage(
                            imageUrl: book.thumbnailUrl,
                            height: 220,
                            fit: BoxFit.cover,
                            errorWidget: Icon(
                              Icons.book,
                              size: 80,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Text(
                            book.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Author: ${book.author ?? 'Unknown Author'}",
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (book.publisher != null)
                            Text(
                              "Publisher: ${book.publisher}",
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Look Inside / Sample Pages Banner
              if (book.samplePages.isNotEmpty ||
                  (book.samplePdfUrl != null &&
                      book.samplePdfUrl!.isNotEmpty)) ...[
                GestureDetector(
                  onTap: () => Get.to(() => BookSamplePreviewView(book: book)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.brandPurple.withValues(alpha: 0.12),
                          AppColors.brandPurple.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.brandPurple.withValues(alpha: 0.28),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandPurple.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brandPurple.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: AppColors.brandPurple,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Look Inside",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandPurple,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "FREE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                book.samplePages.isNotEmpty
                                    ? "Read ${book.samplePages.length} sample pages & contents"
                                    : "Preview sample chapter excerpt (PDF)",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandPurple,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandPurple.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Read Sample",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Format Selector
              Text(
                AppStrings.purchaseOptions,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (hasHard)
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedFormat = 'HARD_COPY'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedFormat == 'HARD_COPY'
                                ? AppColors.brandPurple.withValues(alpha: 0.1)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedFormat == 'HARD_COPY'
                                  ? AppColors.brandPurple
                                  : colorScheme.outline.withAlpha(50),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.menu_book,
                                color: AppColors.brandPurple,
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.hardCopy,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "₹${book.priceHardCopy}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brandPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.stockHardCopy > 0
                                    ? "In Stock (${book.stockHardCopy})"
                                    : "Out of Stock",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: book.stockHardCopy > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  /*
                  if (hasHard && hasSoft) const SizedBox(width: 12),
                  if (hasSoft)
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedFormat = 'SOFT_COPY'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedFormat == 'SOFT_COPY'
                                ? AppColors.brandPurple.withValues(alpha: 0.1)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedFormat == 'SOFT_COPY'
                                  ? AppColors.brandPurple
                                  : colorScheme.outline.withAlpha(50),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: AppColors.brandPurple,
                                size: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.softCopy,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "₹${book.priceSoftCopy}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brandPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.instantDownload,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  */
                ],
              ),
              const SizedBox(height: 20),

              // Quantity Selector (Hard Copy only)
              if (selectedFormat == 'HARD_COPY' && book.stockHardCopy > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.quantity,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(
                              () => quantity > 1 ? quantity-- : null,
                            ),
                            icon: Icon(
                              Icons.remove,
                              size: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            "$quantity",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(
                              () => quantity < book.stockHardCopy
                                  ? quantity++
                                  : null,
                            ),
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Description
              if (book.description != null && book.description!.isNotEmpty) ...[
                Text(
                  AppStrings.aboutThisBook,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book.description!,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Buy Now Button
              CommonButton(
                text: AppStrings.buyNow,
                onPressed:
                    (selectedFormat == 'HARD_COPY' && book.stockHardCopy <= 0)
                    ? null
                    : () => Get.to(
                        () => BookCheckoutView(
                          book: book,
                          format: selectedFormat,
                          quantity: quantity,
                        ),
                      ),
                backgroundColor: AppColors.brandPurple,
                foregroundColor: Colors.white,
                height: 52,
                borderRadius: 16,
              ),
            ],
          ),
        );
      }),
    );
  }
}
