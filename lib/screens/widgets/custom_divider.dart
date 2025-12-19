import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double? height;
  final double thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;

  const CustomDivider({
    super.key,
    this.height,
    this.thickness = 1,
    this.color,
    this.indent,
    this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      color: color ?? Colors.grey.shade300,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
