import '../../study_materials/models/study_material_models.dart';

class BookModel {
  final String id;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final List<String> images;
  final String? author;
  final String? publisher;
  final double? priceHardCopy;
  final double? priceSoftCopy;
  final int stockHardCopy;
  final String? pdfUrl;
  final String categoryId;
  final bool isActive;
  final bool isBookmarked;
  final MaterialCategory? category;

  BookModel({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    required this.images,
    this.author,
    this.publisher,
    this.priceHardCopy,
    this.priceSoftCopy,
    required this.stockHardCopy,
    this.pdfUrl,
    required this.categoryId,
    required this.isActive,
    this.isBookmarked = false,
    this.category,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      author: json['author'],
      publisher: json['publisher'],
      priceHardCopy: json['priceHardCopy'] != null ? (json['priceHardCopy'] as num).toDouble() : null,
      priceSoftCopy: json['priceSoftCopy'] != null ? (json['priceSoftCopy'] as num).toDouble() : null,
      stockHardCopy: json['stockHardCopy'] ?? 0,
      pdfUrl: json['pdfUrl'],
      categoryId: json['categoryId'] ?? '',
      isActive: json['isActive'] ?? true,
      isBookmarked: json['isBookmarked'] ?? false,
      category: json['category'] != null ? MaterialCategory.fromJson(json['category']) : null,
    );
  }
}

class CouponModel {
  final String id;
  final String code;
  final String discountType; // PERCENTAGE or FLAT
  final double discountValue;
  final double minPurchaseAmount;
  final double? maxDiscountAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minPurchaseAmount,
    this.maxDiscountAmount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      discountType: json['discountType'] ?? 'PERCENTAGE',
      discountValue: (json['discountValue'] as num).toDouble(),
      minPurchaseAmount: (json['minPurchaseAmount'] as num).toDouble(),
      maxDiscountAmount: json['maxDiscountAmount'] != null ? (json['maxDiscountAmount'] as num).toDouble() : null,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? true,
    );
  }
}

class BookOrderItemModel {
  final String id;
  final String orderId;
  final String bookId;
  final String format; // HARD_COPY or SOFT_COPY
  final double price;
  final int quantity;
  final BookModel? book;

  BookOrderItemModel({
    required this.id,
    required this.orderId,
    required this.bookId,
    required this.format,
    required this.price,
    required this.quantity,
    this.book,
  });

  factory BookOrderItemModel.fromJson(Map<String, dynamic> json) {
    return BookOrderItemModel(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      bookId: json['bookId'] ?? '',
      format: json['format'] ?? 'HARD_COPY',
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
      book: json['book'] != null ? BookModel.fromJson(json['book']) : null,
    );
  }
}

class BookOrderModel {
  final String id;
  final String studentId;
  final String? couponId;
  final DateTime orderDate;
  final double subTotal;
  final double shippingCharge;
  final double discountAmount;
  final double payableAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String? shippingName;
  final String? shippingPhone;
  final String? shippingAddress;
  final String? paymentScreenshotUrl;
  final List<BookOrderItemModel>? items;
  final CouponModel? coupon;

  BookOrderModel({
    required this.id,
    required this.studentId,
    this.couponId,
    required this.orderDate,
    required this.subTotal,
    required this.shippingCharge,
    required this.discountAmount,
    required this.payableAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.shippingName,
    this.shippingPhone,
    this.shippingAddress,
    this.paymentScreenshotUrl,
    this.items,
    this.coupon,
  });

  factory BookOrderModel.fromJson(Map<String, dynamic> json) {
    return BookOrderModel(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      couponId: json['couponId'],
      orderDate: DateTime.parse(json['orderDate']),
      subTotal: (json['subTotal'] as num).toDouble(),
      shippingCharge: (json['shippingCharge'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      payableAmount: (json['payableAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'COD',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      orderStatus: json['orderStatus'] ?? 'PENDING',
      shippingName: json['shippingName'],
      shippingPhone: json['shippingPhone'],
      shippingAddress: json['shippingAddress'],
      paymentScreenshotUrl: json['paymentScreenshotUrl'],
      items: json['items'] != null
          ? (json['items'] as List).map((i) => BookOrderItemModel.fromJson(i)).toList()
          : null,
      coupon: json['coupon'] != null ? CouponModel.fromJson(json['coupon']) : null,
    );
  }
}

