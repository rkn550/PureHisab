import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/utils/app_colors.dart';

class OtpInputField extends StatefulWidget {
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
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  String _previousValue = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _previousValue = widget.controller.text;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final currentValue = widget.controller.text;
    if (currentValue.isEmpty && _previousValue.isEmpty && widget.index > 0) {
      if (widget.onChanged != null) {
        widget.onChanged!('');
      }
    }
    _previousValue = currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            widget.controller.text.isEmpty &&
            widget.index > 0) {
          // Backspace pressed on empty field - trigger onChanged to move to previous
          if (widget.onChanged != null) {
            widget.onChanged!('');
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size + 10,
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: widget.index < widget.totalFields - 1
              ? TextInputAction.next
              : TextInputAction.done,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          cursorHeight: widget.fontSize - 2,
          decoration: InputDecoration(
            counterText: '',
            hintText: '0',
            hintStyle: TextStyle(
              fontSize: widget.fontSize - 6,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
          ),
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
            if (value.isNotEmpty) {
              HapticFeedback.lightImpact();
            }
            _previousValue = value;
          },
        ),
      ),
    );
  }
}
