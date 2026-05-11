import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/cart_provider.dart';
import '../../../models/product.dart';

class WishlistCard extends ConsumerStatefulWidget {
  final Product product;
  final int index;
  const WishlistCard({super.key, required this.product, required this.index});

  @override
  ConsumerState<WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends ConsumerState<WishlistCard>
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
    _enterOpacity = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
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
        duration: const Duration(milliseconds: 2000),
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
        duration: const Duration(milliseconds: 2000),
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
                    style: AppTypography.label(context).copyWith(
                        color: AppColors.error, fontSize: R.sp(context, 8))),
              ],
            ),
          ),
          child: GestureDetector(
            onTap: () => context.push('/product/${product.slug}'),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : Colors.white,
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurface
                            : AppColors.deepCharcoal)
                        .withValues(alpha: 0.05),
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
                                  horizontal: R.w(context, 6),
                                  vertical: R.h(context, 3)),
                              decoration: BoxDecoration(
                                color: (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.surfaceDark
                                        : Colors.white)
                                    .withValues(alpha: 0.93),
                                borderRadius:
                                    BorderRadius.circular(R.w(context, 4)),
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
                                  horizontal: R.w(context, 5),
                                  vertical: R.h(context, 3)),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius:
                                    BorderRadius.circular(R.w(context, 4)),
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
                                  color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.surfaceDark
                                          : Colors.white)
                                      .withValues(alpha: 0.9),
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
                    padding: EdgeInsets.fromLTRB(R.w(context, 10),
                        R.h(context, 8), R.w(context, 10), R.h(context, 10)),
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
                          style: AppTypography.labelGold(context).copyWith(
                              fontSize: R.sp(context, 7.5), letterSpacing: 0.3),
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
                                crossAxisAlignment: CrossAxisAlignment.baseline,
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
                                  borderRadius:
                                      BorderRadius.circular(R.w(context, 8)),
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
