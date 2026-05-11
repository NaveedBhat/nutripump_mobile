import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/skeleton_loaders.dart';
import '../../../providers/providers.dart';

class AllProductsSection extends ConsumerWidget {
  const AllProductsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THE FULL RANGE',
                          style: AppTypography.label(context).copyWith(
                              color: AppColors.primary,
                              fontSize: R.sp(context, 9),
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w900)),
                      SizedBox(height: R.h(context, 3)),
                      Text('All Products',
                          style: AppTypography.h2(context)
                              .copyWith(fontSize: R.sp(context, 18))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/shop'),
                    child: Text('Browse All →',
                        style: AppTypography.label(context).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: R.sp(context, 10))),
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(context, 14)),
            SizedBox(
              height: R.h(context, 240),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => SizedBox(width: R.w(context, 12)),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: R.w(context, 150),
                    child: ProductCard(product: products[index], compact: true),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const HorizontalProductListSkeleton(height: 240),
      error: (_, __) => const SizedBox(),
    );
  }
}
