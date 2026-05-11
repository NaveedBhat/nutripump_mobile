import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/providers.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../../models/models.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/skeleton_loaders.dart';
import 'widgets/product_detail_app_bar.dart';
import 'widgets/product_header.dart';
import 'widgets/size_selector.dart';
import 'widgets/trust_badges.dart';
import 'widgets/product_tabs.dart';
import 'widgets/frequently_bought_together.dart';
import 'widgets/product_reviews_section.dart';
import 'widgets/you_may_also_like.dart';
import 'widgets/product_bottom_bar.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  final String? promoCode;
  const ProductDetailScreen({super.key, required this.slug, this.promoCode});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductSize? _selectedSize;
  Product? _currentProduct;

  /// Returns the currently selected size, falling back to the first available
  /// size. Computed so it is accessible in all helper methods.
  ProductSize? get effectiveSize =>
      _selectedSize ??
      (_currentProduct?.sizes?.isNotEmpty == true
          ? _currentProduct!.sizes!.first
          : null);

  @override
  void initState() {
    super.initState();
    // ── Deep Link Promo Handler — fetch & apply the real promo ───────────
    if (widget.promoCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyDeepLinkPromo(widget.promoCode!);
      });
    }
  }

  Future<void> _applyDeepLinkPromo(String rawCode) async {
    if (!mounted) return;
    final code = rawCode.toUpperCase();
    try {
      final snap = await FirebaseFirestore.instance
          .collection('promoCodes')
          .doc(code)
          .get();

      if (!mounted) return;

      if (!snap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Text(
              'Promo code "$code" is not valid.',
              style:
                  AppTypography.bodySM(context).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final promo = PromoCode.fromFirestore(snap);

      if (!promo.active ||
          (promo.expiresAt != null &&
              DateTime.now().isAfter(promo.expiresAt!))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Text(
              'Promo code "$code" has expired.',
              style:
                  AppTypography.bodySM(context).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ref.read(cartProvider.notifier).applyPromo(promo);

      final discountLabel = promo.type == 'percentage'
          ? '${promo.value.toInt()}% off'
          : '₹${promo.value.toInt()} off';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 2000),
          content: Row(
            children: [
              const Icon(Icons.local_offer_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Promo "$code" applied — $discountLabel!',
                  style: AppTypography.bodySM(context)
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      // Network error — silently ignore, the user can apply manually from cart
    }
  }



  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productBySlugProvider(widget.slug));

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Product not found')),
            );
          }

          // Keep _currentProduct in sync so helper methods can use effectiveSize
          if (_currentProduct != product) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _currentProduct != product) {
                setState(() => _currentProduct = product);
              }
            });
          }

          final displayPrice = effectiveSize?.price ?? product.price;
          final displayCompareAt =
              effectiveSize?.compareAtPrice ?? product.compareAtPrice;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  ProductDetailAppBar(product: product),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(R.w(context, 20),
                          R.h(context, 24), R.w(context, 20), R.h(context, 24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductHeader(
                            product: product,
                            price: displayPrice,
                            compareAt: displayCompareAt,
                          ),
                          SizedBox(height: R.h(context, 24)),
                          if (product.sizes != null &&
                              product.sizes!.isNotEmpty)
                            SizeSelector(
                              sizes: product.sizes!,
                              selectedSize: effectiveSize,
                              onSizeSelected: (size) {
                                setState(() {
                                  _selectedSize = size;
                                });
                              },
                            ),
                          const TrustBadges(),
                          ProductTabs(product: product),
                          FrequentlyBoughtTogether(product: product),
                          ProductReviewsSection(product: product),
                          YouMayAlsoLike(product: product),
                          SizedBox(height: R.h(context, 120)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ProductBottomBar(
                product: product,
                effectiveSize: effectiveSize,
                displayPrice: displayPrice,
              ),
            ],
          );
        },
        loading: () => const ProductDetailSkeleton(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
