import 'package:flutter/material.dart';

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
    this.onChanged,
    this.validator,
    this.focusNode,
    this.readOnly = false,
    this.onSubmitted,
    this.onTap,
    this.maxLength,
    this.maxLines, this.borderRadius,
  });

  final TextEditingController controller;
  final String title;
  final bool isPassword;
  final bool enableTextField;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool readOnly;
  final int? maxLength;
  final int? maxLines;
  final double? borderRadius;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {

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
                .copyWith(color: textColorLight),
          ),
        ),
        verticalGap(deviceHeight * percentGapVerySmall),
        CustomTextFormField(
          controller: controller,
          enabled: enableTextField,
          onChanged: onChanged,
          readOnly: readOnly,
          validator: validator,
          focusNode: focusNode,
          onSubmitted: onSubmitted,
          onTap: onTap,
          maxLength: maxLength,
          maxLines: maxLines??1,
          borderRadius: borderRadius,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          style: textTheme.bodyMedium!.copyWith(color: textColorDefault),
          isPassword: isPassword,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
        ),
      ],
    );
  }
}
