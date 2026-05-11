import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class EntireAgreementBanner extends StatelessWidget {
  const EntireAgreementBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          R.w(context, 16), 0, R.w(context, 16), R.h(context, 16)),
      child: Container(
        padding: EdgeInsets.all(R.w(context, 18)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(R.w(context, 14)),
          border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : const Color(0xFFFDE68A)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.balance_outlined,
                color: const Color(0xFFD97706), size: R.sp(context, 20)),
            SizedBox(width: R.w(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entire Agreement',
                    style: AppTypography.bodySM(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: R.sp(context, 13),
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.deepCharcoal),
                    ),
                  ),
                  SizedBox(height: R.h(context, 4)),
                  Text(
                    'These Terms of Service, together with our Privacy Policy, constitute the entire agreement between you and NutriPump Artisanal regarding your use of our services and supersede all prior agreements between the parties.',
                    style: AppTypography.bodySM(context).copyWith(
                      fontSize: R.sp(context, 12),
                      height: 1.6,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.onSurface
                              : AppColors.deepCharcoal)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
