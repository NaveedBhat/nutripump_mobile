import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/providers.dart';

class ShopFilterSheet extends ConsumerWidget {
  const ShopFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(shopFiltersProvider);
    final notifier = ref.read(shopFiltersProvider.notifier);
    final productsAsync = ref.watch(allProductsProvider);
    final filteredAsync = ref.watch(filteredProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final availableOrigins = productsAsync.valueOrNull != null
        ? (productsAsync.value!
            .map((p) => p.origin)
            .toSet()
            .where((o) => o.isNotEmpty)
            .toList()
          ..sort())
        : <String>['Kashmir Valley', 'Ladakh Highlands', 'Himachal Slopes'];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(R.w(context, 24))),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(
                  top: R.h(context, 12), bottom: R.h(context, 4)),
              width: R.w(context, 40),
              height: R.h(context, 4),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(R.w(context, 2))),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(R.w(context, 20), R.h(context, 8),
                R.w(context, 8), R.h(context, 12)),
            child: Row(
              children: [
                Text('Filters', style: AppTypography.h3(context)),
                const Spacer(),
                TextButton(
                  onPressed: () => notifier.reset(),
                  child: Text('Clear All',
                      style: AppTypography.bodySM(context).copyWith(
                          color: AppColors.neutralGold,
                          fontSize: R.sp(context, 13))),
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
                Text('CATEGORY',
                    style: AppTypography.label(context).copyWith(
                        fontSize: R.sp(context, 10),
                        color: AppColors.neutralGold,
                        letterSpacing: 1.5)),
                SizedBox(height: R.h(context, 12)),
                categoriesAsync.when(
                  data: (cats) {
                    final all = [
                      const ('all', 'All Products'),
                      ...cats.map((c) => (c.slug, c.name))
                    ];
                    final products = productsAsync.valueOrNull ?? [];
                    return Column(
                      children: all.map((entry) {
                        final (slug, label) = entry;
                        final isSelected = slug == 'all'
                            ? filters.category == null ||
                                filters.category == 'all'
                            : filters.category == slug;
                        final count = slug == 'all'
                            ? products.length
                            : products.where((p) => p.category == slug).length;
                        return InkWell(
                          onTap: () =>
                              notifier.setCategory(slug == 'all' ? null : slug),
                          borderRadius: BorderRadius.circular(R.w(context, 10)),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: R.h(context, 11),
                                horizontal: R.w(context, 12)),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(R.w(context, 10)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(label,
                                        style: AppTypography.bodySM(context)
                                            .copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontSize: R.sp(context, 14),
                                        ))),
                                Text('$count',
                                    style: AppTypography.bodySM(context)
                                        .copyWith(
                                            color: AppColors.neutralGold,
                                            fontSize: R.sp(context, 12))),
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
                    Text('PRICE RANGE',
                        style: AppTypography.label(context).copyWith(
                            fontSize: R.sp(context, 10),
                            color: AppColors.neutralGold,
                            letterSpacing: 1.5)),
                    Text('Up to ₹${filters.priceMax.toInt()}',
                        style: AppTypography.bodySM(context).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: R.sp(context, 13))),
                  ],
                ),
                SizedBox(height: R.h(context, 10)),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.1),
                    trackHeight: R.h(context, 3),
                  ),
                  child: Slider(
                    min: 100,
                    max: 10000,
                    divisions: 99,
                    value: filters.priceMax,
                    onChanged: (v) => notifier.setPriceMax(v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹100',
                        style: AppTypography.bodySM(context).copyWith(
                            color: AppColors.neutralGold,
                            fontSize: R.sp(context, 11))),
                    Text('₹10,000+',
                        style: AppTypography.bodySM(context).copyWith(
                            color: AppColors.neutralGold,
                            fontSize: R.sp(context, 11))),
                  ],
                ),
                SizedBox(height: R.h(context, 24)),
                const Divider(),
                SizedBox(height: R.h(context, 20)),
                // Origin
                Text('ORIGIN',
                    style: AppTypography.label(context).copyWith(
                        fontSize: R.sp(context, 10),
                        color: AppColors.neutralGold,
                        letterSpacing: 1.5)),
                SizedBox(height: R.h(context, 12)),
                ...availableOrigins.map((origin) => InkWell(
                      onTap: () => notifier.toggleOrigin(origin),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: R.h(context, 8)),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: R.w(context, 20),
                              height: R.w(context, 20),
                              decoration: BoxDecoration(
                                color: filters.origins.contains(origin)
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: filters.origins.contains(origin)
                                      ? AppColors.primary
                                      : AppColors.borderLight,
                                  width: 1.5,
                                ),
                                borderRadius:
                                    BorderRadius.circular(R.w(context, 5)),
                              ),
                              child: filters.origins.contains(origin)
                                  ? Icon(Icons.check_rounded,
                                      size: R.sp(context, 13),
                                      color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                          : AppColors.deepCharcoal))
                                  : null,
                            ),
                            SizedBox(width: R.w(context, 12)),
                            Expanded(
                                child: Text(origin,
                                    style: AppTypography.bodySM(context)
                                        .copyWith(
                                            fontSize: R.sp(context, 14)))),
                          ],
                        ),
                      ),
                    )),
                SizedBox(height: R.h(context, 32)),
                Container(
                  padding: EdgeInsets.all(R.w(context, 16)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(R.w(context, 14)),
                  ),
                  child: Text(
                    '"Purity is not an opinion; it\'s our promise. Every product is sourced directly from heritage farmers."',
                    style: AppTypography.bodySM(context).copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: R.sp(context, 12),
                        color: AppColors.neutralGold,
                        height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                R.w(context, 20),
                R.h(context, 12),
                R.w(context, 20),
                MediaQuery.of(context).padding.bottom + R.h(context, 16)),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: R.h(context, 52),
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(R.w(context, 14))),
                child: Center(
                  child: filteredAsync.when(
                    data: (products) => Text(
                      'Show ${products.length} Product${products.length != 1 ? 's' : ''}',
                      style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: R.sp(context, 15),
                          color: AppColors.deepCharcoal),
                    ),
                    loading: () => Text('Show Products',
                        style: AppTypography.bodySM(context).copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: R.sp(context, 15),
                            color: AppColors.deepCharcoal)),
                    error: (_, __) => Text('Show Products',
                        style: AppTypography.bodySM(context).copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: R.sp(context, 15),
                            color: AppColors.deepCharcoal)),
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
