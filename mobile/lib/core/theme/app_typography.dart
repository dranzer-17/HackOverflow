import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Fallback for missing glyphs (avoids "Noto fonts" warning on web).
const List<String> _fontFallback = ['Arial', 'sans-serif'];

/// Syne = display/headers. JetBrains Mono = body. Bebas Neue = accents/tags.
class AppTypography {
  AppTypography._();

  static TextStyle _withFallback(TextStyle style) =>
      style.copyWith(fontFamilyFallback: _fontFallback);

  static TextStyle get displayLarge => _withFallback(GoogleFonts.syne(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.mercury,
        letterSpacing: -0.5,
      ));

  static TextStyle get displayMedium => _withFallback(GoogleFonts.syne(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.mercury,
      ));

  static TextStyle get displaySmall => _withFallback(GoogleFonts.syne(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.mercury,
      ));

  static TextStyle get bodyLarge => _withFallback(GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.mercury,
      ));

  static TextStyle get bodyMedium => _withFallback(GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.mercury,
      ));

  static TextStyle get bodySmall => _withFallback(GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.smog,
      ));

  static TextStyle get label => _withFallback(GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.smog,
        letterSpacing: 0.14,
      ));

  static TextStyle get tag => _withFallback(GoogleFonts.bebasNeue(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        letterSpacing: 1.2,
      ));

  static TextStyle get terminalPrefix => _withFallback(GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      ));
}
