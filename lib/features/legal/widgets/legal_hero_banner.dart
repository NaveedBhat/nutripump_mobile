import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class LegalHeroBanner extends StatelessWidget {
  final String badgeText;
  final IconData badgeIcon;
  final String intro;
  final String lastUpdated;

  const LegalHeroBanner({
    super.key,
    required this.badgeText,
    required this.badgeIcon,
    required this.intro,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.deepCharcoal,
      padding: EdgeInsets.fromLTRB(
          R.w(context, 24), R.h(context, 24), R.w(context, 24), R.h(context, 32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: R.w(context, 10), vertical: R.h(context, 5)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(R.w(context, 20)),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badgeIcon, color: AppColors.primary, size: R.sp(context, 11)),
                SizedBox(width: R.w(context, 5)),
                Text(
                  badgeText.toUpperCase(),
                  style: AppTypography.label(context).copyWith(
                    color: AppColors.primary,
                    fontSize: R.sp(context, 9),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: R.h(context, 12)),
          Text(
            intro,
            style: AppTypography.bodySM(context).copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: R.sp(context, 13),
              height: 1.6,
            ),
          ),
          SizedBox(height: R.h(context, 10)),
          Text(
            'Last updated: $lastUpdated',
            style: AppTypography.label(context).copyWith(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: R.sp(context, 10),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
