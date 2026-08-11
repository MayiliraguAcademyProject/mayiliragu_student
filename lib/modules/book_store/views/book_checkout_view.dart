import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/toast_helper.dart';
import '../controllers/book_store_controller.dart';
import '../models/book_model.dart';
import 'payment_proof_view.dart';

class BookCheckoutView extends StatefulWidget {
  final BookModel book;
  final String format;
  final int quantity;

  const BookCheckoutView({
    super.key,
    required this.book,
    required this.format,
    required this.quantity,
  });

  @override
  State<BookCheckoutView> createState() => _BookCheckoutViewState();
}

class _BookCheckoutViewState extends State<BookCheckoutView> {
  final controller = Get.find<BookStoreController>();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController(text: "Tamil Nadu");
  final _pinController = TextEditingController();
  final _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.removeCoupon();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  List<BookOrderModel> _getUniqueAddresses() {
    final Map<String, BookOrderModel> uniqueMap = {};
    for (final order in controller.myOrdersList) {
      final address = order.shippingAddress;
      final name = order.shippingName;
      final phone = order.shippingPhone;
      if (address != null &&
          address.trim().isNotEmpty &&
          name != null &&
          name.trim().isNotEmpty &&
          phone != null &&
          phone.trim().isNotEmpty) {
        final key =
            "${name.trim().toLowerCase()}_${phone.trim().toLowerCase()}_${address.trim().toLowerCase()}";
        if (!uniqueMap.containsKey(key)) {
          uniqueMap[key] = order;
        }
      }
    }
    return uniqueMap.values.toList();
  }

  void _populateAddress(BookOrderModel order) {
    _nameController.text = order.shippingName ?? '';
    _phoneController.text = order.shippingPhone ?? '';

    final addressStr = order.shippingAddress ?? '';

    try {
      // 1. Extract PIN code (6 digits at the end)
      final pinReg = RegExp(r'-\s?(\d{6})$');
      final pinMatch = pinReg.firstMatch(addressStr);
      String pin = '';
      String mainAddress = addressStr;
      if (pinMatch != null) {
        pin = pinMatch.group(1) ?? '';
        mainAddress = addressStr.substring(0, pinMatch.start).trim();
        if (mainAddress.endsWith('-')) {
          mainAddress = mainAddress.substring(0, mainAddress.length - 1).trim();
        }
      }
      _pinController.text = pin;

      // 2. Extract State (after the last remaining comma)
      final lastCommaIdx = mainAddress.lastIndexOf(',');
      String state = 'Tamil Nadu';
      if (lastCommaIdx != -1) {
        state = mainAddress.substring(lastCommaIdx + 1).trim();
        mainAddress = mainAddress.substring(0, lastCommaIdx).trim();
      }
      _stateController.text = state;

      // 3. Extract City (after the last remaining comma after extracting state)
      final cityCommaIdx = mainAddress.lastIndexOf(',');
      String city = '';
      if (cityCommaIdx != -1) {
        city = mainAddress.substring(cityCommaIdx + 1).trim();
        mainAddress = mainAddress.substring(0, cityCommaIdx).trim();
      } else {
        city = mainAddress;
        mainAddress = '';
      }
      _cityController.text = city;

      // 4. Extract Landmark and Street
      String street = '';
      String landmark = '';
      final landmarkIdx = mainAddress.indexOf(', Landmark:');
      if (landmarkIdx != -1) {
        street = mainAddress.substring(0, landmarkIdx).trim();
        landmark = mainAddress.substring(landmarkIdx + 11).trim();
      } else {
        street = mainAddress;
      }

      _streetController.text = street;
      _landmarkController.text = landmark;
    } catch (e) {
      _streetController.text = addressStr;
      _landmarkController.text = '';
      _cityController.text = '';
      _stateController.text = 'Tamil Nadu';
      _pinController.text = '';
    }
  }

  void _showSavedAddressesBottomSheet() {
    final savedAddresses = _getUniqueAddresses();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Saved Addresses",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: savedAddresses.length,
                itemBuilder: (context, index) {
                  final order = savedAddresses[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade100),
                    ),
                    color: const Color(0xFFFAF9FF),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        _populateAddress(order);
                        Get.back();
                        AppToast.success('Address pre-filled!');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.shippingName ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  order.shippingPhone ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order.shippingAddress ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  double get subTotal {
    final price = widget.format == 'HARD_COPY'
        ? (widget.book.priceHardCopy ?? 0.0)
        : (widget.book.priceSoftCopy ?? 0.0);
    return price * widget.quantity;
  }

  double get shippingCharge => widget.format == 'HARD_COPY' ? 50.0 : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product details card
              _buildProductSummary(),
              const SizedBox(height: 20),

              // Shipping Address Form (Only for Hard Copy)
              if (widget.format == 'HARD_COPY') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Delivery Address",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    if (_getUniqueAddresses().isNotEmpty)
                      TextButton(
                        onPressed: _showSavedAddressesBottomSheet,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Select from saved addresses",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandPurple,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildAddressForm(),
                const SizedBox(height: 20),
              ],

              // Coupons field
              const Text("Offers & Coupons", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              _buildCouponSection(),
              const SizedBox(height: 20),

              // Order Total details
              const Text("Payment Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              _buildPaymentSummary(),
              const SizedBox(height: 24),

              // COD note & Place Order Button
              _buildCheckoutActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(
            widget.format == 'HARD_COPY' ? Icons.menu_book : Icons.picture_as_pdf,
            color: AppColors.brandPurple,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Format: ${widget.format == 'HARD_COPY' ? 'Physical Hard Copy' : 'Digital PDF Soft Copy'}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  "Quantity: ${widget.quantity}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            "₹$subTotal",
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.brandPurple, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildInput(controller: _nameController, hint: "Full Name (e.g. John Doe)"),
          const SizedBox(height: 12),
          _buildInput(controller: _phoneController, hint: "Mobile Number", keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildInput(controller: _streetController, hint: "Flat, House no., Street address"),
          const SizedBox(height: 12),
          _buildInput(controller: _landmarkController, hint: "Landmark (optional)", isRequired: false),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInput(controller: _cityController, hint: "Town/City")),
              const SizedBox(width: 12),
              Expanded(child: _buildInput(controller: _pinController, hint: "Pincode", keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 12),
          _buildInput(controller: _stateController, hint: "State"),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (val) {
        if (isRequired && (val == null || val.trim().isEmpty)) {
          return "$hint is required";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFFAF9FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Obx(() {
        final couponApplied = controller.appliedCoupon.value != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    enabled: !couponApplied,
                    decoration: const InputDecoration(
                      hintText: "Enter Coupon Code",
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Obx(() => TextButton(
                      onPressed: controller.isCouponValidating.value
                          ? null
                          : () {
                              if (couponApplied) {
                                controller.removeCoupon();
                                _couponController.clear();
                              } else {
                                if (_couponController.text.trim().isNotEmpty) {
                                  controller.validateCoupon(_couponController.text.trim(), subTotal);
                                }
                              }
                            },
                      child: Text(
                        couponApplied ? "Remove" : "Apply",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandPurple),
                      ),
                    )),
              ],
            ),
            if (controller.couponError.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 4),
                child: Text(
                  controller.couponError.value,
                  style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            if (couponApplied)
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 4),
                child: Text(
                  "Coupon ${controller.appliedCoupon.value!.code} applied successfully! Discount: ₹${controller.discountAmount.value}",
                  style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Obx(() {
        final discount = controller.discountAmount.value;
        final total = subTotal + shippingCharge - discount;

        return Column(
          children: [
            _buildSummaryRow("Items Subtotal", "₹$subTotal"),
            if (widget.format == 'HARD_COPY') ...[
              const SizedBox(height: 10),
              _buildSummaryRow("Shipping Fee (Flat)", "₹$shippingCharge"),
            ],
            if (discount > 0) ...[
              const SizedBox(height: 10),
              _buildSummaryRow("Coupon Discount", "-₹$discount", isDiscount: true),
            ],
            const Divider(height: 20),
            _buildSummaryRow("Payable Amount", "₹$total", isTotal: true),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryRow(String label, String val, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.normal,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: FontWeight.bold,
            color: isDiscount
                ? Colors.green
                : isTotal
                    ? AppColors.brandPurple
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandPurple.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.delivery_dining, color: AppColors.brandPurple, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.format == 'HARD_COPY'
                      ? "Payment Mode: Cash on Delivery (COD)"
                      : "Pay offline at center to unlock soft copy",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isPlacingOrder.value
                      ? null
                      : () async {
                          if (widget.format == 'HARD_COPY' && !_formKey.currentState!.validate()) {
                            return;
                          }

                          final address = widget.format == 'HARD_COPY'
                              ? "${_streetController.text.trim()}, Landmark: ${_landmarkController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} - ${_pinController.text.trim()}"
                              : null;

                          final order = await controller.placeOrder(
                            bookId: widget.book.id,
                            format: widget.format,
                            quantity: widget.quantity,
                            couponCode: controller.appliedCoupon.value?.code,
                            shippingName: widget.format == 'HARD_COPY' ? _nameController.text.trim() : null,
                            shippingPhone: widget.format == 'HARD_COPY' ? _phoneController.text.trim() : null,
                            shippingAddress: address,
                          );

                          if (order != null) {
                            Get.defaultDialog(
                              title: "Order Created!",
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.format == 'HARD_COPY'
                                        ? "Would you like to pay online now via QR Code or choose Cash on Delivery?"
                                        : "Would you like to pay online now via QR Code to unlock it instantly, or pay offline later at the center?",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Get.back(); // close dialog
                                          Get.back(); // close checkout
                                          Get.back(); // close detail
                                        },
                                        child: Text(
                                          widget.format == 'HARD_COPY' ? 'COD' : 'Pay Offline',
                                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Get.back(); // close dialog
                                          Get.to(() => PaymentProofView(order: order));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.brandPurple,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Pay Online (QR)', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }

                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: controller.isPlacingOrder.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Place Order",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              )),
        ],
      ),
    );
  }
}
