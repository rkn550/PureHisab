import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1565C0); // Brand Blue
  static const Color primaryDark = Color(0xFF0D47A1);

  static const Color secondary = Color(0xFF00ACC1);

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF00ACC1);
  static const Color infoLight = Color(0xFFE0F7FA);

  static const Color shadow = Color(0x1A000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: .topLeft,
    end: .bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [AppColors.secondary, AppColors.primary],
    begin: .topLeft,
    end: .bottomRight,
  );

  static Color primarywithValues(double opacity) {
    return AppColors.primary.withValues(alpha: opacity);
  }

  static Color secondarywithValues(double opacity) {
    return AppColors.secondary.withValues(alpha: opacity);
  }
}
