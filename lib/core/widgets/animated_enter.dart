import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedEnter extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Offset offset;

  const AnimatedEnter({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.2),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
        .slide(begin: offset, end: Offset.zero, duration: 500.ms, curve: Curves.easeOut);
  }
}
