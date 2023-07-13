import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helper/constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    this.labelText,
    this.labelStyle,
    required this.controller,
    this.hintText,
    this.hintStyle,
    this.isPassword = false,
    this.style,
    this.borderRadius,
    this.disableBorder = false,
    this.icon,
    this.onChanged,
    this.contentPadding,
  }) : super(key: key);

  final String? hintText;
  final TextStyle? hintStyle;
  final String? labelText;
  final TextStyle? labelStyle;
  final TextEditingController controller;
  final bool isPassword;
  final TextStyle? style;
  final double? borderRadius;
  final bool disableBorder;
  final Icon? icon;
  final void Function(String)? onChanged;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    return TextField(
      controller: controller,
      obscureText: isPassword,
      onChanged: onChanged,
      style: style,
      decoration: InputDecoration(
        contentPadding:contentPadding?? const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        hintText: hintText,
        hintStyle: hintStyle ?? textTheme.bodySmall,
        labelText: labelText,
        labelStyle: labelStyle ?? textTheme.bodySmall,
        isDense: true,
        alignLabelWithHint: true,
        icon: icon,
        focusedBorder:disableBorder? InputBorder.none:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? kLarge),
            borderSide: BorderSide(color: colorScheme.outline)),
        enabledBorder:disableBorder? InputBorder.none: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? kLarge),
            borderSide: BorderSide(color: colorScheme.outline.withAlpha(60))),
        errorBorder:disableBorder? InputBorder.none: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? kLarge),
            borderSide: BorderSide(color: colorScheme.error.withAlpha(140))),
        focusedErrorBorder:disableBorder? InputBorder.none: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? kLarge),
            borderSide: BorderSide(color: colorScheme.error)),
      ),
    );
  }
}
