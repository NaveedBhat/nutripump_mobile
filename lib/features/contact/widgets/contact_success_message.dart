import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class ContactSuccessMessage extends StatelessWidget {
  final VoidCallback onReset;
  const ContactSuccessMessage({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          vertical: R.h(context, 40), horizontal: R.w(context, 20)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 16)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            width: R.w(context, 64),
            height: R.w(context, 64),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: R.sp(context, 32)),
          ),
          SizedBox(height: R.h(context, 24)),
          Text('Message Delivered',
              style: AppTypography.label(context).copyWith(
                  color: AppColors.primary,
                  fontSize: R.sp(context, 11))),
          SizedBox(height: R.h(context, 8)),
          Text('We\'ve got your note!',
              style: AppTypography.h3(context)
                  .copyWith(fontSize: R.sp(context, 16))),
          SizedBox(height: R.h(context, 8)),
          Text(
              'Our team will personally reply within 24 hours. Thank you for reaching out.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySM(context)
                  .copyWith(color: AppColors.neutralGold)),
          SizedBox(height: R.h(context, 24)),
          TextButton.icon(
            onPressed: onReset,
            icon: Icon(Icons.send_rounded, size: R.sp(context, 14)),
            label: Text('Send another message',
                style: AppTypography.bodySM(context)
                    .copyWith(fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }
}
