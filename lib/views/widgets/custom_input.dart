import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/constants.dart';
import '../../helper/functions.dart';
import 'custom_text_form_field.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    required this.controller,
    required this.title,
    this.isPassword = false,
    this.enableTextField = true,
  });

  final TextEditingController controller;
  final String title;
  final bool isPassword;
  final bool enableTextField;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final height = Get.height;
    final width = Get.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            title,
            style: textTheme.bodyMedium!
                .copyWith(color: textTheme.bodySmall!.color),
          ),
        ),
        verticalGap(height * percentGapVerySmall),
        CustomTextFormField(
          controller: controller,
          enabled: enableTextField,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          style: textTheme.bodyMedium,
          isPassword: isPassword,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
        ),
      ],
    );
  }
}
