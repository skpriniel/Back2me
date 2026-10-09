import 'package:flutter/material.dart';

/// Centralized color tokens from the Back2me design system (v2).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color accent = Color(0xFFF59E0B); // "secondary" role in the design system
  static const Color background = Color(0xFFEEEAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color textDark = Color(0xFF2A2440);

  // On-colors, chosen from the contrast table in the design system.
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onAccent = textDark; // white on amber fails contrast (2.2:1)
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onSuccess = Color(0xFFFFFFFF); // large/bold text only
  static const Color onBackground = textDark;
  static const Color onSurface = textDark;

  static const Color mutedText = Color(0x992A2440); // textDark ~60% for captions
  static const Color divider = Color(0x1A2A2440);
}
