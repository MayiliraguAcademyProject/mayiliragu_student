import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/pdf_viewer_screen.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/toast_helper.dart';
import '../../../../core/controllers/user_session_controller.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/common_button.dart';
import '../../dashboard/models/dashboard_model.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/payment_controller.dart';

class BannerProductDetailView extends StatefulWidget {
  final BannerModel banner;

  const BannerProductDetailView({super.key, required this.banner});

  @override
  State<BannerProductDetailView> createState() =>
      _BannerProductDetailViewState();
}

class _BannerProductDetailViewState extends State<BannerProductDetailView> {
  final _paymentController = Get.find<PaymentController>();
  final _dashboardController = Get.find<DashboardController>();
  Timer? _countdownTimer;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    final offerValidUntil = widget.banner.offerValidUntil;
    if (offerValidUntil == null) return;

    _updateCountdown(offerValidUntil);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCountdown(offerValidUntil);
      } else {
        timer.cancel();
      }
    });
  }

  void _updateCountdown(DateTime target) {
    final now = DateTime.now();
    if (now.isAfter(target)) {
      _countdownTimer?.cancel();
      setState(() {
        _countdownText = '';
      });
      return;
    }

    final diff = target.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    setState(() {
      if (days > 0) {
        _countdownText =
            'Offer ends in ${days}d ${hours}h ${minutes}m ${seconds}s';
      } else if (hours > 0) {
        _countdownText = 'Offer ends in ${hours}h ${minutes}m ${seconds}s';
      } else if (minutes > 0) {
        _countdownText = 'Offer ends in ${minutes}m ${seconds}s';
      } else {
        _countdownText = 'Offer ends in ${seconds}s';
      }
    });
  }

  bool get _isOfferActive {
    final offerPrice = widget.banner.offerPrice;
    final offerValidUntil = widget.banner.offerValidUntil;
    if (offerPrice == null) return false;
    if (offerValidUntil == null) return true;
    return offerValidUntil.isAfter(DateTime.now());
  }

  Future<void> _loadData() async {
    final futures = <Future>[];
    if (widget.banner.linkType != null && widget.banner.linkId != null) {
      futures.add(
        _paymentController.checkExistingRequest(
          widget.banner.linkType!,
          widget.banner.linkId!,
        ),
      );
    }
    futures.add(_paymentController.fetchPaymentSettings());
    futures.add(_dashboardController.fetchDashboardData());
    if (Get.isRegistered<UserSessionController>()) {
      futures.add(Get.find<UserSessionController>().loadSession());
    }

    await Future.wait(futures);
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isEnrolled {
    final linkType = widget.banner.linkType;
    final linkId = widget.banner.linkId;

    // 1. Direct approved payment request check for this banner product
    final req = _paymentController.existingRequest.value;
    if (req != null && req.status == 'APPROVED') {
      return true;
    }

    // 2. Course enrollment check
    if (linkType == 'COURSE') {
      final enrolledList =
          _dashboardController.dashboardData.value?.enrolledCourses ?? [];
      final allCourses =
          _dashboardController.dashboardData.value?.allCourses ?? [];
      if (enrolledList.any((c) => c.id == linkId && c.isEnrolled)) return true;
      if (allCourses.any((c) => c.id == linkId && c.isEnrolled)) return true;
    } else if (linkType == 'TEST') {
      // 3. Test / Premium enrollment check
      if (Get.isRegistered<UserSessionController>()) {
        if (Get.find<UserSessionController>().isPremium.value) return true;
      }
    }
    return false;
  }

  void _openSyllabusPdf(String? pdfUrl) {
    if (pdfUrl == null || pdfUrl.trim().isEmpty) {
      AppToast.error('Syllabus PDF file is not available.');
      return;
    }

    Get.to(
      () => PdfViewerScreen(
        pdfUrl: pdfUrl,
        title: widget.banner.curriculumPdfName ?? 'Syllabus - ${widget.banner.title}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final banner = widget.banner;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          banner.linkType == 'COURSE' ? 'Course Batch' : 'Test Batch',
          style: AppTextStyles.subheading.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Banner Image
                    if (banner.imageUrl.isNotEmpty)
                      CustomNetworkImage(
                        imageUrl: banner.imageUrl,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            banner.title,
                            style: AppTextStyles.heading.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Badges Row (Price & Validity)
                          Row(
                            children: [
                              if (_isOfferActive) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.green.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '₹',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        banner.offerPrice!.toStringAsFixed(0),
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (banner.price != null)
                                  Text(
                                    '₹${banner.price!.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ] else if (banner.price != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '₹',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        banner.price!.toStringAsFixed(0),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(width: 12),
                              if (banner.validityDays != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[900]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black12,
                                    ),
                                  ),
                                  child: Text(
                                    '${banner.validityDays} Days Validity',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          if (_countdownText.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _countdownText,
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Plan Description section
                          if (banner.planDescription != null &&
                              banner.planDescription!.isNotEmpty) ...[
                            Text(
                              'Plan Description',
                              style: AppTextStyles.subheading.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner.planDescription!,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // What You Get / Syllabus Section (PDF & Curriculum)
                          if ((banner.curriculumPdfUrl != null &&
                                  banner.curriculumPdfUrl!.trim().isNotEmpty) ||
                              (banner.curriculumJson != null &&
                                  banner.curriculumJson!.isNotEmpty)) ...[
                            Obx(() {
                              final enrolled = _isEnrolled;
                              final hasPdf =
                                  banner.curriculumPdfUrl != null &&
                                  banner.curriculumPdfUrl!.trim().isNotEmpty;
                              final hasCurriculumList =
                                  banner.curriculumJson != null &&
                                  banner.curriculumJson!.isNotEmpty;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'What You Get / Syllabus',
                                        style: AppTextStyles.subheading
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimary,
                                            ),
                                      ),
                                      if (!enrolled)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.lock_outline_rounded,
                                              size: 14,
                                              color: isDark
                                                  ? Colors.grey[500]
                                                  : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Locked',
                                              style: AppTextStyles.body
                                                  .copyWith(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark
                                                        ? Colors.grey[500]
                                                        : Colors.grey[600],
                                                  ),
                                            ),
                                          ],
                                        )
                                      else
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.lock_open_rounded,
                                              size: 14,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Unlocked',
                                              style: AppTextStyles.body
                                                  .copyWith(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (!enrolled)
                                    GestureDetector(
                                      onTap: () {
                                        AppToast.validation(
                                          'Purchase this plan to unlock the complete syllabus & curriculum.',
                                          title: 'Syllabus Locked',
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.grey[900]
                                              : Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white10
                                                : Colors.black12,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.lock_outline_rounded,
                                              size: 32,
                                              color: isDark
                                                  ? Colors.grey[600]
                                                  : Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              hasPdf
                                                  ? 'Official Syllabus PDF is Locked'
                                                  : 'Curriculum is Locked',
                                              style: AppTextStyles.subheading
                                                  .copyWith(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark
                                                        ? AppColors
                                                              .textPrimaryDark
                                                        : AppColors.textPrimary,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Purchase this plan to unlock and download the complete syllabus.',
                                              style: AppTextStyles.body
                                                  .copyWith(
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? Colors.white60
                                                        : Colors.black54,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else ...[
                                    // Unlocked PDF Card
                                    if (hasPdf) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white12
                                                : Colors.black12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(
                                                  alpha: 0.12,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.picture_as_pdf_rounded,
                                                color: Colors.red,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    banner.curriculumPdfName ??
                                                        'Course_Syllabus.pdf',
                                                    style: AppTextStyles
                                                        .subheading
                                                        .copyWith(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isDark
                                                              ? AppColors
                                                                    .textPrimaryDark
                                                              : AppColors
                                                                    .textPrimary,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Official Syllabus & Schedule Document',
                                                    style: AppTextStyles.body
                                                        .copyWith(
                                                          fontSize: 11,
                                                          color: isDark
                                                              ? Colors.white60
                                                              : Colors.black54,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton.icon(
                                              onPressed: () => _openSyllabusPdf(
                                                banner.curriculumPdfUrl,
                                              ),
                                              icon: const Icon(
                                                Icons.remove_red_eye_outlined,
                                                size: 15,
                                              ),
                                              label: const Text(
                                                'View PDF',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                elevation: 0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (hasCurriculumList)
                                        const SizedBox(height: 14),
                                    ],

                                    // Fallback / Supplementary List items
                                    if (hasCurriculumList)
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            banner.curriculumJson!.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final item =
                                              banner.curriculumJson![index];
                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  top: 2,
                                                ),
                                                child: const Icon(
                                                  Icons
                                                      .check_circle_outline_rounded,
                                                  color: Colors.green,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  item,
                                                  style: AppTextStyles.body.copyWith(
                                                    fontSize: 13,
                                                    color: isDark
                                                        ? AppColors
                                                              .textSecondaryDark
                                                        : AppColors
                                                              .textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                  ],
                                ],
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Obx(() {
            final isRequestLoading = _paymentController.isLoadingExisting.value;
            final req = _paymentController.existingRequest.value;
            final enrolled = _isEnrolled;

            String buttonText = 'Buy Now';
            Widget? buttonIcon;
            VoidCallback? buttonAction;
            Color buttonColor = AppColors.primary;
            bool isBtnEnabled = true;

            if (enrolled) {
              buttonText = banner.linkType == 'COURSE'
                  ? 'Access Course (Enrolled)'
                  : 'Access Tests (Enrolled)';
              buttonIcon = const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              );
              buttonAction = () {
                if (banner.linkType == 'COURSE') {
                  Get.back();
                  if (Get.isRegistered<DashboardController>()) {
                    Get.find<DashboardController>().changeTab(1);
                  }
                } else {
                  Get.back();
                  Get.toNamed(Routes.TEST_SECTIONS);
                }
              };
              buttonColor = Colors.green;
              isBtnEnabled = true;
            } else if (req != null && req.status == 'PENDING') {
              buttonText = 'Payment Pending Review';
              buttonIcon = const Icon(
                Icons.pending_actions_rounded,
                color: Colors.white,
                size: 20,
              );
              buttonAction = null;
              buttonColor = Colors.orange;
              isBtnEnabled = false;
            } else {
              String label = 'Buy Now';
              if (req != null && req.status == 'REJECTED') {
                label = 'Payment Rejected (Retry Checkout)';
              }
              buttonText = label;

              final isLinkValid =
                  widget.banner.linkType != null &&
                  widget.banner.linkId != null;
              buttonAction = () {
                if (!isLinkValid) {
                  AppToast.error(
                    'This product is not available for purchase (missing link configuration).',
                  );
                } else {
                  Get.toNamed(Routes.PAYMENT_QR, arguments: widget.banner);
                }
              };
            }

            return SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardBgDark : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black12,
                      width: 0.5,
                    ),
                  ),
                ),
                child: CommonButton(
                  text: buttonText,
                  icon: buttonIcon,
                  isLoading: isRequestLoading,
                  onPressed: isBtnEnabled ? buttonAction : null,
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  height: 52,
                  borderRadius: 16,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
