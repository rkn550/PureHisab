import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/utils/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final Color? backgroundColor;
  final double borderRadius;
  final RxString? searchQuery; // Optional reactive string

  const CustomSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.backgroundColor,
    this.borderRadius = 8,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final textController = controller ?? TextEditingController();

    // If searchQuery is provided, sync it with controller
    if (searchQuery != null && controller == null) {
      textController.text = searchQuery!.value;
    }

    return Obx(() {
      final hasText = searchQuery != null
          ? searchQuery!.value.isNotEmpty
          : textController.text.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: TextField(
          controller: textController,
          focusNode: focusNode,
          onChanged: (value) {
            if (searchQuery != null) {
              searchQuery!.value = value;
            }
            onChanged?.call(value);
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            prefixIcon: hasText && onClear != null
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      textController.clear();
                      if (searchQuery != null) {
                        searchQuery!.value = '';
                      }
                      onClear?.call();
                    },
                  )
                : Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      );
    });
  }
}
