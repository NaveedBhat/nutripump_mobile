import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../../providers/providers.dart';
import 'widgets/empty_wishlist.dart';
import 'widgets/wishlist_card.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for tab re-tap to scroll to top (Wishlist is index 3).
    // ref.listen MUST be called inside build — not initState.
    ref.listen<int?>(scrollTabEventProvider, (_, index) {
      if (index == 3 && _scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    final items = ref.watch(wishlistProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColors.backgroundLight),
      bottomNavigationBar: items.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.fromLTRB(
                  R.w(context, 16),
                  R.h(context, 16),
                  R.w(context, 16),
                  MediaQuery.paddingOf(context).bottom + R.h(context, 16)),
              child: ElevatedButton.icon(
                onPressed: () => _moveAllToCart(context, ref, items),
                icon: Icon(Icons.shopping_bag_outlined,
                    size: R.sp(context, 16), color: AppColors.deepCharcoal),
                label: Text(
                  'Move All to Cart',
                  style: AppTypography.bodySM(context).copyWith(
                    color: AppColors.deepCharcoal,
                    fontSize: R.sp(context, 13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.deepCharcoal,
                  padding: EdgeInsets.symmetric(vertical: R.h(context, 14)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.w(context, 12))),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── App Bar — clean, no item count / clear all ───────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: (Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).scaffoldBackgroundColor
                : Colors.white),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: Text('Saved for Later',
                style: AppTypography.h3(context)
                    .copyWith(fontSize: R.sp(context, 16))),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.borderLight),
            ),
          ),

          // ── Empty State ───────────────────────────────────────────────
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyWishlist(),
            )
          else ...[
            // ── Item count + Clear All row ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 16),
                    R.w(context, 16), R.h(context, 4)),
                child: Row(
                  children: [
                    Text(
                      '${items.length} item${items.length == 1 ? '' : 's'}',
                      style: AppTypography.bodySM(context).copyWith(
                        color: AppColors.neutralGold,
                        fontWeight: FontWeight.w600,
                        fontSize: R.sp(context, 12),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _confirmClearAll(context, ref),
                      child: Text(
                        'Clear All',
                        style: AppTypography.bodySM(context).copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(context, 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Swipe hint ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 8),
                    R.w(context, 16), R.h(context, 4)),
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 12), vertical: R.h(context, 8)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(R.w(context, 10)),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.13)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.swipe_left_outlined,
                        size: R.sp(context, 14), color: AppColors.neutralGold),
                    SizedBox(width: R.w(context, 8)),
                    Text(
                      'Swipe left on a card to remove it',
                      style: AppTypography.bodySM(context).copyWith(
                        color: AppColors.neutralGold,
                        fontSize: R.sp(context, 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Product Grid ────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 12),
                  R.w(context, 16), R.h(context, 16)),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: R.w(context, 10),
                  mainAxisSpacing: R.h(context, 10),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => WishlistCard(
                    product: items[i],
                    index: i,
                  ),
                  childCount: items.length,
                ),
              ),
            ),

            // Padding so the last item isn't covered by the floating button
            if (items.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(height: R.h(context, 100)),
              ),
          ],
        ],
      ),
    );
  }

  void _moveAllToCart(
      BuildContext context, WidgetRef ref, List<Product> items) {
    for (final p in items) {
      ref.read(cartProvider.notifier).addItem(p, weight: p.weight);
    }
    ref.read(wishlistProvider.notifier).clear();
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2000),
        content: Text('${items.length} items moved to cart'),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(R.w(context, 16))),
        title: Text('Clear Wishlist', style: AppTypography.h3(context)),
        content: Text(
          'Remove all items from your wishlist?',
          style: AppTypography.bodySM(context)
              .copyWith(color: AppColors.neutralGold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel',
                style: AppTypography.bodySM(context)
                    .copyWith(color: AppColors.neutralGold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.w(context, 10))),
              elevation: 0,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(wishlistProvider.notifier).clear();
      HapticFeedback.mediumImpact();
    }
  }
}
