import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helper/constants.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.validator,
  }) : super(key: key);

  final String? hintText;
  final String labelText;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        hintText: hintText,
        labelText: labelText,
        labelStyle: Get.textTheme.titleSmall,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kLarge),
          borderSide: BorderSide(color: Get.theme.colorScheme.outline)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kLarge),
            borderSide: BorderSide(color: Get.theme.colorScheme.outline.withAlpha(60))
        ),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kLarge),
            borderSide: BorderSide(color: Get.theme.colorScheme.outline.withAlpha(60))
        ),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kLarge),
            borderSide: BorderSide(color: Get.theme.colorScheme.outline)
        ),
      ),
    );
  }
}
