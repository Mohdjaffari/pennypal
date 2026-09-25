import 'package:flutter/material.dart';

/// App color palette reflecting the PennyPal design system.
class AppColors {
  AppColors._();

  // Backgrounds & Surface
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF4F6F8);
  static const Color border = Color(0xFFECEFF3);

  // Typography
  static const Color textPrimary = Color(0xFF1E2235);
  static const Color textSecondary = Color(0xFF8E9BAE);
  static const Color textMuted = Color(0xFFA0ABBB);

  // Brand Accents
  static const Color primaryBlue = Color(0xFF4361EE);
  static const Color primaryBlueDark = Color(0xFF334DC7);
  static const Color primaryBlueLight = Color(0xFFEEF2FF);

  static const Color primaryPink = Color(0xFFFF477E);
  static const Color primaryPinkDark = Color(0xFFFF2A5F);
  static const Color primaryPinkLight = Color(0xFFFFEDF3);

  // Status & Categories
  static const Color successGreen = Color(0xFF2CB67D);
  static const Color successGreenLight = Color(0xFFE8F8F0);
  static const Color expenseRed = Color(0xFFE63946);
  static const Color expenseRedLight = Color(0xFFFFECEE);

  static const Color shoppingOrange = Color(0xFFFFB703);
  static const Color shoppingOrangeLight = Color(0xFFFFF7E6);

  static const Color purple = Color(0xFF7B61FF);
  static const Color purpleLight = Color(0xFFF3EFFF);

  // Gradients
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [primaryPink, primaryPinkDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF3F37C9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
