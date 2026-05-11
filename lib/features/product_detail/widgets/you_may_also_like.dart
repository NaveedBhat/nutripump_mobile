import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/product_card.dart';
import '../../../models/product.dart';
import '../../../providers/providers.dart';

class YouMayAlsoLike extends ConsumerWidget {
  final Product product;

  const YouMayAlsoLike({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    return productsAsync.when(
      data: (products) {
        final related = products.where((p) => p.id != product.id).toList();
        if (related.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: EdgeInsets.only(top: R.h(context, 32)),
          padding: EdgeInsets.only(top: R.h(context, 32)),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You May Also Like',
                  style: AppTypography.h2(context)
                      .copyWith(fontSize: R.sp(context, 20))),
              SizedBox(height: R.h(context, 16)),
              SizedBox(
                height: R.h(context, 280),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: related.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: R.w(context, 16)),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: R.w(context, 160),
                      child: ProductCard(product: related[index]),
                    );
                  },
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
