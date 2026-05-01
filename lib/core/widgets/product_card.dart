import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../utils/formatters.dart';
import 'custom_network_image.dart';

// Mirrors the web BADGE_STYLES map exactly
({Color bg, Color text}) _badgeColors(String badge) {
  switch (badge.toUpperCase()) {
    case 'BESTSELLER':
      return (bg: AppColors.primary, text: AppColors.deepCharcoal);
    case 'NEW ARRIVAL':
      return (bg: AppColors.deepCharcoal, text: AppColors.primary);
    case 'LIMITED BATCH':
      return (bg: const Color(0xFF991B1B), text: Colors.white);
    case 'HERITAGE':
      return (bg: AppColors.neutralGold, text: Colors.white);
    case 'SEASONAL':
      return (bg: const Color(0xFF166534), text: Colors.white);
    case 'ARTISANAL':
      return (bg: const Color(0xFFB45309), text: Colors.white);
    case "CHEF'S CHOICE":
      return (bg: AppColors.deepCharcoal, text: AppColors.primary);
    default:
      return (bg: AppColors.primary, text: AppColors.deepCharcoal);
  }
}

class ProductCard extends ConsumerWidget {
  final Product product;
  final bool compact;
  const ProductCard({super.key, required this.product, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.slug}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepCharcoal.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ────────────────────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CustomNetworkImage(
                      imageUrl: product.primaryImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Badge (top-left)
                  if (product.badge != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Builder(builder: (context) {
                        final colors = _badgeColors(product.badge!);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.bg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.badge!.toUpperCase(),
                            style: AppTypography.label.copyWith(
                              fontSize: 6,
                              color: colors.text,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        );
                      }),
                    ),
                  // Discount badge (top-right)
                  if (product.discountPercent > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: AppTypography.label.copyWith(
                            fontSize: 7,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Text + Add button ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Origin · Weight
                  Text(
                    [
                      if (product.origin.isNotEmpty) product.origin.toUpperCase(),
                      product.weight,
                    ].join(' · '),
                    style: AppTypography.labelGold.copyWith(fontSize: compact ? 7.5 : 8.5, letterSpacing: 0.4),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySM.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 11.5 : 13,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price row + Add button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formatPrice(product.price),
                              style: AppTypography.priceSM.copyWith(fontSize: 15),
                            ),
                            if (product.compareAtPrice != null && product.compareAtPrice! > product.price) ...[
                              const SizedBox(width: 5),
                              Text(
                                formatPrice(product.compareAtPrice!),
                                style: AppTypography.priceStrike.copyWith(fontSize: 10),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Add to Cart button
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).addItem(
                            product,
                            weight: product.weight,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.deepCharcoal,
                            ),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
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
    );
  }
}
