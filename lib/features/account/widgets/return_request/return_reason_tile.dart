import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/responsive.dart';

class ReturnReasonTile extends StatelessWidget {
  final String reason;
  final bool isSelected;
  final VoidCallback onTap;

  const ReturnReasonTile({
    super.key,
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(context, 8)),
        padding: EdgeInsets.symmetric(
            horizontal: R.w(context, 14), vertical: R.h(context, 12)),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 10)),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: R.w(context, 18),
              height: R.w(context, 18),
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
                      size: R.sp(context, 10),
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.deepCharcoal))
                  : null,
            ),
            SizedBox(width: R.w(context, 10)),
            Text(reason,
                style: AppTypography.bodySM(context)
                    .copyWith(fontSize: R.sp(context, 13))),
          ],
        ),
      ),
    );
  }
}
