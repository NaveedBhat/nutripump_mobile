import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class NewsletterSection extends StatelessWidget {
  final TextEditingController controller;
  const NewsletterSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.10),
      padding: EdgeInsets.symmetric(
          horizontal: R.w(context, 20), vertical: R.h(context, 40)),
      child: Column(
        children: [
          Text(
            'Join the Collective',
            textAlign: TextAlign.center,
            style:
                AppTypography.h2(context).copyWith(fontSize: R.sp(context, 22)),
          ),
          SizedBox(height: R.h(context, 8)),
          Text(
            'Subscribe to receive exclusive access to limited artisanal drops, maker stories, and heritage events.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySM(context).copyWith(
              color: AppColors.neutralGold,
              height: 1.6,
              fontSize: R.sp(context, 13),
            ),
          ),
          SizedBox(height: R.h(context, 24)),
          TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: AppTypography.bodySM(context).copyWith(
                color: AppColors.neutralGold.withValues(alpha: 0.6),
                fontSize: R.sp(context, 12),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: R.w(context, 16), vertical: R.h(context, 14)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                borderSide:
                    BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                borderSide:
                    BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          SizedBox(height: R.h(context, 12)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.deepCharcoal,
                padding: EdgeInsets.symmetric(vertical: R.h(context, 14)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.w(context, 12))),
                elevation: 0,
              ),
              child: Text(
                'Subscribe',
                style: AppTypography.bodySM(context).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: R.sp(context, 14),
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.deepCharcoal),
                ),
              ),
            ),
          ),
          SizedBox(height: R.h(context, 12)),
          Text(
            'By subscribing, you agree to our Terms of Service and Privacy Policy.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySM(context).copyWith(
              color: AppColors.neutralGold.withValues(alpha: 0.7),
              fontSize: R.sp(context, 10),
            ),
          ),
        ],
      ),
    );
  }
}
