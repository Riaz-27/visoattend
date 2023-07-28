import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.fontWeight,
    required this.text,
    required this.onPressed,
    this.onLongPressed,
  });

  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final FontWeight? fontWeight;
  final String text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    return SizedBox(
      width: width ?? Get.width,
      height: height ?? Get.height * 0.06,
      child: ElevatedButton(
        onLongPress: onLongPressed,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor ?? colorScheme.secondary,
        ),
        child: Text(
          text,
          style:textStyle?? textTheme.bodyLarge!.copyWith(
            color: textColor ?? colorScheme.surface,
          ),
        ),
      ),
    );
  }
}
