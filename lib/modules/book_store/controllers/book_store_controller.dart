import 'package:get/get.dart';
import '../../study_materials/models/study_material_models.dart';
import '../../study_materials/repositories/study_materials_repository.dart';
import '../models/book_model.dart';
import '../repositories/book_store_repository.dart';
import '../../../core/utils/toast_helper.dart';

class BookStoreController extends GetxController {
  final BookStoreRepository _repository;
  final StudyMaterialsRepository _studyRepo; // Reuse for categories

  BookStoreController(this._repository, this._studyRepo);

  // Loading states
  final isBooksLoading = false.obs;
  final isDetailLoading = false.obs;
  final isOrdersLoading = false.obs;
  final isCouponValidating = false.obs;
  final isPlacingOrder = false.obs;
  final isDownloading = false.obs;

  // Data lists
  final categoriesList = <MaterialCategory>[].obs;
  final booksList = <BookModel>[].obs;
  final bookmarksList = <BookModel>[].obs;
  final myBooksList = <BookModel>[].obs;
  final myOrdersList = <BookOrderModel>[].obs;

  // Detail item
  final currentBook = Rxn<BookModel>();

  // Filter/Search variables
  final selectedCategoryId = ''.obs;
  final searchQuery = ''.obs;

  // Checkout info
  final appliedCoupon = Rxn<CouponModel>();
  final discountAmount = 0.0.obs;
  final couponError = ''.obs;
  final paymentQrUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchBooks();
    fetchBookmarks();
    fetchMyBooks();
    fetchMyOrders();
    fetchPaymentQr();
  }


  Future<void> fetchCategories() async {
    try {
      final response = await _studyRepo.getCategories();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<MaterialCategory> loaded =
            data.map((item) => MaterialCategory.fromJson(item)).toList();
        categoriesList.assignAll(loaded);
      }
    } catch (e) {
      print('Categories load error: $e');
    }
  }

  Future<void> fetchBooks() async {
    try {
      isBooksLoading.value = true;
      final response = await _repository.getBooks(
        categoryId: selectedCategoryId.value.isEmpty ? null : selectedCategoryId.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<BookModel> loaded =
            data.map((item) => BookModel.fromJson(item)).toList();
        booksList.assignAll(loaded);
      }
    } catch (e) {
      print('Fetch books error: $e');
    } finally {
      isBooksLoading.value = false;
    }
  }

  Future<void> fetchBookDetail(String id) async {
    try {
      isDetailLoading.value = true;
      currentBook.value = null;
      final response = await _repository.getBookById(id);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          currentBook.value = BookModel.fromJson(data);
        }
      }
    } catch (e) {
      print('Book detail load error: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> toggleBookmark(String id) async {
    try {
      final response = await _repository.toggleBookmark(id);
      if (response.statusCode == 200) {
        // Toggle in booksList local state
        final idx = booksList.indexWhere((b) => b.id == id);
        if (idx != -1) {
          final b = booksList[idx];
          booksList[idx] = BookModel(
            id: b.id,
            title: b.title,
            description: b.description,
            thumbnailUrl: b.thumbnailUrl,
            images: b.images,
            author: b.author,
            publisher: b.publisher,
            priceHardCopy: b.priceHardCopy,
            priceSoftCopy: b.priceSoftCopy,
            stockHardCopy: b.stockHardCopy,
            pdfUrl: b.pdfUrl,
            categoryId: b.categoryId,
            isActive: b.isActive,
            isBookmarked: !b.isBookmarked,
            category: b.category,
          );
        }

        // Toggle in current details item
        if (currentBook.value?.id == id) {
          final b = currentBook.value!;
          currentBook.value = BookModel(
            id: b.id,
            title: b.title,
            description: b.description,
            thumbnailUrl: b.thumbnailUrl,
            images: b.images,
            author: b.author,
            publisher: b.publisher,
            priceHardCopy: b.priceHardCopy,
            priceSoftCopy: b.priceSoftCopy,
            stockHardCopy: b.stockHardCopy,
            pdfUrl: b.pdfUrl,
            categoryId: b.categoryId,
            isActive: b.isActive,
            isBookmarked: !b.isBookmarked,
            category: b.category,
          );
        }

        fetchBookmarks();
      }
    } catch (e) {
      print('Toggle bookmark error: $e');
    }
  }

  Future<void> fetchBookmarks() async {
    try {
      final response = await _repository.getBookmarkedBooks();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<BookModel> loaded = data.map((item) {
          final detail = item['book'];
          return BookModel.fromJson({
            ...detail,
            'isBookmarked': true,
          });
        }).toList();
        bookmarksList.assignAll(loaded);
      }
    } catch (e) {
      print('Fetch bookmarks error: $e');
    }
  }

  Future<void> fetchMyBooks() async {
    try {
      final response = await _repository.getMyBooks();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<BookModel> loaded =
            data.map((item) => BookModel.fromJson(item)).toList();
        myBooksList.assignAll(loaded);
      }
    } catch (e) {
      print('Fetch my books error: $e');
    }
  }

  Future<void> fetchMyOrders() async {
    try {
      isOrdersLoading.value = true;
      final response = await _repository.getMyOrders();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<BookOrderModel> loaded =
            data.map((item) => BookOrderModel.fromJson(item)).toList();
        myOrdersList.assignAll(loaded);
      }
    } catch (e) {
      print('Fetch orders error: $e');
    } finally {
      isOrdersLoading.value = false;
    }
  }

  Future<bool> validateCoupon(String code, double subTotal) async {
    try {
      isCouponValidating.value = true;
      couponError.value = '';
      final response = await _repository.validateCoupon(code, subTotal);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        discountAmount.value = (data['discountAmount'] as num).toDouble();
        appliedCoupon.value = CouponModel(
          id: data['couponId'],
          code: data['code'],
          discountType: '',
          discountValue: 0,
          minPurchaseAmount: 0,
          isActive: true,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        );
        return true;
      }
    } catch (e) {
      couponError.value = 'Invalid or expired coupon';
    } finally {
      isCouponValidating.value = false;
    }
    return false;
  }

  void removeCoupon() {
    appliedCoupon.value = null;
    discountAmount.value = 0.0;
    couponError.value = '';
  }

  Future<BookOrderModel?> placeOrder({
    required String bookId,
    required String format,
    required int quantity,
    String? couponCode,
    String? shippingName,
    String? shippingPhone,
    String? shippingAddress,
  }) async {
    try {
      isPlacingOrder.value = true;
      final items = [
        {'bookId': bookId, 'format': format, 'quantity': quantity}
      ];

      final response = await _repository.placeOrder(
        items: items,
        couponCode: couponCode,
        shippingName: shippingName,
        shippingPhone: shippingPhone,
        shippingAddress: shippingAddress,
      );

      if (response.statusCode == 201) {
        final order = BookOrderModel.fromJson(response.data['data']);
        fetchMyOrders();
        return order;
      }
    } catch (e) {
      AppToast.error(e.toString().replaceAll('Exception:', ''), title: 'Order Error');
    } finally {
      isPlacingOrder.value = false;
    }
    return null;
  }

  Future<Map<String, dynamic>?> downloadBookPdf(String id) async {
    try {
      isDownloading.value = true;
      final response = await _repository.downloadBookPdf(id);
      if (response.statusCode == 200) {
        return response.data['data'];
      }
    } catch (e) {
      AppToast.error('You do not have access to view this book yet. Ensure payment is marked paid.', title: 'Access Error');
    } finally {
      isDownloading.value = false;
    }
    return null;
  }

  Future<void> fetchPaymentQr() async {
    try {
      final response = await _repository.getPaymentQr();
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          paymentQrUrl.value = data['paymentQrUrl'] ?? '';
        }
      }
    } catch (e) {
      print('Fetch payment QR error: $e');
    }
  }

  Future<bool> uploadPaymentScreenshot(String orderId, String filePath) async {
    try {
      isPlacingOrder.value = true;
      final response = await _repository.uploadPaymentScreenshot(orderId, filePath);
      if (response.statusCode == 200) {
        fetchMyOrders();
        return true;
      }
    } catch (e) {
      AppToast.error(e.toString().replaceAll('Exception:', ''), title: 'Upload Error');
    } finally {
      isPlacingOrder.value = false;
    }
    return false;
  }
}

