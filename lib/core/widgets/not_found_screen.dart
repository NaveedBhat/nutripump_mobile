import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../utils/responsive.dart';

class NotFoundScreen extends StatelessWidget {
  final GoRouterState? state;

  const NotFoundScreen({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final attemptedPath = state?.uri.toString() ?? '';
    final showPath = attemptedPath.isNotEmpty &&
        attemptedPath != '/' &&
        !attemptedPath.contains('null');

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: R.sp(context, 20),
            color: isDark ? Colors.white : AppColors.deepCharcoal,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(context, 32)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Gold 404 Emblem ─────────────────────────────────
                Container(
                  width: R.w(context, 80),
                  height: R.w(context, 80),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowGold,
                        blurRadius: 24,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '404',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: R.sp(context, 22),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: R.h(context, 20)),

                // ── Title ───────────────────────────────────────────
                Text(
                  'Page Not Found',
                  style: AppTypography.h2(context).copyWith(
                    color: isDark ? Colors.white : AppColors.deepCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: R.h(context, 10)),

                // ── Subtitle ────────────────────────────────────────
                Text(
                  "We couldn't find what you're looking for.\nThe link may be broken or the page moved.",
                  style: AppTypography.bodySM(context).copyWith(
                    color: isDark ? Colors.white54 : AppColors.neutralGold,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                // ── Path Chip ───────────────────────────────────────
                if (showPath) ...[
                  SizedBox(height: R.h(context, 16)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 12),
                      vertical: R.h(context, 7),
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(R.w(context, 6)),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link_off_rounded,
                          size: R.sp(context, 12),
                          color: isDark
                              ? Colors.white38
                              : AppColors.neutralGold,
                        ),
                        SizedBox(width: R.w(context, 6)),
                        Flexible(
                          child: Text(
                            attemptedPath,
                            style: AppTypography.bodySM(context).copyWith(
                              fontSize: R.sp(context, 11),
                              color: isDark
                                  ? Colors.white38
                                  : AppColors.neutralGold,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: R.h(context, 36)),

                // ── Primary CTA ─────────────────────────────────────
                _CompactButton(
                  label: 'Return to Shop',
                  icon: Icons.storefront_outlined,
                  onTap: () => context.go('/'),
                ),

                SizedBox(height: R.h(context, 14)),

                // ── Secondary text link ─────────────────────────────
                GestureDetector(
                  onTap: () => context.go('/search'),
                  child: Text(
                    'Search for a product instead',
                    style: AppTypography.bodySM(context).copyWith(
                      fontSize: R.sp(context, 12),
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CompactButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.w(context, 22),
          vertical: R.h(context, 11),
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(R.w(context, 10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: R.sp(context, 14),
              color: AppColors.deepCharcoal,
            ),
            SizedBox(width: R.w(context, 6)),
            Text(
              label,
              style: AppTypography.bodySM(context).copyWith(
                fontSize: R.sp(context, 12),
                fontWeight: FontWeight.w700,
                color: AppColors.deepCharcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
