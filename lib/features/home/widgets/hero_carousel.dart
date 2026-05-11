import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/widgets/skeleton_loaders.dart';
import '../../../providers/providers.dart';

class HeroCarousel extends ConsumerStatefulWidget {
  const HeroCarousel({super.key});

  @override
  ConsumerState<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends ConsumerState<HeroCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // Stable reference to the shuffled 4th-slide product ID.
  // Cached once when products load so rebuilds don't reshuffle.
  String? _randomSlideId;
  // Cancelable timer — avoids recursive Future.delayed memory leak.
  Timer? _autoPlayTimer;

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay(int length) {
    if (_autoPlayTimer != null || length <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    // Trigger autoplay and stable-slide selection outside build logic.
    ref.listen<AsyncValue<List>>(allProductsProvider, (_, next) {
      next.whenData((products) {
        if (products.isEmpty) return;
        // Cache the shuffled 4th-slide ID once — stable across rebuilds.
        if (_randomSlideId == null) {
          final deterministic = <dynamic>[];
          final newArrivals = products
              .where((p) =>
                  p.badge?.toLowerCase().contains('new arrival') ?? false)
              .toList();
          final bestSellers = products
              .where(
                  (p) => p.badge?.toLowerCase().contains('bestseller') ?? false)
              .toList();
          deterministic.addAll([...newArrivals, ...bestSellers]);
          if (deterministic.length < 3) {
            deterministic.addAll(products
                .where((p) => p.featured && !deterministic.contains(p)));
          }
          final limit = deterministic.length > 3 ? 3 : deterministic.length;
          final remaining = products
              .where((p) => !deterministic.take(limit).contains(p))
              .toList();
          if (remaining.isNotEmpty) {
            remaining.shuffle();
            _randomSlideId = remaining.first.id as String?;
          }
        }
        // Start autoplay once — noop if already running.
        _startAutoPlay(4); // max 4 slides; actual count computed in build below
      });
    });

    return SizedBox(
      height: R.h(context, 240),
      child: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No banners found.'));
          }

          // 1. Get products with 'New Arrival' badge from Firebase
          final newArrivals = products
              .where((p) =>
                  p.badge?.toLowerCase().contains('new arrival') ?? false)
              .toList();

          // 2. Get products with 'Bestseller' badge from Firebase
          final bestSellers = products
              .where(
                  (p) => p.badge?.toLowerCase().contains('bestseller') ?? false)
              .toList();

          // Combine them in order: New Arrivals first, then Best Sellers
          var slidesData = [...newArrivals, ...bestSellers];

          // If we have fewer than 3, pad with some featured products
          if (slidesData.length < 3) {
            final otherFeatured = products
                .where((p) => p.featured && !slidesData.contains(p))
                .toList();
            slidesData.addAll(otherFeatured);
          }

          // Limit to exactly 3 deterministic slides to start with
          if (slidesData.length > 3) {
            slidesData = slidesData.take(3).toList();
          }

          // 4. Add a stable 4th banner whose ID was cached once in ref.listen.
          // This prevents reshuffling on every rebuild (e.g. theme change, scroll).
          final remainingProducts =
              products.where((p) => !slidesData.contains(p)).toList();
          if (remainingProducts.isNotEmpty) {
            final stableSlide = _randomSlideId != null
                ? remainingProducts.firstWhere(
                    (p) => p.id == _randomSlideId,
                    orElse: () => remainingProducts.first,
                  )
                : remainingProducts.first;
            slidesData.add(stableSlide);
          }

          final slides = slidesData.map((p) {
            return <String, String>{
              'image': p.primaryImage,
              'badge': p.badge?.toUpperCase() ?? 'FEATURED',
              'title': p.name,
              'subtitle': p.shortDescription.isNotEmpty
                  ? p.shortDescription
                  : 'Premium quality, unadulterated.',
              'cta': 'Shop Now',
              'link': '/product/${p.slug}',
            };
          }).toList();

          // Timer started in ref.listen — do NOT call _startAutoPlay here.

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: slides.length,
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return GestureDetector(
                    onTap: () => context.push(slide['link']!),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomNetworkImage(
                            imageUrl: slide['image']!, fit: BoxFit.cover),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.78),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: EdgeInsets.fromLTRB(R.w(context, 20), 0,
                              R.w(context, 20), R.h(context, 28)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: R.w(context, 7),
                                    vertical: R.h(context, 3)),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.primary, width: 1),
                                  borderRadius:
                                      BorderRadius.circular(R.w(context, 4)),
                                ),
                                child: Text(
                                  slide['badge']!,
                                  style: AppTypography.label(context).copyWith(
                                    fontSize: R.sp(context, 8),
                                    color: AppColors.primary,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              SizedBox(height: R.h(context, 8)),
                              Text(
                                slide['title']!,
                                style: AppTypography.h1(context).copyWith(
                                  color: Colors.white,
                                  fontSize: R.sp(context, 20),
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: R.h(context, 4)),
                              Text(
                                slide['subtitle']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySM(context).copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: R.sp(context, 11),
                                ),
                              ),
                              SizedBox(height: R.h(context, 12)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: R.w(context, 14),
                                    vertical: R.h(context, 8)),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(R.w(context, 7)),
                                ),
                                child: Text(
                                  slide['cta']!,
                                  style: AppTypography.label(context).copyWith(
                                    color: AppColors.deepCharcoal,
                                    fontWeight: FontWeight.w900,
                                    fontSize: R.sp(context, 10),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Dot indicators
              Positioned(
                bottom: 18,
                right: 24,
                child: Row(
                  children: List.generate(
                      slides.length,
                      (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(left: R.w(context, 5)),
                            width: _currentPage == index
                                ? R.w(context, 18)
                                : R.w(context, 5),
                            height: R.h(context, 5),
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius:
                                  BorderRadius.circular(R.w(context, 3)),
                            ),
                          )),
                ),
              ),
            ],
          );
        },
        loading: () => const BannerSkeleton(),
        error: (_, __) => const Center(child: Text('Failed to load banners')),
      ),
    );
  }
}
