// lib/features/about/about_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/animated_enter.dart';
import '../../core/utils/responsive.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? Theme.of(context).scaffoldBackgroundColor
        : const Color(0xFFF9F8F6);
    final textColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : AppColors.deepCharcoal;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── Hero ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: R.h(context, 380),
            pinned: true,
            backgroundColor: AppColors.deepCharcoal,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=1200&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.deepCharcoal),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          AppColors.deepCharcoal.withValues(alpha: 0.90),
                        ],
                      ),
                    ),
                  ),
                  // ── Centered App Logo ────────────────────────
                  // Positioned.fill(
                  //   child: Center(
                  //     child: Container(
                  //       padding: EdgeInsets.all(R.w(context, 6)),
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: Colors.white.withValues(alpha: 0.08),
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: AppColors.primary.withValues(alpha: 0.25),
                  //             blurRadius: 40,
                  //             spreadRadius: 5,
                  //           ),
                  //         ],
                  //       ),
                  //       child: Image.asset(
                  //         'assets/images/nutripumplogo.webp',
                  //         width: R.w(context, 110),
                  //         height: R.w(context, 110),
                  //         fit: BoxFit.contain,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Positioned(
                    bottom: R.h(context, 36),
                    left: R.w(context, 24),
                    right: R.w(context, 24),
                    child: AnimatedEnter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NUTRIPUMP ARTISANAL',
                            style: AppTypography.labelGold(context)
                                .copyWith(letterSpacing: 2.5),
                          ),
                          SizedBox(height: R.h(context, 10)),
                          // "About" white, "NutriPump" in gold
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'About\n',
                                  style: AppTypography.h1(context).copyWith(
                                    color: Colors.white,
                                    fontSize: R.sp(context, 38),
                                    height: 1.15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(
                                  text: 'NutriPump',
                                  style: AppTypography.h1(context).copyWith(
                                    color: AppColors.primary,
                                    fontSize: R.sp(context, 38),
                                    height: 1.15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: R.w(context, 24),
                vertical: R.h(context, 32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Mission ───────────────────────────────────
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 80),
                    child: _buildSectionLabel(context, 'WHO WE ARE'),
                  ),
                  SizedBox(height: R.h(context, 12)),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 120),
                    child: Text(
                      'Bringing Kashmir\'s finest artisanal products to the world.',
                      style: AppTypography.h2(context).copyWith(
                        fontSize: R.sp(context, 21),
                        height: 1.35,
                      ),
                    ),
                  ),
                  SizedBox(height: R.h(context, 14)),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 160),
                    child: Text(
                      'NutriPump Artisanal was founded on a single belief — that the purest, most nourishing foods should be accessible to everyone, not just those who live near the source. We journey to the heart of the Kashmir Valley to bring you wildflower honey, stone-ground nut butters, cold-pressed oils, and handcrafted pantry essentials — exactly as nature intended.',
                      style: AppTypography.bodySM(context).copyWith(
                        fontSize: R.sp(context, 14),
                        height: 1.8,
                        color: textColor.withValues(alpha: 0.72),
                      ),
                    ),
                  ),

                  SizedBox(height: R.h(context, 36)),

                  // ── Our Promise ───────────────────────────────
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 200),
                    child: _buildSectionLabel(context, 'OUR PROMISE'),
                  ),
                  SizedBox(height: R.h(context, 16)),

                  AnimatedEnter(
                    delay: const Duration(milliseconds: 230),
                    child: _buildPromiseRow(
                      context,
                      icon: Icons.verified_outlined,
                      title: '100% Authentic',
                      description:
                          'Every product is sourced directly from multi-generational artisan farmers and lab-verified for purity — no additives, no fillers, no compromise.',
                      textColor: textColor,
                    ),
                  ),
                  SizedBox(height: R.h(context, 16)),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 270),
                    child: _buildPromiseRow(
                      context,
                      icon: Icons.local_shipping_outlined,
                      title: 'Fast & Safe Delivery',
                      description:
                          'Carefully packed and shipped across India. Track every order in real-time, right from dispatch to your doorstep.',
                      textColor: textColor,
                    ),
                  ),
                  SizedBox(height: R.h(context, 16)),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 310),
                    child: _buildPromiseRow(
                      context,
                      icon: Icons.support_agent_outlined,
                      title: 'Dedicated Support',
                      description:
                          'Our team is here to help. From order issues to product questions, raise a ticket and we\'ll respond promptly.',
                      textColor: textColor,
                    ),
                  ),
                  SizedBox(height: R.h(context, 16)),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 350),
                    child: _buildPromiseRow(
                      context,
                      icon: Icons.replay_outlined,
                      title: 'Easy Returns',
                      description:
                          'Not satisfied? Our hassle-free return policy ensures your peace of mind with every purchase.',
                      textColor: textColor,
                    ),
                  ),

                  SizedBox(height: R.h(context, 36)),

                  // ── Platforms ─────────────────────────────────
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 390),
                    child: _buildSectionLabel(context, 'OUR PLATFORMS'),
                  ),
                  SizedBox(height: R.h(context, 16)),

                  AnimatedEnter(
                    delay: const Duration(milliseconds: 420),
                    child: _buildPlatformCard(
                      context,
                      icon: Icons.phone_iphone_rounded,
                      title: 'Mobile App',
                      subtitle: 'iOS & Android',
                      description:
                          'Shop, track your orders, get personalised product recommendations via our AI assistant, and manage your account — all on the go.',
                      isDark: isDark,
                      textColor: textColor,
                    ),
                  ),
                  SizedBox(height: R.h(context, 12)),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 460),
                    child: _buildPlatformCard(
                      context,
                      icon: Icons.language_rounded,
                      title: 'Web Store',
                      subtitle: 'nutripump.store',
                      description:
                          'Browse the full catalogue, read our artisan journal, and place orders from any browser — a seamless experience on any device.',
                      isDark: isDark,
                      textColor: textColor,
                    ),
                  ),

                  SizedBox(height: R.h(context, 36)),

                  // ── Developer Card ────────────────────────────
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 500),
                    child: _buildSectionLabel(context, 'BUILT BY'),
                  ),
                  SizedBox(height: R.h(context, 16)),

                  AnimatedEnter(
                    delay: const Duration(milliseconds: 530),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(R.w(context, 20)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.primary.withValues(alpha: 0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(R.w(context, 20)),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: R.w(context, 56),
                                height: R.w(context, 56),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      Color(0xFF8B6914),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'N',
                                    style: AppTypography.h2(context).copyWith(
                                      color: AppColors.deepCharcoal,
                                      fontWeight: FontWeight.w900,
                                      fontSize: R.sp(context, 24),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: R.w(context, 16)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Naveed Mohammad Bhat',
                                      style: AppTypography.h3(context).copyWith(
                                        fontSize: R.sp(context, 16),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: R.h(context, 4)),
                                    Text(
                                      'Sole Architect & Developer',
                                      style: AppTypography.labelGold(context)
                                          .copyWith(
                                              fontSize: R.sp(context, 11.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: R.h(context, 16)),
                          Text(
                            'The entire NutriPump ecosystem — this mobile app, the web storefront, and the admin management panel — was designed, engineered, and launched by one developer. Every screen, every feature, every detail crafted with care.',
                            style: AppTypography.bodySM(context).copyWith(
                              fontSize: R.sp(context, 13.5),
                              height: 1.75,
                              color: textColor.withValues(alpha: 0.70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: R.h(context, 36)),

                  // ── Quick Links ───────────────────────────────
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 570),
                    child: _buildSectionLabel(context, 'QUICK LINKS'),
                  ),
                  SizedBox(height: R.h(context, 14)),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 600),
                    child: _buildQuickLink(
                        context, Icons.book_outlined, 'Artisan Journal',
                        () => context.push('/journal'), isDark),
                  ),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 620),
                    child: _buildQuickLink(
                        context, Icons.auto_stories_outlined, 'Our Story',
                        () => context.push('/our-story'), isDark),
                  ),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 640),
                    child: _buildQuickLink(
                        context, Icons.privacy_tip_outlined, 'Privacy Policy',
                        () => context.push('/privacy'), isDark),
                  ),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 660),
                    child: _buildQuickLink(
                        context, Icons.gavel_outlined, 'Terms of Service',
                        () => context.push('/terms'), isDark,
                        showDivider: false),
                  ),

                  SizedBox(height: R.h(context, 36)),

                  // ── Connect ───────────────────────────────────
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 690),
                    child: _buildSectionLabel(context, 'CONNECT WITH US'),
                  ),
                  SizedBox(height: R.h(context, 16)),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 710),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildLinkButton(
                            context,
                            icon: Icons.language_rounded,
                            label: 'Website',
                            onTap: () => _launch('https://nutripump.store'),
                          ),
                        ),
                        SizedBox(width: R.w(context, 12)),
                        Expanded(
                          child: _buildLinkButton(
                            context,
                            icon: Icons.alternate_email_rounded,
                            label: 'Instagram',
                            onTap: () =>
                                _launch('https://instagram.com/nutripump'),
                          ),
                        ),
                        SizedBox(width: R.w(context, 12)),
                        Expanded(
                          child: _buildLinkButton(
                            context,
                            icon: Icons.mail_outline_rounded,
                            label: 'Email Us',
                            onTap: () =>
                                _launch('mailto:contact@nutripump.in'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: R.h(context, 40)),

                  // ── Footer ────────────────────────────────────
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 740),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Made with ❤️ for Kashmir\'s finest artisanal products.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySM(context).copyWith(
                              fontSize: R.sp(context, 12),
                              color: textColor.withValues(alpha: 0.38),
                            ),
                          ),
                          if (_version.isNotEmpty) ...[
                            SizedBox(height: R.h(context, 8)),
                            Text(
                              'NutriPump Artisanal v$_version',
                              style: AppTypography.labelGold(context).copyWith(
                                fontSize: R.sp(context, 10),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: R.h(context, 40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: AppTypography.labelGold(context).copyWith(letterSpacing: 2.5),
    );
  }

  Widget _buildPromiseRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(R.w(context, 10)),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
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
                style: AppTypography.h3(context)
                    .copyWith(fontSize: R.sp(context, 15)),
              ),
              SizedBox(height: R.h(context, 4)),
              Text(
                description,
                style: AppTypography.bodySM(context).copyWith(
                  fontSize: R.sp(context, 13),
                  height: 1.6,
                  color: textColor.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required bool isDark,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.all(R.w(context, 16)),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 16)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(R.w(context, 10)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(R.w(context, 10)),
            ),
            child:
                Icon(icon, color: AppColors.primary, size: R.sp(context, 22)),
          ),
          SizedBox(width: R.w(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.h3(context).copyWith(
                      fontSize: R.sp(context, 15),
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    )),
                SizedBox(height: R.h(context, 2)),
                Text(subtitle,
                    style: AppTypography.labelGold(context)
                        .copyWith(fontSize: R.sp(context, 11))),
                SizedBox(height: R.h(context, 8)),
                Text(description,
                    style: AppTypography.bodySM(context).copyWith(
                      fontSize: R.sp(context, 13),
                      height: 1.6,
                      color: textColor.withValues(alpha: 0.62),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLink(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDark, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(
              horizontal: R.w(context, 4), vertical: R.h(context, 2)),
          leading: Container(
            width: R.w(context, 36),
            height: R.w(context, 36),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(R.w(context, 8)),
            ),
            child: Icon(icon, color: AppColors.primary, size: R.sp(context, 18)),
          ),
          title: Text(
            label,
            style: AppTypography.bodySM(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: R.sp(context, 14),
            ),
          ),
          trailing: Icon(Icons.chevron_right_rounded,
              color: AppColors.neutralGold, size: R.sp(context, 20)),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: R.w(context, 56),
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
      ],
    );
  }

  Widget _buildLinkButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: R.h(context, 14)),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          border:
              Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: R.sp(context, 22)),
            SizedBox(height: R.h(context, 5)),
            Text(
              label,
              style: AppTypography.bodySM(context).copyWith(
                fontSize: R.sp(context, 11.5),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
