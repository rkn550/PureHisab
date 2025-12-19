import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/utils/app_colors.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int index;
  final int totalFields;
  final ValueChanged<String>? onChanged;
  final bool isFilled;
  final double size;
  final double fontSize;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.index,
    this.totalFields = 6,
    this.onChanged,
    this.isFilled = false,
    this.size = 50,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size + 10,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: .center,
        keyboardType: TextInputType.number,
        textInputAction: index < totalFields - 1
            ? TextInputAction.next
            : TextInputAction.done,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: .bold,
          color: AppColors.textPrimary,
        ),
        cursorHeight: fontSize - 2,
        decoration: InputDecoration(
          counterText: '',
          hintText: '0',
          hintStyle: TextStyle(
            fontSize: fontSize - 6,
            fontWeight: .w500,
            color: AppColors.textSecondary,
          ),
          contentPadding: .zero,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: .circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: .circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: .circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: .circular(8),
            borderSide: BorderSide(color: AppColors.error, width: 1),
          ),
        ),
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
          }
          if (value.isNotEmpty) {
            HapticFeedback.lightImpact();
          }
        },
      ),
    );
  }
}
