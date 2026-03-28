import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E1E1E);
  static const Color secondary = Color(0xFF1E1E1E);
  static const Color teal = Color(0xFF2096A4);
  static const Color tealDark = Color(0xFF1B8A9E);
  static const Color tealLight = Color(0xFFB2DFDB);
  static const Color cardBackground = Color(0xFFECF2F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color danger = Color(0xFFE53935);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFB8C00);
  static const Color info = Color(0xFF2E7D32);

  // Dark mode variants
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkBackground = Color(0xFF121212);

  // Adaptive helpers
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkCard
          : cardBackground;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSurface
          : white;

  static Color accent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? tealLight
          : teal;
}
