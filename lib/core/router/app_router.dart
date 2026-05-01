import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/cart/promo_codes_screen.dart';
import '../../features/account/account_screen.dart';
import '../../features/account/address_book_screen.dart';
import '../../features/account/edit_profile_screen.dart';
import '../../features/account/security_screen.dart';
import '../../features/account/return_request_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/verify_email_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/contact/contact_screen.dart';
import '../../features/support/support_screen.dart';
import '../../features/find_us/find_us_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/journal/article_screen.dart';
import '../../features/journal/journal_screen.dart';
import '../../features/orders/order_detail_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/our_story/our_story_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/product_detail/product_detail_screen.dart';
import '../../features/shop/shop_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/taste_profiler/taste_profiler_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../features/legal/privacy_policy_screen.dart';
import '../../features/legal/terms_of_service_screen.dart';
import '../../providers/providers.dart';
import 'main_shell.dart';
import '../../../main.dart' show navigatorKey;

final _protectedRoutes = ['/checkout', '/account', '/orders'];

final appRouter = GoRouter(
  // ── Shared navigator key lets NotificationService navigate on tap ──────────
  navigatorKey: navigatorKey,
  initialLocation: '/',
  redirect: (context, state) async {
    final authUser = FirebaseAuth.instance.currentUser;
    final isLoggedIn = authUser != null;
    final loc = state.matchedLocation;

    // Guard protected routes
    if (!isLoggedIn &&
        _protectedRoutes.any((r) => loc.startsWith(r))) {
      return '/auth/login?from=${Uri.encodeComponent(loc)}';
    }

    // Admin trying to open /admin on mobile → open web browser instead
    if (isLoggedIn && loc == '/admin') {
      final container = ProviderScope.containerOf(context);
      final userProfile = container.read(authStateProvider).value;
      if (userProfile != null && userProfile.isAdmin) {
        launchUrl(Uri.parse('https://nutripump.store/admin'),
            mode: LaunchMode.externalApplication);
        return '/';
      }
    }

    return null;
  },
  routes: [
    // ── Main Shell (Bottom Nav) ──────────────────────────────
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/shop',
          builder: (_, state) => ShopScreen(
            category: state.uri.queryParameters['category'],
          ),
        ),
        GoRoute(path: '/categories', builder: (_, __) => const CategoriesScreen()),
        GoRoute(path: '/wishlist', builder: (_, __) => const WishlistScreen()),
        GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
      ],
    ),

    // ── Notifications ──────────────────────────────────────────
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),

    // ── Product ───────────────────────────────────────────────
    GoRoute(
      path: '/product/:slug',
      builder: (_, state) => ProductDetailScreen(
        slug: state.pathParameters['slug']!,
        promoCode: state.uri.queryParameters['promo'],
      ),
    ),

    // ── Search ────────────────────────────────────────────────
    GoRoute(
      path: '/search',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final autoStartVoice = extra?['autoStartVoice'] as bool? ?? false;
        return SearchScreen(autoStartVoice: autoStartVoice);
      },
    ),

    // ── Cart ──────────────────────────────────────────────────
    GoRoute(
      path: '/cart',
      builder: (_, __) => const CartScreen(),
      routes: [
        GoRoute(
          path: 'promos',
          builder: (_, __) => const PromoCodesScreen(),
        ),
      ],
    ),

    // ── Checkout ──────────────────────────────────────────────
    GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),

    // ── Orders ────────────────────────────────────────────────
    GoRoute(
      path: '/orders',
      builder: (_, __) => const OrdersScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) =>
              OrderDetailScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),

    // ── Account subpages ──────────────────────────────────────
    GoRoute(path: '/account/edit', builder: (_, __) => const EditProfileScreen()),
    GoRoute(path: '/account/addresses', builder: (_, __) => const AddressBookScreen()),
    GoRoute(
      path: '/account/returns',
      builder: (_, state) => ReturnRequestScreen(
        preselectedOrderId: state.uri.queryParameters['orderId'],
      ),
    ),
    GoRoute(path: '/account/security', builder: (_, __) => const SecurityScreen()),

    // ── Auth ──────────────────────────────────────────────────
    GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/auth/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/auth/verify-email', builder: (_, __) => const VerifyEmailScreen()),

    // ── Journal ───────────────────────────────────────────────
    GoRoute(
      path: '/journal',
      builder: (_, __) => const JournalScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) =>
              ArticleScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),

    // ── Content ───────────────────────────────────────────────
    GoRoute(path: '/taste-profiler', builder: (_, __) => const TasteProfilerScreen()),
    GoRoute(path: '/our-story', builder: (_, __) => const OurStoryScreen()),
    GoRoute(path: '/contact', builder: (_, __) => const ContactScreen()),
    GoRoute(
      path: '/support',
      builder: (_, state) => SupportScreen(
        initialOrderId: state.uri.queryParameters['orderId'],
      ),
    ),
    GoRoute(path: '/find-us', builder: (_, __) => const FindUsScreen()),
    GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPolicyScreen()),
    GoRoute(path: '/terms', builder: (_, __) => const TermsOfServiceScreen()),
  ],
);
