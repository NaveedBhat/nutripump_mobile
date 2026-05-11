import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class EmptyCartState extends StatelessWidget {
  const EmptyCartState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.w(context, 32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: R.w(context, 80),
              height: R.w(context, 80),
              decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2))),
              child: Icon(Icons.shopping_bag_outlined,
                  size: R.sp(context, 32), color: AppColors.primary),
            ),
            SizedBox(height: R.h(context, 20)),
            Text('Your cart is empty',
                style: AppTypography.h2(context)
                    .copyWith(fontSize: R.sp(context, 22))),
            SizedBox(height: R.h(context, 8)),
            Text(
                'Discover hand-harvested artisanal treasures curated from the wild valleys of Kashmir.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySM(context).copyWith(
                    color: AppColors.neutralGold,
                    fontSize: R.sp(context, 12),
                    height: 1.5)),
            SizedBox(height: R.h(context, 24)),
            SizedBox(
              width: R.w(context, 220),
              child: ElevatedButton(
                onPressed: () => context.go('/shop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.deepCharcoal,
                  elevation: 6,
                  padding: EdgeInsets.symmetric(vertical: R.h(context, 12)),
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.w(context, 12))),
                ),
                child: Text('Explore The Pantry',
                    style: AppTypography.bodySM(context).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: R.sp(context, 13),
                        color: AppColors.deepCharcoal)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
