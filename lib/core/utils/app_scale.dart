import 'package:flutter/material.dart';

/// Global scale factor inherited widget.
/// Initialized once in main.dart's MaterialApp builder.
/// Provides [AppScale.of(context)] everywhere in the tree.
class AppScale extends InheritedWidget {
  final double scale;

  const AppScale({
    super.key,
    required this.scale,
    required super.child,
  });

  /// Returns the scale ratio for the given context.
  /// Falls back to 1.0 if AppScale is not in the tree.
  static double of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppScale>();
    return widget?.scale ?? 1.0;
  }

  @override
  bool updateShouldNotify(AppScale oldWidget) => scale != oldWidget.scale;
}
