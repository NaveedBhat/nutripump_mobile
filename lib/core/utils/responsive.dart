import 'package:flutter/material.dart';
import 'app_scale.dart';

/// Responsive sizing utility — design reference: 390 × 844 (iPhone 14 logical px).
///
/// The scale ratio is computed ONCE in main.dart and injected via [AppScale].
/// All methods read from it, so there is no per-call MediaQuery lookup.
///
/// Usage:
///   R.sp(context, 16)   → scaled font size
///   R.h(context, 200)   → proportional height
///   R.w(context, 100)   → proportional width
class R {
  R._();

  static const double _designW = 390.0;
  static const double _designH = 844.0;

  /// Global scale ratio — width-based, clamped to [0.82, 1.1].
  static double r(BuildContext context) => AppScale.of(context);

  /// Scaled font size.
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
}
