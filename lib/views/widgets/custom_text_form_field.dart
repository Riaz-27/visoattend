import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helper/constants.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    Key? key,
    this.labelText,
    this.labelStyle,
    required this.controller,
    this.hintText,
    this.hintStyle,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.style,
    this.borderRadius,
    this.disableBorder = false,
    this.icon,
    this.onChanged,
    this.validator,
    this.contentPadding,
    this.fillColor,
    this.focusNode,
    this.onSubmitted,
    this.onTap,
    this.maxLength, this.maxLines,
  }) : super(key: key);

  final String? hintText;
  final TextStyle? hintStyle;
  final String? labelText;
  final TextStyle? labelStyle;
  final TextEditingController controller;
  final bool isPassword;
  final bool enabled;
  final bool readOnly;
  final TextStyle? style;
  final double? borderRadius;
  final bool disableBorder;
  final Icon? icon;
  final int? maxLength;
  final int? maxLines;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final FocusNode? focusNode;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      style: enabled
          ? style
          : textTheme.bodyMedium!
              .copyWith(color: colorScheme.onBackground.withOpacity(0.6)),
      enabled: enabled,
      readOnly: readOnly,
      focusNode: focusNode,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        filled: fillColor == null ? false : true,
        fillColor: fillColor,
        hintText: hintText,
        hintStyle: hintStyle ?? textTheme.titleSmall,
        labelText: labelText,
        labelStyle: labelStyle ?? textTheme.titleSmall,
        isDense: true,
        alignLabelWithHint: true,
        icon: icon,
        disabledBorder: disableBorder
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? kLarge),
                borderSide:
                    BorderSide(color: colorScheme.outline.withAlpha(60))),
        focusedBorder: disableBorder
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? kLarge),
                borderSide: BorderSide(color: colorScheme.outline)),
        enabledBorder: disableBorder
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? kLarge),
                borderSide:
                    BorderSide(color: colorScheme.outline.withAlpha(60))),
        errorBorder: disableBorder
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? kLarge),
                borderSide:
                    BorderSide(color: colorScheme.error.withAlpha(140))),
        focusedErrorBorder: disableBorder
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? kLarge),
                borderSide: BorderSide(color: colorScheme.error)),
      ),
    );
  }
}
