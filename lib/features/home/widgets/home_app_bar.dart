import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/providers.dart';
import '../../../providers/cart_provider.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white),
      surfaceTintColor: Colors.transparent,
      title: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          height: R.h(context, 36),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark // distinct dark card surface
                : const Color(0xFFF5F3EE),
            borderRadius: BorderRadius.circular(R.w(context, 10)),
            border: Theme.of(context).brightness == Brightness.dark
                ? Border.all(color: AppColors.borderDark, width: 1)
                : null,
          ),
          child: Row(
            children: [
              SizedBox(width: R.w(context, 10)),
              Icon(Icons.search_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.neutralGold,
                  size: R.sp(context, 18)),
              SizedBox(width: R.w(context, 8)),
              Expanded(
                child: Text(
                  'Search honey, saffron, nuts...',
                  style: AppTypography.bodySM(context).copyWith(
                    color: AppColors.neutralGold,
                    fontSize: R.sp(context, 12),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    context.push('/search', extra: {'autoStartVoice': true}),
                child: Padding(
                  padding: EdgeInsets.all(R.w(context, 8)),
                  child: Icon(Icons.mic_none,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.neutralGold,
                      size: R.sp(context, 18)),
                ),
              ),
              SizedBox(width: R.w(context, 2)),
            ],
          ),
        ),
      ),
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final unreadCount = ref.watch(unreadNotificationsCountProvider);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none_outlined,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.deepCharcoal),
                      size: 22),
                  onPressed: () => context.push('/notifications'),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: R.w(context, 14),
                      height: R.w(context, 14),
                      decoration: const BoxDecoration(
                          color: AppColors.error, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: R.sp(context, 8),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Consumer(
          builder: (context, ref, _) {
            final cart = ref.watch(cartProvider);
            final count =
                cart.items.fold<int>(0, (sum, item) => sum + item.quantity);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_bag_outlined,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.deepCharcoal),
                      size: 22),
                  onPressed: () => context.push('/cart'),
                ),
                if (count > 0)
                  Positioned(
                    top: 6,
                    right: 4,
                    child: Container(
                      width: R.w(context, 16),
                      height: R.w(context, 16),
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text('$count',
                            style: TextStyle(
                                color: AppColors.deepCharcoal,
                                fontSize: R.sp(context, 9),
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(width: R.w(context, 4)),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.borderLight),
      ),
    );
  }
}
