import 'package:flutter/material.dart';
import '../../app/utils/app_colors.dart';

class IconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final double iconSize;
  final double fontSize;
  final FontWeight? fontWeight;
  final MainAxisAlignment alignment;
  final double spacing;

  const IconTextWidget({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.iconSize = 20,
    this.fontSize = 14,
    this.fontWeight,
    this.alignment = MainAxisAlignment.start,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor ?? AppColors.primary, size: iconSize),
        SizedBox(width: spacing),
        Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.black87,
            fontSize: fontSize,
            fontWeight: fontWeight ?? FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
