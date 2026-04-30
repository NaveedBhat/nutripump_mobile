// test/unit/cart_notifier_test.dart
// ─────────────────────────────────────────────────────────────────────────────
// Unit tests for CartNotifier state mutations.
//
// Uses a real in-memory Hive box (initialized in setUpAll) and overrides
// the authStateProvider + Firestore sync so no network calls are made.
//
// NOTE: Dart's library-private methods (`_foo`) cannot be overridden from
// another library — that's why the FakeCartNotifier approach didn't work.
// The correct pattern is to initialise Hive with a temp directory instead.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutripump_mobile/providers/cart_provider.dart';
import 'package:nutripump_mobile/providers/providers.dart';
import '../helpers/test_helpers.dart';

// ── Hive box names (must match production code) ──────────────────────────────
const _cartBoxKey = 'nutripump_cart';
const _wishlistBoxKey = 'nutripump_wishlist';

// ── Build a ProviderContainer with auth suppressed ──────────────────────────
ProviderContainer _makeContainer() {
  return ProviderContainer(overrides: [
    // Return null user → CartNotifier won't attempt Firestore sync
    authStateProvider.overrideWith((_) => Stream.value(null)),
  ]);
}

void main() {
  // ── One-time Hive setup ──────────────────────────────────────────────────
  setUpAll(() async {
    // Use the system temp dir so tests are hermetic and portable
    final dir = Directory.systemTemp.createTempSync('nutripump_hive_test_');
    Hive.init(dir.path);
    await Hive.openBox(_cartBoxKey);
    await Hive.openBox(_wishlistBoxKey);
  });

  // Clear boxes between tests to prevent state bleed
  setUp(() async {
    await Hive.box(_cartBoxKey).clear();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  // ── Tests ────────────────────────────────────────────────────────────────
  group('CartNotifier — mutations', () {
    test('addItem adds a new product to the cart', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);

      notifier.addItem(makeProduct());

      final state = c.read(cartProvider);
      expect(state.items.length, 1);
      expect(state.items.first.product.id, 'prod-1');
      expect(state.items.first.quantity, 1);
    });

    test('addItem increments quantity when same product already in cart', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);
      final product = makeProduct();

      notifier.addItem(product);
      notifier.addItem(product, qty: 2);

      final state = c.read(cartProvider);
      expect(state.items.length, 1);
      expect(state.items.first.quantity, 3);
    });

    test('addItem as gift box always creates a separate item', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);
      final product = makeProduct();

      notifier.addItem(product);
      notifier.addItem(product, isGiftBox: true, giftNote: 'Happy Birthday!');

      final state = c.read(cartProvider);
      expect(state.items.length, 2);
      expect(state.items.last.isGiftBox, isTrue);
      expect(state.items.last.giftNote, 'Happy Birthday!');
    });

    test('removeItem removes correct item by cartItemId', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);

      notifier.addItem(makeProduct());
      final cartItemId = c.read(cartProvider).items.first.cartItemId;
      notifier.removeItem(cartItemId);

      expect(c.read(cartProvider).items, isEmpty);
    });

    test('updateQuantity changes item quantity', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);

      notifier.addItem(makeProduct());
      final cartItemId = c.read(cartProvider).items.first.cartItemId;
      notifier.updateQuantity(cartItemId, 5);

      expect(c.read(cartProvider).items.first.quantity, 5);
    });

    test('updateQuantity with qty <= 0 removes the item', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);

      notifier.addItem(makeProduct());
      final cartItemId = c.read(cartProvider).items.first.cartItemId;
      notifier.updateQuantity(cartItemId, 0);

      expect(c.read(cartProvider).items, isEmpty);
    });

    test('applyPromo sets appliedPromo', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);

      notifier.applyPromo(makePromo());
      expect(c.read(cartProvider).appliedPromo?.code, 'SAVE10');
    });

    test('removePromo clears appliedPromo', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);

      notifier.applyPromo(makePromo());
      notifier.removePromo();
      expect(c.read(cartProvider).appliedPromo, isNull);
    });

    test('clearCart empties items and removes promo', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);

      notifier.addItem(makeProduct());
      notifier.applyPromo(makePromo());
      notifier.clearCart();

      final state = c.read(cartProvider);
      expect(state.items, isEmpty);
      expect(state.appliedPromo, isNull);
    });

    test('updateSettings changes gstRate, freeThreshold, and shippingCost', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);

      notifier.updateSettings(
        gstRate: 0.12,
        freeThreshold: 999,
        shippingCost: 50,
      );

      final state = c.read(cartProvider);
      expect(state.gstRate, 0.12);
      expect(state.freeThreshold, 999.0);
      expect(state.shippingCost, 50.0);
    });

    test('total is calculated correctly after add + applyPromo', () {
      final c = _makeContainer();
      addTearDown(c.dispose);
      final notifier = c.read(cartProvider.notifier);

      // ₹1000 product → gst=5% (₹50), shipping=0 (above ₹499 threshold)
      notifier.addItem(makeProduct(price: 1000));
      notifier.applyPromo(makePromo(type: 'flat', value: 50));

      final state = c.read(cartProvider);
      // 1000 + 50 gst − 50 discount + 0 shipping = 1000
      expect(state.total, closeTo(1000.0, 0.01));
    });
  });
}
