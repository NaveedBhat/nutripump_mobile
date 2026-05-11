import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_network_image.dart';

class MakersStorySection extends StatelessWidget {
  const MakersStorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.onSurface
          : AppColors.deepCharcoal),
      padding: EdgeInsets.symmetric(
          horizontal: R.w(context, 20), vertical: R.h(context, 40)),
      child: Column(
        children: [
          // Image with gold accent offset
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: R.h(context, -8),
                left: R.w(context, -8),
                right: R.w(context, 8),
                bottom: R.h(context, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(R.w(context, 16)),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(R.w(context, 16)),
                child: const AspectRatio(
                  aspectRatio: 1,
                  child: CustomNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1699980955924-9fa505a46b99?q=80&w=900&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: R.h(context, 32)),

          // Text content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THE MAKER\'S STORY',
                style: AppTypography.labelGold(context)
                    .copyWith(letterSpacing: 3, fontSize: R.sp(context, 9)),
              ),
              SizedBox(height: R.h(context, 12)),
              Text(
                'Preserving Heritage Through the Hands of Masters',
                style: AppTypography.h2(context).copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  fontSize: R.sp(context, 24),
                  height: 1.25,
                ),
              ),
              SizedBox(height: R.h(context, 16)),
              Text(
                'Every piece in our collection tells a story of dedication, passing through the hands of master craftsmen in the valleys of Kashmir who preserve centuries-old traditions. We bridge the gap between ancient techniques and modern living.',
                style: AppTypography.bodySM(context).copyWith(
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : Colors.white)
                      .withValues(alpha: 0.70),
                  height: 1.7,
                  fontSize: R.sp(context, 13),
                ),
              ),
              SizedBox(height: R.h(context, 16)),
              Container(
                padding: EdgeInsets.only(left: R.w(context, 16)),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                child: Text(
                  '"Our mission is to celebrate the soul of the maker in a world of mass production."',
                  style: AppTypography.bodySM(context).copyWith(
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.surfaceDark
                            : Colors.white)
                        .withValues(alpha: 0.70),
                    fontStyle: FontStyle.italic,
                    height: 1.7,
                    fontSize: R.sp(context, 13),
                  ),
                ),
              ),
              SizedBox(height: R.h(context, 24)),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'Read Our Heritage',
                      style: AppTypography.bodySM(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: R.sp(context, 13),
                      ),
                    ),
                    SizedBox(width: R.w(context, 8)),
                    Icon(Icons.arrow_forward_rounded,
                        color: AppColors.primary, size: R.sp(context, 16)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
