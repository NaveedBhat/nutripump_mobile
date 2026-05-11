import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/widgets/skeleton_loaders.dart';
import 'widgets/account/profile_card.dart';
import 'widgets/account/stats_row.dart';
import 'widgets/account/account_nav_tile.dart';
import 'widgets/account/theme_selection.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<dynamic>>(authStateProvider, (_, next) {
      // Regardless of whether next is data or error, if the user is actually signed out, go to Home.
      if (FirebaseAuth.instance.currentUser == null && context.mounted) {
        context.go('/');
      }
    });

    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const AccountScreenSkeleton(),
      ),
      error: (_, __) {
        // Auth stream emitted an error (e.g. Firestore permission denied on sign-out).
        // Redirect to home rather than showing a broken error screen.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/');
        });
        return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor);
      },
      data: (user) {
        if (user == null) {
          // Fallback — listener above handles the navigation,
          // this just prevents a render error in the frame before redirect fires.
          return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor);
        }
        return _AccountView(user: user, ref: ref);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Logged-in account dashboard
// ═══════════════════════════════════════════════════════════════════════════
class _AccountView extends StatelessWidget {
  final dynamic user; // UserProfile
  final WidgetRef ref;
  const _AccountView({required this.user, required this.ref});

  @override
  Widget build(BuildContext context) {
    final memberSince = _formatMemberSince(user.createdAt);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ─────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('My Account',
                style: AppTypography.h3(context)
                    .copyWith(fontSize: R.sp(context, 16))),
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final themeMode = ref.watch(themeProvider);
                  final isDark = themeMode == ThemeMode.dark ||
                      (themeMode == ThemeMode.system &&
                          MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark);
                  return IconButton(
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.neutralGold,
                    ),
                    onPressed: () {
                      ref
                          .read(themeProvider.notifier)
                          .setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
                    },
                  );
                },
              ),
              SizedBox(width: R.w(context, 8)),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                  height: 1, color: Theme.of(context).colorScheme.outline),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Profile Card ────────────────────────────────────────
                ProfileCard(user: user, memberSince: memberSince),

                // ── Stats Row ───────────────────────────────────────────
                StatsRow(user: user),

                SizedBox(height: R.h(context, 16)),

                // ── My Orders ───────────────────────────────────────────
                const AccountSectionHeader(title: 'Shopping'),
                AccountNavTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Orders',
                  subtitle: 'Track, cancel & return',
                  onTap: () => context.push('/orders'),
                ),
                AccountNavTile(
                  icon: Icons.favorite_border_rounded,
                  label: 'Wishlist',
                  subtitle: 'Saved items',
                  onTap: () => context.push('/wishlist'),
                ),
                AccountNavTile(
                  icon: Icons.local_offer_outlined,
                  label: 'Promo Codes',
                  subtitle: 'Your available coupons',
                  onTap: () => context.push('/cart/promos'),
                ),
                AccountNavTile(
                  icon: Icons.collections_bookmark_outlined,
                  label: 'Collections',
                  subtitle: 'Browse curated artisan collections',
                  onTap: () => context.go('/categories'),
                  showDivider: false,
                ),

                SizedBox(height: R.h(context, 16)),

                // ── Account Settings ────────────────────────────────────
                const AccountSectionHeader(title: 'Account'),
                AccountNavTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  subtitle: 'Name, phone, birthday',
                  onTap: () => context.push('/account/edit'),
                ),
                AccountNavTile(
                  icon: Icons.location_on_outlined,
                  label: 'Address Book',
                  subtitle: 'Saved delivery addresses',
                  onTap: () => context.push('/account/addresses'),
                ),
                AccountNavTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Security',
                  subtitle: 'Password & verification',
                  onTap: () => context.push('/account/security'),
                  showDivider: false,
                ),

                SizedBox(height: R.h(context, 16)),

                // ── App Preferences ─────────────────────────────────────
                const AccountSectionHeader(title: 'App Preferences'),
                const ThemeSelectionTile(),

                SizedBox(height: R.h(context, 16)),

                // ── Support ─────────────────────────────────────────────
                const AccountSectionHeader(title: 'Support'),
                AccountNavTile(
                  icon: Icons.shield_outlined,
                  label: 'Priority Support',
                  subtitle: 'Submit an order ticket',
                  onTap: () => context.push('/support'),
                ),
                AccountNavTile(
                  icon: Icons.undo_rounded,
                  label: 'Returns & Refunds',
                  subtitle: 'Raise a return request',
                  onTap: () => context.push('/account/returns'),
                ),
                AccountNavTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Contact Us',
                  subtitle: 'Get help from our team',
                  onTap: () => context.push('/contact'),
                ),
                AccountNavTile(
                  icon: Icons.location_on_outlined,
                  label: 'Find Us',
                  subtitle: 'Our stores & contact info',
                  onTap: () => context.push('/find-us'),
                  showDivider: false,
                ),

                SizedBox(height: R.h(context, 16)),

                // ── Discover ─────────────────────────────────────────────
                const AccountSectionHeader(title: 'Discover'),
                AccountNavTile(
                  icon: Icons.book_outlined,
                  label: 'Journal',
                  subtitle: 'Heritage stories & artisan recipes',
                  onTap: () => context.push('/journal'),
                ),
                AccountNavTile(
                  icon: Icons.auto_stories_outlined,
                  label: 'Our Story',
                  subtitle: 'Rooted in the Kashmir Valley',
                  onTap: () => context.push('/our-story'),
                  showDivider: false,
                ),

                SizedBox(height: R.h(context, 16)),

                // ── Legal & Info ──────────────────────────────────────────
                const AccountSectionHeader(title: 'Legal & Info'),
                AccountNavTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () => context.push('/privacy'),
                ),
                AccountNavTile(
                  icon: Icons.gavel_outlined,
                  label: 'Terms of Service',
                  subtitle: 'Our legal agreement',
                  onTap: () => context.push('/terms'),
                ),
                AccountNavTile(
                  icon: Icons.info_outline_rounded,
                  label: 'About NutriPump',
                  subtitle: 'The app, the ecosystem & the developer',
                  onTap: () => context.push('/about'),
                  showDivider: false,
                ),

                SizedBox(height: R.h(context, 16)),

                // ── Admin shortcut ──────────────────────────────────────
                if (user.isAdmin) ...[
                  const AccountSectionHeader(title: 'Admin'),
                  AccountNavTile(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Dashboard',
                    subtitle: 'Opens in browser',
                    iconColor: AppColors.primary,
                    onTap: () {},
                    showDivider: false,
                  ),
                  SizedBox(height: R.h(context, 16)),
                ],

                // ── Sign Out ────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.w(context, 16)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : Colors.white,
                      borderRadius: BorderRadius.circular(R.w(context, 12)),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.15)),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: R.w(context, 16),
                          vertical: R.h(context, 2)),
                      leading: Container(
                        width: R.w(context, 34),
                        height: R.w(context, 34),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(R.w(context, 8)),
                        ),
                        child: Icon(Icons.logout_rounded,
                            color: AppColors.error, size: R.sp(context, 16)),
                      ),
                      title: Text(
                        'Sign Out',
                        style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                          fontSize: R.sp(context, 13),
                        ),
                      ),
                      onTap: () => _confirmSignOut(context, ref),
                    ),
                  ),
                ),

                SizedBox(height: R.h(context, 12)),

                // ── App version ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(bottom: R.h(context, 32)),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final versionAsync = ref.watch(appVersionProvider);
                      return versionAsync.when(
                        data: (version) => Text(
                          'NutriPump Artisanal v$version',
                          style: AppTypography.labelGold(context).copyWith(
                              fontSize: R.sp(context, 9), letterSpacing: 1),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMemberSince(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(R.w(context, 16))),
        title: Text('Sign Out', style: AppTypography.h3(context)),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTypography.bodySM(context)
              .copyWith(color: AppColors.neutralGold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel',
                style: AppTypography.bodySM(context)
                    .copyWith(color: AppColors.neutralGold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.deepCharcoal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.w(context, 10))),
              elevation: 0,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      try {
        await ref.read(authServiceProvider).signOut();
      } catch (_) {}
      if (context.mounted) {
        context.go('/');
      }
    }
  }
}


