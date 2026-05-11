import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;
  static const _col = 'products';

  /// Paginated product list — mirrors web getProducts()
  Future<({List<Product> products, DocumentSnapshot? lastDoc})> getProducts({
    String? category,
    String? sortBy,
    int pageSize = 24,
    DocumentSnapshot? lastDoc,
  }) async {
    Query q = _db.collection(_col);

    if (category != null) {
      q = q.where('category', isEqualTo: category);
    }

    final sortMap = {
      'price-asc': ('price', false),
      'price-desc': ('price', true),
      'newest': ('createdAt', true),
      'rating': ('rating', true),
      'featured': ('featured', true),
    };
    final sort = sortMap[sortBy ?? 'newest'] ?? ('createdAt', true);
    q = q.orderBy(sort.$1, descending: sort.$2).limit(pageSize);

    if (lastDoc != null) q = q.startAfterDocument(lastDoc);

    final snap = await q.get();
    final products = snap.docs.map(Product.fromFirestore).toList();
    final last = snap.docs.isNotEmpty ? snap.docs.last : null;
    return (products: products, lastDoc: last);
  }

  /// Get a single product by slug
  Future<Product?> getProductBySlug(String slug) async {
    final snap = await _db
        .collection(_col)
        .where('slug', isEqualTo: slug)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Product.fromFirestore(snap.docs.first);
  }

  /// Get featured products for home screen
  Future<List<Product>> getFeaturedProducts({int limit = 8}) async {
    final snap = await _db
        .collection(_col)
        .where('featured', isEqualTo: true)
        .limit(limit)
        .get();
    return snap.docs.map(Product.fromFirestore).toList();
  }

  /// Real-time stream of featured products
  Stream<List<Product>> featuredProductsStream() => _db
      .collection(_col)
      .where('featured', isEqualTo: true)
      .limit(8)
      .snapshots()
      .map((s) => s.docs.map(Product.fromFirestore).toList());

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category,
      {int limit = 12}) async {
    final snap = await _db
        .collection(_col)
        .where('category', isEqualTo: category)
        .limit(limit)
        .get();
    return snap.docs.map(Product.fromFirestore).toList();
  }

  /// Get product by Firestore doc ID
  Future<Product?> getProductById(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }
}
