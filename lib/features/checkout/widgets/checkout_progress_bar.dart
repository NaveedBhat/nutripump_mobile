import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../checkout_screen.dart';

class CheckoutProgressBar extends ConsumerWidget {
  final int currentStep;
  final List<String> steps;

  const CheckoutProgressBar({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : Colors.white,
      padding: EdgeInsets.symmetric(
          vertical: R.h(context, 24), horizontal: R.w(context, 32)),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ── Background Connector Lines ──
          Positioned(
            top: R.h(context,
                15), // Centers the 2px line exactly behind the 32px circles
            left: R.w(context, 16), // Offset by half the circle width
            right: R.w(context, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: R.h(context, 2),
                    color: 0 < currentStep
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: R.h(context, 2),
                    color: 1 < currentStep
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                ),
              ],
            ),
          ),
          // ── Foreground Circles & Labels ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length, (i) {
              final isCompleted = i < currentStep;
              final isActive = i <= currentStep;
              final isCurrent = i == currentStep;

              return GestureDetector(
                  onTap: isCompleted
                      ? () => ref.read(checkoutStepProvider.notifier).state = i
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: R.w(context, 32),
                        height: R.w(context, 32),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.white,
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.borderLight,
                            width: R.w(context, 2),
                          ),
                          shape: BoxShape.circle,
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      spreadRadius: 1)
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: isCompleted
                            ? Icon(Icons.check_rounded,
                                size: R.sp(context, 16), color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: AppTypography.label(context).copyWith(
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.neutralGold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      SizedBox(height: R.h(context, 10)),
                      Text(
                        steps[i].toUpperCase(),
                        style: AppTypography.label(context).copyWith(
                          fontSize: R.sp(context, 8),
                          letterSpacing: 1.2,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.neutralGold,
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ));
            }),
          ),
        ],
      ),
    );
  }
}
