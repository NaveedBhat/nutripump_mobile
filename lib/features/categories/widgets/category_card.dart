import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutripump_mobile/models/models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_network_image.dart';

class CategoryCard extends StatefulWidget {
  final Category category;
  final int index;
  final String sublabel;
  final String imageUrl;

  const CategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.sublabel,
    required this.imageUrl,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + widget.index * 80),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 90), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            context.push('/shop?category=${cat.slug}');
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(R.w(context, 12)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image
                  CustomNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                  ),

                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x33000000),
                          Color(0xD9000000),
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                  // Shimmer overlay on press
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: _pressed
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                  ),

                  // Text content at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedSlide(
                      offset: _pressed ? const Offset(0, -0.03) : Offset.zero,
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(R.w(context, 12), 0,
                            R.w(context, 12), R.h(context, 12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Sublabel
                            Text(
                              widget.sublabel,
                              style: AppTypography.label(context).copyWith(
                                color:
                                    AppColors.primary.withValues(alpha: 0.92),
                                fontSize: R.sp(context, 8),
                                letterSpacing: 1.8,
                              ),
                            ),
                            SizedBox(height: R.h(context, 4)),
                            // Category name
                            Text(
                              cat.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.h3(context).copyWith(
                                color: Colors.white,
                                fontSize: R.sp(context, 14),
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: R.h(context, 8)),
                            // SHOP NOW button
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: R.h(context, 8)),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(R.w(context, 6)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'SHOP NOW',
                                    style:
                                        AppTypography.label(context).copyWith(
                                      color: AppColors.deepCharcoal,
                                      fontSize: 8,
                                      letterSpacing: 1.4,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 10,
                                    color: AppColors.deepCharcoal,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
