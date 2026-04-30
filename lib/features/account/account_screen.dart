import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) {
        // Auth stream emitted an error (e.g. Firestore permission denied on sign-out).
        // Redirect to home rather than showing a broken error screen.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/');
        });
        return const Scaffold(backgroundColor: AppColors.backgroundLight);
      },
      data: (user) {
        if (user == null) {
          // Fallback — listener above handles the navigation,
          // this just prevents a render error in the frame before redirect fires.
          return const Scaffold(backgroundColor: AppColors.backgroundLight);
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
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ─────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('My Account', style: AppTypography.h3),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.notifications_none_rounded,
            //         color: AppColors.deepCharcoal),
            //     onPressed: () {},
            //   ),
            // ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.borderLight),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Profile Card ────────────────────────────────────────
                _ProfileCard(user: user, memberSince: memberSince),

                // ── Stats Row ───────────────────────────────────────────
                _StatsRow(user: user),

                const SizedBox(height: 20),

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

                const SizedBox(height: 20),

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

                const SizedBox(height: 20),

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
                  showDivider: false,
                ),

                const SizedBox(height: 20),

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
                  const SizedBox(height: 20),
                ],

                // ── Sign Out ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout_rounded,
                            color: AppColors.error, size: 18),
                      ),
                      title: Text(
                        'Sign Out',
                        style: AppTypography.bodySM.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => _confirmSignOut(context, ref),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── App version ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    'NutriPump Artisanal v1.0.0',
                    style: AppTypography.labelGold
                        .copyWith(fontSize: 10, letterSpacing: 1),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: AppTypography.h3),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTypography.bodySM.copyWith(color: AppColors.neutralGold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel',
                style: AppTypography.bodySM
                    .copyWith(color: AppColors.neutralGold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.deepCharcoal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepCharcoal.withValues(alpha: 0.04),
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
                      radius: 34,
                      backgroundImage: NetworkImage(user.photoURL as String),
                    )
                  : Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          user.initials as String,
                          style: AppTypography.h2.copyWith(
                            color: AppColors.deepCharcoal,
                            fontSize: 26,
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
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        size: 11, color: AppColors.deepCharcoal),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (user.displayName as String?) ?? 'Artisanal Member',
                  style: AppTypography.h3.copyWith(fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((user.email as String).isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.email as String,
                    style: AppTypography.bodySM.copyWith(
                      color: AppColors.neutralGold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(user.isAdmin as bool) ? 'Admin' : 'Heritage Member'} · $memberSince',
                    style: AppTypography.label.copyWith(
                      fontSize: 9,
                      color: AppColors.deepCharcoal,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
          const SizedBox(width: 10),
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
          const SizedBox(width: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.bodySM.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: AppColors.deepCharcoal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelGold.copyWith(fontSize: 9),
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelGold.copyWith(
          fontSize: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: showDivider
              ? BorderRadius.zero
              : const BorderRadius.vertical(bottom: Radius.circular(14)),
        ),
        child: Column(
          children: [
            // Top rounded corners only on the first item in a group
            InkWell(
              onTap: onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primary)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon,
                          size: 18, color: iconColor ?? AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: AppTypography.bodySM.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            subtitle,
                            style: AppTypography.labelGold.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.borderLight, size: 20),
                  ],
                ),
              ),
            ),
            if (showDivider)
              Padding(
                padding: const EdgeInsets.only(left: 68),
                child: Divider(
                    height: 1,
                    color: AppColors.borderLight.withValues(alpha: 0.6)),
              ),
          ],
        ),
      ),
    );
  }
}
