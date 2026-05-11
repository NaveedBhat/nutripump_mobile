import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_network_image.dart';

class CategoryHeroBanner extends StatefulWidget {
  final AnimationController zoomCtrl;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String fallbackBannerImage;

  const CategoryHeroBanner({
    super.key,
    required this.zoomCtrl,
    this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    required this.fallbackBannerImage,
  });

  @override
  State<CategoryHeroBanner> createState() => _CategoryHeroBannerState();
}

class _CategoryHeroBannerState extends State<CategoryHeroBanner> {
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scale = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(parent: widget.zoomCtrl, curve: Curves.linear),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: R.h(context, 240),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ken Burns background
          AnimatedBuilder(
            animation: _scale,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: CustomNetworkImage(
                imageUrl: widget.imageUrl ?? widget.fallbackBannerImage,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x6B000000), Color(0xA6000000)],
              ),
            ),
          ),

          // Text content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.subtitle?.toUpperCase() ?? 'CURATED COLLECTIONS',
                    style: AppTypography.labelGold(context).copyWith(
                      letterSpacing: 3,
                      fontSize: R.sp(context, 9),
                    ),
                  ),
                  SizedBox(height: R.h(context, 8)),
                  Text(
                    widget.title ?? 'Explore Our\nCollections',
                    textAlign: TextAlign.center,
                    style: AppTypography.h1(context).copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : Colors.white,
                      fontSize: R.sp(context, 26),
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: R.h(context, 12)),
                  Text(
                    widget.description ??
                        'A refined heritage of artisanal excellence and handcrafted perfection, curated for the modern connoisseur.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySM(context).copyWith(
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.surfaceDark
                              : Colors.white)
                          .withValues(alpha: 0.80),
                      fontStyle: FontStyle.italic,
                      fontSize: R.sp(context, 11),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
