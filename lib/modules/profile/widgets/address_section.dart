import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import './profile_fields.dart';

class AddressSection extends StatelessWidget {
  final ProfileController controller;
  const AddressSection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileTextField(
          label: 'Current Address',
          controller: controller.currentAddressController,
          hint: 'Current Address',
          maxLines: 2,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              controller.permanentAddressController.text = controller.currentAddressController.text;
            },
            child: const Text('SAME AS CURRENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
        ProfileTextField(
          label: 'Permanent Address',
          controller: controller.permanentAddressController,
          hint: 'Permanent Address',
          maxLines: 2,
        ),
        ProfileTextField(
          label: 'City',
          controller: controller.cityController,
          hint: 'City',
        ),
        ProfileTextField(
          label: 'District',
          controller: controller.districtController,
          hint: 'District',
        ),
        ProfileDropdownField(
          label: 'State',
          value: controller.selectedState.value,
          items: const ['Tamil Nadu', 'Kerala', 'Karnataka', 'Andhra Pradesh', 'Puducherry', 'Others'],
          onChanged: (val) => controller.selectedState.value = val ?? 'Tamil Nadu',
        ),
        ProfileTextField(
          label: 'PIN Code',
          controller: controller.pinCodeController,
          hint: '6-digit PIN Code',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
      ],
    ));
  }
}
