import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase/auth_service.dart';
import '../services/firebase/product_service.dart';
import '../services/firebase/order_service.dart';
import '../services/firebase/misc_services.dart';
import '../services/api/checkout_api.dart';
import '../models/user_profile.dart';
import '../models/models.dart';
import '../models/product.dart';

export 'notifications_provider.dart';
export 'theme_provider.dart';

// ── Service Providers ────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final productServiceProvider = Provider<ProductService>((ref) => ProductService());
final orderServiceProvider = Provider<OrderService>((ref) => OrderService());
final categoryServiceProvider = Provider<CategoryService>((ref) => CategoryService());
final settingsServiceProvider = Provider<SettingsService>((ref) => SettingsService());
final reviewServiceProvider = Provider<ReviewService>((ref) => ReviewService());
final addressServiceProvider = Provider<AddressService>((ref) => AddressService());
final wishlistServiceProvider = Provider<WishlistService>((ref) => WishlistService());
final promoCodeServiceProvider = Provider<PromoCodeService>((ref) => PromoCodeService());
final checkoutApiProvider = Provider<CheckoutApi>((ref) => CheckoutApi());

// ── Auth ─────────────────────────────────────────────────────
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authStateProvider = StreamProvider<UserProfile?>((ref) {
  // Watch the raw Firebase auth state as an AsyncValue.
  // When this changes (login, logout, app start), Riverpod rebuilds this
  // provider and cancels the previous stream subscription automatically.
  final authAsync = ref.watch(authStateChangesProvider);

  return authAsync.when(
    // Firebase is still initialising — stay in loading state (no emission).
    loading: () => const Stream.empty(),
    // An error from Firebase auth — treat as signed-out.
    error: (_, __) => Stream.value(null),
    data: (user) {
      if (user == null) {
        // Signed out — emit null immediately.
        return Stream.value(null);
      }
      // Signed in — stream live Firestore profile updates.
      return ref.read(authServiceProvider).getProfileStream(user);
    },
  );
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).value?.isAdmin ?? false;
});

// ── Store Settings (live from Firestore) ──────────────────────
final storeSettingsProvider = StreamProvider<StoreSettings>(
  (ref) => ref.watch(settingsServiceProvider).settingsStream(),
);

final paymentSettingsProvider = StreamProvider<PaymentSettings>(
  (ref) => ref.watch(settingsServiceProvider).paymentSettingsStream(),
);

final announcementProvider = StreamProvider<AnnouncementSettings>(
  (ref) => ref.watch(settingsServiceProvider).announcementStream(),
);

// ── Categories (live from Firestore) ──────────────────────────
final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryServiceProvider).categoriesStream(),
);

// ── Featured Products ─────────────────────────────────────────
final featuredProductsProvider = FutureProvider<List<Product>>(
  (ref) => ref.watch(productServiceProvider).getFeaturedProducts(),
);

// ── Product by slug ───────────────────────────────────────────
final productBySlugProvider = FutureProvider.family<Product?, String>(
  (ref, slug) => ref.watch(productServiceProvider).getProductBySlug(slug),
);

// ── Shop Filters State ────────────────────────────────────────
class ShopFilters {
  final String? category;
  final String searchQuery;
  final double priceMax;
  final List<String> origins;
  final String sortBy;

  const ShopFilters({
    this.category,
    this.searchQuery = '',
    this.priceMax = 10000,
    this.origins = const [],
    this.sortBy = 'featured',
  });

  ShopFilters copyWith({
    String? category,
    bool clearCategory = false,
    String? searchQuery,
    double? priceMax,
    List<String>? origins,
    String? sortBy,
  }) {
    return ShopFilters(
      category: clearCategory ? null : (category ?? this.category),
      searchQuery: searchQuery ?? this.searchQuery,
      priceMax: priceMax ?? this.priceMax,
      origins: origins ?? this.origins,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class ShopFiltersNotifier extends StateNotifier<ShopFilters> {
  ShopFiltersNotifier() : super(const ShopFilters());

  void setCategory(String? category) => state = state.copyWith(category: category, clearCategory: category == null);
  void setSearchQuery(String query) => state = state.copyWith(searchQuery: query);
  void setPriceMax(double max) => state = state.copyWith(priceMax: max);
  void toggleOrigin(String origin) {
    final origins = List<String>.from(state.origins);
    if (origins.contains(origin)) {
      origins.remove(origin);
    } else {
      origins.add(origin);
    }
    state = state.copyWith(origins: origins);
  }
  void setSortBy(String sort) => state = state.copyWith(sortBy: sort);
  void reset() => state = const ShopFilters();
}

final shopFiltersProvider = StateNotifierProvider<ShopFiltersNotifier, ShopFilters>((ref) => ShopFiltersNotifier());

// ── All Products (cached) ──────────────────────────────────────
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final res = await ref.watch(productServiceProvider).getProducts(pageSize: 1000);
  return res.products;
});

// ── Filtered Products ─────────────────────────────────────────
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(allProductsProvider);
  final filters = ref.watch(shopFiltersProvider);

  return productsAsync.whenData((products) {
    var filtered = products;

    // Search
    if (filters.searchQuery.trim().isNotEmpty) {
      final q = filters.searchQuery.trim().toLowerCase();
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(q) || 
        p.origin.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q)
      ).toList();
    }

    // Category
    if (filters.category != null && filters.category != 'all') {
      filtered = filtered.where((p) => p.category == filters.category).toList();
    }

    // Origins
    if (filters.origins.isNotEmpty) {
      filtered = filtered.where((p) => filters.origins.contains(p.origin)).toList();
    }

    // Price Max
    filtered = filtered.where((p) => p.price <= filters.priceMax).toList();

    // Sort
    filtered = List<Product>.from(filtered);
    filtered.sort((a, b) {
      switch (filters.sortBy) {
        case 'price-asc': return a.price.compareTo(b.price);
        case 'price-desc': return b.price.compareTo(a.price);
        case 'rating': return b.rating.compareTo(a.rating);
        case 'newest': return b.createdAt.compareTo(a.createdAt);
        case 'featured':
        default:
          final aNew = a.badge?.toUpperCase() == 'NEW ARRIVAL' ? 1 : 0;
          final bNew = b.badge?.toUpperCase() == 'NEW ARRIVAL' ? 1 : 0;
          if (aNew != bNew) return bNew - aNew;
          return (b.featured ? 1 : 0).compareTo(a.featured ? 1 : 0);
      }
    });

    return filtered;
  });
});

// ── User orders ───────────────────────────────────────────────
final userOrdersProvider = StreamProvider.family<List<dynamic>, String>(
  (ref, userId) => ref.watch(orderServiceProvider).userOrdersStream(userId),
);

// ── Single order ──────────────────────────────────────────────
final orderByIdProvider = StreamProvider.family<dynamic, String>(
  (ref, id) => ref.watch(orderServiceProvider).orderStream(id),
);

// ── User addresses ────────────────────────────────────────────
final userAddressesProvider = StreamProvider.family<List<dynamic>, String>(
  (ref, userId) => ref.watch(addressServiceProvider).addressesStream(userId),
);

// ── Product Reviews ────────────────────────────────────────
final productReviewsProvider = FutureProvider.family<List<Review>, String>((ref, productId) => ref.watch(reviewServiceProvider).getProductReviews(productId));
