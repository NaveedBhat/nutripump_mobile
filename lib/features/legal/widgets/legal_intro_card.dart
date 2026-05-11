import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class LegalIntroCard extends StatelessWidget {
  final String text;

  const LegalIntroCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          R.w(context, 16), R.h(context, 16), R.w(context, 16), 0),
      child: Container(
        padding: EdgeInsets.all(R.w(context, 18)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 16)),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: AppTypography.bodySM(context).copyWith(
            fontSize: R.sp(context, 13),
            height: 1.7,
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.deepCharcoal)
                .withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}
