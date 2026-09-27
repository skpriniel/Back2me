import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Type scale from the design system, mapped to named text styles.
/// Uses Plus Jakarta Sans via google_fonts (fetched from Google Fonts).
///
/// To bundle the font locally instead (e.g. for a fully offline build):
///  1. Download the Plus Jakarta Sans .ttf files.
///  2. Put them in assets/fonts/.
///  3. Add a `fonts:` section to pubspec.yaml declaring the family and
///     weights, then replace GoogleFonts.plusJakartaSans(...) below with
///     TextStyle(fontFamily: 'Plus Jakarta Sans', ...).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base(double size, FontWeight weight, double height) {
    return GoogleFonts.plusJakartaSans(
      textStyle: TextStyle(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: AppColors.textDark,
      ),
    );
  }

  static TextStyle headlineSmall = _base(24, FontWeight.w700, 1.3);
  static TextStyle titleMedium = _base(20, FontWeight.w600, 1.3);
  static TextStyle bodyMedium = _base(16, FontWeight.w400, 1.5);
  static TextStyle labelSmall = _base(12, FontWeight.w400, 1.4);
  static TextStyle labelLarge = _base(16, FontWeight.w600, 1.2);
}
