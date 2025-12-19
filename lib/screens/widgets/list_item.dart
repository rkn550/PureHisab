import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final IconData? leadingIcon;
  final Widget? leading;
  final Widget? trailingWidget;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool showDivider;

  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.leading,
    this.trailingWidget,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.padding,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: showDivider
              ? Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                )
              : null,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 16),
            ] else if (leadingIcon != null) ...[
              Icon(leadingIcon, color: Colors.grey.shade700, size: 24),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  if (subtitle != null) const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? Colors.black87,
                      fontSize: subtitle != null ? 16 : 15,
                      fontWeight: subtitle != null
                          ? FontWeight.normal
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget!
            else if (trailing != null)
              Text(
                trailing!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              )
            else if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
