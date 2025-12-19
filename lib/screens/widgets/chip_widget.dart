import 'package:flutter/material.dart';
import '../../app/utils/app_colors.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? deleteIcon;
  final bool selected;
  final VoidCallback? onTap;

  const CustomChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.backgroundColor,
    this.textColor,
    this.deleteIcon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: textColor ?? (selected ? Colors.white : Colors.black87),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor:
            backgroundColor ??
            (selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.1)),
        deleteIcon: onDeleted != null
            ? Icon(
                deleteIcon ?? Icons.close,
                size: 18,
                color: textColor ?? (selected ? Colors.white : Colors.black87),
              )
            : null,
        onDeleted: onDeleted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: selected
              ? BorderSide.none
              : BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
        ),
      ),
    );
  }
}
