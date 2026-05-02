import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// NutriPump Artisanal — Typography System
/// Uses Newsreader serif (same as web app)
class AppTypography {
  AppTypography._();

  // ── Display ───────────────────────────────────────────────
  static TextStyle get displayXL => GoogleFonts.newsreader(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    height: 1.05,
    color: AppColors.deepCharcoal,
  );

  static TextStyle get displayLG => GoogleFonts.newsreader(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.1,
    color: AppColors.deepCharcoal,
  );

  static TextStyle get displayMD => GoogleFonts.newsreader(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: AppColors.deepCharcoal,
  );

  // ── Headings ──────────────────────────────────────────────
  static TextStyle get h1 => GoogleFonts.newsreader(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.deepCharcoal,
  );

  static TextStyle get h2 => GoogleFonts.newsreader(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.deepCharcoal,
  );

  static TextStyle get h3 => GoogleFonts.newsreader(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.deepCharcoal,
  );

  // ── Body ──────────────────────────────────────────────────
  static TextStyle get bodyLG => GoogleFonts.newsreader(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.deepCharcoal,
  );

  static TextStyle get body => GoogleFonts.newsreader(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.deepCharcoal,
  );

  static TextStyle get bodySM => GoogleFonts.newsreader(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.deepCharcoal,
  );

  // ── Utility ───────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.newsreader(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.neutralGold,
  );

  static TextStyle get label => GoogleFonts.newsreader(
    fontSize: 9,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: AppColors.deepCharcoal,
  );

  static TextStyle get labelGold => GoogleFonts.newsreader(
    fontSize: 9,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: AppColors.neutralGold,
  );

  static TextStyle get price => GoogleFonts.newsreader(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.deepCharcoal,
  );

  static TextStyle get priceSM => GoogleFonts.newsreader(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.deepCharcoal,
  );

  static TextStyle get priceStrike => GoogleFonts.newsreader(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.neutralGold,
    decoration: TextDecoration.lineThrough,
  );
}

