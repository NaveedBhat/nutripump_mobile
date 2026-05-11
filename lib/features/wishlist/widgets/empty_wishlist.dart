import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class EmptyWishlist extends StatefulWidget {
  const EmptyWishlist({super.key});

  @override
  State<EmptyWishlist> createState() => _EmptyWishlistState();
}

class _EmptyWishlistState extends State<EmptyWishlist>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: R.w(context, 40), vertical: R.h(context, 60)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: R.w(context, 70),
                  height: R.w(context, 70),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        width: 1.5),
                  ),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: R.sp(context, 28),
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: R.h(context, 20)),
              Text('Your wishlist is empty',
                  style: AppTypography.h2(context)
                      .copyWith(fontSize: R.sp(context, 18))),
              SizedBox(height: R.h(context, 8)),
              Text(
                'Explore our artisanal collection and save your favorites to review them later.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySM(context).copyWith(
                  color: AppColors.neutralGold,
                  height: 1.4,
                  fontSize: R.sp(context, 11),
                ),
              ),
              SizedBox(height: R.h(context, 24)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/shop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.deepCharcoal,
                    padding: EdgeInsets.symmetric(vertical: R.h(context, 12)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 10))),
                    elevation: 0,
                  ),
                  child: Text(
                    'Explore the Shop',
                    style: AppTypography.bodySM(context).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: R.sp(context, 11)),
                  ),
                ),
              ),
              SizedBox(height: R.h(context, 10)),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/categories'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: EdgeInsets.symmetric(vertical: R.h(context, 11)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 10))),
                  ),
                  child: Text(
                    'Browse Collections',
                    style: AppTypography.bodySM(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.deepCharcoal),
                      fontSize: R.sp(context, 11),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
