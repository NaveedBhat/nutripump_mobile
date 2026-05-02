import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../providers/providers.dart';
import '../../providers/cart_provider.dart';
import 'widgets/announcement_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Container(
            color: const Color(0xFFF8F6F1),
            child: Column(
              children: [
                const AnnouncementBar(),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
            _HomeAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeroCarousel(),
                  const _TrustStrip(),
                  const SizedBox(height: 36),
                  _CategoriesSection(),
                  const SizedBox(height: 36),
                  _FeaturedProductsSection(),
                  const SizedBox(height: 36),
                  const _WhyNutriPump(),
                  const SizedBox(height: 36),
                  const _TasteProfilerCta(),
                  const SizedBox(height: 36),
                  const _HoneyWheelSection(),
                  const SizedBox(height: 36),
                  _AllProductsSection(),
                  const SizedBox(height: 36),
                  const _B2BSection(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── App Bar ──────────────────────────────────────────────────
class _HomeAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3EE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              const Icon(Icons.search_rounded, color: AppColors.neutralGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Search honey, saffron, nuts...',
                  style: AppTypography.bodySM.copyWith(
                    color: AppColors.neutralGold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/search', extra: {'autoStartVoice': true}),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.mic_none, color: AppColors.neutralGold, size: 18),
                ),
              ),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final unreadCount = ref.watch(unreadNotificationsCountProvider);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined, color: AppColors.deepCharcoal, size: 22),
                  onPressed: () => context.push('/notifications'),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Consumer(
          builder: (context, ref, _) {
            final cart = ref.watch(cartProvider);
            final count = cart.items.fold<int>(0, (sum, item) => sum + item.quantity);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.deepCharcoal, size: 22),
                  onPressed: () => context.push('/cart'),
                ),
                if (count > 0)
                  Positioned(
                    top: 6,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text('$count', style: const TextStyle(color: AppColors.deepCharcoal, fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.borderLight),
      ),
    );
  }
}

// ── Hero Carousel ────────────────────────────────────────────
class _HeroCarousel extends ConsumerStatefulWidget {
  const _HeroCarousel();

  @override
  ConsumerState<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends ConsumerState<_HeroCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isAutoPlaying = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay(int length) {
    if (_isAutoPlaying || length <= 1) return;
    _isAutoPlaying = true;
    _autoPlayTick(length);
  }

  void _autoPlayTick(int length) {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
      _autoPlayTick(length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    return SizedBox(
      height: 240,
      child: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No banners found.'));
          }

          // 1. Get products with 'New Arrival' badge from Firebase
          final newArrivals = products.where((p) => p.badge?.toLowerCase().contains('new arrival') ?? false).toList();
          
          // 2. Get products with 'Bestseller' badge from Firebase
          final bestSellers = products.where((p) => p.badge?.toLowerCase().contains('bestseller') ?? false).toList();
          
          // Combine them in order: New Arrivals first, then Best Sellers
          var slidesData = [...newArrivals, ...bestSellers];
          
          // If we have fewer than 3, pad with some featured products
          if (slidesData.length < 3) {
            final otherFeatured = products.where((p) => p.featured && !slidesData.contains(p)).toList();
            slidesData.addAll(otherFeatured);
          }
          
          // Limit to exactly 3 deterministic slides to start with
          if (slidesData.length > 3) {
            slidesData = slidesData.take(3).toList();
          }

          // 4. Add a 4th random banner from the remaining catalog that changes on every rebuild (swipe)
          final remainingProducts = products.where((p) => !slidesData.contains(p)).toList();
          if (remainingProducts.isNotEmpty) {
            remainingProducts.shuffle();
            slidesData.add(remainingProducts.first);
          }

          final slides = slidesData.map((p) {
             return <String, String>{
                'image': p.primaryImage,
                'badge': p.badge?.toUpperCase() ?? 'FEATURED',
                'title': p.name,
                'subtitle': p.shortDescription.isNotEmpty ? p.shortDescription : 'Premium quality, unadulterated.',
                'cta': 'Shop Now',
                'link': '/product/${p.slug}',
             };
          }).toList();

          _startAutoPlay(slides.length);

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
                        CustomNetworkImage(imageUrl: slide['image']!, fit: BoxFit.cover),
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
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primary, width: 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  slide['badge']!,
                                  style: AppTypography.label.copyWith(
                                    fontSize: 8,
                                    color: AppColors.primary,
                                    letterSpacing: 2.0,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                slide['title']!,
                                style: AppTypography.h1.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                slide['subtitle']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySM.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  slide['cta']!,
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.deepCharcoal,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
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
                  children: List.generate(slides.length, (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(left: 5),
                    width: _currentPage == index ? 18 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primary : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('Failed to load banners')),
      ),
    );
  }
}

// ── Trust Strip ──────────────────────────────────────────────
class _TrustStrip extends StatefulWidget {
  const _TrustStrip();

  @override
  State<_TrustStrip> createState() => _TrustStripState();
}

class _TrustStripState extends State<_TrustStrip> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ScrollController _scrollController = ScrollController();
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final delta = (elapsed - _lastElapsed).inMilliseconds;
      _lastElapsed = elapsed;
      if (_scrollController.hasClients && delta > 0) {
        // Adjust 35.0 to control speed (pixels per second)
        _scrollController.jumpTo(_scrollController.offset + (35.0 * delta / 1000.0));
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ticker.start();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.local_shipping_outlined, 'Free Ship ₹499+'),
      (Icons.eco_outlined, '100% Natural'),
      (Icons.location_on_outlined, 'From Kashmir'),
      (Icons.verified_outlined, 'Lab Tested'),
    ];

    return Container(
      color: Colors.white,
      height: 42,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = items[index % items.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$1, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  item.$2,
                  style: AppTypography.label.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 32),
                Container(width: 1, height: 12, color: AppColors.borderLight),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Categories ───────────────────────────────────────────────
class _CategoriesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shop by Category', style: AppTypography.h2.copyWith(fontSize: 18)),
              GestureDetector(
                onTap: () => context.push('/categories'),
                child: Text('See All', style: AppTypography.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return const SizedBox();
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () => context.push('/shop?category=${cat.name}'),
                    child: Column(
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF0EBE0),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: cat.image != null && cat.image!.isNotEmpty
                                  ? CustomNetworkImage(imageUrl: cat.image!)
                                  : CustomNetworkImage(imageUrl: _getCategoryFallbackImage(cat.name)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 66,
                          child: Text(
                            cat.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label.copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  String _getCategoryFallbackImage(String name) {
    switch (name.toLowerCase()) {
      case 'raw honey':
      case 'honey':
        return 'https://images.unsplash.com/photo-1587049352851-8d4e89133924?q=80&w=400&auto=format&fit=crop';
      case 'saffron':
        return 'https://images.unsplash.com/photo-1596662951362-b48c66a4bc2c?q=80&w=400&auto=format&fit=crop';
      case 'dry fruits':
      case 'nuts':
        return 'https://images.unsplash.com/photo-1599579100062-1718713bd733?q=80&w=400&auto=format&fit=crop';
      case 'oils':
      case 'cold pressed oils':
        return 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?q=80&w=400&auto=format&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1618897996318-5a901fa6ca71?q=80&w=400&auto=format&fit=crop';
    }
  }
}

// ── Featured Products ─────────────────────────────────────────
class _FeaturedProductsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURATED SELECTION', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 9, letterSpacing: 2.0, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Featured Products', style: AppTypography.h2.copyWith(fontSize: 20)),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/shop'),
                child: Text('View All →', style: AppTypography.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: featuredAsync.when(
            data: (products) {
              if (products.isEmpty) return const SizedBox();
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 155,
                    child: ProductCard(product: products[index], compact: true),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

// ── Why NutriPump ─────────────────────────────────────────────
class _WhyNutriPump extends StatelessWidget {
  const _WhyNutriPump();

  @override
  Widget build(BuildContext context) {
    final values = [
      (Icons.thermostat_outlined, 'Cold-Pressed', 'Nutrients preserved at every step'),
      (Icons.location_on_outlined, 'Srinagar Origin', 'Sourced directly from Kashmir\'s valleys'),
      (Icons.science_outlined, 'Lab Verified', 'Every batch tested for purity'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHY NUTRIPUMP', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 9, letterSpacing: 2.0, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('Crafted Different', style: AppTypography.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          Row(
            children: values.map((v) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: v == values.last ? 0 : 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(v.$1, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(v.$2, textAlign: TextAlign.center, style: AppTypography.label.copyWith(fontWeight: FontWeight.w800, fontSize: 10, height: 1.2)),
                      const SizedBox(height: 4),
                      Text(v.$3, textAlign: TextAlign.center, style: AppTypography.label.copyWith(color: AppColors.neutralGold, fontSize: 8.5, height: 1.3)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── All Products ─────────────────────────────────────────────
class _AllProductsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THE FULL RANGE', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 9, letterSpacing: 2.0, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('All Products', style: AppTypography.h2.copyWith(fontSize: 20)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/shop'),
                    child: Text('Browse All →', style: AppTypography.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 155,
                    child: ProductCard(product: products[index], compact: true),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

// ── Taste Profiler CTA ────────────────────────────────────────
class _TasteProfilerCta extends StatelessWidget {
  const _TasteProfilerCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3B36),
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1636800637091-3d54ec4dfffb?q=80&w=600&auto=format&fit=crop'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('AI-POWERED', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 8, letterSpacing: 2.0, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 12),
            Text(
              'Not sure where\nto start?',
              style: AppTypography.h1.copyWith(color: Colors.white, fontSize: 26, height: 1.1),
            ),
            const SizedBox(height: 10),
            Text(
              'Take our 1-minute Artisanal Pulse quiz and get a curated recommendation just for you.',
              style: AppTypography.bodySM.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.push('/taste-profiler'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.deepCharcoal, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'TAKE THE QUIZ',
                      style: AppTypography.label.copyWith(
                        color: AppColors.deepCharcoal,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── B2B & Gastronomy ──────────────────────────────────────────
class _B2BSection extends StatelessWidget {
  const _B2BSection();

  @override
  Widget build(BuildContext context) {
    const features = [
      (Icons.restaurant_outlined, 'Custom Sourcing', 'Bespoke artisanal sourcing for your restaurant, hotel, or specialty store.'),
      (Icons.local_offer_outlined, 'Bulk Supply', 'Competitive rates for large-volume orders with guaranteed freshness.'),
      (Icons.storefront_outlined, 'White Label', 'Private labeling available for your brand with our premium products.'),
      (Icons.school_outlined, 'Staff Training', 'Product knowledge sessions for your culinary and hospitality team.'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Decorative accent
          Positioned(
            top: 0, right: 0, bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Container(
                width: 80,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'B2B & GASTRONOMY',
                  style: AppTypography.label.copyWith(
                    color: AppColors.primary,
                    fontSize: 9,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 22, height: 1.15),
                    children: [
                      const TextSpan(text: 'Elevate Your\nCulinary '),
                      TextSpan(
                        text: 'Signature',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.primary,
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We partner with restaurants, luxury hotels, and high-end retailers to provide premium, single-origin artisan products.',
                  style: AppTypography.bodySM.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 2.1,
                  padding: EdgeInsets.zero,
                  children: features.map((f) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(f.$1, color: AppColors.primary, size: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(f.$2, style: AppTypography.label.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(f.$3, style: AppTypography.label.copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 8.5, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Stat strip
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _b2bStat('500+', 'Partners'),
                      Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
                      _b2bStat('50+', 'Restaurants'),
                      Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
                      _b2bStat('10+', 'Hotels'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => context.push('/contact?type=bulk'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Request Partnership Kit',
                          style: AppTypography.label.copyWith(
                            color: AppColors.deepCharcoal,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: AppColors.deepCharcoal, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _b2bStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.h3.copyWith(color: AppColors.primary, fontSize: 18)),
        Text(label, style: AppTypography.label.copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 9)),
      ],
    );
  }
}

// ── Honey Taster's Wheel ──────────────────────────────────────
class _HoneyWheelSection extends StatefulWidget {
  const _HoneyWheelSection();

  @override
  State<_HoneyWheelSection> createState() => _HoneyWheelSectionState();
}

class _HoneyWheelSectionState extends State<_HoneyWheelSection>
    with TickerProviderStateMixin {
  int _active = 0;
  late final AnimationController _spinCtrl;
  late final AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _profiles = [
    _HoneyProfile('Floral & Light', '🌸', Color(0xFFEEBD2B),
        'Chamomile • Vanilla • White Iris',
        'Delicate and airy with a luminous golden hue. Soft, nectar-like sweetness that fades into lingering botanical finishes.'),
    _HoneyProfile('Woody & Aromatic', '🌲', Color(0xFF9A7020),
        'Pine Resin • Molasses • Leather',
        'Deep amber, harvested from high-elevation forests. Complex, resinous viscosity with malty undertones.'),
    _HoneyProfile('Earthy & Herbaceous', '🌿', Color(0xFF6B8040),
        'Wild Thyme • Mineral • Sage',
        'A wild, untamed terroir profile. Rich with mineral complexities and a mildly savory edge.'),
  ];

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (!mounted) return;
      _switchTo((_active + 1) % _profiles.length);
      _startAutoPlay();
    });
  }

  void _switchTo(int index) {
    _fadeCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _active = index);
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profiles[_active];

    return Container(
      color: const Color(0xFF1A2820),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EDUCATION', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 9, letterSpacing: 2.5, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text("The Honey Taster's Wheel", style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 22, height: 1.1)),
          const SizedBox(height: 8),
          Text(
            'Like fine wine, honey has complex aromatic compounds. Use our guide to identify the nuances in our artisanal selection.',
            style: AppTypography.bodySM.copyWith(color: Colors.white.withValues(alpha: 0.55), fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 24),
          // Interactive wheel
          Center(
            child: GestureDetector(
              onTap: () => _switchTo((_active + 1) % _profiles.length),
              child: SizedBox(
                width: 230,
                height: 230,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinning dashed ring
                    AnimatedBuilder(
                      animation: _spinCtrl,
                      builder: (_, __) => Transform.rotate(
                        angle: _spinCtrl.value * 2 * 3.14159,
                        child: Container(
                          width: 230,
                          height: 230,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
                          ),
                        ),
                      ),
                    ),
                    // Color segmented ring
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: _WheelPainter(activeIndex: _active, profiles: _profiles),
                    ),
                    // Center hub
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1A2820),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                          boxShadow: [BoxShadow(color: profile.color.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: -5)],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(profile.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 6),
                            ...profile.notes.split(' • ').map((n) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                n.toUpperCase(),
                                style: TextStyle(color: profile.color, fontSize: 7.5, fontWeight: FontWeight.w900, letterSpacing: 0.5, height: 1.1),
                                textAlign: TextAlign.center,
                              ),
                            )),
                            const SizedBox(height: 3),
                            Text('PROFILE', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
                          ],
                        ),
                      ),
                    ),
                    // Down arrow indicator
                    const Positioned(
                      top: 0,
                      child: Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Profile selector list
          ...List.generate(_profiles.length, (i) {
            final p = _profiles[i];
            final isActive = _active == i;
            return GestureDetector(
              onTap: () => _switchTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive ? AppColors.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10, height: 10,
                      margin: const EdgeInsets.only(top: 3),
                      decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: AppTypography.label.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                          if (isActive) ...[
                            const SizedBox(height: 4),
                            Text(p.desc, style: AppTypography.bodySM.copyWith(color: Colors.white.withValues(alpha: 0.55), fontSize: 11, height: 1.4)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/journal/honey-tasters-guide'),
            child: Row(
              children: [
                Text('Explore Full Tasting Guide', style: AppTypography.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, color: AppColors.primary, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HoneyProfile {
  final String name;
  final String emoji;
  final Color color;
  final String notes;
  final String desc;
  const _HoneyProfile(this.name, this.emoji, this.color, this.notes, this.desc);
}

class _WheelPainter extends CustomPainter {
  final int activeIndex;
  final List<_HoneyProfile> profiles;

  _WheelPainter({required this.activeIndex, required this.profiles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    const innerR = 52.0; // Center hole radius
    const sweepAngle = 2 * math.pi / 3; // 120 degrees per segment

    for (int i = 0; i < profiles.length; i++) {
      // Start at top (-90 degrees)
      final startAngle = -math.pi / 2 + i * sweepAngle;
      
      // Draw the colored segment
      final paint = Paint()
        ..color = profiles[i].color.withValues(alpha: activeIndex == i ? 1.0 : 0.4)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx + innerR * math.cos(startAngle), center.dy + innerR * math.sin(startAngle))
        ..lineTo(center.dx + outerR * math.cos(startAngle), center.dy + outerR * math.sin(startAngle))
        ..arcTo(Rect.fromCircle(center: center, radius: outerR), startAngle, sweepAngle, false)
        ..lineTo(center.dx + innerR * math.cos(startAngle + sweepAngle), center.dy + innerR * math.sin(startAngle + sweepAngle))
        ..arcTo(Rect.fromCircle(center: center, radius: innerR), startAngle + sweepAngle, -sweepAngle, false)
        ..close();

      canvas.drawPath(path, paint);

      // Draw the divider line between segments
      final divPaint = Paint()
        ..color = const Color(0xFF1A2820) // Match background color
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
        
      canvas.drawLine(
        Offset(center.dx + innerR * math.cos(startAngle), center.dy + innerR * math.sin(startAngle)),
        Offset(center.dx + outerR * math.cos(startAngle), center.dy + outerR * math.sin(startAngle)),
        divPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.activeIndex != activeIndex;
}
