import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/providers.dart';

class FrequentlyBoughtTogether extends ConsumerStatefulWidget {
  final Product product;

  const FrequentlyBoughtTogether({super.key, required this.product});

  @override
  ConsumerState<FrequentlyBoughtTogether> createState() =>
      _FrequentlyBoughtTogetherState();
}

class _FrequentlyBoughtTogetherState
    extends ConsumerState<FrequentlyBoughtTogether> {
  bool _fbtThisItem = true;
  bool _fbtChecked = true;

  Widget _buildCheckbox(bool value) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: R.w(context, 22),
      height: R.w(context, 22),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary
            : (Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.white),
        border: Border.all(
            color: value ? AppColors.primary : AppColors.borderLight, width: 2),
        borderRadius: BorderRadius.circular(R.w(context, 6)),
      ),
      child: value
          ? Icon(Icons.check,
              color: AppColors.deepCharcoal, size: R.sp(context, 14))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final relatedAsync = ref.watch(allProductsProvider);
    return relatedAsync.when(
      data: (allProducts) {
        final related = allProducts
            .where((p) => p.id != widget.product.id)
            .take(2)
            .toList();
        if (related.isEmpty) return const SizedBox.shrink();

        final fbtProduct = related.first;
        final fbtDiscountPct = fbtProduct.compareAtPrice != null &&
                fbtProduct.compareAtPrice! > fbtProduct.price
            ? ((fbtProduct.compareAtPrice! - fbtProduct.price) /
                    fbtProduct.compareAtPrice! *
                    100)
                .clamp(0.0, 100.0)
            : 10.0;
        final discountedFbtPrice =
            fbtProduct.price * (1 - fbtDiscountPct / 100);

        double totalPrice = 0;
        if (_fbtThisItem) totalPrice += widget.product.price;
        if (_fbtChecked) totalPrice += discountedFbtPrice;

        int itemCount = (_fbtThisItem ? 1 : 0) + (_fbtChecked ? 1 : 0);

        return Container(
          margin: EdgeInsets.only(top: R.h(context, 32)),
          padding: EdgeInsets.only(top: R.h(context, 32)),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Frequently Bought Together',
                  style: AppTypography.h2(context)
                      .copyWith(fontSize: R.sp(context, 20))),
              SizedBox(height: R.h(context, 16)),
              Container(
                padding: EdgeInsets.all(R.w(context, 16)),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  borderRadius: BorderRadius.circular(R.w(context, 16)),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AnimatedOpacity(
                          opacity: _fbtThisItem ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 200),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(R.w(context, 10)),
                            child: CustomNetworkImage(
                                imageUrl: widget.product.images.first,
                                width: R.w(context, 64),
                                height: R.w(context, 64),
                                fit: BoxFit.cover),
                          ),
                        ),
                        SizedBox(width: R.w(context, 10)),
                        Container(
                          padding: EdgeInsets.all(R.w(context, 4)),
                          decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.surfaceDark
                                  : const Color(0xFFF0F0F0),
                              shape: BoxShape.circle),
                          child: Icon(Icons.add,
                              color: AppColors.neutralGold,
                              size: R.sp(context, 16)),
                        ),
                        SizedBox(width: R.w(context, 10)),
                        AnimatedOpacity(
                          opacity: _fbtChecked ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 200),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(R.w(context, 10)),
                            child: CustomNetworkImage(
                                imageUrl: fbtProduct.images.first,
                                width: R.w(context, 64),
                                height: R.w(context, 64),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(context, 16)),
                    const Divider(color: AppColors.borderLight, height: 1),
                    SizedBox(height: R.h(context, 12)),
                    GestureDetector(
                      onTap: () => setState(() => _fbtThisItem = !_fbtThisItem),
                      child: Row(
                        children: [
                          _buildCheckbox(_fbtThisItem),
                          SizedBox(width: R.w(context, 10)),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    child: Text(widget.product.name,
                                        style: AppTypography.bodySM(context)
                                            .copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: R.sp(context, 12)),
                                        overflow: TextOverflow.ellipsis)),
                                SizedBox(width: R.w(context, 8)),
                                Text(formatPrice(widget.product.price),
                                    style: AppTypography.label(context)
                                        .copyWith(
                                            color: const Color(0xFF1A7A42),
                                            fontWeight: FontWeight.w800,
                                            fontSize: R.sp(context, 11))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: R.h(context, 10)),
                    GestureDetector(
                      onTap: () => setState(() => _fbtChecked = !_fbtChecked),
                      child: Row(
                        children: [
                          _buildCheckbox(_fbtChecked),
                          SizedBox(width: R.w(context, 10)),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    child: Text(fbtProduct.name,
                                        style: AppTypography.bodySM(context)
                                            .copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: R.sp(context, 12)),
                                        overflow: TextOverflow.ellipsis)),
                                SizedBox(width: R.w(context, 8)),
                                Row(
                                  children: [
                                    Text(formatPrice(discountedFbtPrice),
                                        style: AppTypography.label(context)
                                            .copyWith(
                                                color: const Color(0xFF1A7A42),
                                                fontWeight: FontWeight.w800,
                                                fontSize: R.sp(context, 11))),
                                    SizedBox(width: R.w(context, 4)),
                                    Text(formatPrice(fbtProduct.price),
                                        style:
                                            AppTypography.priceStrike(context)
                                                .copyWith(
                                                    fontSize:
                                                        R.sp(context, 10))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: R.h(context, 16)),
                    const Divider(color: AppColors.borderLight, height: 1),
                    SizedBox(height: R.h(context, 12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL',
                            style: AppTypography.label(context).copyWith(
                                color: AppColors.neutralGold,
                                fontSize: R.sp(context, 9),
                                letterSpacing: 2.0)),
                        Text(itemCount == 0 ? '—' : formatPrice(totalPrice),
                            style: AppTypography.h3(context)
                                .copyWith(fontSize: R.sp(context, 20))),
                      ],
                    ),
                    SizedBox(height: R.h(context, 12)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: itemCount == 0
                              ? AppColors.borderLight
                              : AppColors.primary,
                          foregroundColor: AppColors.deepCharcoal,
                          padding:
                              EdgeInsets.symmetric(vertical: R.h(context, 14)),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(R.w(context, 12))),
                          elevation: 0,
                        ),
                        onPressed: itemCount == 0
                            ? null
                            : () {
                                if (_fbtThisItem) {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addItem(widget.product, qty: 1);
                                }
                                if (_fbtChecked) {
                                  ref.read(cartProvider.notifier).addItem(
                                      fbtProduct,
                                      qty: 1,
                                      bundlePrice: discountedFbtPrice);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    duration:
                                        const Duration(milliseconds: 2000),
                                    content: Text(
                                        '$itemCount item${itemCount == 1 ? '' : 's'} added to cart')));
                              },
                        child: Text(
                          itemCount == 0
                              ? 'Select at least one item'
                              : 'Add $itemCount Item${itemCount == 1 ? '' : 's'} to Cart',
                          style: AppTypography.bodySM(context).copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: R.sp(context, 12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
