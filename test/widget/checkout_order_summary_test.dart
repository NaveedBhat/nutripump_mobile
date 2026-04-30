// test/widget/checkout_order_summary_test.dart
// ─────────────────────────────────────────────────────────────────────────────
// Widget tests for the checkout order summary section.
// Uses real in-memory Hive (temp dir) + auth suppressed via Riverpod override.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutripump_mobile/providers/cart_provider.dart';
import 'package:nutripump_mobile/providers/providers.dart';
import '../helpers/test_helpers.dart';

// ── Minimal router ────────────────────────────────────────────────────────────
final _testRouter = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const _SummaryHost()),
  GoRoute(path: '/cart', builder: (_, __) => const Scaffold(body: Text('Cart'))),
]);

// ── Host widget renders the cart summary ──────────────────────────────────────
class _SummaryHost extends ConsumerWidget {
  const _SummaryHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: ${cart.itemCount}', key: const Key('item-count')),
            Text('Subtotal: ₹${cart.subtotal.toStringAsFixed(0)}',
                key: const Key('subtotal')),
            Text('GST: ₹${cart.gst.toStringAsFixed(0)}',
                key: const Key('gst')),
            Text('Shipping: ₹${cart.shipping.toStringAsFixed(0)}',
                key: const Key('shipping')),
            if (cart.discount > 0)
              Text('Discount: -₹${cart.discount.toStringAsFixed(0)}',
                  key: const Key('discount')),
            Text('Total: ₹${cart.total.toStringAsFixed(0)}',
                key: const Key('total')),
            if (cart.shipping == 0)
              const Text('Free shipping applied!',
                  key: Key('free-shipping-badge')),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
ProviderContainer _makeContainer() => ProviderContainer(overrides: [
      // Suppress Firebase auth so CartNotifier skips Firestore sync
      authStateProvider.overrideWith((_) => Stream.value(null)),
    ]);

Widget _buildTestApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: _testRouter),
  );
}

void main() {
  // ── Hive lifecycle ────────────────────────────────────────────────────────
  setUpAll(() async {
    final dir = Directory.systemTemp
        .createTempSync('nutripump_hive_widget_test_');
    Hive.init(dir.path);
    await Hive.openBox('nutripump_cart');
    await Hive.openBox('nutripump_wishlist');
  });

  setUp(() async => Hive.box('nutripump_cart').clear());

  tearDownAll(() async => Hive.close());

  // ── Widget tests ──────────────────────────────────────────────────────────
  group('Checkout — order summary widget', () {
    testWidgets('shows 0 items and ₹99 shipping when cart is empty',
        (tester) async {
      final c = _makeContainer();
      addTearDown(c.dispose);

      await tester.pumpWidget(_buildTestApp(c));
      await tester.pumpAndSettle();

      expect(find.text('Items: 0'), findsOneWidget);
      expect(find.text('Shipping: ₹99'), findsOneWidget);
      expect(find.byKey(const Key('free-shipping-badge')), findsNothing);
    });

    testWidgets('reflects correct subtotal after adding items', (tester) async {
      final c = _makeContainer();
      addTearDown(c.dispose);

      c.read(cartProvider.notifier).addItem(makeProduct(price: 500), qty: 2);

      await tester.pumpWidget(_buildTestApp(c));
      await tester.pumpAndSettle();

      expect(find.text('Items: 2'), findsOneWidget);
      expect(find.text('Subtotal: ₹1000'), findsOneWidget);
    });

    testWidgets('shows free shipping badge when subtotal >= 499',
        (tester) async {
      final c = _makeContainer();
      addTearDown(c.dispose);

      c.read(cartProvider.notifier).addItem(makeProduct(price: 499));

      await tester.pumpWidget(_buildTestApp(c));
      await tester.pumpAndSettle();

      expect(find.text('Shipping: ₹0'), findsOneWidget);
      expect(find.byKey(const Key('free-shipping-badge')), findsOneWidget);
    });

    testWidgets('shows discount row when promo is applied', (tester) async {
      final c = _makeContainer();
      addTearDown(c.dispose);

      c.read(cartProvider.notifier).addItem(makeProduct(price: 1000));
      c.read(cartProvider.notifier)
          .applyPromo(makePromo(type: 'flat', value: 100));

      await tester.pumpWidget(_buildTestApp(c));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('discount')), findsOneWidget);
      expect(find.text('Discount: -₹100'), findsOneWidget);
    });

    testWidgets('discount row is hidden when no promo applied', (tester) async {
      final c = _makeContainer();
      addTearDown(c.dispose);

      c.read(cartProvider.notifier).addItem(makeProduct(price: 500));

      await tester.pumpWidget(_buildTestApp(c));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('discount')), findsNothing);
    });

    testWidgets('total updates reactively when item is removed', (tester) async {
      final c = _makeContainer();
      addTearDown(c.dispose);

      c.read(cartProvider.notifier).addItem(makeProduct(price: 500));
      c.read(cartProvider.notifier)
          .addItem(makeProduct(id: 'prod-2', price: 200));

      await tester.pumpWidget(_buildTestApp(c));
      await tester.pumpAndSettle();

      // subtotal=700, gst=35, shipping=0 (>=499) → total=735
      expect(find.text('Total: ₹735'), findsOneWidget);

      final cartItemId = c.read(cartProvider).items.last.cartItemId;
      c.read(cartProvider.notifier).removeItem(cartItemId);
      await tester.pump();

      // subtotal=500, gst=25, shipping=0 → total=525
      expect(find.text('Total: ₹525'), findsOneWidget);
    });
  });
}
