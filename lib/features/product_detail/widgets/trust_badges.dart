import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class TrustBadges extends StatelessWidget {
  const TrustBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: R.h(context, 24)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(R.w(context, 10)),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(R.w(context, 6)),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(R.w(context, 6))),
                    child: Icon(Icons.auto_awesome,
                        color: AppColors.primary, size: R.sp(context, 14)),
                  ),
                  SizedBox(width: R.w(context, 8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PURITY GUARANTEED',
                            style: AppTypography.label(context).copyWith(
                                fontSize: R.sp(context, 7),
                                letterSpacing: 1.0)),
                        SizedBox(height: R.h(context, 2)),
                        Text('100% Cold-Pressed',
                            style: AppTypography.bodySM(context).copyWith(
                                fontSize: R.sp(context, 9),
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: R.w(context, 8)),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(R.w(context, 10)),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(R.w(context, 6)),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(R.w(context, 6))),
                    child: Icon(Icons.verified_outlined,
                        color: AppColors.primary, size: R.sp(context, 14)),
                  ),
                  SizedBox(width: R.w(context, 8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FROM SRINAGAR',
                            style: AppTypography.label(context).copyWith(
                                fontSize: R.sp(context, 7),
                                letterSpacing: 1.0)),
                        SizedBox(height: R.h(context, 2)),
                        Text('Arrives in 3-5 Days',
                            style: AppTypography.bodySM(context).copyWith(
                                fontSize: R.sp(context, 9),
                                fontWeight: FontWeight.w700)),
                      ],
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
