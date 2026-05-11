import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/product.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';

class ChatProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onClose;

  const ChatProductCard({super.key, required this.product, this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onClose != null) onClose!();
        context.push('/product/${product.slug}');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(context, 6)),
        padding: EdgeInsets.all(R.w(context, 8)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: R.w(context, 40),
              height: R.w(context, 40),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(R.w(context, 8)),
              ),
              clipBehavior: Clip.antiAlias,
              child: product.images.isNotEmpty
                  ? Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.shopping_bag_outlined,
                      size: R.sp(context, 16), color: AppColors.primary),
            ),
            SizedBox(width: R.w(context, 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySM(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: R.sp(context, 12),
                    ),
                  ),
                  SizedBox(height: R.h(context, 2)),
                  Text(
                    formatPrice(product.price),
                    style: AppTypography.bodySM(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: R.sp(context, 11),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: R.sp(context, 14),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
