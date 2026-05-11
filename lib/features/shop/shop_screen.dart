import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/providers.dart';
import 'ai_gift_builder.dart';
import '../../core/widgets/skeleton_loaders.dart';
import 'widgets/shop_hero_banner.dart';
import 'widgets/shop_view_mode_toggle.dart';
import 'widgets/shop_category_pills.dart';
import 'widgets/shop_filter_sheet.dart';

const _sortOptions = [
  ('featured', 'Featured'),
  ('newest', 'Newest'),
  ('price-asc', 'Price: Low → High'),
  ('price-desc', 'Price: High → Low'),
  ('rating', 'Top Rated'),
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
  Timer? _debounceTimer;
  final ScrollController _scrollController = ScrollController();

  String? _heroBg;

  @override
  void initState() {
    super.initState();
    _loadHeroBg();
    // One-time category pre-selection — ref.read is allowed anywhere.
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
        if (mounted) {
          setState(() => _heroBg = snap.data()!['imageUrl'] as String);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ShopFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for tab re-tap to scroll to top (Shop is index 1).
    // ref.listen MUST be called inside build — not initState.
    ref.listen<int?>(scrollTabEventProvider, (_, index) {
      if (index == 1 && _scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    final filteredAsync = ref.watch(filteredProductsProvider);
    final filters = ref.watch(shopFiltersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : (Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).scaffoldBackgroundColor
              : const Color(0xFFF9F8F6))),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Hero Banner ──────────────────────────────────────────
          SliverToBoxAdapter(child: ShopHeroBanner(heroBg: _heroBg)),

          // ── Catalog / AI Gift Builder Toggle ─────────────────────
          SliverToBoxAdapter(
            child: ShopViewModeToggle(
              viewMode: _viewMode,
              onViewModeChanged: (mode) {
                setState(() => _viewMode = mode);
              },
            ),
          ),

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
                data: (cats) => ShopCategoryPills(
                    categories: cats, selectedCategory: filters.category),
                loading: () => const SizedBox(height: 36),
                error: (_, __) => const SizedBox(),
              ),
            ),

            // ── Search + Sort/Filter row ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 12),
                    R.w(context, 16), R.h(context, 8)),
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.surfaceDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(R.w(context, 10)),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: R.w(context, 12)),
                          Icon(Icons.search_rounded,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppColors.neutralGold,
                              size: R.sp(context, 16)),
                          SizedBox(width: R.w(context, 8)),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) {
                                if (_debounceTimer?.isActive ?? false) {
                                  _debounceTimer!.cancel();
                                }
                                _debounceTimer = Timer(
                                    const Duration(milliseconds: 300), () {
                                  ref
                                      .read(shopFiltersProvider.notifier)
                                      .setSearchQuery(v);
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search products, origins…',
                                hintStyle:
                                    AppTypography.bodySM(context).copyWith(
                                  color: AppColors.neutralGold
                                      .withValues(alpha: 0.6),
                                  fontSize: R.sp(context, 11),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: R.h(context, 8)),
                              ),
                            ),
                          ),
                          if (filters.searchQuery.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.close_rounded,
                                  size: R.sp(context, 16)),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(shopFiltersProvider.notifier)
                                    .setSearchQuery('');
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
                          child: filteredAsync
                                  .whenData((products) => Text(
                                        '${products.length} product${products.length != 1 ? 's' : ''}',
                                        style: AppTypography.bodySM(context)
                                            .copyWith(
                                                color: AppColors.neutralGold,
                                                fontSize: R.sp(context, 11)),
                                      ))
                                  .valueOrNull ??
                              const SizedBox(),
                        ),
                        // Filters button
                        GestureDetector(
                          onTap: () => _openFilters(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: R.w(context, 12),
                                vertical: R.h(context, 8)),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.surfaceDark
                                  : Colors.white,
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius:
                                  BorderRadius.circular(R.w(context, 8)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.tune_rounded,
                                    size: R.sp(context, 13),
                                    color: (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                        : AppColors.deepCharcoal)),
                                SizedBox(width: R.w(context, 6)),
                                Text('Filters',
                                    style: AppTypography.bodySM(context)
                                        .copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: R.sp(context, 11))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: R.w(context, 8)),
                        // Sort dropdown
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.surfaceDark
                                    : Colors.white,
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius:
                                BorderRadius.circular(R.w(context, 8)),
                          ),
                          child: PopupMenuButton<String>(
                            initialValue: filters.sortBy,
                            onSelected: (val) => ref
                                .read(shopFiltersProvider.notifier)
                                .setSortBy(val),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(R.w(context, 10))),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: R.w(context, 12),
                                  vertical: R.h(context, 8)),
                              child: Row(
                                children: [
                                  Text(
                                    _sortOptions
                                        .firstWhere(
                                            (o) => o.$1 == filters.sortBy,
                                            orElse: () => _sortOptions.first)
                                        .$2,
                                    style: AppTypography.bodySM(context)
                                        .copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: R.sp(context, 11)),
                                  ),
                                  SizedBox(width: R.w(context, 4)),
                                  Icon(Icons.keyboard_arrow_down_rounded,
                                      size: R.sp(context, 14),
                                      color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                          : AppColors.deepCharcoal)),
                                ],
                              ),
                            ),
                            itemBuilder: (_) => _sortOptions
                                .map((o) => PopupMenuItem(
                                      value: o.$1,
                                      child: Text(o.$2,
                                          style: AppTypography.bodySM(context)
                                              .copyWith(
                                                  fontSize: R.sp(context, 11))),
                                    ))
                                .toList(),
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
                          const Icon(Icons.inventory_2_outlined,
                              size: 48, color: AppColors.borderLight),
                          const SizedBox(height: 16),
                          Text('No products found',
                              style: AppTypography.h3(context)),
                          const SizedBox(height: 8),
                          Text('Try adjusting your filters',
                              style: AppTypography.bodySM(context)
                                  .copyWith(color: AppColors.neutralGold)),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(shopFiltersProvider.notifier).reset();
                            },
                            child: Text('Clear all filters',
                                style: AppTypography.bodySM(context).copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(R.w(context, 16),
                      R.h(context, 20), R.w(context, 16), R.h(context, 40)),
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
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('Error: $e'))),
              ),
            ),
          ], // end else (catalog mode)
        ],
      ),
    );
  }
}
