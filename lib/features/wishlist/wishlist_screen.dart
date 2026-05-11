import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../../providers/providers.dart';

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
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });

    final items = ref.watch(wishlistProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
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
            backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : Colors.white),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: Text('Saved for Later', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
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
                padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 16), R.w(context, 16), R.h(context, 4)),
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
                margin: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 8), R.w(context, 16), R.h(context, 4)),
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 12), vertical: R.h(context, 8)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(R.w(context, 10)),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.13)),
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
              padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 12), R.w(context, 16), R.h(context, 16)),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: R.w(context, 10),
                  mainAxisSpacing: R.h(context, 10),
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
      SnackBar(duration: const Duration(milliseconds: 2000), 
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 16))),
        title: Text('Clear Wishlist', style: AppTypography.h3(context)),
        content: Text(
          'Remove all items from your wishlist?',
          style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold),
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
          padding: EdgeInsets.symmetric(horizontal: R.w(context, 40), vertical: R.h(context, 60)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: R.w(context, 70),
                  height: R.w(context, 70),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
                  ),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: R.sp(context, 28),
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: R.h(context, 20)),
              Text('Your wishlist is empty',
                  style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 18))),
              SizedBox(height: R.h(context, 8)),
              Text(
                'Explore our artisanal collection and save your favorites to review them later.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySM(context).copyWith(
                  color: AppColors.neutralGold,
                  height: 1.4,
                  fontSize: R.sp(context, 11),
                ),
              ),
              SizedBox(height: R.h(context, 24)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/shop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.deepCharcoal,
                    padding: EdgeInsets.symmetric(vertical: R.h(context, 12)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 10))),
                    elevation: 0,
                  ),
                  child: Text(
                    'Explore the Shop',
                    style: AppTypography.bodySM(context).copyWith(
                        fontWeight: FontWeight.w800, fontSize: R.sp(context, 11)),
                  ),
                ),
              ),
              SizedBox(height: R.h(context, 10)),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/categories'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: EdgeInsets.symmetric(vertical: R.h(context, 11)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 10))),
                  ),
                  child: Text(
                    'Browse Collections',
                    style: AppTypography.bodySM(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
                      fontSize: R.sp(context, 11),
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
      SnackBar(duration: const Duration(milliseconds: 2000), 
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
      SnackBar(duration: const Duration(milliseconds: 2000), 
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
              borderRadius: BorderRadius.circular(R.w(context, 12)),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: R.w(context, 16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: R.sp(context, 20)),
                SizedBox(height: R.h(context, 4)),
                Text('Remove',
                    style: AppTypography.label(context)
                        .copyWith(color: AppColors.error, fontSize: R.sp(context, 8))),
              ],
            ),
          ),
          child: GestureDetector(
            onTap: () => context.push('/product/${product.slug}'),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal).withValues(alpha: 0.05),
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
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(R.w(context, 12))),
                          child: CustomNetworkImage(
                            imageUrl: product.primaryImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Badge top-left
                        if (product.badge != null)
                          Positioned(
                            top: R.h(context, 8),
                            left: R.w(context, 8),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: R.w(context, 6), vertical: R.h(context, 3)),
                              decoration: BoxDecoration(
                                color: (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.93),
                                borderRadius: BorderRadius.circular(R.w(context, 4)),
                              ),
                              child: Text(
                                product.badge!.toUpperCase(),
                                style: AppTypography.label(context).copyWith(
                                  fontSize: R.sp(context, 7),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                        // Discount top-right
                        if (product.discountPercent > 0)
                          Positioned(
                            top: R.h(context, 8),
                            right: R.w(context, 8),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: R.w(context, 5), vertical: R.h(context, 3)),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(R.w(context, 4)),
                              ),
                              child: Text(
                                '-${product.discountPercent}%',
                                style: AppTypography.label(context).copyWith(
                                  fontSize: R.sp(context, 7.5),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        // Heart remove (shown when no discount badge)
                        if (product.discountPercent == 0)
                          Positioned(
                            top: R.h(context, 7),
                            right: R.w(context, 7),
                            child: GestureDetector(
                              onTap: _removeFromWishlist,
                              child: Container(
                                width: R.w(context, 26),
                                height: R.w(context, 26),
                                decoration: BoxDecoration(
                                  color: (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: R.sp(context, 13),
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
                    padding: EdgeInsets.fromLTRB(R.w(context, 10), R.h(context, 8), R.w(context, 10), R.h(context, 10)),
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
                          style: AppTypography.labelGold(context)
                              .copyWith(fontSize: R.sp(context, 7.5), letterSpacing: 0.3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: R.h(context, 2)),
                        // Name
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySM(context).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: R.sp(context, 11),
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: R.h(context, 6)),

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
                                    style: AppTypography.priceSM(context)
                                        .copyWith(fontSize: R.sp(context, 13)),
                                  ),
                                  if (product.compareAtPrice != null &&
                                      product.compareAtPrice! >
                                          product.price) ...[
                                    SizedBox(width: R.w(context, 4)),
                                    Text(
                                      formatPrice(product.compareAtPrice!),
                                      style: AppTypography.priceStrike(context)
                                          .copyWith(fontSize: R.sp(context, 9)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Cart icon button
                            GestureDetector(
                              onTap: _addToCart,
                              child: Container(
                                width: R.w(context, 30),
                                height: R.w(context, 30),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(R.w(context, 8)),
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  size: R.sp(context, 15),
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
