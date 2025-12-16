import 'package:flutter/material.dart';
import '../../app/utils/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextAlign textAlign;
  final double titleFontSize;
  final double subtitleFontSize;
  final Color? titleColor;
  final Color? subtitleColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.textAlign = TextAlign.center,
    this.titleFontSize = 28,
    this.subtitleFontSize = 16,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: titleColor ?? AppColors.textPrimary,
          ),
          textAlign: textAlign,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: subtitleColor ?? AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}
