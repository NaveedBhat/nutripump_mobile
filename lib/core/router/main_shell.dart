import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../../providers/inapp_popup_provider.dart';
import '../../features/ai_chat/ai_chat_widget.dart';
import '../../features/notifications/inapp_popup.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(label: 'Home',       icon: Icons.home_outlined,      activeIcon: Icons.home,           path: '/'),
    _TabItem(label: 'Shop',       icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag, path: '/shop'),
    _TabItem(label: 'Categories', icon: Icons.grid_view_outlined,  activeIcon: Icons.grid_view,      path: '/categories'),
    _TabItem(label: 'Wishlist',   icon: Icons.favorite_border,     activeIcon: Icons.favorite,       path: '/wishlist'),
    _TabItem(label: 'Account',    icon: Icons.person_outline,      activeIcon: Icons.person,         path: '/account'),
  ];

  int _currentIndex(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).uri.toString();
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = _currentIndex(context);
    final popupAsync = ref.watch(inAppPopupProvider);

    return Scaffold(
      body: Stack(
        children: [
          child,
          const AiChatWidget(),
          // ── In-App Popup Banner overlay ──────────────────────────────
          if (popupAsync.value != null)
            Positioned.fill(
              child: InAppPopup(
                title: popupAsync.value!.title,
                body: popupAsync.value!.body,
                imageUrl: popupAsync.value!.imageUrl,
                ctaLabel: popupAsync.value!.ctaLabel,
                deepLink: popupAsync.value!.deepLink,
                bgColor: popupAsync.value!.bgColor,
                onDismiss: () {
                  markCampaignSeen(popupAsync.value!.campaignId);
                  // Invalidate provider so it re-checks (it will emit null now)
                  ref.invalidate(inAppPopupProvider);
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepCharcoal.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: _tabs.asMap().entries.map((e) {
                final i = e.key;
                final tab = e.value;
                final active = i == idx;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // If tapping Account while not logged in → go straight to login
                      if (tab.path == '/account') {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          context.push('/auth/login');
                          return;
                        }
                      }
                      if (!active) context.go(tab.path);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              active ? tab.activeIcon : tab.icon,
                              key: ValueKey(active),
                              size: 22,
                              color: active
                                  ? AppColors.primary
                                  : AppColors.neutralGold.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            tab.label,
                            style: AppTypography.label.copyWith(
                              fontSize: 9,
                              color: active
                                  ? const Color(0xFFEEBD2B)
                                  : const Color(0xFF9A864C).withValues(alpha: 0.6),
                              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}
