import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/legal_provider.dart';
import '../../providers/providers.dart' show storeSettingsProvider;
import 'legal_widgets.dart';

class TermsOfServiceScreen extends ConsumerWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(termsPageProvider);
    final storeSettings = ref.watch(storeSettingsProvider).value;
    final contactEmail = storeSettings?.storeEmail ?? 'contact@nutripump.in';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
              'Terms of Service',
              style: AppTypography.h3(context).copyWith(color: Colors.white),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                  height: 1, color: Colors.white.withValues(alpha: 0.1)),
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load terms of service.',
                        style: AppTypography.bodySM(context),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(termsPageProvider),
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
                  child: Center(child: Text('Terms of Service not available')),
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
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.balance_outlined,
                                    color: AppColors.primary, size: 11),
                                const SizedBox(width: 5),
                                Text(
                                  'LEGAL AGREEMENT',
                                  style: AppTypography.label(context).copyWith(
                                    color: AppColors.primary,
                                    fontSize: 9,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.intro,
                            style: AppTypography.bodySM(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Last updated: $lastUpdated',
                            style: AppTypography.label(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Intro Card ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15)),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.deepCharcoal.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'These Terms of Service ("Terms") constitute a legally binding agreement between you and NutriPump Artisanal ("NutriPump", "we", "our", or "us"), governing your access to and use of our website at nutripump.com, our mobile applications, and the purchase of our products. If you have any questions about these Terms, please contact us at contact@nutripump.in before using our services.',
                          style: AppTypography.bodySM(context).copyWith(
                            fontSize: 13,
                            height: 1.7,
                            color:
                                AppColors.deepCharcoal.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Sections ─────────────────────────────────────────
                    ...page.sections.asMap().entries.map((entry) =>
                        LegalSectionWidget(
                            section: entry.value, index: entry.key + 1)),

                    // ── Entire Agreement Banner ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.balance_outlined,
                                color: Color(0xFFD97706), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Entire Agreement',
                                    style: AppTypography.bodySM(context).copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.deepCharcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'These Terms of Service, together with our Privacy Policy, constitute the entire agreement between you and NutriPump Artisanal regarding your use of our services and supersede all prior agreements between the parties.',
                                    style: AppTypography.bodySM(context).copyWith(
                                      fontSize: 12,
                                      height: 1.6,
                                      color: AppColors.deepCharcoal
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Contact Block ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.deepCharcoal,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.balance_outlined,
                                      color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Legal Questions?',
                                        style: AppTypography.bodySM(context).copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Our legal team is here to help',
                                        style: AppTypography.label(context).copyWith(
                                          color: Colors.white.withValues(alpha: 0.45),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.08)),
                            const SizedBox(height: 16),

                            // Description
                            Text(
                              'If you have questions about these Terms, want to report a violation, or need legal documentation, please reach out.',
                              style: AppTypography.bodySM(context).copyWith(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 12.5,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Email CTA
                            GestureDetector(
                              onTap: () => launchUrl(
                                  Uri.parse('mailto:$contactEmail')),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.mail_outline_rounded,
                                        color: AppColors.deepCharcoal, size: 17),
                                    const SizedBox(width: 8),
                                    Text(
                                      contactEmail,
                                      style: AppTypography.bodySM(context).copyWith(
                                        color: AppColors.deepCharcoal,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Response footnote
                            Center(
                              child: Text(
                                'We respond within 5 business days',
                                style: AppTypography.label(context).copyWith(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 10,
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
