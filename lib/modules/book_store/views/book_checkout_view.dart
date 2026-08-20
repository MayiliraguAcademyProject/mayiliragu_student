import 'package:Mayiliragu/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
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

      final lastCommaIdx = mainAddress.lastIndexOf(',');
      String state = 'Tamil Nadu';
      if (lastCommaIdx != -1) {
        state = mainAddress.substring(lastCommaIdx + 1).trim();
        mainAddress = mainAddress.substring(0, lastCommaIdx).trim();
      }
      _stateController.text = state;

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
    final colorScheme = Theme.of(context).colorScheme;
    final savedAddresses = _getUniqueAddresses();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
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
                Text(
                  AppStrings.savedAddresses,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: colorScheme.onSurface),
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
                      side: BorderSide(color: colorScheme.outline.withAlpha(50)),
                    ),
                    color: colorScheme.surfaceContainerHighest,
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  order.shippingPhone ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              order.shippingAddress ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
    return (widget.book.priceHardCopy ?? 0) * widget.quantity.toDouble();
    /*
    if (widget.format == 'HARD_COPY') {
      return (widget.book.priceHardCopy ?? 0) * widget.quantity.toDouble();
    } else {
      return (widget.book.priceSoftCopy ?? 0) * widget.quantity.toDouble();
    }
    */
  }

  double get shippingCharge => 50.0; // widget.format == 'HARD_COPY' ? 50.0 : 0.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(
          AppStrings.checkout,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductSummary(colorScheme),
              const SizedBox(height: 20),

              if (widget.format == 'HARD_COPY') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.deliveryAddress,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (_getUniqueAddresses().isNotEmpty)
                      TextButton(
                        onPressed: _showSavedAddressesBottomSheet,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          AppStrings.selectSavedAddress,
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
                _buildAddressForm(colorScheme),
                const SizedBox(height: 20),
              ],

              Text(
                AppStrings.offersAndCoupons,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              _buildCouponSection(colorScheme),
              const SizedBox(height: 20),

              Text(
                AppStrings.paymentSummary,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              _buildPaymentSummary(colorScheme),
              const SizedBox(height: 24),

              _buildCheckoutActions(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSummary(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withAlpha(50)),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Format: ${widget.format == 'HARD_COPY' ? 'Physical Hard Copy' : 'Digital PDF Soft Copy'}",
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  "Quantity: ${widget.quantity}",
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
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

  Widget _buildAddressForm(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withAlpha(50)),
      ),
      child: Column(
        children: [
          _buildInput(controller: _nameController, hint: "Full Name (e.g. John Doe)", colorScheme: colorScheme),
          const SizedBox(height: 12),
          _buildInput(controller: _phoneController, hint: "Mobile Number", keyboardType: TextInputType.phone, colorScheme: colorScheme),
          const SizedBox(height: 12),
          _buildInput(controller: _streetController, hint: "Flat, House no., Street address", colorScheme: colorScheme),
          const SizedBox(height: 12),
          _buildInput(controller: _landmarkController, hint: "Landmark (optional)", isRequired: false, colorScheme: colorScheme),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInput(controller: _cityController, hint: "Town/City", colorScheme: colorScheme)),
              const SizedBox(width: 12),
              Expanded(child: _buildInput(controller: _pinController, hint: "Pincode", keyboardType: TextInputType.number, colorScheme: colorScheme)),
            ],
          ),
          const SizedBox(height: 12),
          _buildInput(controller: _stateController, hint: "State", colorScheme: colorScheme),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required ColorScheme colorScheme,
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
        hintStyle: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
    );
  }

  Widget _buildCouponSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withAlpha(50)),
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
                    decoration: InputDecoration(
                      hintText: "Enter Coupon Code",
                      hintStyle: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
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

  Widget _buildPaymentSummary(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withAlpha(50)),
      ),
      child: Obx(() {
        final discount = controller.discountAmount.value;
        final total = subTotal + shippingCharge - discount;

        return Column(
          children: [
            _buildSummaryRow("Items Subtotal", "₹$subTotal", colorScheme: colorScheme),
            if (widget.format == 'HARD_COPY') ...[
              const SizedBox(height: 10),
              _buildSummaryRow("Shipping Fee (Flat)", "₹$shippingCharge", colorScheme: colorScheme),
            ],
            if (discount > 0) ...[
              const SizedBox(height: 10),
              _buildSummaryRow("Coupon Discount", "-₹$discount", isDiscount: true, colorScheme: colorScheme),
            ],
            Divider(height: 20, color: colorScheme.outline.withAlpha(50)),
            _buildSummaryRow("Payable Amount", "₹$total", isTotal: true, colorScheme: colorScheme),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryRow(String label, String val, {required ColorScheme colorScheme, bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.normal,
            color: isTotal ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
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
                    : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutActions(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandPurple.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.15)),
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
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => CommonButton(
                text: widget.format == 'HARD_COPY' ? 'Place Order (COD)' : 'Place Order & Pay',
                isLoading: controller.isPlacingOrder.value,
                onPressed: () async {
                  if (widget.format == 'HARD_COPY') {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                  }
                  
                  final order = await controller.placeOrder(
                    bookId: widget.book.id,
                    format: widget.format,
                    quantity: widget.quantity,
                    couponCode: controller.appliedCoupon.value?.code,
                    shippingName: widget.format == 'HARD_COPY' ? _nameController.text.trim() : null,
                    shippingPhone: widget.format == 'HARD_COPY' ? _phoneController.text.trim() : null,
                    shippingAddress: widget.format == 'HARD_COPY'
                        ? "${_streetController.text.trim()}, ${_landmarkController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} - ${_pinController.text.trim()}"
                        : null,
                  );

                  if (order != null) {
                    if (widget.format == 'HARD_COPY') {
                      Get.back(); // Go back from checkout screen
                      AppToast.success('Order placed successfully! Cash on Delivery.');
                    } else {
                      Get.off(() => PaymentProofView(order: order)); // Replace checkout with proof upload
                    }
                  }
                },
                backgroundColor: AppColors.brandPurple,
                foregroundColor: Colors.white,
              )),
        ],
      ),
    );
  }
}
