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

  // Luxury Dark Mode Palette (Deep Astral Navy / Midnight Sapphire - NOT black)
  static const Color darkBackground = Color(0xFF111726); // Rich oceanic midnight navy
  static const Color darkSurface = Color(0xFF1A2238);    // Lush indigo-navy card surface
  static const Color darkSurfaceMuted = Color(0xFF232D4A); // Elevated inputs & chips
  static const Color darkBorder = Color(0xFF2C395E);     // Luminous soft sapphire border

  // Dark Typography
  static const Color darkTextPrimary = Color(0xFFF1F5FD); // Crisp ice white
  static const Color darkTextSecondary = Color(0xFFA2B4D6); // Soft silver periwinkle
  static const Color darkTextMuted = Color(0xFF6E80A8);     // Twilight slate

  // Dark Mode Accent Variations
  static const Color darkPrimaryBlueLight = Color(0xFF212E52);
  static const Color darkPrimaryPinkLight = Color(0xFF381F33);
  static const Color darkSuccessGreenLight = Color(0xFF18382C);
  static const Color darkExpenseRedLight = Color(0xFF3B1D25);

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

  // Dynamic Theme Resolvers
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color backgroundOf(BuildContext context) =>
      isDark(context) ? darkBackground : background;

  static Color surfaceOf(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color surfaceMutedOf(BuildContext context) =>
      isDark(context) ? darkSurfaceMuted : surfaceMuted;

  static Color borderOf(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? darkTextPrimary : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;

  static Color textMutedOf(BuildContext context) =>
      isDark(context) ? darkTextMuted : textMuted;

  static Color primaryBlueLightOf(BuildContext context) =>
      isDark(context) ? darkPrimaryBlueLight : primaryBlueLight;
}
