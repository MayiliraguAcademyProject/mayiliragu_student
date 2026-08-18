import 'package:dio/dio.dart' as dio_instance;
import '../../../core/network/api_client.dart';

class BookStoreRepository {
  final ApiClient _apiClient;

  BookStoreRepository(this._apiClient);

  Future<dio_instance.Response> getBooks({
    String? categoryId,
    String? search,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    return await _apiClient.get(
      '/books',
      queryParameters: queryParams,
    );
  }

  Future<dio_instance.Response> getBookById(String id) async {
    return await _apiClient.get('/books/$id');
  }

  Future<dio_instance.Response> toggleBookmark(String bookId) async {
    return await _apiClient.post(
      '/books/bookmark',
      data: {'bookId': bookId},
    );
  }

  Future<dio_instance.Response> getBookmarkedBooks() async {
    return await _apiClient.get('/books/bookmarks');
  }

  Future<dio_instance.Response> validateCoupon(String code, double subTotal) async {
    return await _apiClient.post(
      '/books/coupons/validate',
      data: {'code': code, 'subTotal': subTotal},
    );
  }

  Future<dio_instance.Response> placeOrder({
    required List<Map<String, dynamic>> items,
    String? couponCode,
    String? shippingName,
    String? shippingPhone,
    String? shippingAddress,
  }) async {
    return await _apiClient.post(
      '/books/orders',
      data: {
        'items': items,
        'couponCode': ?couponCode,
        'shippingName': ?shippingName,
        'shippingPhone': ?shippingPhone,
        'shippingAddress': ?shippingAddress,
      },
    );
  }

  Future<dio_instance.Response> getMyOrders() async {
    return await _apiClient.get('/books/orders/my-orders');
  }

  Future<dio_instance.Response> getMyBooks() async {
    return await _apiClient.get('/books/my-books');
  }

  /*
  Future<dio_instance.Response> downloadBookPdf(String id) async {
    return await _apiClient.get('/books/$id/read');
  }
  */

  Future<dio_instance.Response> getPaymentQr() async {
    return await _apiClient.get('/books/payment-qr');
  }

  Future<dio_instance.Response> uploadPaymentScreenshot(String orderId, String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = dio_instance.FormData.fromMap({
      'screenshot': await dio_instance.MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });
    return await _apiClient.post(
      '/books/orders/$orderId/payment-screenshot',
      data: formData,
    );
  }
}

