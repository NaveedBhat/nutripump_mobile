import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/product.dart';

class SizeSelector extends StatelessWidget {
  final List<ProductSize> sizes;
  final ProductSize? selectedSize;
  final ValueChanged<ProductSize> onSizeSelected;

  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SELECT JAR SIZE',
                style: AppTypography.label(context).copyWith(
                    color: AppColors.neutralGold,
                    letterSpacing: 1.5,
                    fontSize: R.sp(context, 10))),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: R.w(context, 6), vertical: R.h(context, 2)),
              decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(R.w(context, 4))),
              child: Text('SMALL BATCH FRESH',
                  style: AppTypography.label(context).copyWith(
                      color: AppColors.primary, fontSize: R.sp(context, 8))),
            ),
          ],
        ),
        SizedBox(height: R.h(context, 12)),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            crossAxisSpacing: R.w(context, 10),
            mainAxisSpacing: R.h(context, 10),
          ),
          itemCount: sizes.length,
          itemBuilder: (context, idx) {
            final size = sizes[idx];
            final isSelected = selectedSize?.label == size.label;
            return GestureDetector(
              onTap: () => onSizeSelected(size),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 12)),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : Colors.white.withValues(alpha: 0.5)),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(R.w(context, 12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      size.label,
                      style: AppTypography.bodySM(context).copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.onSurface
                                  : AppColors.deepCharcoal)
                              : AppColors.neutralGold,
                          fontSize: R.sp(context, 12)),
                    ),
                    Text(
                      formatPrice(size.price),
                      style: AppTypography.label(context).copyWith(
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.neutralGold,
                          fontSize: R.sp(context, 10)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
