import 'package:flutter/material.dart';

/// NutriPump Artisanal — Design System Colors
/// Direct translation from tailwind.config.ts
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────
  static const Color primary = Color(0xFFEEBD2B); // #eebd2b gold
  static const Color primaryDark = Color(0xFFD4A820); // hover state
  static const Color deepCharcoal = Color(0xFF1B180D); // primary text
  static const Color neutralGold = Color(0xFF9A864C); // secondary text

  // ── Backgrounds ───────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F7F6);
  static const Color backgroundDark = Color(0xFF221D10);

  // ── Surfaces (cards, sheets) ──────────────────────────────
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2510);

  // ── Borders ───────────────────────────────────────────────
  static const Color borderLight = Color(0xFFE8E3D8);
  static const Color borderDark = Color(0xFF3A3018);

  // ── Shadows ───────────────────────────────────────────────
  static const Color shadowGold = Color(0x40EEBD2B); // 25% opacity gold
  static const Color shadowProduct = Color(0x1A1B180D); // 10% charcoal

  // ── Semantic ──────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Status badges (order status) ─────────────────────────
  static const Color statusPending = Color(0xFFFEF3C7);
  static const Color statusConfirmed = Color(0xFFDBEAFE);
  static const Color statusShipped = Color(0xFFFFEDD5);
  static const Color statusDelivered = Color(0xFFDCFCE7);
  static const Color statusCancelled = Color(0xFFFEE2E2);
}
