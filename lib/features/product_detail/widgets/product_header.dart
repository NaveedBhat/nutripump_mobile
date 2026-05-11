import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/product.dart';

class ProductHeader extends StatelessWidget {
  final Product product;
  final double price;
  final double? compareAt;

  const ProductHeader({
    super.key,
    required this.product,
    required this.price,
    this.compareAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.shortDescription.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: R.h(context, 8)),
            child: Text(
              product.shortDescription.toUpperCase(),
              style: AppTypography.label(context).copyWith(
                color: AppColors.primary,
                letterSpacing: 2.0,
                fontSize: R.sp(context, 9),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        Text(product.name,
            style: AppTypography.h1(context)
                .copyWith(fontSize: R.sp(context, 26), height: 1.1)),
        SizedBox(height: R.h(context, 12)),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: R.w(context, 8),
          runSpacing: R.h(context, 6),
          children: [
            Text(formatPrice(price),
                style: AppTypography.h2(context)
                    .copyWith(fontSize: R.sp(context, 24))),
            if (compareAt != null && compareAt! > price) ...[
              Text(
                formatPrice(compareAt!),
                style: AppTypography.priceStrike(context).copyWith(
                    fontSize: R.sp(context, 16), decorationThickness: 2),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 7), vertical: R.h(context, 3)),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(R.w(context, 5)),
                ),
                child: Text(
                  '${calculateDiscount(compareAt!, price)}% OFF',
                  style: AppTypography.label(context).copyWith(
                    color: AppColors.error,
                    fontSize: R.sp(context, 9),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: R.h(context, 12)),
        Row(
          children: [
            Row(
              children: List.generate(
                  5,
                  (index) => Icon(
                        Icons.star,
                        size: R.sp(context, 14),
                        color: index < (product.rating.floor())
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                      )),
            ),
            SizedBox(width: R.w(context, 6)),
            Text(
              '${product.reviewCount} REVIEWS',
              style: AppTypography.label(context).copyWith(
                  color: AppColors.neutralGold,
                  fontSize: R.sp(context, 9),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    );
  }
}
