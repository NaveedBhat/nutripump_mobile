import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── App Bar — clean, no item count / clear all ───────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: Text('Saved for Later', style: AppTypography.h3),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.borderLight),
            ),
          ),

          // ── Empty State ───────────────────────────────────────────────
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyWishlist(),
            )
          else ...[
            // ── Item count + Clear All row ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    Text(
                      '${items.length} item${items.length == 1 ? '' : 's'}',
                      style: AppTypography.bodySM.copyWith(
                        color: AppColors.neutralGold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _confirmClearAll(context, ref),
                      child: Text(
                        'Clear All',
                        style: AppTypography.bodySM.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
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
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.13)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swipe_left_outlined,
                        size: 15, color: AppColors.neutralGold),
                    const SizedBox(width: 8),
                    Text(
                      'Swipe left on a card to remove it',
                      style: AppTypography.bodySM.copyWith(
                        color: AppColors.neutralGold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Product Grid ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _WishlistCard(
                    product: items[i],
                    index: i,
                  ),
                  childCount: items.length,
                ),
              ),
            ),

            // ── Move All to Cart ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 0, 16, MediaQuery.of(context).padding.bottom + 24),
                child: ElevatedButton.icon(
                  onPressed: () => _moveAllToCart(context, ref, items),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: const Text('Move All to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepCharcoal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear Wishlist', style: AppTypography.h3),
        content: Text(
          'Remove all items from your wishlist?',
          style: AppTypography.bodySM.copyWith(color: AppColors.neutralGold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel',
                style: AppTypography.bodySM
                    .copyWith(color: AppColors.neutralGold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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

// ═══════════════════════════════════════════════════════════════════════════
// Empty State
// ═══════════════════════════════════════════════════════════════════════════
class _EmptyWishlist extends StatefulWidget {
  @override
  State<_EmptyWishlist> createState() => _EmptyWishlistState();
}

class _EmptyWishlistState extends State<_EmptyWishlist>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text('Your wishlist is empty',
                  style: AppTypography.h2.copyWith(fontSize: 20)),
              const SizedBox(height: 12),
              Text(
                'Explore our artisanal collection and save your favorites to review them later.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySM.copyWith(
                  color: AppColors.neutralGold,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/shop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.deepCharcoal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Explore the Shop',
                    style: AppTypography.bodySM.copyWith(
                        fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/categories'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Browse Collections',
                    style: AppTypography.bodySM.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepCharcoal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Wishlist Card
// ═══════════════════════════════════════════════════════════════════════════
class _WishlistCard extends ConsumerStatefulWidget {
  final Product product;
  final int index;
  const _WishlistCard({required this.product, required this.index});

  @override
  ConsumerState<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends ConsumerState<_WishlistCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterOpacity;
  late final Animation<Offset> _enterSlide;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 380 + widget.index * 60),
    );
    _enterOpacity =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 70), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  void _removeFromWishlist() {
    HapticFeedback.lightImpact();
    ref.read(wishlistProvider.notifier).toggle(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} removed'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () =>
              ref.read(wishlistProvider.notifier).toggle(widget.product),
        ),
      ),
    );
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    ref.read(cartProvider.notifier).addItem(
      widget.product,
      weight: widget.product.weight,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return FadeTransition(
      opacity: _enterOpacity,
      child: SlideTransition(
        position: _enterSlide,
        child: Dismissible(
          key: ValueKey(product.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _removeFromWishlist(),
          background: Container(
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 22),
                const SizedBox(height: 4),
                Text('Remove',
                    style: AppTypography.label
                        .copyWith(color: AppColors.error, fontSize: 9)),
              ],
            ),
          ),
          child: GestureDetector(
            onTap: () => context.push('/product/${product.slug}'),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepCharcoal.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image ──────────────────────────────────────────
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                          child: CustomNetworkImage(
                            imageUrl: product.primaryImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Badge top-left
                        if (product.badge != null)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.93),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.badge!.toUpperCase(),
                                style: AppTypography.label.copyWith(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        // Discount top-right
                        if (product.discountPercent > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${product.discountPercent}%',
                                style: AppTypography.label.copyWith(
                                  fontSize: 7.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        // Heart remove (shown when no discount badge)
                        if (product.discountPercent == 0)
                          Positioned(
                            top: 7,
                            right: 7,
                            child: GestureDetector(
                              onTap: _removeFromWishlist,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  size: 14,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Product info ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Origin · Weight
                        Text(
                          [
                            if (product.origin.isNotEmpty)
                              product.origin.toUpperCase(),
                            product.weight,
                          ].join(' · '),
                          style: AppTypography.labelGold
                              .copyWith(fontSize: 7.5, letterSpacing: 0.3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Name
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySM.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 7),

                        // ── Price + Cart icon in ONE row ───────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Price
                            Expanded(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    formatPrice(product.price),
                                    style: AppTypography.priceSM
                                        .copyWith(fontSize: 14),
                                  ),
                                  if (product.compareAtPrice != null &&
                                      product.compareAtPrice! >
                                          product.price) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      formatPrice(product.compareAtPrice!),
                                      style: AppTypography.priceStrike
                                          .copyWith(fontSize: 9.5),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Cart icon button
                            GestureDetector(
                              onTap: _addToCart,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 16,
                                  color: AppColors.deepCharcoal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
