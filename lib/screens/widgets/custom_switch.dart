import 'package:flutter/material.dart';
import '../../app/utils/app_colors.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? label;
  final String? subtitle;

  const CustomSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.label,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final switchWidget = Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? AppColors.success,
      activeTrackColor: (activeColor ?? AppColors.success).withValues(
        alpha: 0.5,
      ),
      inactiveThumbColor: inactiveColor ?? Colors.grey.shade400,
      inactiveTrackColor: Colors.grey.shade300,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    if (label == null) {
      return switchWidget;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
        switchWidget,
      ],
    );
  }
}
