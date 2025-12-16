import 'package:flutter/material.dart';
import '../../app/utils/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final String? logoPath;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primaryWithOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            logoPath ?? 'assets/images/pure_hisab_logo.png',
            fit: BoxFit.contain,
            color: AppColors.primaryDark,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          const Text(
            'PureHisab',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
