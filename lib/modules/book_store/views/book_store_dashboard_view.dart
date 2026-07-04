import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../study_materials/widgets/category_chip.dart';
import '../controllers/book_store_controller.dart';
import '../../../../core/utils/toast_helper.dart';
import '../models/book_model.dart';
import 'book_detail_view.dart';
import '../../../../shared/widgets/custom_network_image.dart';

class BookStoreDashboardView extends StatefulWidget {
  const BookStoreDashboardView({super.key});

  @override
  State<BookStoreDashboardView> createState() => _BookStoreDashboardViewState();
}

class _BookStoreDashboardViewState extends State<BookStoreDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.find<BookStoreController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Book Store',
          style: AppTextStyles.heading.copyWith(fontSize: 20, color: AppColors.textPrimary),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.brandPurple,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPurple.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: "Catalog"),
                Tab(text: "My Books"),
                Tab(text: "Order History"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCatalogTab(),
          _buildMyBooksTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildCatalogTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchCategories();
        await controller.fetchBooks();
      },
      color: AppColors.brandPurple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 20),

            // Categories Filter Header
            const Text(
              "Categories",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            // Category chips list
            _buildCategoryFilters(),
            const SizedBox(height: 24),

            // Books Grid
            Obx(() {
              if (controller.isBooksLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
              }

              if (controller.booksList.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      Icon(Icons.menu_book_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        "No books found.",
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.booksList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final book = controller.booksList[index];
                  return _buildBookGridCard(book);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBooksTab() {
    return RefreshIndicator(
      onRefresh: () async => await controller.fetchMyBooks(),
      color: AppColors.brandPurple,
      child: Obx(() {
        if (controller.myBooksList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "No paid digital books yet.\nSoft copies appear here after admin approves payment.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.myBooksList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final book = controller.myBooksList[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomNetworkImage(
                      imageUrl: book.thumbnailUrl,
                      width: 50,
                      height: 70,
                      fit: fitCover(book.thumbnailUrl),
                      errorWidget: const Icon(Icons.book, size: 40),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (book.author != null)
                          Text("by ${book.author}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _handlePdfRead(book.id),
                    icon: const Icon(Icons.chrome_reader_mode, size: 14, color: Colors.white),
                    label: const Text("Read", style: TextStyle(fontSize: 11, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async => await controller.fetchMyOrders(),
      color: AppColors.brandPurple,
      child: Obx(() {
        if (controller.isOrdersLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
        }

        if (controller.myOrdersList.isEmpty) {
          return const Center(
            child: Text(
              "No orders placed yet.",
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.myOrdersList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = controller.myOrdersList[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #${order.id.substring(0, 8)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: order.orderStatus == 'DELIVERED'
                              ? Colors.green.shade50
                              : order.orderStatus == 'CANCELLED'
                                  ? Colors.red.shade50
                                  : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.orderStatus,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: order.orderStatus == 'DELIVERED'
                                ? Colors.green.shade700
                                : order.orderStatus == 'CANCELLED'
                                    ? Colors.red.shade700
                                    : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Date: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}",
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items?.length ?? 0,
                    itemBuilder: (context, idx) {
                      final item = order.items![idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${item.book?.title ?? 'Book'} (${item.format == 'HARD_COPY' ? 'Hard Copy' : 'Soft Copy'})",
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text("x${item.quantity}  ₹${item.price}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment: ${order.paymentStatus}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: order.paymentStatus == 'PAID' ? Colors.green : Colors.orange,
                        ),
                      ),
                      Text(
                        "Total: ₹${order.payableAmount}",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brandPurple),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        onChanged: (val) {
          controller.searchQuery.value = val;
          controller.fetchBooks();
        },
        decoration: const InputDecoration(
          hintText: "Search books, authors...",
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 38,
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categoriesList.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              final active = controller.selectedCategoryId.value.isEmpty;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CategoryChip(
                  label: "All Books",
                  isSelected: active,
                  onSelected: (selected) {
                    controller.selectedCategoryId.value = "";
                    controller.fetchBooks();
                  },
                ),
              );
            }

            final cat = controller.categoriesList[index - 1];
            final active = controller.selectedCategoryId.value == cat.id;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CategoryChip(
                label: cat.name,
                isSelected: active,
                onSelected: (selected) {
                  controller.selectedCategoryId.value = cat.id;
                  controller.fetchBooks();
                },
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildBookGridCard(BookModel book) {
    return GestureDetector(
      onTap: () => Get.to(() => BookDetailView(bookId: book.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F6FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: CustomNetworkImage(
                    imageUrl: book.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: const Icon(Icons.book, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author ?? 'Unknown Author',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        book.priceHardCopy != null ? "₹${book.priceHardCopy}" : "₹${book.priceSoftCopy}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.brandPurple),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brandPurple.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.priceHardCopy != null ? "Hard Copy" : "Soft Copy",
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.brandPurple),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePdfRead(String bookId) async {
    final result = await controller.downloadBookPdf(bookId);
    if (result != null) {
      final pdfUrl = result['pdfUrl'] as String;
      String fullUrl = pdfUrl;
      if (!pdfUrl.startsWith('http://') && !pdfUrl.startsWith('https://')) {
        final base = ApiConstants.baseUrl.replaceAll('/api', '');
        fullUrl = '$base$pdfUrl';
      }
      final uri = Uri.parse(fullUrl);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        AppToast.error('Could not open book PDF', title: 'Error');
      }
    }
  }

  BoxFit fitCover(String url) => url.isNotEmpty ? BoxFit.cover : BoxFit.contain;
}

extension ColorsHex on Colors {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
