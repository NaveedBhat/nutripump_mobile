import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/cart_provider.dart';
import '../../providers/providers.dart';
import 'widgets/empty_cart_state.dart';
import 'widgets/free_shipping_progress.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_footer.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final productsAsync = ref.watch(allProductsProvider); // For upsell strip

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColors.backgroundLight),
      appBar: AppBar(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Column(
          children: [
            Text('Your Cart', style: AppTypography.h3(context)),
            Text(
              'HAND-HARVESTED TREASURES',
              style: AppTypography.label(context).copyWith(
                  fontSize: R.sp(context, 10),
                  color: AppColors.neutralGold,
                  letterSpacing: 1.5),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (cartState.items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              child: Text('CLEAR',
                  style: AppTypography.label(context)
                      .copyWith(color: AppColors.error)),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: cartState.items.isEmpty
          ? const EmptyCartState()
          : Column(
              children: [
                FreeShippingProgress(
                  subtotal: cartState.subtotal,
                  threshold: cartState.freeThreshold,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                        horizontal: R.w(context, 16),
                        vertical: R.h(context, 12)),
                    children: [
                      ...cartState.items
                          .map((item) => CartItemCard(item: item)),
                    ],
                  ),
                ),
                CartFooter(
                  state: cartState,
                  productsAsync: productsAsync,
                ),
              ],
            ),
    );
  }
}

