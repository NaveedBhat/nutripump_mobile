import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import 'ai_gift_builder.dart';
import '../../core/widgets/skeleton_loaders.dart';

const _sortOptions = [
  ('featured',   'Featured'),
  ('newest',     'Newest'),
  ('price-asc',  'Price: Low → High'),
  ('price-desc', 'Price: High → Low'),
  ('rating',     'Top Rated'),
];

class ShopScreen extends ConsumerStatefulWidget {
  final String? category;
  const ShopScreen({super.key, this.category});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _searchController = TextEditingController();
  String _viewMode = 'catalog';

  static const _fallbackHero =
      'https://images.unsplash.com/photo-1647427062468-74ff21e8934f?q=80&w=1200&auto=format&fit=crop';
  String? _heroBg;

  @override
  void initState() {
    super.initState();
    _loadHeroBg();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.category != null) {
        ref.read(shopFiltersProvider.notifier).setCategory(widget.category);
      }
    });
  }

  Future<void> _loadHeroBg() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('settings')
          .doc('shopBanner')
          .get();
      if (snap.exists && snap.data()?['imageUrl'] != null) {
        if (mounted) setState(() => _heroBg = snap.data()!['imageUrl'] as String);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredProductsProvider);
    final filters = ref.watch(shopFiltersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : Color(0xFFF9F8F6))),
      body: CustomScrollView(
        slivers: [
          // ── Hero Banner ──────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeroBanner()),

          // ── Catalog / AI Gift Builder Toggle ─────────────────────
          SliverToBoxAdapter(child: _buildToggle()),

          // ── Mode: AI Gift Builder ─────────────────────────────────
          if (_viewMode == 'gift-builder') ...[
            const SliverFillRemaining(
              hasScrollBody: true,
              child: AIGiftBuilder(),
            ),
          ] else ...[
            // ── Category Pills ──────────────────────────────────────
            SliverToBoxAdapter(
              child: categoriesAsync.when(
                data: (cats) => _buildCategoryPills(cats, filters.category),
                loading: () => const SizedBox(height: 36),
                error: (_, __) => const SizedBox(),
              ),
            ),

            // ── Search + Sort/Filter row ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 12), R.w(context, 16), R.h(context, 8)),
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(R.w(context, 10)),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: R.w(context, 12)),
                          Icon(Icons.search_rounded, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.neutralGold, size: R.sp(context, 16)),
                          SizedBox(width: R.w(context, 8)),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) => ref.read(shopFiltersProvider.notifier).setSearchQuery(v),
                              decoration: InputDecoration(
                                hintText: 'Search products, origins…',
                                hintStyle: AppTypography.bodySM(context).copyWith(
                                  color: AppColors.neutralGold.withValues(alpha: 0.6),
                                  fontSize: R.sp(context, 11),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: R.h(context, 8)),
                              ),
                            ),
                          ),
                          if (filters.searchQuery.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.close_rounded, size: R.sp(context, 16)),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(shopFiltersProvider.notifier).setSearchQuery('');
                              },
                            ),
                          SizedBox(width: R.w(context, 4)),
                        ],
                      ),
                    ),

                    SizedBox(height: R.h(context, 12)),

                    // Result count + Filters + Sort row
                    Row(
                      children: [
                        Expanded(
                          child: filteredAsync.whenData((products) => Text(
                            '${products.length} product${products.length != 1 ? 's' : ''}',
                            style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 11)),
                          )).valueOrNull ?? const SizedBox(),
                        ),
                        // Filters button
                        GestureDetector(
                          onTap: () => _openFilters(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: R.w(context, 12), vertical: R.h(context, 8)),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius: BorderRadius.circular(R.w(context, 8)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.tune_rounded, size: R.sp(context, 13), color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
                                SizedBox(width: R.w(context, 6)),
                                Text('Filters', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 11))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: R.w(context, 8)),
                        // Sort dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(R.w(context, 8)),
                          ),
                          child: PopupMenuButton<String>(
                            initialValue: filters.sortBy,
                            onSelected: (val) => ref.read(shopFiltersProvider.notifier).setSortBy(val),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 10))),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: R.w(context, 12), vertical: R.h(context, 8)),
                              child: Row(
                                children: [
                                  Text(
                                    _sortOptions.firstWhere((o) => o.$1 == filters.sortBy, orElse: () => _sortOptions.first).$2,
                                    style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 11)),
                                  ),
                                  SizedBox(width: R.w(context, 4)),
                                  Icon(Icons.keyboard_arrow_down_rounded, size: R.sp(context, 14), color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
                                ],
                              ),
                            ),
                            itemBuilder: (_) => _sortOptions.map((o) => PopupMenuItem(
                              value: o.$1,
                              child: Text(o.$2, style: AppTypography.bodySM(context).copyWith(fontSize: R.sp(context, 11))),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Product Grid ──────────────────────────────────────
            filteredAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.borderLight),
                          const SizedBox(height: 16),
                          Text('No products found', style: AppTypography.h3(context)),
                          const SizedBox(height: 8),
                          Text('Try adjusting your filters', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(shopFiltersProvider.notifier).reset();
                            },
                            child: Text('Clear all filters', style: AppTypography.bodySM(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 20), R.w(context, 16), R.h(context, 40)),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: R.w(context, 14),
                      mainAxisSpacing: R.h(context, 14),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => ProductCard(product: products[i]),
                      childCount: products.length,
                    ),
                  ),
                );
              },
              loading: () => const ProductGridSkeleton(),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Error: $e'))),
              ),
            ),
          ], // end else (catalog mode)
        ],
      ),
    );
  }

  // ── Hero Banner ─────────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    final imageUrl = _heroBg ?? _fallbackHero;
    return SizedBox(
      height: R.h(context, 240),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xA6201E0D), Color(0xC7201E0D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(R.w(context, 20), R.h(context, 48), R.w(context, 20), R.h(context, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('HOME / SHOP', style: AppTypography.labelGold(context).copyWith(letterSpacing: 1.5, fontSize: R.sp(context, 9))),
                SizedBox(height: R.h(context, 6)),
                Text('The Curated\nCollection', style: AppTypography.h1(context).copyWith(color: Colors.white, fontSize: R.sp(context, 22), height: 1.15)),
                SizedBox(height: R.h(context, 6)),
                Text(
                  'Discover the essence of purity with our hand-harvested, artisanal selection from the heart of the valley.',
                  style: AppTypography.bodySM(context).copyWith(color: Colors.white.withValues(alpha: 0.85), fontStyle: FontStyle.italic, fontSize: R.sp(context, 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Catalog / AI Toggle ──────────────────────────────────────────────────────
  Widget _buildToggle() {
    final isCatalog = _viewMode == 'catalog';
    return Container(
      margin: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 16), R.w(context, 16), R.h(context, 12)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Catalog tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _viewMode = 'catalog'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: R.h(context, 10)),
                decoration: BoxDecoration(
                  color: isCatalog
                      ? (Theme.of(context).brightness == Brightness.dark ? AppColors.backgroundDark : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(R.w(context, 11)),
                  boxShadow: isCatalog ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_view_rounded, size: R.sp(context, 14), color: isCatalog ? (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal) : AppColors.neutralGold),
                    SizedBox(width: R.w(context, 6)),
                    Text('Catalog', style: AppTypography.bodySM(context).copyWith(
                      fontWeight: FontWeight.w800, fontSize: R.sp(context, 11),
                      color: isCatalog ? (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal) : AppColors.neutralGold,
                    )),
                  ],
                ),
              ),
            ),
          ),
          // AI Gift Builder tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _viewMode = 'gift-builder'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: R.h(context, 10)),
                decoration: BoxDecoration(
                  color: !isCatalog ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(R.w(context, 11)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: R.sp(context, 14), color: !isCatalog ? (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal) : AppColors.neutralGold),
                    SizedBox(width: R.w(context, 6)),
                    Text('AI Gift Builder', style: AppTypography.bodySM(context).copyWith(
                      fontWeight: FontWeight.w800, fontSize: R.sp(context, 11),
                      color: !isCatalog ? (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal) : AppColors.neutralGold,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Pills ───────────────────────────────────────────────────────────
  Widget _buildCategoryPills(List<Category> cats, String? selectedCategory) {
    final all = [const ('all', 'All Products'), ...cats.map((c) => (c.slug, c.name))];
    return SizedBox(
      height: R.h(context, 32),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: R.w(context, 16)),
        separatorBuilder: (_, __) => SizedBox(width: R.w(context, 8)),
        itemCount: all.length,
        itemBuilder: (context, i) {
          final (slug, label) = all[i];
          final isSelected = slug == 'all'
              ? selectedCategory == null || selectedCategory == 'all'
              : selectedCategory == slug;
          return GestureDetector(
            onTap: () => ref.read(shopFiltersProvider.notifier).setCategory(slug == 'all' ? null : slug),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 14)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white),
                borderRadius: BorderRadius.circular(R.w(context, 16)),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
              ),
              child: Text(
                label,
                style: AppTypography.bodySM(context).copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal) : AppColors.neutralGold,
                  fontSize: R.sp(context, 11),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(shopFiltersProvider);
    final notifier = ref.read(shopFiltersProvider.notifier);
    final productsAsync = ref.watch(allProductsProvider);
    final filteredAsync = ref.watch(filteredProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final availableOrigins = productsAsync.valueOrNull != null
        ? (productsAsync.value!.map((p) => p.origin).toSet().where((o) => o.isNotEmpty).toList()..sort())
        : <String>['Kashmir Valley', 'Ladakh Highlands', 'Himachal Slopes'];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.w(context, 24))),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: R.h(context, 12), bottom: R.h(context, 4)),
              width: R.w(context, 40), height: R.h(context, 4),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(R.w(context, 2))),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(R.w(context, 20), R.h(context, 8), R.w(context, 8), R.h(context, 12)),
            child: Row(
              children: [
                Text('Filters', style: AppTypography.h3(context)),
                const Spacer(),
                TextButton(
                  onPressed: () => notifier.reset(),
                  child: Text('Clear All', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 13))),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(R.w(context, 20)),
              children: [
                // Category
                Text('CATEGORY', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10), color: AppColors.neutralGold, letterSpacing: 1.5)),
                SizedBox(height: R.h(context, 12)),
                categoriesAsync.when(
                  data: (cats) {
                    final all = [const ('all', 'All Products'), ...cats.map((c) => (c.slug, c.name))];
                    final products = productsAsync.valueOrNull ?? [];
                    return Column(
                      children: all.map((entry) {
                        final (slug, label) = entry;
                        final isSelected = slug == 'all'
                            ? filters.category == null || filters.category == 'all'
                            : filters.category == slug;
                        final count = slug == 'all' ? products.length : products.where((p) => p.category == slug).length;
                        return InkWell(
                          onTap: () => notifier.setCategory(slug == 'all' ? null : slug),
                          borderRadius: BorderRadius.circular(R.w(context, 10)),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: R.h(context, 11), horizontal: R.w(context, 12)),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(R.w(context, 10)),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(label, style: AppTypography.bodySM(context).copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: R.sp(context, 14),
                                ))),
                                Text('$count', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 12))),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const SizedBox(height: 40),
                  error: (_, __) => const SizedBox(),
                ),
                SizedBox(height: R.h(context, 24)),
                const Divider(),
                SizedBox(height: R.h(context, 20)),
                // Price Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PRICE RANGE', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10), color: AppColors.neutralGold, letterSpacing: 1.5)),
                    Text('Up to ₹${filters.priceMax.toInt()}', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 13))),
                  ],
                ),
                SizedBox(height: R.h(context, 10)),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.primary.withValues(alpha: 0.15),
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.1),
                    trackHeight: R.h(context, 3),
                  ),
                  child: Slider(
                    min: 100, max: 10000, divisions: 99,
                    value: filters.priceMax,
                    onChanged: (v) => notifier.setPriceMax(v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹100', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 11))),
                    Text('₹10,000+', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 11))),
                  ],
                ),
                SizedBox(height: R.h(context, 24)),
                const Divider(),
                SizedBox(height: R.h(context, 20)),
                // Origin
                Text('ORIGIN', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10), color: AppColors.neutralGold, letterSpacing: 1.5)),
                SizedBox(height: R.h(context, 12)),
                ...availableOrigins.map((origin) => InkWell(
                  onTap: () => notifier.toggleOrigin(origin),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: R.h(context, 8)),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: R.w(context, 20), height: R.w(context, 20),
                          decoration: BoxDecoration(
                            color: filters.origins.contains(origin) ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: filters.origins.contains(origin) ? AppColors.primary : AppColors.borderLight,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(R.w(context, 5)),
                          ),
                          child: filters.origins.contains(origin)
                              ? Icon(Icons.check_rounded, size: R.sp(context, 13), color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal))
                              : null,
                        ),
                        SizedBox(width: R.w(context, 12)),
                        Expanded(child: Text(origin, style: AppTypography.bodySM(context).copyWith(fontSize: R.sp(context, 14)))),
                      ],
                    ),
                  ),
                )),
                SizedBox(height: R.h(context, 32)),
                Container(
                  padding: EdgeInsets.all(R.w(context, 16)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(R.w(context, 14)),
                  ),
                  child: Text(
                    '"Purity is not an opinion; it\'s our promise. Every product is sourced directly from heritage farmers."',
                    style: AppTypography.bodySM(context).copyWith(fontStyle: FontStyle.italic, fontSize: R.sp(context, 12), color: AppColors.neutralGold, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(R.w(context, 20), R.h(context, 12), R.w(context, 20), MediaQuery.of(context).padding.bottom + R.h(context, 16)),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: R.h(context, 52),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(R.w(context, 14))),
                child: Center(
                  child: filteredAsync.when(
                    data: (products) => Text(
                      'Show ${products.length} Product${products.length != 1 ? 's' : ''}',
                      style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 15), color: AppColors.deepCharcoal),
                    ),
                    loading: () => Text('Show Products', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 15), color: AppColors.deepCharcoal)),
                    error: (_, __) => Text('Show Products', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 15), color: AppColors.deepCharcoal)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
