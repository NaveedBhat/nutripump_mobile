import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';

class FreeShippingProgress extends StatelessWidget {
  final double subtotal;
  final double threshold;

  const FreeShippingProgress({
    super.key,
    required this.subtotal,
    required this.threshold,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = subtotal >= threshold;
    final progress = (subtotal / threshold).clamp(0.0, 1.0);
    final remaining = threshold - subtotal;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: R.w(context, 20), vertical: R.h(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border(
            bottom:
                BorderSide(color: AppColors.primary.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          if (isUnlocked)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: R.w(context, 8),
                  height: R.w(context, 8),
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle),
                ),
                SizedBox(width: R.w(context, 8)),
                Text('FREE EXPRESS SHIPPING UNLOCKED',
                    style: AppTypography.label(context).copyWith(
                        color: AppColors.success, letterSpacing: 1.2)),
              ],
            )
          else
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTypography.bodySM(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onSurface
                        : AppColors.deepCharcoal)),
                children: [
                  const TextSpan(text: 'You are just '),
                  TextSpan(
                      text: formatPrice(remaining),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' away from '),
                  const TextSpan(
                      text: 'Free Shipping! 🚀',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          SizedBox(height: R.h(context, 12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(R.w(context, 10)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: R.h(context, 6),
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                  isUnlocked ? AppColors.success : AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
