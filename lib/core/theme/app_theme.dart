import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Central theme configuration for PennyPal.
/// Defines elegant, human-readable Material 3 configurations
/// for both Light and Dark slate modes with unified typography,
/// adaptive multilingual fonts (Urdu Nastaliq, Arabic Cairo, Latin Inter),
/// and generous line-heights to eliminate clipped Nastaliq glyphs.
class AppTheme {
  AppTheme._();

  static const List<String> _fontFallbacks = [
    'Noto Nastaliq Urdu',
    'Noto Sans Arabic',
    'Cairo',
    'Arial',
    'sans-serif',
  ];

  static TextTheme _buildAdaptiveTextTheme(
    String? languageCode,
    Brightness brightness,
  ) {
    final code = languageCode?.toLowerCase() ?? 'en';
    final textColor = brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final secondaryColor = brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    TextTheme baseTheme;
    double lineHeight = 1.25;

    if (code == 'ur') {
      lineHeight = 1.5;
      baseTheme = GoogleFonts.notoNastaliqUrduTextTheme();
    } else if (code == 'ar') {
      lineHeight = 1.35;
      baseTheme = GoogleFonts.cairoTextTheme();
    } else {
      baseTheme = GoogleFonts.interTextTheme();
    }

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        color: textColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        color: textColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        color: textColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        color: textColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        color: textColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        color: textColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        color: textColor,
        height: lineHeight,
        fontWeight: FontWeight.w700,
        fontFamilyFallback: _fontFallbacks,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        color: textColor,
        height: lineHeight,
        fontWeight: FontWeight.w600,
        fontFamilyFallback: _fontFallbacks,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        color: textColor,
        height: lineHeight,
        fontWeight: FontWeight.w600,
        fontFamilyFallback: _fontFallbacks,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        color: textColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        color: textColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        color: secondaryColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        color: textColor,
        height: lineHeight,
        fontWeight: FontWeight.w600,
        fontFamilyFallback: _fontFallbacks,
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        color: secondaryColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        color: secondaryColor,
        height: lineHeight,
        fontFamilyFallback: _fontFallbacks,
      ),
    );
  }

  /// Light Theme Configuration with optional locale adaptation
  static ThemeData lightTheme([String? languageCode]) {
    final textTheme = _buildAdaptiveTextTheme(languageCode, Brightness.light);
    final isUrdu = languageCode == 'ur';
    final isArabic = languageCode == 'ar';
    final primaryFont = isUrdu ? 'Noto Nastaliq Urdu' : (isArabic ? 'Cairo' : 'Inter');

    return ThemeData(
      useMaterial3: true,
      fontFamily: primaryFont,
      fontFamilyFallback: _fontFallbacks,
      textTheme: textTheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      cardColor: AppColors.surface,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryPink,
        surface: AppColors.surface,
        error: AppColors.expenseRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: primaryFont,
          fontFamilyFallback: _fontFallbacks,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryBlue;
          return AppColors.textMuted.withValues(alpha: 0.35);
        }),
      ),
    );
  }

  /// Dark Theme Configuration with optional locale adaptation
  static ThemeData darkTheme([String? languageCode]) {
    final textTheme = _buildAdaptiveTextTheme(languageCode, Brightness.dark);
    final isUrdu = languageCode == 'ur';
    final isArabic = languageCode == 'ar';
    final primaryFont = isUrdu ? 'Noto Nastaliq Urdu' : (isArabic ? 'Cairo' : 'Inter');

    return ThemeData(
      useMaterial3: true,
      fontFamily: primaryFont,
      fontFamilyFallback: _fontFallbacks,
      textTheme: textTheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkSurface,
      cardColor: AppColors.darkSurface,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryPink,
        surface: AppColors.darkSurface,
        error: AppColors.expenseRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: primaryFont,
          fontFamilyFallback: _fontFallbacks,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryBlue;
          return AppColors.darkBorder;
        }),
      ),
    );
  }
}
