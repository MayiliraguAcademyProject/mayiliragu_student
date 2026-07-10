import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import './profile_fields.dart';

class EducationSection extends StatelessWidget {
  final ProfileController controller;
  const EducationSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileTextField(
          label: 'Highest Qualification',
          controller: controller.qualificationController,
          hint: 'Highest Qualification',
        ),
        ProfileTextField(
          label: 'Degree',
          controller: controller.degreeController,
          hint: 'Degree',
        ),
        ProfileTextField(
          label: 'College',
          controller: controller.collegeController,
          hint: 'College',
        ),
        ProfileTextField(
          label: 'Year of Passing',
          controller: controller.yearOfPassingController,
          hint: 'e.g. YYYY',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
        ),
        ProfileTextField(
          label: 'Percentage / CGPA',
          controller: controller.percentageController,
          hint: 'Percentage or CGPA',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        ProfileDropdownField(
          label: 'Medium',
          value: controller.selectedMedium.value,
          items: const ['English', 'Tamil'],
          onChanged: (val) => controller.selectedMedium.value = val ?? 'English',
        ),
      ],
    ));
  }
}
