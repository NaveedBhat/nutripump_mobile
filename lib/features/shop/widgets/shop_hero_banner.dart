import 'package:flutter/material.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_network_image.dart';

class ShopHeroBanner extends StatelessWidget {
  final String? heroBg;

  const ShopHeroBanner({
    super.key,
    required this.heroBg,
  });

  static const _fallbackHero =
      'https://images.unsplash.com/photo-1647427062468-74ff21e8934f?q=80&w=1200&auto=format&fit=crop';

  @override
  Widget build(BuildContext context) {
    final imageUrl = heroBg ?? _fallbackHero;
    return SizedBox(
      height: R.h(context, 240),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xA6201E0D), Color(0xC7201E0D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(R.w(context, 20), R.h(context, 48),
                R.w(context, 20), R.h(context, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('HOME / SHOP',
                    style: AppTypography.labelGold(context).copyWith(
                        letterSpacing: 1.5, fontSize: R.sp(context, 9))),
                SizedBox(height: R.h(context, 6)),
                Text('The Curated\nCollection',
                    style: AppTypography.h1(context).copyWith(
                        color: Colors.white,
                        fontSize: R.sp(context, 22),
                        height: 1.15)),
                SizedBox(height: R.h(context, 6)),
                Text(
                  'Discover the essence of purity with our hand-harvested, artisanal selection from the heart of the valley.',
                  style: AppTypography.bodySM(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontStyle: FontStyle.italic,
                      fontSize: R.sp(context, 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
