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
        return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor);
      },
      data: (user) {
        if (user == null) {
          // Fallback — listener above handles the navigation,
          // this just prevents a render error in the frame before redirect fires.
          return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor);
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
            title: Text('My Account', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final themeMode = ref.watch(themeProvider);
                  final isDark = themeMode == ThemeMode.dark || 
                                (themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);
                  return IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.neutralGold,
                    ),
                    onPressed: () {
                      ref.read(themeProvider.notifier).setTheme(
                        isDark ? ThemeMode.light : ThemeMode.dark
                      );
                    },
                  );
                },
              ),
              SizedBox(width: R.w(context, 8)),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: Theme.of(context).colorScheme.outline),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Profile Card ────────────────────────────────────────
                _ProfileCard(user: user, memberSince: memberSince),

                // ── Stats Row ───────────────────────────────────────────
                _StatsRow(user: user),

                SizedBox(height: R.h(context, 16)),

                // ── My Orders ───────────────────────────────────────────
                const _SectionHeader(title: 'Shopping'),
                _NavTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Orders',
                  subtitle: 'Track, cancel & return',
                  onTap: () => context.push('/orders'),
                ),
                _NavTile(
                  icon: Icons.favorite_border_rounded,
                  label: 'Wishlist',
                  subtitle: 'Saved items',
                  onTap: () => context.push('/wishlist'),
                ),
                _NavTile(
                  icon: Icons.local_offer_outlined,
                  label: 'Promo Codes',
                  subtitle: 'Your available coupons',
                  onTap: () => context.push('/cart/promos'),
                ),
                _NavTile(
                  icon: Icons.collections_bookmark_outlined,
                  label: 'Collections',
                  subtitle: 'Browse curated artisan collections',
                  onTap: () => context.go('/categories'),
                  showDivider: false,
                ),

                SizedBox(height: R.h(context, 16)),

                // ── Account Settings ────────────────────────────────────
                const _SectionHeader(title: 'Account'),
                _NavTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  subtitle: 'Name, phone, birthday',
                  onTap: () => context.push('/account/edit'),
                ),
                _NavTile(
                  icon: Icons.location_on_outlined,
                  label: 'Address Book',
                  subtitle: 'Saved delivery addresses',
                  onTap: () => context.push('/account/addresses'),
                ),
                _NavTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Security',
                  subtitle: 'Password & verification',
                  onTap: () => context.push('/account/security'),
                  showDivider: false,
                ),

                SizedBox(height: R.h(context, 16)),
                
                // ── App Preferences ─────────────────────────────────────
                const _SectionHeader(title: 'App Preferences'),
                const _ThemeSelectionTile(),

                SizedBox(height: R.h(context, 16)),

                // ── Support ─────────────────────────────────────────────
                const _SectionHeader(title: 'Support'),
                _NavTile(
                  icon: Icons.shield_outlined,
                  label: 'Priority Support',
                  subtitle: 'Submit an order ticket',
                  onTap: () => context.push('/support'),
                ),
                _NavTile(
                  icon: Icons.undo_rounded,
                  label: 'Returns & Refunds',
                  subtitle: 'Raise a return request',
                  onTap: () => context.push('/account/returns'),
                ),
                _NavTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Contact Us',
                  subtitle: 'Get help from our team',
                  onTap: () => context.push('/contact'),
                ),
                _NavTile(
                  icon: Icons.location_on_outlined,
                  label: 'Find Us',
                  subtitle: 'Our presence & contact info',
                  onTap: () => context.push('/find-us'),
                ),
                _NavTile(
                  icon: Icons.book_outlined,
                  label: 'Journal',
                  subtitle: 'Heritage stories & recipes',
                  onTap: () => context.push('/journal'),
                ),
                _NavTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () => context.push('/privacy'),
                ),
                _NavTile(
                  icon: Icons.gavel_outlined,
                  label: 'Terms of Service',
                  subtitle: 'Our legal agreement',
                  onTap: () => context.push('/terms'),
                  showDivider: false,
                ),

                SizedBox(height: R.h(context, 16)),

                // ── Admin shortcut ──────────────────────────────────────
                if (user.isAdmin) ...[
                  const _SectionHeader(title: 'Admin'),
                  _NavTile(
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
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(R.w(context, 12)),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 2)),
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
                          style: AppTypography.labelGold(context)
                              .copyWith(fontSize: R.sp(context, 9), letterSpacing: 1),
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 16))),
        title: Text('Sign Out', style: AppTypography.h3(context)),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold),
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

// ─────────────────────────────────────────────────────────────────────────────
// Profile Card
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final dynamic user;
  final String memberSince;
  const _ProfileCard({required this.user, required this.memberSince});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 16), R.w(context, 16), 0),
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 20), vertical: R.h(context, 20)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 16)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal).withValues(alpha: 0.04),
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
                            color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          user.initials as String,
                          style: AppTypography.h2(context).copyWith(
                            color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
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
                      border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white, width: 2),
                    ),
                    child: Icon(Icons.edit_rounded,
                        size: R.sp(context, 10), color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
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
                  style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16)),
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
                      color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
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

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions Row
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends ConsumerWidget {
  final dynamic user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Live order count
    final ordersAsync = ref.watch(userOrdersProvider(user.uid as String));
    final exactOrderCount = ordersAsync.maybeWhen(
      data: (orders) => orders.length,
      orElse: () => user.totalOrders ?? 0,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 12), R.w(context, 16), 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/orders'),
              child: _StatChip(
                icon: Icons.receipt_long_outlined,
                label: 'Total Orders',
                value: '$exactOrderCount',
              ),
            ),
          ),
          SizedBox(width: R.w(context, 10)),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/orders'),
              child: const _StatChip(
                icon: Icons.local_shipping_outlined,
                label: 'Status',
                value: 'Track',
              ),
            ),
          ),
          SizedBox(width: R.w(context, 10)),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/account/addresses'),
              child: const _StatChip(
                icon: Icons.location_on_outlined,
                label: 'Addresses',
                value: 'Manage',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 12), vertical: R.h(context, 12)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(icon, size: R.sp(context, 16), color: AppColors.primary),
          SizedBox(height: R.h(context, 4)),
          Text(
            value,
            style: AppTypography.bodySM(context).copyWith(
              fontWeight: FontWeight.w800,
              fontSize: R.sp(context, 12),
              color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: R.h(context, 2)),
          Text(
            label,
            style: AppTypography.labelGold(context).copyWith(fontSize: R.sp(context, 8)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(R.w(context, 20), 0, R.w(context, 20), R.h(context, 8)),
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

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Tile
// ─────────────────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;
  final Color? iconColor;

  const _NavTile({
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
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: showDivider
              ? BorderRadius.zero
              : BorderRadius.vertical(bottom: Radius.circular(R.w(context, 12))),
        ),
        child: Column(
          children: [
            // Top rounded corners only on the first item in a group
            InkWell(
              onTap: onTap,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 12)),
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
                          size: R.sp(context, 16), color: iconColor ?? AppColors.primary),
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
                        color: Theme.of(context).colorScheme.outline, size: R.sp(context, 18)),
                  ],
                ),
              ),
            ),
            if (showDivider)
              Padding(
                padding: EdgeInsets.only(left: R.w(context, 62)),
                child: Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme Selection Tile
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeSelectionTile extends ConsumerWidget {
  const _ThemeSelectionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    String modeName = 'System';
    IconData modeIcon = Icons.brightness_auto_rounded;
    if (themeMode == ThemeMode.light) {
      modeName = 'Light';
      modeIcon = Icons.light_mode_rounded;
    } else if (themeMode == ThemeMode.dark) {
      modeName = 'Dark';
      modeIcon = Icons.dark_mode_rounded;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 16)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 12)),
        ),
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(R.w(context, 20)))),
              builder: (ctx) => const _ThemeSelectionSheet(),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 12)),
            child: Row(
              children: [
                Container(
                  width: R.w(context, 34),
                  height: R.w(context, 34),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(R.w(context, 8)),
                  ),
                  child: Icon(Icons.color_lens_outlined, size: R.sp(context, 16), color: AppColors.primary),
                ),
                SizedBox(width: R.w(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(context, 13),
                        ),
                      ),
                      SizedBox(height: R.h(context, 1)),
                      Text(
                        'Customize your visual experience',
                        style: AppTypography.labelGold(context).copyWith(
                          fontSize: R.sp(context, 10),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: R.w(context, 8), vertical: R.h(context, 4)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(R.w(context, 6)),
                  ),
                  child: Row(
                    children: [
                      Icon(modeIcon, size: R.sp(context, 12), color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
                      SizedBox(width: R.w(context, 4)),
                      Text(
                        modeName,
                        style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(context, 10),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: R.w(context, 8)),
                Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.outline, size: R.sp(context, 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeSelectionSheet extends ConsumerWidget {
  const _ThemeSelectionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(R.w(context, 20), R.h(context, 20), R.w(context, 20), R.h(context, 16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 18))),
            SizedBox(height: R.h(context, 4)),
            Text('Choose how NutriPump looks to you.', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
            SizedBox(height: R.h(context, 24)),
            _ThemeOption(
              icon: Icons.brightness_auto_rounded,
              label: 'System Default',
              isSelected: themeMode == ThemeMode.system,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              label: 'Light Mode',
              isSelected: themeMode == ThemeMode.light,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              label: 'Dark Mode',
              isSelected: themeMode == ThemeMode.dark,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal), size: R.sp(context, 20)),
            SizedBox(width: R.w(context, 16)),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySM(context).copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
                  fontSize: R.sp(context, 14),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: R.sp(context, 20)),
          ],
        ),
      ),
    );
  }
}
