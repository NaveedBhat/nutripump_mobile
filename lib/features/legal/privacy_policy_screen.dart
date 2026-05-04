import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/legal_provider.dart';
import '../../providers/providers.dart';
import 'legal_widgets.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(privacyPageProvider);
    final storeSettings = ref.watch(storeSettingsProvider).value;
    final contactEmail = storeSettings?.storeEmail ?? 'contact@nutripump.in';

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.deepCharcoal,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Privacy Policy',
              style: AppTypography.h3(context).copyWith(color: Colors.white, fontSize: R.sp(context, 16)),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                  height: 1, color: (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.1)),
            ),
          ),

          pageState.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(R.w(context, 24)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: R.sp(context, 48)),
                      SizedBox(height: R.h(context, 16)),
                      Text(
                        'Failed to load privacy policy.',
                        style: AppTypography.bodySM(context),
                      ),
                      SizedBox(height: R.h(context, 16)),
                      ElevatedButton(
                        onPressed: () => ref.refresh(privacyPageProvider),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            data: (page) {
              if (page == null) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Privacy Policy not available')),
                );
              }

              final lastUpdated = page.lastUpdated != null
                  ? DateFormat.yMMMMd().format(page.lastUpdated!)
                  : 'May 1, 2025';

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero Banner ──────────────────────────────────────
                    Container(
                      width: double.infinity,
                      color: AppColors.deepCharcoal,
                      padding: EdgeInsets.fromLTRB(R.w(context, 24), R.h(context, 24), R.w(context, 24), R.h(context, 32)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: R.w(context, 10), vertical: R.h(context, 5)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(R.w(context, 20)),
                              border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_outlined,
                                    color: AppColors.primary, size: R.sp(context, 11)),
                                SizedBox(width: R.w(context, 5)),
                                Text(
                                  'YOUR PRIVACY MATTERS',
                                  style: AppTypography.label(context).copyWith(
                                    color: AppColors.primary,
                                    fontSize: R.sp(context, 9),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: R.h(context, 12)),
                          Text(
                            page.intro,
                            style: AppTypography.bodySM(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: R.sp(context, 13),
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: R.h(context, 10)),
                          Text(
                            'Last updated: $lastUpdated',
                            style: AppTypography.label(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: R.sp(context, 10),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Intro Card ────────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 16), R.w(context, 16), 0),
                      child: Container(
                        padding: EdgeInsets.all(R.w(context, 18)),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(R.w(context, 16)),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15)),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'This Privacy Policy applies to all products and services offered by NutriPump Artisanal ("NutriPump", "we", "our", or "us"), including our website at nutripump.com and our mobile applications. By using our services, you agree to the collection and use of information in accordance with this policy.',
                          style: AppTypography.bodySM(context).copyWith(
                            fontSize: R.sp(context, 13),
                            height: 1.7,
                            color:
                                (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal).withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: R.h(context, 24)),

                    // ── Sections ─────────────────────────────────────────
                    ...page.sections.asMap().entries.map((entry) =>
                        LegalSectionWidget(
                            section: entry.value, index: entry.key + 1)),

                    // ── Contact Block ─────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(R.w(context, 16), 0, R.w(context, 16), R.h(context, 32)),
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
                                  child: Icon(Icons.shield_outlined,
                                      color: AppColors.primary, size: R.sp(context, 20)),
                                ),
                                SizedBox(width: R.w(context, 14)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Privacy Questions?',
                                        style: AppTypography.bodySM(context).copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: R.sp(context, 15),
                                        ),
                                      ),
                                      SizedBox(height: R.h(context, 3)),
                                      Text(
                                        'Our privacy team is here to help',
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
                            Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.08)),
                            SizedBox(height: R.h(context, 16)),

                            // Description
                            Text(
                              'If you have any questions, requests, or complaints about this Privacy Policy or our data practices, please reach out.',
                              style: AppTypography.bodySM(context).copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: R.sp(context, 12.5),
                                height: 1.6,
                              ),
                            ),

                            SizedBox(height: R.h(context, 20)),

                            // Email CTA
                            GestureDetector(
                              onTap: () => launchUrl(
                                  Uri.parse('mailto:$contactEmail')),
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
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
