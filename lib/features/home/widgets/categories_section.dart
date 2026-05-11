import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/widgets/skeleton_loaders.dart';
import '../../../providers/providers.dart';

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    final circleSize = R.w(context, 58);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shop by Category',
                  style: AppTypography.h2(context)
                      .copyWith(fontSize: R.sp(context, 16))),
              GestureDetector(
                onTap: () => context.push('/categories'),
                child: Text('See All',
                    style: AppTypography.label(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: R.sp(context, 10),
                    )),
              ),
            ],
          ),
        ),
        SizedBox(height: R.h(context, 12)),
        SizedBox(
          height: circleSize + R.h(context, 26),
          child: categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return const SizedBox();
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => SizedBox(width: R.w(context, 12)),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () => context.push('/shop?category=${cat.slug}'),
                    child: Column(
                      children: [
                        Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Theme.of(context).scaffoldBackgroundColor
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : const Color(0xFFF0EBE0))),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                width: 1.5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(R.w(context, 3)),
                            child: ClipOval(
                              child: cat.image != null && cat.image!.isNotEmpty
                                  ? CustomNetworkImage(imageUrl: cat.image!)
                                  : CustomNetworkImage(
                                      imageUrl:
                                          _getCategoryFallbackImage(cat.name)),
                            ),
                          ),
                        ),
                        SizedBox(height: R.h(context, 6)),
                        SizedBox(
                          width: circleSize,
                          child: Text(
                            cat.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label(context).copyWith(
                              fontSize: R.sp(context, 10),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const CategoryListSkeleton(),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  String _getCategoryFallbackImage(String name) {
    switch (name.toLowerCase()) {
      case 'raw honey':
      case 'honey':
        return 'https://images.unsplash.com/photo-1587049352851-8d4e89133924?q=80&w=400&auto=format&fit=crop';
      case 'saffron':
        return 'https://images.unsplash.com/photo-1596662951362-b48c66a4bc2c?q=80&w=400&auto=format&fit=crop';
      case 'dry fruits':
      case 'nuts':
        return 'https://images.unsplash.com/photo-1599579100062-1718713bd733?q=80&w=400&auto=format&fit=crop';
      case 'oils':
      case 'cold pressed oils':
        return 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?q=80&w=400&auto=format&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1618897996318-5a901fa6ca71?q=80&w=400&auto=format&fit=crop';
    }
  }
}
