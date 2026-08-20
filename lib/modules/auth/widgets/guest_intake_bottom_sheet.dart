import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/common_button.dart';

class GuestIntakeBottomSheet extends StatefulWidget {
  final Future<void> Function({
    required String name,
    required String phoneNumber,
    required String place,
    required String targetCourse,
    required String studyMode,
  }) onSubmit;

  const GuestIntakeBottomSheet({
    super.key,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required String name,
      required String phoneNumber,
      required String place,
      required String targetCourse,
      required String studyMode,
    }) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GuestIntakeBottomSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<GuestIntakeBottomSheet> createState() => _GuestIntakeBottomSheetState();
}

class _GuestIntakeBottomSheetState extends State<GuestIntakeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _placeController = TextEditingController();
  final _courseController = TextEditingController();

  String _selectedStudyMode = 'ONLINE';
  bool _isSubmitting = false;
  String _errorMessage = '';

  final List<String> _suggestedCourses = [
    'TNPSC Group 4',
    'TNPSC Group 2',
    'Police SI',
    'Police Constable',
    'Banking',
    'VAO',
    'TET / TRB',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _placeController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      await widget.onSubmit(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        place: _placeController.text.trim(),
        targetCourse: _courseController.text.trim(),
        studyMode: _selectedStudyMode,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBgDark : AppColors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Close Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Guest Explorer',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Help us personalize your study experience',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_errorMessage.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(fontSize: 12, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 1. Full Name
              _buildLabel('Full Name', isRequired: true, isDark: isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 2. Phone Number
              _buildLabel('Phone Number', isRequired: true, isDark: isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: _inputDecoration(
                  hint: '10-digit mobile number',
                  prefixIcon: Icons.phone_android_rounded,
                  prefixText: '+91 ',
                  isDark: isDark,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.trim().length != 10) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 3. Place / Location
              _buildLabel('Place / District', isRequired: true, isDark: isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _placeController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  hint: 'e.g. Karur, Trichy, Chennai',
                  prefixIcon: Icons.location_on_outlined,
                  isDark: isDark,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your city/place';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 4. Interested Course
              _buildLabel('Which Course Are You Interested In?', isRequired: true, isDark: isDark),
              const SizedBox(height: 6),
              TextFormField(
                controller: _courseController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  hint: 'e.g. TNPSC Group 4',
                  prefixIcon: Icons.school_outlined,
                  isDark: isDark,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter or select a course';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Quick Course Suggestion Chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _suggestedCourses.map((c) {
                  final isSelected = _courseController.text == c;
                  return ChoiceChip(
                    label: Text(
                      c,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
                    onSelected: (selected) {
                      setState(() {
                        _courseController.text = selected ? c : '';
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 5. Mode of Study
              _buildLabel('Mode of Study', isRequired: true, isDark: isDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStudyModeCard(
                      mode: 'ONLINE',
                      title: '🌐 Online Class',
                      subtitle: 'Learn via App videos & tests',
                      isSelected: _selectedStudyMode == 'ONLINE',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStudyModeCard(
                      mode: 'OFFLINE',
                      title: '🏛️ Offline Academy',
                      subtitle: 'Classroom batch in Karur',
                      isSelected: _selectedStudyMode == 'OFFLINE',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              CommonButton(
                text: 'Start Exploring Now',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleSubmit,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                borderRadius: 14,
                height: 50,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, {required bool isRequired, required bool isDark}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ]
            : [],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    String? prefixText,
    required bool isDark,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? AppColors.borderDark : AppColors.border,
      ),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13,
        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF94A3B8),
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 20,
        color: isDark ? AppColors.textSecondaryDark : AppColors.primary,
      ),
      prefixText: prefixText,
      prefixStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _buildStudyModeCard({
    required String mode,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStudyMode = mode;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
