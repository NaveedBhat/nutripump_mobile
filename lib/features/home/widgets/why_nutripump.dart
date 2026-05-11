import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class WhyNutriPump extends StatelessWidget {
  const WhyNutriPump({super.key});

  @override
  Widget build(BuildContext context) {
    final values = [
      (
        Icons.thermostat_outlined,
        'Cold-Pressed',
        'Nutrients preserved at every step'
      ),
      (
        Icons.location_on_outlined,
        'Srinagar Origin',
        'Sourced directly from Kashmir\'s valleys'
      ),
      (Icons.science_outlined, 'Lab Verified', 'Every batch tested for purity'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHY NUTRIPUMP',
              style: AppTypography.label(context).copyWith(
                  color: AppColors.primary,
                  fontSize: R.sp(context, 9),
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w900)),
          SizedBox(height: R.h(context, 4)),
          Text('Crafted Different',
              style: AppTypography.h2(context)
                  .copyWith(fontSize: R.sp(context, 18))),
          SizedBox(height: R.h(context, 14)),
          Row(
            children: values.map((v) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      right: v == values.last ? 0 : R.w(context, 10)),
                  padding: EdgeInsets.all(R.w(context, 12)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(R.w(context, 14)),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(R.w(context, 7)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(R.w(context, 8)),
                        ),
                        child: Icon(v.$1,
                            color: AppColors.primary, size: R.sp(context, 15)),
                      ),
                      SizedBox(height: R.h(context, 8)),
                      Text(v.$2,
                          textAlign: TextAlign.center,
                          style: AppTypography.label(context).copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: R.sp(context, 10),
                              height: 1.2)),
                      SizedBox(height: R.h(context, 3)),
                      Text(v.$3,
                          textAlign: TextAlign.center,
                          style: AppTypography.label(context).copyWith(
                              color: AppColors.neutralGold,
                              fontSize: R.sp(context, 8),
                              height: 1.3)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
