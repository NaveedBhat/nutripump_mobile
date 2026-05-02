import 'package:flutter/material.dart';

/// Responsive sizing utility — design reference: 390 × 844 (iPhone 14 logical px).
///
/// Usage:
///   R.sp(context, 16)   → scaled font size
///   R.h(context, 200)   → proportional height
///   R.w(context, 100)   → proportional width
///   R.r(context)        → raw scale ratio
///
/// The ratio is clamped to [0.85, 1.1] so very small or very large
/// screens don't get extreme values.
class R {
  R._();

  static const double _designW = 390.0;
  static const double _designH = 844.0;

  /// Scale ratio based on screen width, clamped to safe range.
  static double r(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (w / _designW).clamp(0.82, 1.1);
  }

  /// Scaled font size — use instead of hardcoded fontSize.
  static double sp(BuildContext context, double size) => size * r(context);

  /// Proportional width relative to design reference.
  static double w(BuildContext context, double size) {
    final sw = MediaQuery.sizeOf(context).width;
    return size * (sw / _designW);
  }

  /// Proportional height relative to design reference.
  static double h(BuildContext context, double size) {
    final sh = MediaQuery.sizeOf(context).height;
    return size * (sh / _designH);
  }

  /// Vertical padding/margin scaled to screen height.
  static double v(BuildContext context, double size) => h(context, size);
}
