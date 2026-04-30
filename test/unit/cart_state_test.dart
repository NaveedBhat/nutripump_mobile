// test/unit/cart_state_test.dart
// ─────────────────────────────────────────────────────────────────────────────
// Pure unit tests for CartState computed properties.
// No Firebase, no Hive, no Riverpod — just pure Dart logic.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';
import 'package:nutripump_mobile/providers/cart_provider.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CartState — computed properties', () {
    // ── Initial state ────────────────────────────────────────────────────────
    test('starts empty with zero totals', () {
      const state = CartState();
      expect(state.items, isEmpty);
      expect(state.subtotal, 0.0);
      expect(state.gst, 0.0);
      expect(state.shipping, 99.0); // below free-threshold
      expect(state.total, 99.0);
      expect(state.itemCount, 0);
    });

    // ── Subtotal ─────────────────────────────────────────────────────────────
    test('subtotal sums lineTotal of all items', () {
      final state = CartState(items: [
        makeCartItem(product: makeProduct(price: 300), quantity: 2), // 600
        makeCartItem(cartItemId: 'item-2', product: makeProduct(id: 'p2', price: 150), quantity: 1), // 150
      ]);
      expect(state.subtotal, 750.0);
    });

    test('lineTotal uses bundlePrice when set', () {
      final item = makeCartItem(product: makeProduct(price: 499), bundlePrice: 399, quantity: 2);
      expect(item.lineTotal, 798.0);
    });

    // ── Free shipping threshold ───────────────────────────────────────────────
    test('shipping is 0 when subtotal meets freeThreshold', () {
      final state = CartState(
        items: [makeCartItem(product: makeProduct(price: 499), quantity: 1)],
        freeThreshold: 499,
        shippingCost: 99,
      );
      expect(state.shipping, 0.0);
    });

    test('shipping applies when subtotal is below threshold', () {
      final state = CartState(
        items: [makeCartItem(product: makeProduct(price: 300), quantity: 1)],
        freeThreshold: 499,
        shippingCost: 99,
      );
      expect(state.shipping, 99.0);
    });

    // ── GST ──────────────────────────────────────────────────────────────────
    test('gst is 5% of subtotal by default', () {
      final state = CartState(
        items: [makeCartItem(product: makeProduct(price: 1000), quantity: 1)],
      );
      expect(state.gst, closeTo(50.0, 0.001));
    });

    // ── Promo — percentage ───────────────────────────────────────────────────
    test('percentage promo reduces total correctly', () {
      final promo = makePromo(type: 'percentage', value: 10); // 10%
      final state = CartState(
        items: [makeCartItem(product: makeProduct(price: 1000), quantity: 1)],
        appliedPromo: promo,
        shippingCost: 0,
      );
      // subtotal=1000, gst=50, discount=100, shipping=0 → total=950
      expect(state.discount, 100.0);
      expect(state.total, closeTo(950.0, 0.01));
    });

    test('flat promo reduces total correctly', () {
      final promo = makePromo(type: 'flat', value: 50);
      final state = CartState(
        items: [makeCartItem(product: makeProduct(price: 1000), quantity: 1)],
        appliedPromo: promo,
        shippingCost: 0,
      );
      expect(state.discount, 50.0);
      expect(state.total, closeTo(1000.0, 0.01)); // 1000+50 gst - 50 discount
    });

    test('promo with minOrderValue is ignored when subtotal is too low', () {
      final promo = makePromo(type: 'flat', value: 100, minOrderValue: 500);
      final state = CartState(
        items: [makeCartItem(product: makeProduct(price: 200), quantity: 1)],
        appliedPromo: promo,
      );
      expect(state.discount, 0.0);
    });

    // ── total never goes negative ─────────────────────────────────────────────
    test('total is clamped to 0 even if discount exceeds subtotal+gst', () {
      final promo = makePromo(type: 'flat', value: 10000);
      final state = CartState(
        items: [makeCartItem(product: makeProduct(price: 100), quantity: 1)],
        appliedPromo: promo,
        shippingCost: 0,
      );
      expect(state.total, 0.0);
    });

    // ── itemCount ────────────────────────────────────────────────────────────
    test('itemCount sums quantities of all items', () {
      final state = CartState(items: [
        makeCartItem(quantity: 3),
        makeCartItem(cartItemId: 'item-2', quantity: 2),
      ]);
      expect(state.itemCount, 5);
    });

    // ── copyWith ─────────────────────────────────────────────────────────────
    test('copyWith clearPromo removes appliedPromo', () {
      final promo = makePromo();
      final state = CartState(appliedPromo: promo);
      final cleared = state.copyWith(clearPromo: true);
      expect(cleared.appliedPromo, isNull);
    });

    test('copyWith preserves existing promo when not cleared', () {
      final promo = makePromo();
      final state = CartState(appliedPromo: promo);
      final updated = state.copyWith(shippingCost: 50);
      expect(updated.appliedPromo, promo);
    });
  });

  // ── PromoCode.calculateDiscount ────────────────────────────────────────────────
  group('PromoCode.calculateDiscount', () {
    test('percentage computes correct amount', () {
      final promo = makePromo(type: 'percentage', value: 20);
      expect(promo.calculateDiscount(500), 100.0);
    });

    test('flat returns flat value regardless of subtotal', () {
      final promo = makePromo(type: 'flat', value: 75);
      expect(promo.calculateDiscount(500), 75.0);
    });

    test('returns 0 when minOrderValue not met', () {
      final promo = makePromo(type: 'flat', value: 100, minOrderValue: 600);
      expect(promo.calculateDiscount(500), 0.0);
    });

    test('applies when subtotal exactly meets minOrderValue', () {
      final promo = makePromo(type: 'flat', value: 100, minOrderValue: 500);
      expect(promo.calculateDiscount(500), 100.0);
    });
  });
}
