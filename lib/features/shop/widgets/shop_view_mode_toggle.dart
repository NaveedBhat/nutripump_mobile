import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class ShopViewModeToggle extends StatelessWidget {
  final String viewMode;
  final ValueChanged<String> onViewModeChanged;

  const ShopViewModeToggle({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCatalog = viewMode == 'catalog';
    return Container(
      margin: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 16),
          R.w(context, 16), R.h(context, 12)),
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
              onTap: () => onViewModeChanged('catalog'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: R.h(context, 10)),
                decoration: BoxDecoration(
                  color: isCatalog
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.backgroundDark
                          : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(R.w(context, 11)),
                  boxShadow: isCatalog
                      ? [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_view_rounded,
                        size: R.sp(context, 14),
                        color: isCatalog
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.onSurface
                                : AppColors.deepCharcoal)
                            : AppColors.neutralGold),
                    SizedBox(width: R.w(context, 6)),
                    Text('Catalog',
                        style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: R.sp(context, 11),
                          color: isCatalog
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.onSurface
                                  : AppColors.deepCharcoal)
                              : AppColors.neutralGold,
                        )),
                  ],
                ),
              ),
            ),
          ),
          // AI Gift Builder tab
          Expanded(
            child: GestureDetector(
              onTap: () => onViewModeChanged('gift-builder'),
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
                    Icon(Icons.auto_awesome_rounded,
                        size: R.sp(context, 14),
                        color: !isCatalog
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.onSurface
                                : AppColors.deepCharcoal)
                            : AppColors.neutralGold),
                    SizedBox(width: R.w(context, 6)),
                    Text('AI Gift Builder',
                        style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: R.sp(context, 11),
                          color: !isCatalog
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.onSurface
                                  : AppColors.deepCharcoal)
                              : AppColors.neutralGold,
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
}
