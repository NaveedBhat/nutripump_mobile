import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import '../utils/app_scale.dart';

/// NutriPump Artisanal — Responsive Typography System
///
/// All font sizes are multiplied by [AppScale.of(context)] which is
/// injected once at the app root in main.dart.
/// This means EVERY screen gets proportionally correct text automatically —
/// no per-screen changes needed.
///
/// Usage: AppTypography.h1(context)  — context-aware, scaled
///        AppTypography.h1Value      — raw design value (for overrides only)
class AppTypography {
  AppTypography._();

  // ── Raw design values (390px reference) ──────────────────────
  static const double h1Value      = 24;
  static const double h2Value      = 19;
  static const double h3Value      = 16;
  static const double bodyLGValue  = 16;
  static const double bodyValue    = 14;
  static const double bodySMValue  = 13;
  static const double captionValue = 11;
  static const double labelValue   = 9;
  static const double priceValue   = 18;
  static const double priceSMValue = 14;

  // ── Display ───────────────────────────────────────────────────
  static TextStyle displayXL(BuildContext context) => GoogleFonts.newsreader(
    fontSize: 34 * AppScale.of(context),
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    height: 1.05,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  static TextStyle displayLG(BuildContext context) => GoogleFonts.newsreader(
    fontSize: 28 * AppScale.of(context),
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.1,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  static TextStyle displayMD(BuildContext context) => GoogleFonts.newsreader(
    fontSize: 22 * AppScale.of(context),
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  // ── Headings ──────────────────────────────────────────────────
  static TextStyle h1(BuildContext context) => GoogleFonts.newsreader(
    fontSize: h1Value * AppScale.of(context),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  static TextStyle h2(BuildContext context) => GoogleFonts.newsreader(
    fontSize: h2Value * AppScale.of(context),
    fontWeight: FontWeight.w700,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  static TextStyle h3(BuildContext context) => GoogleFonts.newsreader(
    fontSize: h3Value * AppScale.of(context),
    fontWeight: FontWeight.w600,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  // ── Body ──────────────────────────────────────────────────────
  static TextStyle bodyLG(BuildContext context) => GoogleFonts.newsreader(
    fontSize: bodyLGValue * AppScale.of(context),
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  static TextStyle body(BuildContext context) => GoogleFonts.newsreader(
    fontSize: bodyValue * AppScale.of(context),
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  static TextStyle bodySM(BuildContext context) => GoogleFonts.newsreader(
    fontSize: bodySMValue * AppScale.of(context),
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  // ── Utility ───────────────────────────────────────────────────
  static TextStyle caption(BuildContext context) => GoogleFonts.newsreader(
    fontSize: captionValue * AppScale.of(context),
    fontWeight: FontWeight.w500,
    color: AppColors.neutralGold,
  );

  static TextStyle label(BuildContext context) => GoogleFonts.newsreader(
    fontSize: labelValue * AppScale.of(context),
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  static TextStyle labelGold(BuildContext context) => GoogleFonts.newsreader(
    fontSize: labelValue * AppScale.of(context),
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: AppColors.neutralGold,
  );

  static TextStyle price(BuildContext context) => GoogleFonts.newsreader(
    fontSize: priceValue * AppScale.of(context),
    fontWeight: FontWeight.w800,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  static TextStyle priceSM(BuildContext context) => GoogleFonts.newsreader(
    fontSize: priceSMValue * AppScale.of(context),
    fontWeight: FontWeight.w700,
    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.deepCharcoal,
  );

  static TextStyle priceStrike(BuildContext context) => GoogleFonts.newsreader(
    fontSize: 12 * AppScale.of(context),
    fontWeight: FontWeight.w400,
    color: AppColors.neutralGold,
    decoration: TextDecoration.lineThrough,
  );
}

