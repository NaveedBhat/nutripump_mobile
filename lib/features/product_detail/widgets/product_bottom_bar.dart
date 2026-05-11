import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';

class ProductBottomBar extends ConsumerStatefulWidget {
  final Product product;
  final ProductSize? effectiveSize;
  final double displayPrice;

  const ProductBottomBar({
    super.key,
    required this.product,
    required this.effectiveSize,
    required this.displayPrice,
  });

  @override
  ConsumerState<ProductBottomBar> createState() => _ProductBottomBarState();
}

class _ProductBottomBarState extends ConsumerState<ProductBottomBar> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            R.w(context, 20),
            R.h(context, 12),
            R.w(context, 20),
            MediaQuery.of(context).padding.bottom + R.h(context, 12)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          border: const Border(top: BorderSide(color: AppColors.borderLight)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                offset: const Offset(0, -5),
                blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(R.w(context, 12)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: R.sp(context, 16)),
                    onPressed: () => setState(() {
                      if (_quantity > 1) _quantity--;
                    }),
                    color: AppColors.neutralGold,
                    padding: EdgeInsets.all(R.w(context, 8)),
                    constraints: const BoxConstraints(),
                  ),
                  Text('$_quantity',
                      style: AppTypography.h3(context)
                          .copyWith(fontSize: R.sp(context, 14))),
                  IconButton(
                    icon: Icon(Icons.add, size: R.sp(context, 16)),
                    onPressed: _quantity < widget.product.stockCount
                        ? () => setState(() {
                              _quantity++;
                            })
                        : null,
                    color: _quantity < widget.product.stockCount
                        ? AppColors.neutralGold
                        : AppColors.borderLight,
                    padding: EdgeInsets.all(R.w(context, 8)),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            SizedBox(width: R.w(context, 12)),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).addItem(
                        widget.product,
                        qty: _quantity,
                        weight: widget.effectiveSize?.label ?? widget.product.weight,
                        bundlePrice: widget.effectiveSize?.price ?? widget.product.price,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 2000),
                      content: const Text('Added to cart'),
                      action: SnackBarAction(
                          label: 'VIEW CART',
                          onPressed: () => context.push('/cart')),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.deepCharcoal,
                  padding: EdgeInsets.symmetric(vertical: R.h(context, 14)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.w(context, 12))),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: R.sp(context, 16), color: AppColors.deepCharcoal),
                    SizedBox(width: R.w(context, 6)),
                    Text('Add to Bag — ${formatPrice(widget.displayPrice * _quantity)}',
                        style: AppTypography.bodySM(context).copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: R.sp(context, 12),
                            color: AppColors.deepCharcoal)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
