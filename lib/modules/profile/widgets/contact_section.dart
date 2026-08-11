import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/profile_controller.dart';
import './profile_fields.dart';

class ContactSection extends StatelessWidget {
  final ProfileController controller;
  const ContactSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileTextField(
          label: 'Mobile Number',
          controller: controller.mobileController,
          hint: '10-digit Mobile',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        ProfileTextField(
          label: 'WhatsApp Number',
          controller: controller.whatsappController,
          hint: '10-digit WhatsApp number',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        ProfileTextField(
          label: 'Emergency Contact',
          controller: controller.emergencyController,
          hint: '10-digit Emergency Contact',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        ProfileTextField(
          label: 'Parent Name',
          controller: controller.parentNameController,
          hint: 'Parent / Guardian name',
        ),
        ProfileTextField(
          label: 'Parent Mobile',
          controller: controller.parentMobileController,
          hint: '10-digit parent mobile',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
      ],
    );
  }
}
