import 'package:flutter/material.dart';
import '../../app/utils/app_colors.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;
  final double strokeWidth;

  const CustomLoadingIndicator({
    super.key,
    this.color,
    this.size,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      strokeWidth: strokeWidth,
    );

    if (size != null) {
      return SizedBox(width: size, height: size, child: indicator);
    }

    return indicator;
  }
}

class CustomLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? overlayColor;

  const CustomLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (overlayColor ?? Colors.black).withValues(alpha: 0.3),
            child: const Center(child: CustomLoadingIndicator()),
          ),
      ],
    );
  }
}
