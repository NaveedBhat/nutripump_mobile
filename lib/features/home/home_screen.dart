import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
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
                  _SectionGap(),
                  _CategoriesSection(),
                  _SectionGap(),
                  _FeaturedProductsSection(),
                  _SectionGap(),
                  const _WhyNutriPump(),
                  _SectionGap(),
                  const _TasteProfilerCta(),
                  _SectionGap(),
                  const _HoneyWheelSection(),
                  _SectionGap(),
                  _AllProductsSection(),
                  _SectionGap(),
                  const _B2BSection(),
                  _SectionGap(),
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

// ── Responsive Section Gap ───────────────────────────────────
class _SectionGap extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(height: R.h(context, 24));
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
          height: R.h(context, 36),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3EE),
            borderRadius: BorderRadius.circular(R.w(context, 10)),
          ),
          child: Row(
            children: [
              SizedBox(width: R.w(context, 10)),
              Icon(Icons.search_rounded, color: AppColors.neutralGold, size: R.sp(context, 18)),
              SizedBox(width: R.w(context, 8)),
              Expanded(
                child: Text(
                  'Search honey, saffron, nuts...',
                  style: AppTypography.bodySM(context).copyWith(
                    color: AppColors.neutralGold,
                    fontSize: R.sp(context, 12),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/search', extra: {'autoStartVoice': true}),
                child: Padding(
                  padding: EdgeInsets.all(R.w(context, 8)),
                  child: Icon(Icons.mic_none, color: AppColors.neutralGold, size: R.sp(context, 18)),
                ),
              ),
              SizedBox(width: R.w(context, 2)),
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
                      width: R.w(context, 14),
                      height: R.w(context, 14),
                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: TextStyle(color: Colors.white, fontSize: R.sp(context, 8), fontWeight: FontWeight.bold),
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
                      width: R.w(context, 16),
                      height: R.w(context, 16),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text('$count', style: TextStyle(color: AppColors.deepCharcoal, fontSize: R.sp(context, 9), fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(width: R.w(context, 4)),
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
      height: R.h(context, 240),
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
                          padding: EdgeInsets.fromLTRB(
                            R.w(context, 20), 0, R.w(context, 20), R.h(context, 28)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: R.w(context, 7), vertical: R.h(context, 3)),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primary, width: 1),
                                  borderRadius: BorderRadius.circular(R.w(context, 4)),
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
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: R.sp(context, 11),
                                ),
                              ),
                              SizedBox(height: R.h(context, 12)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: R.w(context, 14), vertical: R.h(context, 8)),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(R.w(context, 7)),
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
                  children: List.generate(slides.length, (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.only(left: R.w(context, 5)),
                    width: _currentPage == index ? R.w(context, 18) : R.w(context, 5),
                    height: R.h(context, 5),
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primary : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(R.w(context, 3)),
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
      height: R.h(context, 38),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = items[index % items.length];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(context, 14)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$1, size: R.sp(context, 13), color: AppColors.primary),
                SizedBox(width: R.w(context, 6)),
                Text(
                  item.$2,
                  style: AppTypography.label(context).copyWith(
                    fontSize: R.sp(context, 10),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(width: R.w(context, 28)),
                Container(width: 1, height: R.h(context, 11), color: AppColors.borderLight),
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

    final circleSize = R.w(context, 58);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shop by Category',
                  style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 16))),
              GestureDetector(
                onTap: () => context.push('/categories'),
                child: Text('See All',
                    style: AppTypography.label(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: R.sp(context, 10),
                    )),
              ),
            ],
          ),
        ),
        SizedBox(height: R.h(context, 12)),
        SizedBox(
          height: circleSize + R.h(context, 26),
          child: categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return const SizedBox();
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => SizedBox(width: R.w(context, 12)),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () => context.push('/shop?category=${cat.slug}'),
                    child: Column(
                      children: [
                        Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF0EBE0),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(R.w(context, 3)),
                            child: ClipOval(
                              child: cat.image != null && cat.image!.isNotEmpty
                                  ? CustomNetworkImage(imageUrl: cat.image!)
                                  : CustomNetworkImage(imageUrl: _getCategoryFallbackImage(cat.name)),
                            ),
                          ),
                        ),
                        SizedBox(height: R.h(context, 6)),
                        SizedBox(
                          width: circleSize,
                          child: Text(
                            cat.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(context).copyWith(
                              fontSize: R.sp(context, 10),
                              fontWeight: FontWeight.w700,
                            ),
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
          padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURATED SELECTION',
                      style: AppTypography.label(context).copyWith(
                        color: AppColors.primary,
                        fontSize: R.sp(context, 9),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                      )),
                  SizedBox(height: R.h(context, 3)),
                  Text('Featured Products',
                      style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 17))),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/shop'),
                child: Text('View All →',
                    style: AppTypography.label(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: R.sp(context, 10),
                    )),
              ),
            ],
          ),
        ),
        SizedBox(height: R.h(context, 14)),
        SizedBox(
          height: R.h(context, 240),
          child: featuredAsync.when(
            data: (products) {
              if (products.isEmpty) return const SizedBox();
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => SizedBox(width: R.w(context, 12)),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: R.w(context, 150),
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
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHY NUTRIPUMP', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 9), letterSpacing: 2.0, fontWeight: FontWeight.w900)),
          SizedBox(height: R.h(context, 4)),
          Text('Crafted Different', style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 18))),
          SizedBox(height: R.h(context, 14)),
          Row(
            children: values.map((v) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: v == values.last ? 0 : R.w(context, 10)),
                  padding: EdgeInsets.all(R.w(context, 12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.w(context, 14)),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(R.w(context, 7)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(R.w(context, 8)),
                        ),
                        child: Icon(v.$1, color: AppColors.primary, size: R.sp(context, 15)),
                      ),
                      SizedBox(height: R.h(context, 8)),
                      Text(v.$2, textAlign: TextAlign.center, style: AppTypography.label(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 10), height: 1.2)),
                      SizedBox(height: R.h(context, 3)),
                      Text(v.$3, textAlign: TextAlign.center, style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 8), height: 1.3)),
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
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THE FULL RANGE', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 9), letterSpacing: 2.0, fontWeight: FontWeight.w900)),
                      SizedBox(height: R.h(context, 3)),
                      Text('All Products', style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 18))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/shop'),
                    child: Text('Browse All →', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: R.sp(context, 10))),
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(context, 14)),
            SizedBox(
              height: R.h(context, 240),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => SizedBox(width: R.w(context, 12)),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: R.w(context, 150),
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
      margin: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3B36),
        borderRadius: BorderRadius.circular(R.w(context, 20)),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1636800637091-3d54ec4dfffb?q=80&w=600&auto=format&fit=crop'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(R.w(context, 22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 8), vertical: R.h(context, 4)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(R.w(context, 4)),
              ),
              child: Text('AI-POWERED', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 8), letterSpacing: 2.0, fontWeight: FontWeight.w900)),
            ),
            SizedBox(height: R.h(context, 10)),
            Text(
              'Not sure where\nto start?',
              style: AppTypography.h1(context).copyWith(color: Colors.white, fontSize: R.sp(context, 22), height: 1.1),
            ),
            SizedBox(height: R.h(context, 8)),
            Text(
              'Take our 1-minute Artisanal Pulse quiz and get a curated recommendation just for you.',
              style: AppTypography.bodySM(context).copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: R.sp(context, 12), height: 1.5),
            ),
            SizedBox(height: R.h(context, 20)),
            GestureDetector(
              onTap: () => context.push('/taste-profiler'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 18), vertical: R.h(context, 12)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(R.w(context, 10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.deepCharcoal, size: R.sp(context, 13)),
                    SizedBox(width: R.w(context, 7)),
                    Text(
                      'TAKE THE QUIZ',
                      style: AppTypography.label(context).copyWith(
                        color: AppColors.deepCharcoal,
                        fontWeight: FontWeight.w900,
                        fontSize: R.sp(context, 10),
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
      margin: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E2A),
        borderRadius: BorderRadius.circular(R.w(context, 20)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0, right: 0, bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(R.w(context, 20)),
                bottomRight: Radius.circular(R.w(context, 20)),
              ),
              child: Container(
                width: R.w(context, 70),
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(R.w(context, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('B2B & GASTRONOMY', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 9), letterSpacing: 2.5, fontWeight: FontWeight.w900)),
                SizedBox(height: R.h(context, 6)),
                RichText(
                  text: TextSpan(
                    style: AppTypography.h2(context).copyWith(color: Colors.white, fontSize: R.sp(context, 19), height: 1.15),
                    children: [
                      const TextSpan(text: 'Elevate Your\nCulinary '),
                      TextSpan(
                        text: 'Signature',
                        style: AppTypography.h2(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 19), fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.h(context, 10)),
                Text(
                  'We partner with restaurants, luxury hotels, and high-end retailers to provide premium, single-origin artisan products.',
                  style: AppTypography.bodySM(context).copyWith(color: Colors.white.withValues(alpha: 0.6), fontSize: R.sp(context, 11), height: 1.5),
                ),
                SizedBox(height: R.h(context, 16)),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: R.h(context, 12),
                  crossAxisSpacing: R.w(context, 12),
                  childAspectRatio: 2.2,
                  padding: EdgeInsets.zero,
                  children: features.map((f) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(R.w(context, 6)),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(R.w(context, 7)),
                          ),
                          child: Icon(f.$1, color: AppColors.primary, size: R.sp(context, 13)),
                        ),
                        SizedBox(width: R.w(context, 7)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(f.$2, style: AppTypography.label(context).copyWith(color: Colors.white, fontSize: R.sp(context, 9), fontWeight: FontWeight.w800)),
                              SizedBox(height: R.h(context, 2)),
                              Text(f.$3, style: AppTypography.label(context).copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: R.sp(context, 8), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: R.h(context, 16)),
                Container(
                  padding: EdgeInsets.symmetric(vertical: R.h(context, 10), horizontal: R.w(context, 14)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(R.w(context, 10)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _b2bStat(context, '500+', 'Partners'),
                      Container(width: 1, height: R.h(context, 22), color: Colors.white.withValues(alpha: 0.1)),
                      _b2bStat(context, '50+', 'Restaurants'),
                      Container(width: 1, height: R.h(context, 22), color: Colors.white.withValues(alpha: 0.1)),
                      _b2bStat(context, '10+', 'Hotels'),
                    ],
                  ),
                ),
                SizedBox(height: R.h(context, 16)),
                GestureDetector(
                  onTap: () => context.push('/contact?type=bulk'),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: R.h(context, 12)),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(R.w(context, 10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Request Partnership Kit',
                          style: AppTypography.label(context).copyWith(
                            color: AppColors.deepCharcoal,
                            fontWeight: FontWeight.w900,
                            fontSize: R.sp(context, 11),
                          ),
                        ),
                        SizedBox(width: R.w(context, 7)),
                        Icon(Icons.arrow_forward, color: AppColors.deepCharcoal, size: R.sp(context, 13)),
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

  Widget _b2bStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.h3(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 16))),
        Text(label, style: AppTypography.label(context).copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: R.sp(context, 9))),
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
    final wheelSize = R.w(context, 220);
    final hubSize = R.w(context, 100);

    return Container(
      color: const Color(0xFF1A2820),
      padding: EdgeInsets.all(R.w(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EDUCATION', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 9), letterSpacing: 2.5, fontWeight: FontWeight.w900)),
          SizedBox(height: R.h(context, 5)),
          Text("The Honey Taster's Wheel", style: AppTypography.h2(context).copyWith(color: Colors.white, fontSize: R.sp(context, 19), height: 1.1)),
          SizedBox(height: R.h(context, 6)),
          Text(
            'Like fine wine, honey has complex aromatic compounds. Use our guide to identify the nuances in our artisanal selection.',
            style: AppTypography.bodySM(context).copyWith(color: Colors.white.withValues(alpha: 0.55), fontSize: R.sp(context, 11), height: 1.5),
          ),
          SizedBox(height: R.h(context, 20)),
          // Interactive wheel
          Center(
            child: GestureDetector(
              onTap: () => _switchTo((_active + 1) % _profiles.length),
              child: SizedBox(
                width: wheelSize,
                height: wheelSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinning dashed ring
                    AnimatedBuilder(
                      animation: _spinCtrl,
                      builder: (_, __) => Transform.rotate(
                        angle: _spinCtrl.value * 2 * 3.14159,
                        child: Container(
                          width: wheelSize,
                          height: wheelSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
                          ),
                        ),
                      ),
                    ),
                    // Color segmented ring
                    CustomPaint(
                      size: Size(wheelSize * 0.87, wheelSize * 0.87),
                      painter: _WheelPainter(activeIndex: _active, profiles: _profiles),
                    ),
                    // Center hub
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: hubSize,
                        height: hubSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1A2820),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                          boxShadow: [BoxShadow(color: profile.color.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: -5)],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(profile.emoji, style: TextStyle(fontSize: R.sp(context, 22))),
                            SizedBox(height: R.h(context, 4)),
                            ...profile.notes.split(' • ').map((n) => Padding(
                              padding: EdgeInsets.only(bottom: R.h(context, 2)),
                              child: Text(
                                n.toUpperCase(),
                                style: TextStyle(color: profile.color, fontSize: R.sp(context, 7), fontWeight: FontWeight.w900, letterSpacing: 0.5, height: 1.1),
                                textAlign: TextAlign.center,
                              ),
                            )),
                            SizedBox(height: R.h(context, 2)),
                            Text('PROFILE', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: R.sp(context, 6.5), fontWeight: FontWeight.w800, letterSpacing: 2.0)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: R.sp(context, 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: R.h(context, 20)),
          // Profile selector list
          ...List.generate(_profiles.length, (i) {
            final p = _profiles[i];
            final isActive = _active == i;
            return GestureDetector(
              onTap: () => _switchTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(bottom: R.h(context, 8)),
                padding: EdgeInsets.all(R.w(context, 12)),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(R.w(context, 12)),
                  border: Border.all(
                    color: isActive ? AppColors.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: R.w(context, 9), height: R.w(context, 9),
                      margin: EdgeInsets.only(top: R.h(context, 3)),
                      decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                    ),
                    SizedBox(width: R.w(context, 10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: AppTypography.label(context).copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: R.sp(context, 11))),
                          if (isActive) ...[
                            SizedBox(height: R.h(context, 3)),
                            Text(p.desc, style: AppTypography.bodySM(context).copyWith(color: Colors.white.withValues(alpha: 0.55), fontSize: R.sp(context, 11), height: 1.4)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: R.h(context, 12)),
          GestureDetector(
            onTap: () => context.push('/journal/honey-tasters-guide'),
            child: Row(
              children: [
                Text('Explore Full Tasting Guide', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: R.sp(context, 11))),
                SizedBox(width: R.w(context, 6)),
                Icon(Icons.arrow_forward, color: AppColors.primary, size: R.sp(context, 13)),
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
