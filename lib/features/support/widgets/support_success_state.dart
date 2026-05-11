import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/animated_enter.dart';
import '../../../core/widgets/primary_button.dart';

class SupportSuccessState extends StatelessWidget {
  final String orderId;

  const SupportSuccessState({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedEnter(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: R.w(context, 24), vertical: R.h(context, 48)),
        child: Column(
          children: [
            Container(
              width: R.w(context, 80),
              height: R.w(context, 80),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: R.sp(context, 40)),
            ),
            SizedBox(height: R.h(context, 24)),
            Text(
              'Ticket Submitted',
              style: AppTypography.h2(context)
                  .copyWith(fontSize: R.sp(context, 28)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.h(context, 12)),
            Text(
              'Our dedicated concierge team has received your request concerning order $orderId. We will prioritize this and respond within 12 hours.',
              style: AppTypography.bodySM(context)
                  .copyWith(color: AppColors.neutralGold, height: 1.6),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.h(context, 32)),
            PrimaryButton(
              text: 'Return to Dashboard',
              onPressed: () => context.go('/account'),
            ),
          ],
        ),
      ),
    );
  }
}
