import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/book_store_controller.dart';
import 'book_checkout_view.dart';
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

  @override
  void initState() {
    super.initState();
    controller.fetchBookDetail(widget.bookId);
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

        // Set default format if one is not available
        if (selectedFormat == 'HARD_COPY' &&
            book.priceHardCopy == null &&
            book.priceSoftCopy != null) {
          selectedFormat = 'SOFT_COPY';
        }

        final hasHard = book.priceHardCopy != null;
        final hasSoft = book.priceSoftCopy != null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image and header info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outline.withAlpha(50),
                  ),
                ),
                child: Column(
                  children: [
                    ClipRRect(
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
                    const SizedBox(height: 16),
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
              const SizedBox(height: 20),

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
              if (book.description != null &&
                  book.description!.isNotEmpty) ...[
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
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      (selectedFormat == 'HARD_COPY' && book.stockHardCopy <= 0)
                          ? null
                          : () => Get.to(() => BookCheckoutView(
                                book: book,
                                format: selectedFormat,
                                quantity: quantity,
                              )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    AppStrings.buyNow,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
