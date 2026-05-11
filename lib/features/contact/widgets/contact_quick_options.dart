import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class ContactQuickOptions extends StatelessWidget {
  final Function(String) onLaunchUrl;
  const ContactQuickOptions({super.key, required this.onLaunchUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reach Us Directly',
            style: AppTypography.h3(context)
                .copyWith(fontSize: R.sp(context, 16))),
        SizedBox(height: R.h(context, 16)),

        _ContactTile(
          icon: Icons.email_outlined,
          title: 'Email Support',
          subtitle: 'support@nutripump.store',
          onTap: () => onLaunchUrl('mailto:support@nutripump.store'),
          trailingIcon: Icons.open_in_new_rounded,
        ),
        SizedBox(height: R.h(context, 12)),
        _ContactTile(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'WhatsApp',
          subtitle: 'Chat with us instantly',
          onTap: () => onLaunchUrl('https://wa.me/919149621219'),
          trailingIcon: Icons.open_in_new_rounded,
        ),
        SizedBox(height: R.h(context, 12)),
        _ContactTile(
          icon: Icons.language_rounded,
          title: 'Help Centre',
          subtitle: 'FAQs & Guides',
          onTap: () => onLaunchUrl('https://nutripump.store/support'),
          trailingIcon: Icons.open_in_new_rounded,
        ),
        SizedBox(height: R.h(context, 12)),
        _ContactTile(
          icon: Icons.alternate_email_rounded,
          title: 'Instagram',
          subtitle: '@nutripump.store',
          onTap: () => onLaunchUrl('https://instagram.com/nutripump.store'),
          trailingIcon: Icons.open_in_new_rounded,
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData trailingIcon;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: R.w(context, 16), vertical: R.h(context, 14)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: (Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.deepCharcoal)
                  .withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: R.w(context, 40),
              height: R.w(context, 40),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(R.w(context, 10)),
              ),
              child:
                  Icon(icon, size: R.sp(context, 20), color: AppColors.primary),
            ),
            SizedBox(width: R.w(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(context, 14))),
                  SizedBox(height: R.h(context, 2)),
                  Text(subtitle,
                      style: AppTypography.bodySM(context).copyWith(
                          color: AppColors.neutralGold,
                          fontSize: R.sp(context, 12))),
                ],
              ),
            ),
            Icon(trailingIcon,
                size: R.sp(context, 16), color: AppColors.neutralGold),
          ],
        ),
      ),
    );
  }
}
