import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class SupportPromiseSection extends StatelessWidget {
  const SupportPromiseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : Colors.white,
      padding: EdgeInsets.all(R.w(context, 32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Our Support Promise', style: AppTypography.h2(context)),
          SizedBox(height: R.h(context, 32)),
          _buildPromiseItem(
            context,
            Icons.schedule_rounded,
            '12-Hour Priority Response',
            'As an esteemed customer, your ticket bypasses the general queue.',
          ),
          SizedBox(height: R.h(context, 24)),
          _buildPromiseItem(
            context,
            Icons.inventory_2_outlined,
            'No-Hassle Replacements',
            'If any product arrived damaged, we dispatch a replacement batch immediately.',
          ),
          SizedBox(height: R.h(context, 24)),
          _buildPromiseItem(
            context,
            Icons.local_shipping_outlined,
            'Real-Time Transit Tracking',
            'Delivery delayed? We communicate with logistics partners to expedite it.',
          ),
          SizedBox(height: R.h(context, 48)),
          Text('DIRECT LINE',
              style: AppTypography.labelGold(context)
                  .copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: R.h(context, 8)),
          Text('support@nutripump.com', style: AppTypography.h3(context)),
          SizedBox(height: R.h(context, 4)),
          Text('Available Mon - Sat, 9am - 7pm EST',
              style: AppTypography.bodySM(context).copyWith(
                  color: AppColors.neutralGold, fontSize: R.sp(context, 12))),
        ],
      ),
    );
  }

  Widget _buildPromiseItem(
      BuildContext context, IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: R.w(context, 48),
          height: R.w(context, 48),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.white,
            borderRadius: BorderRadius.circular(R.w(context, 16)),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.primary, size: R.sp(context, 20)),
        ),
        SizedBox(width: R.w(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.body(context)
                      .copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: R.h(context, 4)),
              Text(desc,
                  style: AppTypography.bodySM(context).copyWith(
                      color: AppColors.neutralGold,
                      fontSize: R.sp(context, 13),
                      height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
