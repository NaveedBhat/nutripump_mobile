import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';

class ProductDetailAppBar extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailAppBar({super.key, required this.product});

  @override
  ConsumerState<ProductDetailAppBar> createState() => _ProductDetailAppBarState();
}

class _ProductDetailAppBarState extends ConsumerState<ProductDetailAppBar> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: R.h(context, 340),
      pinned: true,
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white),
      elevation: 0,
      actions: [
        // ── Share button ─────────────────────────────────────────────────────────
        Container(
          margin: EdgeInsets.only(right: R.w(context, 4)),
          decoration: BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : Colors.white)
                .withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.ios_share_rounded,
                size: R.sp(context, 20),
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.deepCharcoal)),
            tooltip: 'Share product',
            onPressed: () {
              final url = 'https://nutripump.store/product/${widget.product.slug}';
              SharePlus.instance.share(
                ShareParams(
                  text:
                      '🌿 ${widget.product.name} — Pure Kashmiri Artisanal.\n\nCheck it out on NutriPump: $url',
                  subject: widget.product.name,
                ),
              );
            },
          ),
        ),
        // ── Wishlist button ──────────────────────────────────────────────────
        Consumer(
          builder: (context, ref, _) {
            final wishlist = ref.watch(wishlistProvider);
            final isWishlisted = wishlist.any((p) => p.id == widget.product.id);
            return Container(
              margin: EdgeInsets.only(right: R.w(context, 8)),
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : Colors.white)
                    .withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted
                      ? AppColors.error
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.deepCharcoal),
                  size: R.sp(context, 20),
                ),
                onPressed: () {
                  ref.read(wishlistProvider.notifier).toggle(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        duration: const Duration(milliseconds: 2000),
                        content: Text(isWishlisted
                            ? 'Removed from wishlist'
                            : 'Added to wishlist')),
                  );
                },
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.product.images.length,
              itemBuilder: (context, index) {
                return CustomNetworkImage(
                  imageUrl: widget.product.images[index],
                  fit: BoxFit.cover,
                );
              },
            ),
            Container(
              height: R.h(context, 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent
                  ],
                ),
              ),
            ),
            if (widget.product.images.length > 1)
              Padding(
                padding: EdgeInsets.only(bottom: R.h(context, 20)),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.product.images.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: R.w(context, 5),
                    dotWidth: R.w(context, 5),
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
