import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// NutriPump Artisanal — Material 3 Theme
class AppTheme {
  AppTheme._();

  // ── Light Theme ───────────────────────────────────────────
  static ThemeData light(BuildContext context) => ThemeData(
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
        textTheme: _buildTextTheme(context, AppColors.deepCharcoal),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          foregroundColor: AppColors.deepCharcoal,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: AppTypography.h3(context),
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
            textStyle: AppTypography.label(context).copyWith(fontSize: 14),
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
            textStyle: AppTypography.label(context).copyWith(fontSize: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.primary.withValues(alpha: 0.05),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: AppTypography.bodySM(context)
              .copyWith(color: AppColors.neutralGold),
          hintStyle: AppTypography.bodySM(context).copyWith(
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
          labelStyle: AppTypography.label(context).copyWith(fontSize: 11),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.deepCharcoal,
          contentTextStyle: AppTypography.bodySM(context)
              .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          behavior: SnackBarBehavior.floating,
          elevation: 10,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          actionTextColor: AppColors.primary,
          showCloseIcon: true,
          closeIconColor: Colors.white70,
        ),
      );

  // ── Dark Theme ────────────────────────────────────────────
  static ThemeData dark(BuildContext context) => ThemeData(
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
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: _buildTextTheme(context, const Color(0xFFF5F0E8)),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
          actionsIconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: AppTypography.h3(context)
              .copyWith(color: const Color(0xFFF5F0E8)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.backgroundDark,
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
            foregroundColor: AppColors
                .deepCharcoal, // Primary buttons usually have dark text even in dark mode for contrast
            elevation: 0,
            shadowColor: AppColors.shadowGold,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: AppTypography.label(context).copyWith(fontSize: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(
                0xFFF5F0E8), // White/cream text for outlined buttons in dark mode
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: AppTypography.label(context).copyWith(fontSize: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: AppTypography.bodySM(context)
              .copyWith(color: AppColors.neutralGold),
          hintStyle: AppTypography.bodySM(context).copyWith(
            color: const Color(0xFFF5F0E8).withValues(alpha: 0.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderDark),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderDark,
          thickness: 1,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedColor: AppColors.primary,
          labelStyle: AppTypography.label(context)
              .copyWith(fontSize: 11, color: const Color(0xFFF5F0E8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: AppColors.borderDark),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(
              0xFFF5F0E8), // Cream color for high contrast against dark mode
          contentTextStyle: AppTypography.bodySM(context).copyWith(
              color: AppColors.deepCharcoal, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          behavior: SnackBarBehavior.floating,
          elevation: 10,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          actionTextColor: AppColors.primary,
          showCloseIcon: true,
          closeIconColor: AppColors.deepCharcoal.withValues(alpha: 0.7),
        ),
      );

  static TextTheme _buildTextTheme(BuildContext context, Color color) =>
      TextTheme(
        displayLarge: AppTypography.displayXL(context).copyWith(color: color),
        displayMedium: AppTypography.displayLG(context).copyWith(color: color),
        displaySmall: AppTypography.displayMD(context).copyWith(color: color),
        headlineLarge: AppTypography.h1(context).copyWith(color: color),
        headlineMedium: AppTypography.h2(context).copyWith(color: color),
        headlineSmall: AppTypography.h3(context).copyWith(color: color),
        bodyLarge: AppTypography.bodyLG(context).copyWith(color: color),
        bodyMedium: AppTypography.body(context).copyWith(color: color),
        bodySmall: AppTypography.bodySM(context).copyWith(color: color),
        labelSmall: AppTypography.label(context).copyWith(color: color),
      );
}
