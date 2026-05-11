import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/cart_item.dart';
import '../../../providers/cart_provider.dart';

class CartItemCard extends ConsumerWidget {
  final CartItem item;
  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(context, 12)),
      padding: EdgeInsets.all(R.w(context, 12)),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.white)
            .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(R.w(context, 16)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
              color: (Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.deepCharcoal)
                  .withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: R.w(context, 80),
            height: R.w(context, 80),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(R.w(context, 12)),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              image: item.product.primaryImage.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.product.primaryImage),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                          Colors.black12, BlendMode.multiply),
                    )
                  : null,
            ),
            child: item.product.primaryImage.isEmpty
                ? const Icon(Icons.image_outlined, color: AppColors.neutralGold)
                : null,
          ),
          SizedBox(width: R.w(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySM(context).copyWith(
                            fontWeight: FontWeight.w800,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context).colorScheme.onSurface
                                    : AppColors.deepCharcoal)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .removeItem(item.cartItemId),
                      child: Container(
                        padding: EdgeInsets.all(R.w(context, 4)),
                        decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded,
                            size: R.sp(context, 14), color: AppColors.error),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.h(context, 4)),
                Row(
                  children: [
                    Text(item.selectedWeight ?? item.product.weight,
                        style: AppTypography.label(context).copyWith(
                            fontSize: R.sp(context, 10),
                            color: AppColors.neutralGold)),
                    if (item.product.stockCount > 0 &&
                        item.product.stockCount <= 5) ...[
                      SizedBox(width: R.w(context, 8)),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: R.w(context, 4),
                            vertical: R.h(context, 2)),
                        decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(R.w(context, 4))),
                        child: Text('ONLY ${item.product.stockCount} LEFT',
                            style: AppTypography.label(context).copyWith(
                                fontSize: R.sp(context, 8),
                                color: AppColors.error)),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: R.h(context, 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.surfaceDark
                            : Colors.white,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(R.w(context, 8)),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .updateQuantity(
                                    item.cartItemId, item.quantity - 1),
                            child: Padding(
                                padding: EdgeInsets.all(R.w(context, 6)),
                                child: Icon(Icons.remove,
                                    size: R.sp(context, 14))),
                          ),
                          SizedBox(
                              width: R.w(context, 20),
                              child: Text('${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodySM(context)
                                      .copyWith(fontWeight: FontWeight.bold))),
                          InkWell(
                            onTap: item.quantity < item.product.stockCount
                                ? () => ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(
                                        item.cartItemId, item.quantity + 1)
                                : null,
                            child: Padding(
                              padding: EdgeInsets.all(R.w(context, 6)),
                              child: Icon(Icons.add,
                                  size: R.sp(context, 14),
                                  color: item.quantity < item.product.stockCount
                                      ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                          : AppColors.deepCharcoal)
                                      : AppColors.borderLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(formatPrice(item.effectivePrice * item.quantity),
                        style: AppTypography.price(context).copyWith(
                            fontSize: R.sp(context, 14),
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context).colorScheme.onSurface
                                    : AppColors.deepCharcoal))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
