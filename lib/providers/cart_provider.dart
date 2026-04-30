import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/models.dart';
import 'providers.dart';

// ── Cart State ────────────────────────────────────────────────
class CartState {
  final List<CartItem> items;
  final PromoCode? appliedPromo;
  final double gstRate;
  final double freeThreshold;
  final double shippingCost;
  final bool isFirstOrder;

  const CartState({
    this.items = const [],
    this.appliedPromo,
    this.gstRate = 0.05,
    this.freeThreshold = 499,
    this.shippingCost = 99,
    this.isFirstOrder = true, // Defaults to true for guests
  });

  double get subtotal => items.fold(0, (s, i) => s + i.lineTotal);
  double get gst => subtotal * gstRate;
  double get discount => _calcDiscount();
  double get shipping => subtotal >= freeThreshold ? 0 : shippingCost;
  double get total => (subtotal + gst + shipping - discount).clamp(0, double.infinity);
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);

  double _calcDiscount() {
    if (appliedPromo == null) return 0;
    final productIds = items.map((i) => i.product.id).toList();
    if (!appliedPromo!.isValidFor(subtotal, isFirstOrder, productIds)) {
      return 0; // Invalidated because conditions aren't met
    }
    return appliedPromo!.calculateDiscount(subtotal);
  }

  CartState copyWith({
    List<CartItem>? items,
    PromoCode? appliedPromo,
    bool clearPromo = false,
    double? gstRate,
    double? freeThreshold,
    double? shippingCost,
    bool? isFirstOrder,
  }) => CartState(
    items: items ?? this.items,
    appliedPromo: clearPromo ? null : (appliedPromo ?? this.appliedPromo),
    gstRate: gstRate ?? this.gstRate,
    freeThreshold: freeThreshold ?? this.freeThreshold,
    shippingCost: shippingCost ?? this.shippingCost,
    isFirstOrder: isFirstOrder ?? this.isFirstOrder,
  );
}

// ── Cart Notifier ─────────────────────────────────────────────
class CartNotifier extends StateNotifier<CartState> {
  static const _boxKey = 'nutripump_cart';
  final _uuid = const Uuid();

  final Ref _ref;
  String? _userId;
  StreamSubscription? _sub;
  Timer? _debounceTimer;

  CartNotifier(this._ref) : super(const CartState()) {
    _loadFromHive();

    _ref.listen(authStateProvider, (prev, next) {
      final user = next.value;
      
      final isFirst = user == null || user.totalOrders == 0;
      if (state.isFirstOrder != isFirst) {
         state = state.copyWith(isFirstOrder: isFirst);
      }

      if (user?.uid != _userId) {
        final wasLoggedIn = _userId != null;
        _userId = user?.uid;
        
        // If the user signed out, clear their cart so the guest starts fresh
        if (wasLoggedIn && _userId == null) {
          clearCart();
        }
        
        _setupSync();
      }
    }, fireImmediately: true);

    _ref.listen(storeSettingsProvider, (prev, next) {
      if (next.hasValue && next.value != null) {
        final settings = next.value!;
        updateSettings(
          gstRate: settings.gstRate / 100, // Convert percentage to decimal
          freeThreshold: settings.freeShippingThreshold,
          shippingCost: settings.shippingCost,
        );
      }
    }, fireImmediately: true);
  }

  void _setupSync() {
    _sub?.cancel();
    if (_userId == null) return;
    
    bool isFirstSnapshot = true;
    
    _sub = FirebaseFirestore.instance.collection('carts').doc(_userId!).snapshots().listen((snap) {
      final data = snap.data();
      final rawItems = data != null ? (data['items'] as List<dynamic>? ?? []) : [];
      
      final cloudItems = rawItems.map((item) {
        try {
           return CartItem.fromMap(item as Map<String, dynamic>);
        } catch (_) {
           return null;
        }
      }).whereType<CartItem>().toList();

      if (isFirstSnapshot) {
         isFirstSnapshot = false;
         
         // Merge local guest items with cloud items
         final guestItems = List<CartItem>.from(state.items);
         final merged = [...cloudItems];
         
         for (var guest in guestItems) {
            final exists = guest.isGiftBox 
               ? cloudItems.any((ci) => ci.cartItemId == guest.cartItemId)
               : cloudItems.any((ci) => ci.product.id == guest.product.id);
            if (!exists) merged.add(guest);
         }
         
         state = state.copyWith(items: merged);
         _debouncedPush(immediate: true);
      } else {
         state = state.copyWith(items: cloudItems);
      }
    });
  }

  void _debouncedPush({bool immediate = false}) {
    _saveToHive(); // Always keep local fallback updated
    if (_userId == null) return;
    
    _debounceTimer?.cancel();
    
    Future<void> action() async {
      try {
        final user = _ref.read(authStateProvider).value;
        if (user == null) return;
        
        await FirebaseFirestore.instance.collection('carts').doc(_userId!).set({
           'userId': user.uid,
           'userEmail': user.email,
           'userName': user.displayName,
           'items': state.items.map((i) => i.toMap()).toList(),
           'subtotal': state.items.fold(0.0, (s, i) => s + (i.lineTotal)),
           'status': state.items.isEmpty ? 'empty' : 'abandoned',
           'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        // silently fail
      }
    }

    if (immediate) {
      action();
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 1500), action);
    }
  }

  void _loadFromHive() {
    final box = Hive.box(_boxKey);
    final raw = box.get('items');
    if (raw == null) return;
    try {
      final List<dynamic> list = raw as List<dynamic>;
      final items = list.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return CartItem.fromMap(map);
      }).toList();
      state = state.copyWith(items: items);
    } catch (_) {
      // Ignore if cache is corrupted or from an old format
    }
  }

  void _saveToHive() {
    final box = Hive.box(_boxKey);
    box.put('items', state.items.map((e) => e.toMap()).toList());
  }

  void addItem(
    Product product, {
    int qty = 1,
    String? weight,
    double? bundlePrice,
    bool isGiftBox = false,
    String? giftNote,
  }) {
    if (isGiftBox) {
      state = state.copyWith(items: [
        ...state.items,
        CartItem(
          cartItemId: _uuid.v4(),
          product: product,
          quantity: qty,
          selectedWeight: weight,
          bundlePrice: bundlePrice,
          isGiftBox: true,
          giftNote: giftNote,
        ),
      ]);
      _debouncedPush();
      return;
    }

    final idx = state.items.indexWhere(
      (i) => i.product.id == product.id && !i.isGiftBox);
    if (idx >= 0) {
      final updated = List<CartItem>.from(state.items);
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + qty);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [
        ...state.items,
        CartItem(
          cartItemId: _uuid.v4(),
          product: product,
          quantity: qty,
          selectedWeight: weight,
          bundlePrice: bundlePrice,
        ),
      ]);
    }
    _debouncedPush();
  }

  void removeItem(String cartItemId) {
    state = state.copyWith(
      items: state.items.where((i) => i.cartItemId != cartItemId).toList(),
    );
    _debouncedPush();
  }

  void updateQuantity(String cartItemId, int qty) {
    if (qty <= 0) { removeItem(cartItemId); return; }
    final updated = state.items.map(
      (i) => i.cartItemId == cartItemId ? i.copyWith(quantity: qty) : i,
    ).toList();
    state = state.copyWith(items: updated);
    _debouncedPush();
  }

  void applyPromo(PromoCode promo) {
    state = state.copyWith(appliedPromo: promo);
  }

  void removePromo() {
    state = state.copyWith(clearPromo: true);
  }

  void updateSettings({
    required double gstRate,
    required double freeThreshold,
    required double shippingCost,
  }) {
    state = state.copyWith(
      gstRate: gstRate,
      freeThreshold: freeThreshold,
      shippingCost: shippingCost,
    );
  }

  void clearCart() {
    state = state.copyWith(items: [], clearPromo: true);
    _debouncedPush();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(ref),
);

// ── Wishlist ──────────────────────────────────────────────────
class WishlistNotifier extends StateNotifier<List<Product>> {
  static const _boxKey = 'nutripump_wishlist';
  final Ref _ref;
  String? _userId;
  StreamSubscription? _sub;
  Timer? _debounceTimer;

  WishlistNotifier(this._ref) : super([]) {
    _loadFromHive();
    _ref.listen(authStateProvider, (prev, next) {
      final user = next.value;
      if (user?.uid != _userId) {
        final wasLoggedIn = _userId != null;
        _userId = user?.uid;
        
        // Clear wishlist on sign out
        if (wasLoggedIn && _userId == null) {
          clear();
        }
        
        _setupSync();
      }
    }, fireImmediately: true);
  }

  void _setupSync() {
    _sub?.cancel();
    if (_userId == null) return;
    
    final service = _ref.read(wishlistServiceProvider);
    bool isFirstSnapshot = true;
    
    _sub = service.wishlistsStream(_userId!).listen((cloudItems) {
      if (isFirstSnapshot) {
         isFirstSnapshot = false;
         // Merge local guest items with cloud items
         final guestItems = List<Product>.from(state);
         final merged = [...cloudItems];
         for (var guest in guestItems) {
            if (!cloudItems.any((Product c) => c.id == guest.id)) {
               merged.add(guest);
            }
         }
         state = merged;
         _saveToHive();
         // Push merged up to cloud
         service.saveWishlist(_userId!, merged);
      } else {
         // Subsequent sync down
         state = cloudItems;
         _saveToHive();
      }
    });
  }

  void toggle(Product product) {
    if (state.any((p) => p.id == product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [product, ...state];
    }
    _debouncedPush();
  }

  void _debouncedPush() {
    _saveToHive(); // Always save to local storage
    if (_userId == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      _ref.read(wishlistServiceProvider).saveWishlist(_userId!, state);
    });
  }

  void _loadFromHive() {
    final box = Hive.box(_boxKey);
    final raw = box.get('items');
    if (raw == null) return;
    try {
      final List<dynamic> list = raw as List<dynamic>;
      final items = list.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return Product.fromMap(map);
      }).toList();
      state = items;
    } catch (_) {
      // Ignore corrupted cache
    }
  }

  void _saveToHive() {
    final box = Hive.box(_boxKey);
    box.put('items', state.map((e) => e.toMap()).toList());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  bool isInWishlist(String productId) => state.any((p) => p.id == productId);

  void setItems(List<Product> items) {
    state = items;
    _debouncedPush();
  }

  void clear() {
    state = [];
    _debouncedPush();
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<Product>>(
  (ref) => WishlistNotifier(ref),
);
