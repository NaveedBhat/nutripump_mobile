import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class B2BSection extends StatelessWidget {
  const B2BSection({super.key});

  @override
  Widget build(BuildContext context) {
    const features = [
      (
        Icons.restaurant_outlined,
        'Custom Sourcing',
        'Bespoke artisanal sourcing for your restaurant, hotel, or specialty store.'
      ),
      (
        Icons.local_offer_outlined,
        'Bulk Supply',
        'Competitive rates for large-volume orders with guaranteed freshness.'
      ),
      (
        Icons.storefront_outlined,
        'White Label',
        'Private labeling available for your brand with our premium products.'
      ),
      (
        Icons.school_outlined,
        'Staff Training',
        'Product knowledge sessions for your culinary and hospitality team.'
      ),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E2A),
        borderRadius: BorderRadius.circular(R.w(context, 20)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(R.w(context, 20)),
                bottomRight: Radius.circular(R.w(context, 20)),
              ),
              child: Container(
                width: R.w(context, 70),
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(R.w(context, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('B2B & GASTRONOMY',
                    style: AppTypography.label(context).copyWith(
                        color: AppColors.primary,
                        fontSize: R.sp(context, 9),
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: R.h(context, 6)),
                RichText(
                  text: TextSpan(
                    style: AppTypography.h2(context).copyWith(
                        color: Colors.white,
                        fontSize: R.sp(context, 19),
                        height: 1.15),
                    children: [
                      const TextSpan(text: 'Elevate Your\nCulinary '),
                      TextSpan(
                        text: 'Signature',
                        style: AppTypography.h2(context).copyWith(
                            color: AppColors.primary,
                            fontSize: R.sp(context, 19),
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.h(context, 10)),
                Text(
                  'We partner with restaurants, luxury hotels, and high-end retailers to provide premium, single-origin artisan products.',
                  style: AppTypography.bodySM(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: R.sp(context, 11),
                      height: 1.5),
                ),
                SizedBox(height: R.h(context, 16)),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: R.h(context, 12),
                  crossAxisSpacing: R.w(context, 12),
                  childAspectRatio: 2.2,
                  padding: EdgeInsets.zero,
                  children: features.map((f) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(R.w(context, 6)),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(R.w(context, 7)),
                          ),
                          child: Icon(f.$1,
                              color: AppColors.primary,
                              size: R.sp(context, 13)),
                        ),
                        SizedBox(width: R.w(context, 7)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(f.$2,
                                  style: AppTypography.label(context).copyWith(
                                      color: Colors.white,
                                      fontSize: R.sp(context, 9),
                                      fontWeight: FontWeight.w800)),
                              SizedBox(height: R.h(context, 2)),
                              Text(f.$3,
                                  style: AppTypography.label(context).copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      fontSize: R.sp(context, 8),
                                      height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: R.h(context, 16)),
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: R.h(context, 10), horizontal: R.w(context, 14)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(R.w(context, 10)),
                    border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.surfaceDark
                            : Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _b2bStat(context, '500+', 'Partners'),
                      Container(
                          width: 1,
                          height: R.h(context, 22),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.surfaceDark
                              : Colors.white.withValues(alpha: 0.1)),
                      _b2bStat(context, '50+', 'Restaurants'),
                      Container(
                          width: 1,
                          height: R.h(context, 22),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.surfaceDark
                              : Colors.white.withValues(alpha: 0.1)),
                      _b2bStat(context, '10+', 'Hotels'),
                    ],
                  ),
                ),
                SizedBox(height: R.h(context, 16)),
                GestureDetector(
                  onTap: () => context.push('/contact?type=bulk'),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: R.h(context, 12)),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(R.w(context, 10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Request Partnership Kit',
                          style: AppTypography.label(context).copyWith(
                            color: AppColors.deepCharcoal,
                            fontWeight: FontWeight.w900,
                            fontSize: R.sp(context, 11),
                          ),
                        ),
                        SizedBox(width: R.w(context, 7)),
                        Icon(Icons.arrow_forward,
                            color: AppColors.deepCharcoal,
                            size: R.sp(context, 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _b2bStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.h3(context).copyWith(
                color: AppColors.primary, fontSize: R.sp(context, 16))),
        Text(label,
            style: AppTypography.label(context).copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: R.sp(context, 9))),
      ],
    );
  }
}
