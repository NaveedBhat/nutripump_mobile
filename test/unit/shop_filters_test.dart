// test/unit/shop_filters_test.dart
// ─────────────────────────────────────────────────────────────────────────────
// Unit tests for ShopFiltersNotifier — pure Riverpod state, no Firebase.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutripump_mobile/providers/providers.dart';

ProviderContainer _container() => ProviderContainer();

void main() {
  group('ShopFiltersNotifier', () {
    test('initial state has no category and empty searchQuery', () {
      final c = _container();
      addTearDown(c.dispose);
      final filters = c.read(shopFiltersProvider);
      expect(filters.category, isNull);
      expect(filters.searchQuery, '');
      expect(filters.sortBy, 'featured');
    });

    test('setCategory updates category', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(shopFiltersProvider.notifier).setCategory('honey');
      expect(c.read(shopFiltersProvider).category, 'honey');
    });

    test('setCategory with null clears category', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(shopFiltersProvider.notifier).setCategory('honey');
      c.read(shopFiltersProvider.notifier).setCategory(null);
      expect(c.read(shopFiltersProvider).category, isNull);
    });

    test('setSearchQuery updates searchQuery', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(shopFiltersProvider.notifier).setSearchQuery('saffron');
      expect(c.read(shopFiltersProvider).searchQuery, 'saffron');
    });

    test('setPriceMax updates priceMax', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(shopFiltersProvider.notifier).setPriceMax(800.0);
      expect(c.read(shopFiltersProvider).priceMax, 800.0);
    });

    test('toggleOrigin adds origin when not present', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(shopFiltersProvider.notifier).toggleOrigin('Kashmir');
      expect(c.read(shopFiltersProvider).origins, contains('Kashmir'));
    });

    test('toggleOrigin removes origin when already present', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(shopFiltersProvider.notifier).toggleOrigin('Kashmir');
      c.read(shopFiltersProvider.notifier).toggleOrigin('Kashmir');
      expect(c.read(shopFiltersProvider).origins, isEmpty);
    });

    test('setSortBy updates sortBy', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(shopFiltersProvider.notifier).setSortBy('price-asc');
      expect(c.read(shopFiltersProvider).sortBy, 'price-asc');
    });

    test('reset restores all fields to defaults', () {
      final c = _container();
      addTearDown(c.dispose);
      final n = c.read(shopFiltersProvider.notifier);
      n.setCategory('honey');
      n.setSearchQuery('raw');
      n.toggleOrigin('Kashmir');
      n.setSortBy('rating');
      n.reset();

      final filters = c.read(shopFiltersProvider);
      expect(filters.category, isNull);
      expect(filters.searchQuery, '');
      expect(filters.origins, isEmpty);
      expect(filters.sortBy, 'featured');
    });
  });
}
