import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../models/order.dart';

class ReturnOrderSelectionCard extends StatelessWidget {
  final Order order;
  final bool isSelected;
  final VoidCallback onTap;

  const ReturnOrderSelectionCard({
    super.key,
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(context, 10)),
        padding: EdgeInsets.all(R.w(context, 14)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onSurface
                        : AppColors.deepCharcoal)
                    .withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: R.w(context, 20),
              height: R.w(context, 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.borderLight,
                    width: 1.5),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded,
                      size: R.sp(context, 12),
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.deepCharcoal))
                  : null,
            ),
            SizedBox(width: R.w(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatOrderId(order.id),
                      style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: R.sp(context, 13))),
                  SizedBox(height: R.h(context, 2)),
                  Text(
                    order.items
                        .map((i) => i.product.name)
                        .where((n) => n.isNotEmpty)
                        .take(2)
                        .join(', '),
                    style: AppTypography.bodySM(context).copyWith(
                        fontSize: R.sp(context, 11),
                        color: AppColors.neutralGold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(formatPrice(order.total),
                style: AppTypography.bodySM(context).copyWith(
                    fontWeight: FontWeight.w700, fontSize: R.sp(context, 13))),
          ],
        ),
      ),
    );
  }
}
