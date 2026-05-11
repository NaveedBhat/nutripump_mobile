import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class ContactBusinessHours extends StatelessWidget {
  const ContactBusinessHours({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(context, 20)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: R.sp(context, 18),
                  color: AppColors.neutralGold),
              SizedBox(width: R.w(context, 8)),
              Text('Business Hours',
                  style: AppTypography.bodySM(context)
                      .copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          SizedBox(height: R.h(context, 12)),
          const _HoursRow(
              day: 'Mon – Fri', hours: '10:00 AM – 7:00 PM'),
          SizedBox(height: R.h(context, 6)),
          const _HoursRow(day: 'Saturday', hours: '10:00 AM – 4:00 PM'),
          SizedBox(height: R.h(context, 6)),
          const _HoursRow(day: 'Sunday', hours: 'Closed'),
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String hours;
  const _HoursRow({required this.day, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day,
            style: AppTypography.bodySM(context).copyWith(
                color: AppColors.neutralGold, fontSize: R.sp(context, 13))),
        Text(hours,
            style: AppTypography.bodySM(context).copyWith(
                fontWeight: FontWeight.w700, fontSize: R.sp(context, 13))),
      ],
    );
  }
}
