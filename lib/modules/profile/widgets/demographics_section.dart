import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import './profile_fields.dart';

class DemographicsSection extends StatelessWidget {
  final ProfileController controller;
  const DemographicsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileDropdownField(
          label: 'Gender',
          value: controller.selectedGender.value.isEmpty ? null : controller.selectedGender.value,
          items: const ['Male', 'Female', 'Other'],
          onChanged: (val) => controller.selectedGender.value = val ?? '',
        ),
        ProfileDatePickerField(
          label: 'Date of Birth',
          controller: controller.dobController,
        ),
        ProfileTextField(
          label: 'Blood Group',
          controller: controller.bloodGroupController,
          hint: 'e.g. O+ve',
        ),
        ProfileTextField(
          label: 'Aadhaar Number',
          controller: controller.aadhaarController,
          hint: '12-digit Aadhaar Number',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
        ),
        ProfileTextField(
          label: 'Nationality',
          controller: controller.nationalityController,
          hint: 'e.g. Indian',
        ),
        ProfileDropdownField(
          label: 'Category',
          value: controller.selectedCategory.value,
          items: const ['General', 'Others'],
          onChanged: (val) => controller.selectedCategory.value = val ?? 'General',
        ),
      ],
    ));
  }
}
