// lib/features/home/widgets/advertisement_banners_section.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../models/advertisement_banner.dart';
import '../providers/advertisement_banners_provider.dart';

/// Premium Advertisement Banners Section for the Home screen.
/// Features:
///  - Real-time Firestore stream via Riverpod
///  - Auto-scrolling PageView with a safely-disposed Timer
///  - Smooth fade/slide page transitions
///  - Dynamic navigation (internal via GoRouter, external via url_launcher)
///  - Gradient overlay for premium text readability
///  - NutriPump brand-matched design
class AdvertisementBannersSection extends ConsumerWidget {
  const AdvertisementBannersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(advertisementBannersProvider);

    return bannersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();
        return _AdvertisementCarousel(banners: banners);
      },
    );
  }
}

// ── Internal Carousel (StatefulWidget for Timer + PageController) ──────────

class _AdvertisementCarousel extends StatefulWidget {
  final List<AdvertisementBanner> banners;
  const _AdvertisementCarousel({required this.banners});

  @override
  State<_AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<_AdvertisementCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  
  // Start at a large initial page so the user can swipe backwards immediately
  // and we don't hit the beginning of the PageView bounds.
  int _currentPage = 10000;

  @override
  void initState() {
    super.initState();
    // For 1 banner, we want to center it exactly. For multiple, we use viewportFraction to peek.
    // However, since we are duplicating it infinitely, viewportFraction 0.88 works well always.
    _pageController = PageController(
      viewportFraction: 0.88,
      initialPage: _currentPage,
    );
    _startTimer();
  }

  void _startTimer() {
    // We now start the timer even if there is only 1 banner, 
    // creating a continuous panning/looping effect of the same banner.
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _pageController.dispose();
    super.dispose();
  }

  void _handleBannerTap(BuildContext context, AdvertisementBanner banner) {
    try {
      if (banner.redirectValue.isEmpty) return; // Silent return for purely visual banners

      switch (banner.redirectType) {
        // Product detail is a sub-route → push() preserves back button
        case 'product':
          context.push('/product/${banner.redirectValue}');
          break;
        // Tab-level routes → go() correctly updates bottom nav active state
        case 'category':
          context.go('/categories/${banner.redirectValue}');
          break;
        case 'brand':
          context.go('/shop?brand=${banner.redirectValue}');
          break;
        case 'external':
          final raw = banner.redirectValue;
          final uri = Uri.tryParse(
            raw.startsWith('http') ? raw : 'https://$raw',
          );
          if (uri != null) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          break;
        case 'custom':
        default:
          final raw = banner.redirectValue;
          if (raw.startsWith('http')) {
            final uri = Uri.tryParse(raw);
            if (uri != null) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } else {
            // Use go() for tab paths (/shop, /categories), push() for sub-routes
            final path = raw.startsWith('/') ? raw : '/$raw';
            context.go(path);
          }
          break;
      }
    } catch (_) {
      // Silently handle any navigation errors to prevent crashes
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ───────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXCLUSIVE OFFERS',
                style: AppTypography.label(context).copyWith(
                  color: AppColors.primary,
                  fontSize: R.sp(context, 9),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: R.h(context, 3)),
              Text(
                'Promotions',
                style: AppTypography.h2(context)
                    .copyWith(fontSize: R.sp(context, 17)),
              ),
            ],
          ),
        ),
        SizedBox(height: R.h(context, 14)),

        // ── PageView Carousel (Infinite) ──────────────────────
        SizedBox(
          height: R.h(context, 180),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // When user manually drags, stop the auto-timer to avoid jank
              if (notification is ScrollStartNotification) _stopTimer();
              if (notification is ScrollEndNotification) _startTimer();
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              // No itemCount makes it scroll infinitely
              onPageChanged: (i) {
                if (mounted) setState(() => _currentPage = i);
              },
              itemBuilder: (context, index) {
                // Modulo math ensures we wrap around the banner array
                final realIndex = index % widget.banners.length;
                final banner = widget.banners[realIndex];
                return _BannerCard(
                  banner: banner,
                  onTap: () => _handleBannerTap(context, banner),
                );
              },
            ),
          ),
        ),

        // ── Page Indicators ───────────────────────────────────
        if (widget.banners.length > 1) ...[
          SizedBox(height: R.h(context, 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (index) {
              final realCurrentPage = _currentPage % widget.banners.length;
              final isActive = index == realCurrentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin:
                    EdgeInsets.symmetric(horizontal: R.w(context, 3)),
                width: isActive ? R.w(context, 20) : R.w(context, 6),
                height: R.h(context, 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : isDark
                          ? AppColors.neutralGold.withValues(alpha: 0.3)
                          : AppColors.neutralGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

// ── Individual Banner Card ─────────────────────────────────────────────────

class _BannerCard extends StatelessWidget {
  final AdvertisementBanner banner;
  final VoidCallback onTap;

  const _BannerCard({required this.banner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          right: R.w(context, 12),
          left: R.w(context, 2),
          bottom: R.h(context, 4),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * R.r(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepCharcoal.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20 * R.r(context)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background Image ───────────────────────────
              CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.deepCharcoal.withValues(alpha: 0.08),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.deepCharcoal.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white30,
                    size: 32,
                  ),
                ),
              ),

              // ── Gradient Overlay — premium editorial feel ──
              if (banner.title.isNotEmpty || (banner.subtitle?.isNotEmpty ?? false) || (banner.ctaText?.isNotEmpty ?? false))
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.transparent,
                        Color(0xBB1B180D),
                      ],
                      stops: [0.3, 1.0],
                    ),
                  ),
                ),

              // ── Content Overlay ────────────────────────────
              Positioned(
                left: R.w(context, 18),
                right: R.w(context, 90),
                top: 0,
                bottom: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    if (banner.title.isNotEmpty)
                      Text(
                        banner.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.h2(context).copyWith(
                          fontSize: R.sp(context, 15),
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),

                    // Subtitle
                    if (banner.subtitle != null &&
                        banner.subtitle!.isNotEmpty) ...[
                      SizedBox(height: R.h(context, 5)),
                      Text(
                        banner.subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(context).copyWith(
                          fontSize: R.sp(context, 10),
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.3,
                        ),
                      ),
                    ],

                    // CTA Button
                    if (banner.ctaText != null &&
                        banner.ctaText!.isNotEmpty) ...[
                      SizedBox(height: R.h(context, 10)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: R.w(context, 12),
                          vertical: R.h(context, 5),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(6 * R.r(context)),
                        ),
                        child: Text(
                          banner.ctaText!,
                          style: AppTypography.label(context).copyWith(
                            fontSize: R.sp(context, 9),
                            color: AppColors.deepCharcoal,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
