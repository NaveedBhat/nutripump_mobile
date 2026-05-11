import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../../features/ai_chat/ai_chat_widget.dart';
import '../../features/notifications/inapp_popup.dart';
import '../../providers/inapp_popup_provider.dart';
import '../../providers/providers.dart';

/// 🔧 FEATURE FLAG — Hide bottom navigation bar when user scrolls down.
/// Set to [true]  → immersive mode ON  (bar hides on scroll down)
/// Set to [false] → immersive mode OFF (bar always visible)
const bool kHideBottomBarOnScroll = false;

class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _showBottomBar = true;
  int _prevTabIndex = 0; // tracks tab changes to avoid rebuild-loop

  static const _tabs = [
    _TabItem(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        path: '/'),
    _TabItem(
        label: 'Shop',
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag,
        path: '/shop'),
    _TabItem(
        label: 'Categories',
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view,
        path: '/categories'),
    _TabItem(
        label: 'Wishlist',
        icon: Icons.favorite_border,
        activeIcon: Icons.favorite,
        path: '/wishlist'),
    _TabItem(
        label: 'Account',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        path: '/account'),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = widget.navigationShell.currentIndex;
    final popupAsync = ref.watch(inAppPopupProvider);

    // Reset bottom bar visibility when the tab CHANGES (not on every build).
    // Gating on idx != _prevTabIndex prevents the addPostFrameCallback from
    // scheduling a setState → rebuild → callback → setState infinite loop.
    if (kHideBottomBarOnScroll && idx != _prevTabIndex) {
      _prevTabIndex = idx;
      if (!_showBottomBar) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _showBottomBar = true);
        });
      }
    }

    return PopScope(
      canPop: idx == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && idx != 0) {
          widget.navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        body: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (!kHideBottomBarOnScroll) return false;
            if (notification.direction == ScrollDirection.reverse) {
              if (_showBottomBar) setState(() => _showBottomBar = false);
            } else if (notification.direction == ScrollDirection.forward) {
              if (!_showBottomBar) setState(() => _showBottomBar = true);
            }
            return false;
          },
          child: Stack(
            children: [
              widget.navigationShell,
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
        ),
        bottomNavigationBar: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: kHideBottomBarOnScroll && !_showBottomBar
              ? const SizedBox.shrink()
              : Container(
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
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.onSurface
                                : AppColors.deepCharcoal)
                            .withValues(alpha: 0.06),
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
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user == null) {
                                    context.push('/auth/login');
                                    return;
                                  }
                                }
                                if (active) {
                                  ref
                                      .read(scrollTabEventProvider.notifier)
                                      .state = i;
                                }

                                widget.navigationShell.goBranch(
                                  i,
                                  initialLocation:
                                      i == widget.navigationShell.currentIndex,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: Icon(
                                        active ? tab.activeIcon : tab.icon,
                                        key: ValueKey(active),
                                        size: 22,
                                        color: active
                                            ? AppColors.primary
                                            : AppColors.neutralGold
                                                .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      tab.label,
                                      style:
                                          AppTypography.label(context).copyWith(
                                        fontSize: 9,
                                        color: active
                                            ? const Color(0xFFEEBD2B)
                                            : const Color(0xFF9A864C)
                                                .withValues(alpha: 0.6),
                                        fontWeight: active
                                            ? FontWeight.w800
                                            : FontWeight.w500,
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
                ), // Closes Container
        ), // Closes AnimatedSize
      ), // Closes Scaffold
    ); // Closes PopScope
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
