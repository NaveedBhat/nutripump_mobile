import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// NutriPump Artisanal — Material 3 Theme
class AppTheme {
  AppTheme._();

  // ── Light Theme ───────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.deepCharcoal,
      secondary: AppColors.neutralGold,
      onSecondary: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.deepCharcoal,
      error: AppColors.error,
      outline: AppColors.borderLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: _buildTextTheme(AppColors.deepCharcoal),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.deepCharcoal,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTypography.h3,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.neutralGold,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.deepCharcoal,
        elevation: 0,
        shadowColor: AppColors.shadowGold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: AppTypography.label.copyWith(fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.deepCharcoal,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: AppTypography.label.copyWith(fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.primary.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      labelStyle: AppTypography.bodySM.copyWith(color: AppColors.neutralGold),
      hintStyle: AppTypography.bodySM.copyWith(
        color: AppColors.neutralGold.withValues(alpha: 0.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.primary.withValues(alpha: 0.1),
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      selectedColor: AppColors.primary,
      labelStyle: AppTypography.label.copyWith(fontSize: 11),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.deepCharcoal,
      contentTextStyle: AppTypography.bodySM.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ── Dark Theme ────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.deepCharcoal,
      secondary: AppColors.neutralGold,
      surface: AppColors.surfaceDark,
      onSurface: Color(0xFFF5F0E8),
      error: AppColors.error,
      outline: AppColors.borderDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: _buildTextTheme(const Color(0xFFF5F0E8)),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: const Color(0xFFF5F0E8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTypography.h3.copyWith(color: const Color(0xFFF5F0E8)),
    ),
  );

  static TextTheme _buildTextTheme(Color color) => TextTheme(
    displayLarge: AppTypography.displayXL.copyWith(color: color),
    displayMedium: AppTypography.displayLG.copyWith(color: color),
    displaySmall: AppTypography.displayMD.copyWith(color: color),
    headlineLarge: AppTypography.h1.copyWith(color: color),
    headlineMedium: AppTypography.h2.copyWith(color: color),
    headlineSmall: AppTypography.h3.copyWith(color: color),
    bodyLarge: AppTypography.bodyLG.copyWith(color: color),
    bodyMedium: AppTypography.body.copyWith(color: color),
    bodySmall: AppTypography.bodySM.copyWith(color: color),
    labelSmall: AppTypography.label.copyWith(color: color),
  );
}
