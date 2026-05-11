import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/legal_provider.dart';
import '../../providers/providers.dart' show storeSettingsProvider;
import 'widgets/legal_hero_banner.dart';
import 'widgets/legal_intro_card.dart';
import 'widgets/legal_contact_block.dart';
import 'widgets/legal_section_widget.dart';
import 'widgets/entire_agreement_banner.dart';

class TermsOfServiceScreen extends ConsumerWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(termsPageProvider);
    final storeSettings = ref.watch(storeSettingsProvider).value;
    final contactEmail = storeSettings?.storeEmail ?? 'contact@nutripump.in';

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColors.backgroundLight),
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
              style: AppTypography.h3(context)
                  .copyWith(color: Colors.white, fontSize: R.sp(context, 16)),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                  height: 1,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : Colors.white)
                      .withValues(alpha: 0.1)),
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
                      Icon(Icons.error_outline,
                          color: Colors.red, size: R.sp(context, 48)),
                      SizedBox(height: R.h(context, 16)),
                      Text(
                        'Failed to load terms of service.',
                        style: AppTypography.bodySM(context),
                      ),
                      SizedBox(height: R.h(context, 16)),
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
                    LegalHeroBanner(
                      badgeText: 'LEGAL AGREEMENT',
                      badgeIcon: Icons.balance_outlined,
                      intro: page.intro,
                      lastUpdated: lastUpdated,
                    ),

                    // ── Intro Card ────────────────────────────────────────
                    const LegalIntroCard(
                      text:
                          'These Terms of Service ("Terms") constitute a legally binding agreement between you and NutriPump Artisanal ("NutriPump", "we", "our", or "us"), governing your access to and use of our website at nutripump.com, our mobile applications, and the purchase of our products. If you have any questions about these Terms, please contact us at contact@nutripump.in before using our services.',
                    ),

                    SizedBox(height: R.h(context, 24)),

                    // ── Sections ─────────────────────────────────────────
                    ...page.sections.asMap().entries.map((entry) =>
                        LegalSectionWidget(
                            section: entry.value, index: entry.key + 1)),

                    // ── Entire Agreement Banner ───────────────────────────
                    const EntireAgreementBanner(),

                    // ── Contact Block ─────────────────────────────────────
                    LegalContactBlock(
                      title: 'Legal Questions?',
                      subtitle: 'Our legal team is here to help',
                      description:
                          'If you have questions about these Terms, want to report a violation, or need legal documentation, please reach out.',
                      contactEmail: contactEmail,
                      icon: Icons.balance_outlined,
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
