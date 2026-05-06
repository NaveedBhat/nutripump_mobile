import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final productsAsync = ref.watch(allProductsProvider); // For upsell strip

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
      appBar: AppBar(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : Colors.white),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Column(
          children: [
            Text('Your Cart', style: AppTypography.h3(context)),
            Text(
              'HAND-HARVESTED TREASURES',
              style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10), color: AppColors.neutralGold, letterSpacing: 1.5),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (cartState.items.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              child: Text('CLEAR', style: AppTypography.label(context).copyWith(color: AppColors.error)),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: cartState.items.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                _buildFreeShippingWidget(context, cartState.subtotal, cartState.freeThreshold),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 12)),
                    children: [
                      ...cartState.items.map((item) => _buildCartItem(context, ref, item)),
                    ],
                  ),
                ),
                _buildOrderSummaryFooter(context, ref, cartState, productsAsync),
              ],
            ),
    );
  }

  // ── Gamified Free Shipping Widget ─────────────────────────────────────────
  Widget _buildFreeShippingWidget(BuildContext context, double subtotal, double freeThreshold) {
    final isUnlocked = subtotal >= freeThreshold;
    final progress = (subtotal / freeThreshold).clamp(0.0, 1.0);
    final remaining = freeThreshold - subtotal;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 20), vertical: R.h(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          if (isUnlocked)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: R.w(context, 8),
                  height: R.w(context, 8),
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
                SizedBox(width: R.w(context, 8)),
                Text('FREE EXPRESS SHIPPING UNLOCKED', style: AppTypography.label(context).copyWith(color: AppColors.success, letterSpacing: 1.2)),
              ],
            )
          else
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w600, color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
                children: [
                  const TextSpan(text: 'You are just '),
                  TextSpan(text: formatPrice(remaining), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' away from '),
                  const TextSpan(text: 'Free Shipping! 🚀', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          SizedBox(height: R.h(context, 12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(R.w(context, 10)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: R.h(context, 6),
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(isUnlocked ? AppColors.success : AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cart Item (Glassmorphism + Enhanced UI) ──────────────────────────────
  Widget _buildCartItem(BuildContext context, WidgetRef ref, CartItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(context, 12)),
      padding: EdgeInsets.all(R.w(context, 12)),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(R.w(context, 16)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              image: item.product.primaryImage.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.product.primaryImage),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(Colors.black12, BlendMode.multiply),
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
                        style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(cartProvider.notifier).removeItem(item.cartItemId),
                      child: Container(
                        padding: EdgeInsets.all(R.w(context, 4)),
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded, size: R.sp(context, 14), color: AppColors.error),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.h(context, 4)),
                Row(
                  children: [
                    Text(item.selectedWeight ?? item.product.weight, style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10), color: AppColors.neutralGold)),
                    if (item.product.stockCount > 0 && item.product.stockCount <= 5) ...[
                      SizedBox(width: R.w(context, 8)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: R.w(context, 4), vertical: R.h(context, 2)),
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(R.w(context, 4))),
                        child: Text('ONLY ${item.product.stockCount} LEFT', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 8), color: AppColors.error)),
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
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(R.w(context, 8)),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => ref.read(cartProvider.notifier).updateQuantity(item.cartItemId, item.quantity - 1),
                            child: Padding(padding: EdgeInsets.all(R.w(context, 6)), child: Icon(Icons.remove, size: R.sp(context, 14))),
                          ),
                          SizedBox(width: R.w(context, 20), child: Text('${item.quantity}', textAlign: TextAlign.center, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.bold))),
                          InkWell(
                            onTap: item.quantity < item.product.stockCount
                                ? () => ref.read(cartProvider.notifier).updateQuantity(item.cartItemId, item.quantity + 1)
                                : null,
                            child: Padding(
                              padding: EdgeInsets.all(R.w(context, 6)),
                              child: Icon(Icons.add, size: R.sp(context, 14), color: item.quantity < item.product.stockCount ? (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal) : AppColors.borderLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(formatPrice(item.effectivePrice * item.quantity), style: AppTypography.price(context).copyWith(fontSize: R.sp(context, 14), color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Upsell Strip & Footer ──────────────────────────────────────────────────
  Widget _buildOrderSummaryFooter(BuildContext context, WidgetRef ref, CartState state, AsyncValue<List<Product>> productsAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -10), blurRadius: 30)],
      ),
      child: Column(
        children: [
          // ── Upsell Strip ──
          productsAsync.when(
            data: (allProducts) {
              // Mock upsell: grab 3 items not in cart
              final cartIds = state.items.map((i) => i.product.id).toSet();
              final upsells = allProducts.where((p) => !cartIds.contains(p.id) && p.inStock).take(3).toList();

              if (upsells.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  border: Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.1))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: R.sp(context, 14), color: AppColors.primary),
                          SizedBox(width: R.w(context, 6)),
                          Text('FREQUENTLY PAIRED WITH YOUR SELECTION', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 9), color: AppColors.primary, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                    SizedBox(height: R.h(context, 12)),
                    SizedBox(
                      height: R.h(context, 100),
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
                        scrollDirection: Axis.horizontal,
                        itemCount: upsells.length,
                        separatorBuilder: (_, __) => SizedBox(width: R.w(context, 12)),
                        itemBuilder: (context, index) {
                          final p = upsells[index];
                          return Container(
                            width: R.w(context, 200),
                            padding: EdgeInsets.all(R.w(context, 8)),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(R.w(context, 12)),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: R.w(context, 50),
                                  height: R.w(context, 50),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(R.w(context, 8)),
                                    image: p.primaryImage.isNotEmpty ? DecorationImage(image: NetworkImage(p.primaryImage), fit: BoxFit.cover) : null,
                                  ),
                                ),
                                SizedBox(width: R.w(context, 10)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.bodySM(context).copyWith(fontSize: R.sp(context, 10), fontWeight: FontWeight.bold)),
                                      SizedBox(height: R.h(context, 4)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(formatPrice(p.price), style: AppTypography.price(context).copyWith(fontSize: R.sp(context, 12), color: AppColors.success)),
                                          GestureDetector(
                                            onTap: () => ref.read(cartProvider.notifier).addItem(p, qty: 1),
                                            child: Icon(Icons.add_circle_rounded, size: R.sp(context, 20), color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // ── Pricing Summary ──
          Padding(
            padding: EdgeInsets.fromLTRB(R.w(context, 24), R.h(context, 20), R.w(context, 24), R.h(context, 16)),
            child: Column(
              children: [
                // Apply Promo Button
                GestureDetector(
                  onTap: () => context.push('/cart/promos'),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 12)),
                    decoration: BoxDecoration(
                      color: state.appliedPromo != null ? AppColors.success.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(R.w(context, 12)),
                      border: Border.all(color: state.appliedPromo != null ? AppColors.success : AppColors.primary, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(state.appliedPromo != null ? Icons.check_circle_outline_rounded : Icons.local_offer_outlined, size: R.sp(context, 20), color: state.appliedPromo != null ? AppColors.success : AppColors.primary),
                        SizedBox(width: R.w(context, 12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(state.appliedPromo != null ? '\'${state.appliedPromo!.code}\' Applied' : 'Apply Promo Code', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, color: state.appliedPromo != null ? AppColors.success : (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal))),
                              if (state.appliedPromo != null) Text('You saved ${formatPrice(state.discount)}', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10), color: AppColors.success)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.neutralGold),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: R.h(context, 16)),
                
                _buildSummaryRow(context, 'Subtotal', state.subtotal),
                SizedBox(height: R.h(context, 8)),
                if (state.shipping == 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shipping Delivery', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w600, color: AppColors.success)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: R.w(context, 8), vertical: R.h(context, 2)),
                        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), border: Border.all(color: AppColors.success.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(R.w(context, 12))),
                        child: Text('FREE', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 9), color: AppColors.success)),
                      ),
                    ],
                  )
                else
                  _buildSummaryRow(context, 'Estimated Shipping', state.shipping),

                SizedBox(height: R.h(context, 8)),
                _buildSummaryRow(context, 'Estimated Taxes (${(state.gstRate * 100).toInt()}%)', state.gst),

                SizedBox(height: R.h(context, 16)),
                const Divider(color: AppColors.borderLight, height: 1),
                SizedBox(height: R.h(context, 16)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estimated Total', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.bold, textBaseline: TextBaseline.alphabetic)),
                        SizedBox(height: R.h(context, 4)),
                        Text('Taxes & shipping verified at checkout', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 9), color: AppColors.neutralGold)),
                      ],
                    ),
                    Text(formatPrice(state.total), style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 24), height: 1)),
                  ],
                ),
                SizedBox(height: R.h(context, 24)),
                
                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: R.h(context, 56),
                  child: ElevatedButton(
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null && state.appliedPromo != null &&
                         (state.appliedPromo!.isFirstOrderOnly || state.appliedPromo!.oneTimeUsePerUser)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(duration: Duration(milliseconds: 2000), 
                            content: Text('You need to log in to avail this exclusive promo code offer.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }
                      context.push('/checkout');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.deepCharcoal,
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 16))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Proceed to Checkout', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 16), color: AppColors.deepCharcoal)),
                        SizedBox(width: R.w(context, 8)),
                        Icon(Icons.arrow_forward_rounded, size: R.sp(context, 20), color: AppColors.deepCharcoal),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: R.h(context, 20)),
                
                // Trust Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTrustBadge(context, Icons.local_shipping_outlined, 'EXPRESS'),
                    SizedBox(width: R.w(context, 24)),
                    _buildTrustBadge(context, Icons.shield_outlined, 'SECURE'),
                    SizedBox(width: R.w(context, 24)),
                    _buildTrustBadge(context, Icons.verified_outlined, 'AUTHENTIC'),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: R.sp(context, 16), color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal).withValues(alpha: 0.6)),
        SizedBox(height: R.h(context, 4)),
        Text(label, style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 8), color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal).withValues(alpha: 0.6), letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontWeight: FontWeight.w500)),
        Text(formatPrice(value), style: AppTypography.bodySM(context).copyWith(color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.w(context, 32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: R.w(context, 80),
              height: R.w(context, 80),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
              child: Icon(Icons.shopping_bag_outlined, size: R.sp(context, 32), color: AppColors.primary),
            ),
            SizedBox(height: R.h(context, 20)),
            Text('Your cart is empty', style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 22))),
            SizedBox(height: R.h(context, 8)),
            Text('Discover hand-harvested artisanal treasures curated from the wild valleys of Kashmir.', textAlign: TextAlign.center, style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 12), height: 1.5)),
            SizedBox(height: R.h(context, 24)),
            SizedBox(
              width: R.w(context, 220),
              child: ElevatedButton(
                onPressed: () => context.go('/shop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.deepCharcoal,
                  elevation: 6,
                  padding: EdgeInsets.symmetric(vertical: R.h(context, 12)),
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 12))),
                ),
                child: Text('Explore The Pantry', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 13), color: AppColors.deepCharcoal)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
