import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class ShopCategoryPills extends ConsumerWidget {
  final List<Category> categories;
  final String? selectedCategory;

  const ShopCategoryPills({
    super.key,
    required this.categories,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = [
      const ('all', 'All Products'),
      ...categories.map((c) => (c.slug, c.name))
    ];
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
            onTap: () => ref
                .read(shopFiltersProvider.notifier)
                .setCategory(slug == 'all' ? null : slug),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 14)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : Colors.white),
                borderRadius: BorderRadius.circular(R.w(context, 16)),
                border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.borderLight),
              ),
              child: Text(
                label,
                style: AppTypography.bodySM(context).copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.deepCharcoal)
                      : AppColors.neutralGold,
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
