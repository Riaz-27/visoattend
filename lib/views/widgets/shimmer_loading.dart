import 'package:flutter/material.dart';

import '../../helper/constants.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    this.margin,
    this.height,
    this.width,
    this.radius,
    this.color,
  });

  final EdgeInsets? margin;
  final double? height, width, radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width ?? 100,
      height: height ?? 15,
      decoration: BoxDecoration(
        color: color?? loadColor,
        borderRadius: BorderRadius.circular(radius??15),
      ),
    );
  }
}
