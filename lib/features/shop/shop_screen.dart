import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import 'ai_gift_builder.dart';

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
      backgroundColor: const Color(0xFFF9F8F6),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(Icons.search_rounded, color: AppColors.neutralGold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) => ref.read(shopFiltersProvider.notifier).setSearchQuery(v),
                              decoration: InputDecoration(
                                hintText: 'Search products, origins…',
                                hintStyle: AppTypography.bodySM(context).copyWith(
                                  color: AppColors.neutralGold.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          if (filters.searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(shopFiltersProvider.notifier).setSearchQuery('');
                              },
                            ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Result count + Filters + Sort row
                    Row(
                      children: [
                        Expanded(
                          child: filteredAsync.whenData((products) => Text(
                            '${products.length} product${products.length != 1 ? 's' : ''}',
                            style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 12),
                          )).valueOrNull ?? const SizedBox(),
                        ),
                        // Filters button
                        GestureDetector(
                          onTap: () => _openFilters(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.tune_rounded, size: 15, color: AppColors.deepCharcoal),
                                const SizedBox(width: 6),
                                Text('Filters', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Sort dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton<String>(
                            initialValue: filters.sortBy,
                            onSelected: (val) => ref.read(shopFiltersProvider.notifier).setSortBy(val),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              child: Row(
                                children: [
                                  Text(
                                    _sortOptions.firstWhere((o) => o.$1 == filters.sortBy, orElse: () => _sortOptions.first).$2,
                                    style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.deepCharcoal),
                                ],
                              ),
                            ),
                            itemBuilder: (_) => _sortOptions.map((o) => PopupMenuItem(
                              value: o.$1,
                              child: Text(o.$2, style: AppTypography.bodySM(context).copyWith(fontSize: 13)),
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
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => ProductCard(product: products[i]),
                      childCount: products.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
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
      height: 240,
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
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('HOME / SHOP', style: AppTypography.labelGold(context).copyWith(letterSpacing: 1.5, fontSize: 10)),
                const SizedBox(height: 8),
                Text('The Curated\nCollection', style: AppTypography.h1(context).copyWith(color: Colors.white, fontSize: 28, height: 1.15)),
                const SizedBox(height: 8),
                Text(
                  'Discover the essence of purity with our hand-harvested, artisanal selection from the heart of the valley.',
                  style: AppTypography.bodySM(context).copyWith(color: Colors.white.withValues(alpha: 0.85), fontStyle: FontStyle.italic, fontSize: 12),
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
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(14),
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
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: isCatalog ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: isCatalog ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_view_rounded, size: 17, color: isCatalog ? AppColors.deepCharcoal : AppColors.neutralGold),
                    const SizedBox(width: 8),
                    Text('Catalog', style: AppTypography.bodySM(context).copyWith(
                      fontWeight: FontWeight.w800, fontSize: 13,
                      color: isCatalog ? AppColors.deepCharcoal : AppColors.neutralGold,
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
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: !isCatalog ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 17, color: !isCatalog ? AppColors.deepCharcoal : AppColors.neutralGold),
                    const SizedBox(width: 8),
                    Text('AI Gift Builder', style: AppTypography.bodySM(context).copyWith(
                      fontWeight: FontWeight.w800, fontSize: 13,
                      color: !isCatalog ? AppColors.deepCharcoal : AppColors.neutralGold,
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
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
              ),
              child: Text(
                label,
                style: AppTypography.bodySM(context).copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.deepCharcoal : AppColors.neutralGold,
                  fontSize: 12,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 12),
            child: Row(
              children: [
                Text('Filters', style: AppTypography.h3(context)),
                const Spacer(),
                TextButton(
                  onPressed: () => notifier.reset(),
                  child: Text('Clear All', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 13)),
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
              padding: const EdgeInsets.all(20),
              children: [
                // Category
                Text('CATEGORY', style: AppTypography.label(context).copyWith(fontSize: 10, color: AppColors.neutralGold, letterSpacing: 1.5)),
                const SizedBox(height: 12),
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
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(label, style: AppTypography.bodySM(context).copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 14,
                                ))),
                                Text('$count', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 20),
                // Price Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PRICE RANGE', style: AppTypography.label(context).copyWith(fontSize: 10, color: AppColors.neutralGold, letterSpacing: 1.5)),
                    Text('Up to ₹${filters.priceMax.toInt()}', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.primary.withValues(alpha: 0.15),
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.1),
                    trackHeight: 3,
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
                    Text('₹100', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 11)),
                    Text('₹10,000+', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 20),
                // Origin
                Text('ORIGIN', style: AppTypography.label(context).copyWith(fontSize: 10, color: AppColors.neutralGold, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                ...availableOrigins.map((origin) => InkWell(
                  onTap: () => notifier.toggleOrigin(origin),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: filters.origins.contains(origin) ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: filters.origins.contains(origin) ? AppColors.primary : AppColors.borderLight,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: filters.origins.contains(origin)
                              ? const Icon(Icons.check_rounded, size: 13, color: AppColors.deepCharcoal)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(origin, style: AppTypography.bodySM(context).copyWith(fontSize: 14))),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '"Purity is not an opinion; it\'s our promise. Every product is sourced directly from heritage farmers."',
                    style: AppTypography.bodySM(context).copyWith(fontStyle: FontStyle.italic, fontSize: 12, color: AppColors.neutralGold, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 52,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: filteredAsync.when(
                    data: (products) => Text(
                      'Show ${products.length} Product${products.length != 1 ? 's' : ''}',
                      style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    loading: () => Text('Show Products', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
                    error: (_, __) => Text('Show Products', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
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
