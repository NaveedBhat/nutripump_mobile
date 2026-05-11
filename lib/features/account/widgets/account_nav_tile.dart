import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class AccountSectionHeader extends StatelessWidget {
  final String title;
  const AccountSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          R.w(context, 20), 0, R.w(context, 20), R.h(context, 8)),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelGold(context).copyWith(
          fontSize: R.sp(context, 9),
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class AccountNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;
  final Color? iconColor;

  const AccountNavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 16)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: showDivider
              ? BorderRadius.zero
              : BorderRadius.vertical(
                  bottom: Radius.circular(R.w(context, 12))),
        ),
        child: Column(
          children: [
            // Top rounded corners only on the first item in a group
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 16), vertical: R.h(context, 12)),
                child: Row(
                  children: [
                    Container(
                      width: R.w(context, 34),
                      height: R.w(context, 34),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primary)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(R.w(context, 8)),
                      ),
                      child: Icon(icon,
                          size: R.sp(context, 16),
                          color: iconColor ?? AppColors.primary),
                    ),
                    SizedBox(width: R.w(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: AppTypography.bodySM(context).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: R.sp(context, 13),
                            ),
                          ),
                          SizedBox(height: R.h(context, 1)),
                          Text(
                            subtitle,
                            style: AppTypography.labelGold(context).copyWith(
                              fontSize: R.sp(context, 10),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.outline,
                        size: R.sp(context, 18)),
                  ],
                ),
              ),
            ),
            if (showDivider)
              Padding(
                padding: EdgeInsets.only(left: R.w(context, 62)),
                child: Divider(
                    height: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.6)),
              ),
          ],
        ),
      ),
    );
  }
}
