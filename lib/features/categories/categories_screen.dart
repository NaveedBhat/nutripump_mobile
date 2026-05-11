import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

// ── Static fallback data (mirrors web STATIC_CATEGORIES) ───────────────────
const _fallbackBannerImage =
    'https://res.cloudinary.com/dil7vl8um/image/upload/v1775281875/closeup-jar-homemade-pumpkin-seed-butter-showcasing-its-creamy-texture-vibrant_924727-82832_gswpgr';

const _fallbackHero =
    'https://images.unsplash.com/photo-1587049352851-8d4e89133924?w=800&q=80';

final _staticCategories = [
  const _StaticCat('honey',        'Artisanal Honey',  'LIQUID GOLD',       'https://images.unsplash.com/photo-1587049352851-8d4e89133924?w=600&q=80'),
  const _StaticCat('nut-butters',  'Nut Butters',      'PURE ENERGY',       'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&q=80'),
  const _StaticCat('ghee-oils',    'Ghee & Oils',      'HERITAGE RECIPE',   'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=600&q=80'),
  const _StaticCat('dried-produce','Dried Produce',    'FROM THE VALLEY',   'https://images.unsplash.com/photo-1518977822534-7049a61ee0c2?w=600&q=80'),
  const _StaticCat('apparel',      'Artisan Apparel',  'SUSTAINABLE LIVING','https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80'),
  const _StaticCat('spices',       'Spices',           'AUTHENTIC FLAVOURS','https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=600&q=80'),
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
    _heroZoom = AnimationController(vsync: this, duration: const Duration(seconds: 9))
      ..forward();
    _headerFade = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
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
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });

    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Hero Banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroBanner(
              zoomCtrl: _heroZoom,
              title: _heroTitle,
              subtitle: _heroSubtitle,
              description: _heroDesc,
              imageUrl: _heroBg,
            ),
          ),

          // ── Section Header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(R.w(context, 20), R.h(context, 32), R.w(context, 20), R.h(context, 20)),
              child: FadeTransition(
                opacity: _headerFade,
                child: Column(
                  children: [
                    Text(
                      'CURATED SELECTION',
                      style: AppTypography.labelGold(context).copyWith(letterSpacing: 3, fontSize: R.sp(context, 10)),
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
                  ? _staticCategories.map((s) => Category(
                        id: s.slug,
                        name: s.label,
                        slug: s.slug,
                        image: s.imageUrl,
                        sublabel: s.sublabel,
                      )).toList()
                  : cats;

              return SliverPadding(
                padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 8), R.w(context, 16), R.h(context, 8)),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4 / 5,
                    crossAxisSpacing: R.w(context, 12),
                    mainAxisSpacing: R.h(context, 12),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _CategoryCard(
                      category: list[i],
                      index: i,
                    ),
                    childCount: list.length,
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 8), R.w(context, 16), R.h(context, 8)),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 5,
                  crossAxisSpacing: R.w(context, 12),
                  mainAxisSpacing: R.h(context, 12),
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const _CategorySkeleton(),
                  childCount: 6,
                ),
              ),
            ),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
          ),

          // ── Maker's Story ─────────────────────────────────────────────
          SliverToBoxAdapter(child: SizedBox(height: R.h(context, 24))),
          const SliverToBoxAdapter(child: _MakersStorySection()),

          // ── Newsletter ────────────────────────────────────────────────
          SliverToBoxAdapter(child: _NewsletterSection(controller: _emailController)),

          SliverToBoxAdapter(child: SizedBox(height: R.h(context, 32))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hero Banner — Ken Burns zoom
// ═══════════════════════════════════════════════════════════════════════════
class _HeroBanner extends StatefulWidget {
  final AnimationController zoomCtrl;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;

  const _HeroBanner({
    required this.zoomCtrl,
    this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
  });

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scale = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(parent: widget.zoomCtrl, curve: Curves.linear),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: R.h(context, 240),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ken Burns background
          AnimatedBuilder(
            animation: _scale,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: CustomNetworkImage(
                imageUrl: widget.imageUrl ?? _fallbackBannerImage,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x6B000000), Color(0xA6000000)],
              ),
            ),
          ),

          // Text content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.subtitle?.toUpperCase() ?? 'CURATED COLLECTIONS',
                    style: AppTypography.labelGold(context).copyWith(
                      letterSpacing: 3,
                      fontSize: R.sp(context, 9),
                    ),
                  ),
                  SizedBox(height: R.h(context, 8)),
                  Text(
                    widget.title ?? 'Explore Our\nCollections',
                    textAlign: TextAlign.center,
                    style: AppTypography.h1(context).copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                      fontSize: R.sp(context, 26),
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: R.h(context, 12)),
                  Text(
                    widget.description ?? 'A refined heritage of artisanal excellence and handcrafted perfection, curated for the modern connoisseur.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySM(context).copyWith(
                      color: (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.80),
                      fontStyle: FontStyle.italic,
                      fontSize: R.sp(context, 11),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Category Card
// ═══════════════════════════════════════════════════════════════════════════
class _CategoryCard extends StatefulWidget {
  final Category category;
  final int index;
  const _CategoryCard({required this.category, required this.index});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + widget.index * 80),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 90), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final sublabel = _sublabelFor(cat);
    final imageUrl = _imageFor(cat);

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            context.push('/shop?category=${cat.slug}');
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(R.w(context, 12)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image
                  CustomNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  ),

                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x33000000),
                          Color(0xD9000000),
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                  // Shimmer overlay on press
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: _pressed
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                  ),

                  // Text content at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedSlide(
                      offset: _pressed ? const Offset(0, -0.03) : Offset.zero,
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(R.w(context, 12), 0, R.w(context, 12), R.h(context, 12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Sublabel
                            Text(
                              sublabel,
                              style: AppTypography.label(context).copyWith(
                                color: AppColors.primary.withValues(alpha: 0.92),
                                fontSize: R.sp(context, 8),
                                letterSpacing: 1.8,
                              ),
                            ),
                            SizedBox(height: R.h(context, 4)),
                            // Category name
                            Text(
                              cat.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.h3(context).copyWith(
                                color: Colors.white,
                                fontSize: R.sp(context, 14),
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: R.h(context, 8)),
                            // SHOP NOW button
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: R.h(context, 8)),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(R.w(context, 6)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'SHOP NOW',
                                    style: AppTypography.label(context).copyWith(
                                      color: AppColors.deepCharcoal,
                                      fontSize: 8,
                                      letterSpacing: 1.4,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 10,
                                    color: AppColors.deepCharcoal,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

// ═══════════════════════════════════════════════════════════════════════════
// Skeleton Card
// ═══════════════════════════════════════════════════════════════════════════
class _CategorySkeleton extends StatefulWidget {
  const _CategorySkeleton();

  @override
  State<_CategorySkeleton> createState() => _CategorySkeletonState();
}

class _CategorySkeletonState extends State<_CategorySkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final color = Color.lerp(
          const Color(0xFFE8E3D8),
          const Color(0xFFF5F1EA),
          _anim.value,
        )!;
        return ClipRRect(
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          child: Container(
            color: color,
            child: Stack(
              children: [
                Positioned(
                  bottom: R.h(context, 12),
                  left: R.w(context, 12),
                  right: R.w(context, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: R.h(context, 8), width: R.w(context, 60), color: color.withValues(alpha: 0.5)),
                      SizedBox(height: R.h(context, 4)),
                      Container(height: R.h(context, 14), width: R.w(context, 100), color: color.withValues(alpha: 0.5)),
                      SizedBox(height: R.h(context, 8)),
                      Container(height: R.h(context, 28), decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(R.w(context, 6)),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Maker's Story Section
// ═══════════════════════════════════════════════════════════════════════════
class _MakersStorySection extends StatelessWidget {
  const _MakersStorySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 20), vertical: R.h(context, 40)),
      child: Column(
        children: [
          // Image with gold accent offset
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: R.h(context, -8),
                left: R.w(context, -8),
                right: R.w(context, 8),
                bottom: R.h(context, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(R.w(context, 16)),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(R.w(context, 16)),
                child: const AspectRatio(
                  aspectRatio: 1,
                  child: CustomNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1699980955924-9fa505a46b99?q=80&w=900&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: R.h(context, 32)),

          // Text content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE MAKER\'S STORY',
                style: AppTypography.labelGold(context).copyWith(letterSpacing: 3, fontSize: R.sp(context, 9)),
              ),
              SizedBox(height: R.h(context, 12)),
              Text(
                'Preserving Heritage Through the Hands of Masters',
                style: AppTypography.h2(context).copyWith(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                  fontSize: R.sp(context, 24),
                  height: 1.25,
                ),
              ),
              SizedBox(height: R.h(context, 16)),
              Text(
                'Every piece in our collection tells a story of dedication, passing through the hands of master craftsmen in the valleys of Kashmir who preserve centuries-old traditions. We bridge the gap between ancient techniques and modern living.',
                style: AppTypography.bodySM(context).copyWith(
                  color: (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.70),
                  height: 1.7,
                  fontSize: R.sp(context, 13),
                ),
              ),
              SizedBox(height: R.h(context, 16)),
              Container(
                padding: EdgeInsets.only(left: R.w(context, 16)),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                child: Text(
                  '"Our mission is to celebrate the soul of the maker in a world of mass production."',
                  style: AppTypography.bodySM(context).copyWith(
                    color: (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.70),
                    fontStyle: FontStyle.italic,
                    height: 1.7,
                    fontSize: R.sp(context, 13),
                  ),
                ),
              ),
              SizedBox(height: R.h(context, 24)),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'Read Our Heritage',
                      style: AppTypography.bodySM(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: R.sp(context, 13),
                      ),
                    ),
                    SizedBox(width: R.w(context, 8)),
                    Icon(Icons.arrow_forward_rounded,
                        color: AppColors.primary, size: R.sp(context, 16)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Newsletter Section
// ═══════════════════════════════════════════════════════════════════════════
class _NewsletterSection extends StatelessWidget {
  final TextEditingController controller;
  const _NewsletterSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.10),
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 20), vertical: R.h(context, 40)),
      child: Column(
        children: [
          Text(
            'Join the Collective',
            textAlign: TextAlign.center,
            style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 22)),
          ),
          SizedBox(height: R.h(context, 8)),
          Text(
            'Subscribe to receive exclusive access to limited artisanal drops, maker stories, and heritage events.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySM(context).copyWith(
              color: AppColors.neutralGold,
              height: 1.6,
              fontSize: R.sp(context, 13),
            ),
          ),
          SizedBox(height: R.h(context, 24)),
          TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: AppTypography.bodySM(context).copyWith(
                color: AppColors.neutralGold.withValues(alpha: 0.6),
                fontSize: R.sp(context, 12),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: R.w(context, 16), vertical: R.h(context, 14)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          SizedBox(height: R.h(context, 12)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.deepCharcoal,
                padding: EdgeInsets.symmetric(vertical: R.h(context, 14)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.w(context, 12))),
                elevation: 0,
              ),
              child: Text(
                'Subscribe',
                style: AppTypography.bodySM(context).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: R.sp(context, 14),
                  color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
                ),
              ),
            ),
          ),
          SizedBox(height: R.h(context, 12)),
          Text(
            'By subscribing, you agree to our Terms of Service and Privacy Policy.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySM(context).copyWith(
              color: AppColors.neutralGold.withValues(alpha: 0.7),
              fontSize: R.sp(context, 10),
            ),
          ),
        ],
      ),
    );
  }
}
