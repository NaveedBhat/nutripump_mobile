import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/responsive.dart';

class ProfileCard extends StatelessWidget {
  final dynamic user;
  final String memberSince;
  const ProfileCard({super.key, required this.user, required this.memberSince});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          R.w(context, 16), R.h(context, 16), R.w(context, 16), 0),
      padding: EdgeInsets.symmetric(
          horizontal: R.w(context, 20), vertical: R.h(context, 20)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 16)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.deepCharcoal)
                .withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              user.photoURL != null
                  ? CircleAvatar(
                      radius: R.w(context, 30),
                      backgroundImage: NetworkImage(user.photoURL as String),
                    )
                  : Container(
                      width: R.w(context, 60),
                      height: R.w(context, 60),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 2),
                      ),
                      child: Center(
                        child: Text(
                          user.initials as String,
                          style: AppTypography.h2(context).copyWith(
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                    ? Theme.of(context).colorScheme.onSurface
                                    : AppColors.deepCharcoal),
                            fontSize: R.sp(context, 22),
                          ),
                        ),
                      ),
                    ),
              // Edit badge
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.push('/account/edit'),
                  child: Container(
                    width: R.w(context, 22),
                    height: R.w(context, 22),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.surfaceDark
                              : Colors.white,
                          width: 2),
                    ),
                    child: Icon(Icons.edit_rounded,
                        size: R.sp(context, 10),
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurface
                            : AppColors.deepCharcoal)),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: R.w(context, 16)),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (user.displayName as String?) ?? 'Artisanal Member',
                  style: AppTypography.h3(context)
                      .copyWith(fontSize: R.sp(context, 16)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((user.email as String).isNotEmpty) ...[
                  SizedBox(height: R.h(context, 2)),
                  Text(
                    user.email as String,
                    style: AppTypography.bodySM(context).copyWith(
                      color: AppColors.neutralGold,
                      fontSize: R.sp(context, 11),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: R.h(context, 6)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 10), vertical: R.h(context, 4)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(R.w(context, 20)),
                  ),
                  child: Text(
                    '${(user.isAdmin as bool) ? 'Admin' : 'Heritage Member'} · $memberSince',
                    style: AppTypography.label(context).copyWith(
                      fontSize: R.sp(context, 8),
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.deepCharcoal),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
