import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

class CategorySkeleton extends StatefulWidget {
  const CategorySkeleton({super.key});

  @override
  State<CategorySkeleton> createState() => _CategorySkeletonState();
}

class _CategorySkeletonState extends State<CategorySkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final color = Color.lerp(
          const Color(0xFFE8E3D8),
          const Color(0xFFF5F1EA),
          _anim.value,
        )!;
        return ClipRRect(
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          child: Container(
            color: color,
            child: Stack(
              children: [
                Positioned(
                  bottom: R.h(context, 12),
                  left: R.w(context, 12),
                  right: R.w(context, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: R.h(context, 8),
                          width: R.w(context, 60),
                          color: color.withValues(alpha: 0.5)),
                      SizedBox(height: R.h(context, 4)),
                      Container(
                          height: R.h(context, 14),
                          width: R.w(context, 100),
                          color: color.withValues(alpha: 0.5)),
                      SizedBox(height: R.h(context, 8)),
                      Container(
                          height: R.h(context, 28),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.5),
                            borderRadius:
                                BorderRadius.circular(R.w(context, 6)),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
