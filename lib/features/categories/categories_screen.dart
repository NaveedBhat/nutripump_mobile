import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import 'widgets/category_hero_banner.dart';
import 'widgets/category_card.dart';
import 'widgets/category_skeleton.dart';
import 'widgets/makers_story_section.dart';
import 'widgets/newsletter_section.dart';

// ── Static fallback data (mirrors web STATIC_CATEGORIES) ───────────────────
const _fallbackBannerImage =
    'https://res.cloudinary.com/dil7vl8um/image/upload/v1775281875/closeup-jar-homemade-pumpkin-seed-butter-showcasing-its-creamy-texture-vibrant_924727-82832_gswpgr';

const _fallbackHero =
    'https://images.unsplash.com/photo-1587049352851-8d4e89133924?w=800&q=80';

final _staticCategories = [
  const _StaticCat('honey', 'Artisanal Honey', 'LIQUID GOLD',
      'https://images.unsplash.com/photo-1587049352851-8d4e89133924?w=600&q=80'),
  const _StaticCat('nut-butters', 'Nut Butters', 'PURE ENERGY',
      'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&q=80'),
  const _StaticCat('ghee-oils', 'Ghee & Oils', 'HERITAGE RECIPE',
      'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=600&q=80'),
  const _StaticCat('dried-produce', 'Dried Produce', 'FROM THE VALLEY',
      'https://images.unsplash.com/photo-1518977822534-7049a61ee0c2?w=600&q=80'),
  const _StaticCat('apparel', 'Artisan Apparel', 'SUSTAINABLE LIVING',
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80'),
  const _StaticCat('spices', 'Spices', 'AUTHENTIC FLAVOURS',
      'https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=600&q=80'),
];

class _StaticCat {
  final String slug, label, sublabel, imageUrl;
  const _StaticCat(this.slug, this.label, this.sublabel, this.imageUrl);
}

// Map Firestore Category → display fields using static fallback when needed
String _sublabelFor(Category cat) {
  if (cat.sublabel != null && cat.sublabel!.isNotEmpty) return cat.sublabel!;
  final match = _staticCategories.where((s) => s.slug == cat.slug).firstOrNull;
  return match?.sublabel ?? 'CURATED SELECTION';
}

String _imageFor(Category cat) {
  if (cat.image != null && cat.image!.isNotEmpty) return cat.image!;
  final match = _staticCategories.where((s) => s.slug == cat.slug).firstOrNull;
  return match?.imageUrl ?? _fallbackHero;
}

// ═══════════════════════════════════════════════════════════════════════════
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});
  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heroZoom;
  late final AnimationController _headerFade;
  final _emailController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _heroTitle;
  String? _heroSubtitle;
  String? _heroDesc;
  String? _heroBg;

  @override
  void initState() {
    super.initState();
    _heroZoom =
        AnimationController(vsync: this, duration: const Duration(seconds: 9))
          ..forward();
    _headerFade = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _loadCategoryBanner();
  }

  Future<void> _loadCategoryBanner() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('settings')
          .doc('categoryBanner')
          .get();
      if (snap.exists) {
        final data = snap.data()!;
        if (mounted) {
          setState(() {
            _heroTitle = data['title'] as String?;
            _heroSubtitle = data['subtitle'] as String?;
            _heroDesc = data['description'] as String?;
            _heroBg = data['imageUrl'] as String?;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroZoom.dispose();
    _headerFade.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for tab re-tap to scroll to top (Categories is index 2).
    // ref.listen MUST be called inside build — not initState.
    ref.listen<int?>(scrollTabEventProvider, (_, index) {
      if (index == 2 && _scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColors.backgroundLight),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Hero Banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: CategoryHeroBanner(
              zoomCtrl: _heroZoom,
              title: _heroTitle,
              subtitle: _heroSubtitle,
              description: _heroDesc,
              imageUrl: _heroBg,
              fallbackBannerImage: _fallbackBannerImage,
            ),
          ),

          // ── Section Header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(R.w(context, 20), R.h(context, 32),
                  R.w(context, 20), R.h(context, 20)),
              child: FadeTransition(
                opacity: _headerFade,
                child: Column(
                  children: [
                    Text(
                      'CURATED SELECTION',
                      style: AppTypography.labelGold(context).copyWith(
                          letterSpacing: 3, fontSize: R.sp(context, 10)),
                    ),
                    SizedBox(height: R.h(context, 8)),
                    Text(
                      'MASTERFUL\nCRAFTSMANSHIP',
                      textAlign: TextAlign.center,
                      style: AppTypography.h1(context).copyWith(
                        fontSize: R.sp(context, 24),
                        letterSpacing: 0.5,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Category Grid ─────────────────────────────────────────────
          categoriesAsync.when(
            data: (cats) {
              final list = cats.isEmpty
                  ? _staticCategories
                      .map((s) => Category(
                            id: s.slug,
                            name: s.label,
                            slug: s.slug,
                            image: s.imageUrl,
                            sublabel: s.sublabel,
                          ))
                      .toList()
                  : cats;

              return SliverPadding(
                padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 8),
                    R.w(context, 16), R.h(context, 8)),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4 / 5,
                    crossAxisSpacing: R.w(context, 12),
                    mainAxisSpacing: R.h(context, 12),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final cat = list[i];
                      return CategoryCard(
                        category: cat,
                        index: i,
                        sublabel: _sublabelFor(cat),
                        imageUrl: _imageFor(cat),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 8),
                  R.w(context, 16), R.h(context, 8)),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 5,
                  crossAxisSpacing: R.w(context, 12),
                  mainAxisSpacing: R.h(context, 12),
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const CategorySkeleton(),
                  childCount: 6,
                ),
              ),
            ),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
          ),

          // ── Maker's Story ─────────────────────────────────────────────
          SliverToBoxAdapter(child: SizedBox(height: R.h(context, 24))),
          const SliverToBoxAdapter(child: MakersStorySection()),

          // ── Newsletter ────────────────────────────────────────────────
          SliverToBoxAdapter(
              child: NewsletterSection(controller: _emailController)),

          SliverToBoxAdapter(child: SizedBox(height: R.h(context, 32))),
        ],
      ),
    );
  }
}
