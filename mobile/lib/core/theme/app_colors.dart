import 'package:flutter/material.dart';

/// Light theme aligned with project-morpheus website :root (white background, shiny blue primary).
class AppColors {
  AppColors._();

  // Background & surface (light mode — project-morpheus default)
  static const Color background = Color(0xFFFFFFFF);
  static const Color card = Color(0xCCFFFFFF); // rgba(255,255,255,0.8)
  static const Color cardBorder = Color(0x140A0A0A); // rgba(0,0,0,0.08)
  static const Color surface = Color(0xFFF5F5F5);

  // Foreground (dark text on light)
  static const Color foreground = Color(0xFF0A0A0A);
  static const Color foregroundMuted = Color(0xE60A0A0A); // ~90%
  static const Color foregroundFaded = Color(0x800A0A0A);  // ~50%
  static const Color foregroundDim = Color(0x660A0A0A);   // ~40%

  // Primary — shiny blue (website --shiny-blue)
  static const Color primary = Color(0xFF0A7FFF);
  static const Color primaryLight = Color(0xFF1A8FFF);
  static const Color primaryDark = Color(0xFF0966D9);

  // Legacy aliases for compatibility
  static const Color void_ = background;
  static const Color obsidian = surface;
  static const Color ash = Color(0xFFE0E0E0);
  static const Color mercury = foreground;
  static const Color smog = foregroundDim;
  static const Color ember = primary;
  static const Color gold = Color(0xFFC9A84C);

  static Color get glass => const Color.fromRGBO(0, 0, 0, 0.04);

  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);
  static Color emberWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);
  static Color goldWithOpacity(double opacity) =>
      gold.withValues(alpha: opacity);
}
