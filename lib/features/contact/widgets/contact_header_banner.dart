import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class ContactHeaderBanner extends StatelessWidget {
  const ContactHeaderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(R.w(context, 16)),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: R.w(context, 48),
            height: R.w(context, 48),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.support_agent_rounded,
                size: R.sp(context, 26), color: AppColors.primary),
          ),
          SizedBox(width: R.w(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('We\'re here to help!',
                    style: AppTypography.bodySM(context).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: R.sp(context, 15))),
                SizedBox(height: R.h(context, 4)),
                Text('Typically reply within 2–4 hours',
                    style: AppTypography.bodySM(context).copyWith(
                        color: AppColors.neutralGold,
                        fontSize: R.sp(context, 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
