// test/helpers/test_helpers.dart
// ─────────────────────────────────────────────────────────────────────────────
// Shared fixtures and factories for all tests.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:nutripump_mobile/models/product.dart';
import 'package:nutripump_mobile/models/cart_item.dart';
import 'package:nutripump_mobile/models/models.dart';

// ── Product factory ───────────────────────────────────────────────────────────
Product makeProduct({
  String id = 'prod-1',
  String name = 'Kashmiri Honey',
  String slug = 'kashmiri-honey',
  double price = 499.0,
  double? compareAtPrice,
  bool inStock = true,
  int stockCount = 100,
  String category = 'honey',
}) =>
    Product(
      id: id,
      name: name,
      slug: slug,
      description: 'Pure Kashmiri honey',
      shortDescription: 'Pure honey',
      price: price,
      compareAtPrice: compareAtPrice,
      images: const ['https://example.com/honey.jpg'],
      category: category,
      tags: const ['honey', 'natural'],
      origin: 'Kashmir',
      weight: '500g',
      inStock: inStock,
      stockCount: stockCount,
      rating: 4.8,
      reviewCount: 42,
      badge: null,
      featured: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

// ── CartItem factory ──────────────────────────────────────────────────────────
CartItem makeCartItem({
  String cartItemId = 'item-1',
  Product? product,
  int quantity = 1,
  double? bundlePrice,
  bool isGiftBox = false,
  String? giftNote,
}) =>
    CartItem(
      cartItemId: cartItemId,
      product: product ?? makeProduct(),
      quantity: quantity,
      bundlePrice: bundlePrice,
      isGiftBox: isGiftBox,
      giftNote: giftNote,
    );

// ── PromoCode factory ─────────────────────────────────────────────────────────
PromoCode makePromo({
  String code = 'SAVE10',
  String type = 'percentage',
  double value = 10,
  double minOrderValue = 0,
}) =>
    PromoCode(
      code: code,
      type: type,
      value: value,
      minOrderValue: minOrderValue,
      title: code,
      description: 'Test promo',
    );
