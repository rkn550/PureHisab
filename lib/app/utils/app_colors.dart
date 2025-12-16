import 'package:flutter/material.dart';

/// App Color Palette
/// Professional and modern colors for PureHisab financial app
class AppColors {
  // Primary Colors - Brand Blue (Deep, confident blue)
  static const Color primary = Color(0xFF1565C0); // Brand Blue
  static const Color primaryDark = Color(
    0xFF0D47A1,
  ); // Dark variant for headers, navbars, icons

  // Secondary Colors - Aqua Accent
  static const Color secondary = Color(
    0xFF00ACC1,
  ); // Aqua accent for highlights, charts, CTAs

  // Background Colors
  static const Color background = Color(
    0xFFF5F7FA,
  ); // Soft professional grey (fintech standard)
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // Clean, modern cards/surfaces

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E1E); // Sharp and readable
  static const Color textSecondary = Color(
    0xFF616161,
  ); // Subtle and professional
  static const Color textWhite = Color(0xFFFFFFFF); // White text

  // Border & Divider Colors
  static const Color border = Color(0xFFE0E0E0); // Divider/Border color
  static const Color divider = Color(0xFFE0E0E0); // Divider color

  // Status Colors (keeping for consistency)
  static const Color success = Color(0xFF10B981); // Green
  static const Color successLight = Color(0xFFD1FAE5); // Light Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFFEE2E2); // Light Red
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color warningLight = Color(0xFFFEF3C7); // Light Orange
  static const Color info = Color(0xFF00ACC1); // Aqua (using secondary)
  static const Color infoLight = Color(0xFFE0F7FA); // Light Aqua

  // Shadow Colors
  static const Color shadow = Color(0x1A000000); // Black with 10% opacity

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00ACC1), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Helper method to get primary color with opacity
  static Color primaryWithOpacity(double opacity) {
    return primary.withValues(alpha: opacity);
  }

  // Helper method to get secondary color with opacity
  static Color secondaryWithOpacity(double opacity) {
    return secondary.withValues(alpha: opacity);
  }
}
