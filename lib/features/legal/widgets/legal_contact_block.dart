import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class LegalContactBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String contactEmail;
  final IconData icon;

  const LegalContactBlock({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.contactEmail,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          R.w(context, 16), 0, R.w(context, 16), R.h(context, 32)),
      child: Container(
        padding: EdgeInsets.all(R.w(context, 24)),
        decoration: BoxDecoration(
          color: AppColors.deepCharcoal,
          borderRadius: BorderRadius.circular(R.w(context, 20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: R.w(context, 42),
                  height: R.w(context, 42),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(R.w(context, 12)),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: R.sp(context, 20)),
                ),
                SizedBox(width: R.w(context, 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodySM(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(context, 15),
                        ),
                      ),
                      SizedBox(height: R.h(context, 3)),
                      Text(
                        subtitle,
                        style: AppTypography.label(context).copyWith(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: R.sp(context, 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(context, 16)),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            SizedBox(height: R.h(context, 16)),
            // Description
            Text(
              description,
              style: AppTypography.bodySM(context).copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: R.sp(context, 12.5),
                height: 1.6,
              ),
            ),
            SizedBox(height: R.h(context, 20)),
            // Email CTA
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('mailto:$contactEmail')),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 18), vertical: R.h(context, 14)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(R.w(context, 12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline_rounded,
                        color: AppColors.deepCharcoal, size: R.sp(context, 17)),
                    SizedBox(width: R.w(context, 8)),
                    Text(
                      contactEmail,
                      style: AppTypography.bodySM(context).copyWith(
                        color: AppColors.deepCharcoal,
                        fontWeight: FontWeight.w700,
                        fontSize: R.sp(context, 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: R.h(context, 12)),
            // Response footnote
            Center(
              child: Text(
                'We respond within 5 business days',
                style: AppTypography.label(context).copyWith(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: R.sp(context, 10),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
