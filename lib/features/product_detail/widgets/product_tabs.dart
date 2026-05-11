import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/product.dart';

class ProductTabs extends StatefulWidget {
  final Product product;

  const ProductTabs({super.key, required this.product});

  @override
  State<ProductTabs> createState() => _ProductTabsState();
}

class _ProductTabsState extends State<ProductTabs> {
  String _activeTab = 'Description';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: R.h(context, 24)),
      padding: EdgeInsets.only(top: R.h(context, 24)),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Description', 'Ingredients', 'Nutrition'].map((tab) {
                final isActive = _activeTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: Container(
                    margin: EdgeInsets.only(right: R.w(context, 24)),
                    padding: EdgeInsets.only(bottom: R.h(context, 8)),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: isActive
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2)),
                    ),
                    child: Text(
                      tab.toUpperCase(),
                      style: AppTypography.label(context).copyWith(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.neutralGold,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        fontSize: R.sp(context, 10),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: R.h(context, 24)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildTabContent(widget.product, key: ValueKey(_activeTab)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(Product product, {Key? key}) {
    if (_activeTab == 'Description') {
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deeply Sourced & Crafted',
              style: AppTypography.h3(context)
                  .copyWith(fontSize: R.sp(context, 16))),
          SizedBox(height: R.h(context, 12)),
          Text(product.description,
              style: AppTypography.bodySM(context).copyWith(
                  height: 1.6,
                  color: AppColors.neutralGold,
                  fontSize: R.sp(context, 13))),
        ],
      );
    } else if (_activeTab == 'Ingredients') {
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What\'s Inside',
              style: AppTypography.h3(context)
                  .copyWith(fontSize: R.sp(context, 16))),
          SizedBox(height: R.h(context, 6)),
          Text('100% Transparent. No hidden preservatives.',
              style: AppTypography.bodySM(context).copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.neutralGold,
                  fontSize: R.sp(context, 12))),
          SizedBox(height: R.h(context, 16)),
          Container(
            padding: EdgeInsets.all(R.w(context, 16)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(R.w(context, 12)),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome,
                    color: AppColors.primary, size: R.sp(context, 16)),
                SizedBox(width: R.w(context, 12)),
                Expanded(
                  child: Text(
                    product.ingredients ??
                        'Crafted with 100% natural ingredients. Check packaging for specific list.',
                    style: AppTypography.bodySM(context).copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        fontSize: R.sp(context, 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nutrition per 100g',
                  style: AppTypography.h3(context)
                      .copyWith(fontSize: R.sp(context, 16))),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 6), vertical: R.h(context, 3)),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(R.w(context, 100))),
                child: Text('VERIFIED',
                    style: AppTypography.label(context).copyWith(
                        color: AppColors.primary,
                        fontSize: R.sp(context, 7),
                        letterSpacing: 1.5)),
              ),
            ],
          ),
          SizedBox(height: R.h(context, 16)),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: R.h(context, 10),
            crossAxisSpacing: R.w(context, 10),
            childAspectRatio: 1.6,
            children: [
              _buildNutritionCard(
                  'Calories', product.calories ?? '654', 'kcal'),
              _buildNutritionCard(
                  'Total Fat', product.fat ?? '65g', '9g Omega-3'),
              _buildNutritionCard(
                  'Protein', product.protein ?? '15g', 'per 100g'),
              _buildNutritionCard('Carbs', product.carbs ?? '14g', '2g sugar'),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildNutritionCard(String label, String value, String sub) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : const Color(0xFFF5F1E9),
        borderRadius: BorderRadius.circular(R.w(context, 16)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      padding: EdgeInsets.all(R.w(context, 12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: AppTypography.h2(context).copyWith(
                  fontSize: R.sp(context, 20),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFF5F0E8)
                      : const Color(0xFF1B3B36))),
          SizedBox(height: R.h(context, 2)),
          Text(label.toUpperCase(),
              style: AppTypography.label(context).copyWith(
                  fontSize: R.sp(context, 8),
                  letterSpacing: 1.0,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFF5F0E8)
                          : const Color(0xFF1B3B36))
                      .withValues(alpha: 0.7))),
          SizedBox(height: R.h(context, 2)),
          Text(sub,
              style: AppTypography.label(context).copyWith(
                  fontSize: R.sp(context, 7),
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFF5F0E8)
                          : const Color(0xFF1B3B36))
                      .withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}
