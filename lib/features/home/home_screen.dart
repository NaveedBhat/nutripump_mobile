import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';
import 'widgets/announcement_bar.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/trust_strip.dart';
import 'widgets/categories_section.dart';
import 'widgets/featured_products_section.dart';
import 'widgets/advertisement_banners_section.dart';
import 'widgets/why_nutripump.dart';
import 'widgets/all_products_section.dart';
import 'widgets/taste_profiler_cta.dart';
import 'widgets/b2b_section.dart';
import 'widgets/honey_wheel_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    // Listen for tab re-tap to scroll to top (Home is index 0).
    // ref.listen MUST be called inside build — not initState.
    ref.listen<int?>(scrollTabEventProvider, (_, index) {
      if (index == 0 && _scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white),
        body: SafeArea(
          bottom: false,
          child: Container(
            color: (Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).scaffoldBackgroundColor
                : (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).scaffoldBackgroundColor
                    : const Color(0xFFF8F6F1))),
            child: Column(
              children: [
                const AnnouncementBar(),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      const HomeAppBar(),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HeroCarousel(),
                            const TrustStrip(),
                            _SectionGap(),
                            const CategoriesSection(),
                            _SectionGap(),
                            const FeaturedProductsSection(),
                            _SectionGap(),
                            const AdvertisementBannersSection(),
                            _SectionGap(),
                            const WhyNutriPump(),
                            _SectionGap(),
                            const TasteProfilerCta(),
                            _SectionGap(),
                            const HoneyWheelSection(),
                            _SectionGap(),
                            const AllProductsSection(),
                            _SectionGap(),
                            const B2BSection(),
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


