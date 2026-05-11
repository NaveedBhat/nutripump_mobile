import 'package:cloud_firestore/cloud_firestore.dart';

/// Equivalent to TypeScript ProductCategory = string
typedef ProductCategory = String;

class ProductSize {
  final String label;
  final double price;
  final double? compareAtPrice;

  const ProductSize({
    required this.label,
    required this.price,
    this.compareAtPrice,
  });

  factory ProductSize.fromMap(Map<String, dynamic> m) => ProductSize(
        label: m['label'] as String,
        price: (m['price'] as num).toDouble(),
        compareAtPrice: m['compareAtPrice'] != null
            ? (m['compareAtPrice'] as num).toDouble()
            : null,
      );

  Map<String, dynamic> toMap() => {
        'label': label,
        'price': price,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
      };
}

class Product {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;
  final double price;
  final double? compareAtPrice;
  final List<String> images;
  final ProductCategory category;
  final List<String> tags;
  final String origin;
  final String weight;
  final bool inStock;
  final int stockCount;
  final double rating;
  final int reviewCount;
  final String? badge;
  final List<String>? benefits;
  final List<ProductSize>? sizes;
  final bool featured;
  final double? bundlePrice;
  final String? ingredients;
  final String? nutrition;
  final String? calories;
  final String? fat;
  final String? protein;
  final String? carbs;
  final String? flavorProfile;
  final String? vibe;
  final String? texture;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.shortDescription,
    required this.price,
    this.compareAtPrice,
    required this.images,
    required this.category,
    required this.tags,
    required this.origin,
    required this.weight,
    required this.inStock,
    required this.stockCount,
    required this.rating,
    required this.reviewCount,
    this.badge,
    this.benefits,
    this.sizes,
    required this.featured,
    this.bundlePrice,
    this.ingredients,
    this.nutrition,
    this.calories,
    this.fat,
    this.protein,
    this.carbs,
    this.flavorProfile,
    this.vibe,
    this.texture,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    return Product.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
  }

  factory Product.fromMap(Map<String, dynamic> d, {String? id}) {
    return Product(
      id: id ?? d['id']?.toString() ?? '',
      name: d['name']?.toString() ?? '',
      slug: d['slug']?.toString() ?? '',
      description: d['description']?.toString() ?? '',
      shortDescription: d['shortDescription']?.toString() ?? '',
      price: (d['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: (d['compareAtPrice'] as num?)?.toDouble(),
      images: List<String>.from(d['images'] as List? ?? []),
      category: d['category']?.toString() ?? '',
      tags: List<String>.from(d['tags'] as List? ?? []),
      origin: d['origin']?.toString() ?? '',
      weight: d['weight']?.toString() ?? '',
      inStock: d['inStock'] as bool? ?? false,
      stockCount: (d['stockCount'] as num?)?.toInt() ?? 0,
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (d['reviewCount'] as num?)?.toInt() ?? 0,
      badge: d['badge']?.toString(),
      benefits: d['benefits'] != null
          ? List<String>.from(d['benefits'] as List)
          : null,
      sizes: d['sizes'] != null
          ? (d['sizes'] as List)
              .map((s) => ProductSize.fromMap(s as Map<String, dynamic>))
              .toList()
          : null,
      featured: d['featured'] as bool? ?? false,
      bundlePrice: (d['bundlePrice'] as num?)?.toDouble(),
      ingredients: d['ingredients']?.toString(),
      nutrition: d['nutrition']?.toString(),
      calories: d['calories']?.toString(),
      fat: d['fat']?.toString(),
      protein: d['protein']?.toString(),
      carbs: d['carbs']?.toString(),
      flavorProfile: d['flavor_profile']?.toString(),
      vibe: d['vibe']?.toString(),
      texture: d['texture']?.toString(),
      createdAt: d['createdAt'] is Timestamp
          ? (d['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(d['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      updatedAt: d['updatedAt'] is Timestamp
          ? (d['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(d['updatedAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  bool get isAvailable => inStock && stockCount > 0;

  int get discountPercent {
    if (compareAtPrice == null || compareAtPrice! <= price) return 0;
    return (((compareAtPrice! - price) / compareAtPrice!) * 100).round();
  }

  String get primaryImage => images.isNotEmpty ? images[0] : '';

  Product copyWithBundlePrice(double bundlePrice) {
    return Product(
      id: id,
      name: name,
      slug: slug,
      description: description,
      shortDescription: shortDescription,
      price: price,
      compareAtPrice: compareAtPrice,
      images: images,
      category: category,
      tags: tags,
      origin: origin,
      weight: weight,
      inStock: inStock,
      stockCount: stockCount,
      rating: rating,
      reviewCount: reviewCount,
      badge: badge,
      benefits: benefits,
      sizes: sizes,
      featured: featured,
      bundlePrice: bundlePrice,
      ingredients: ingredients,
      nutrition: nutrition,
      calories: calories,
      fat: fat,
      protein: protein,
      carbs: carbs,
      flavorProfile: flavorProfile,
      vibe: vibe,
      texture: texture,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'shortDescription': shortDescription,
        'price': price,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        'images': images,
        'category': category,
        'tags': tags,
        'origin': origin,
        'weight': weight,
        'inStock': inStock,
        'stockCount': stockCount,
        'rating': rating,
        'reviewCount': reviewCount,
        if (badge != null) 'badge': badge,
        if (benefits != null) 'benefits': benefits,
        if (sizes != null) 'sizes': sizes!.map((s) => s.toMap()).toList(),
        'featured': featured,
        if (bundlePrice != null) 'bundlePrice': bundlePrice,
        if (ingredients != null) 'ingredients': ingredients,
        if (nutrition != null) 'nutrition': nutrition,
        if (calories != null) 'calories': calories,
        if (fat != null) 'fat': fat,
        if (protein != null) 'protein': protein,
        if (carbs != null) 'carbs': carbs,
        if (flavorProfile != null) 'flavor_profile': flavorProfile,
        if (vibe != null) 'vibe': vibe,
        if (texture != null) 'texture': texture,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
