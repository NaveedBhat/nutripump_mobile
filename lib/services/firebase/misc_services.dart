import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';

class CategoryService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Category>> categoriesStream() =>
      _db.collection('categories')
          .orderBy('order')
          .snapshots()
          .map((s) => s.docs.map(Category.fromFirestore).toList());

  Future<List<Category>> getCategories() async {
    final snap = await _db.collection('categories').orderBy('order').get();
    return snap.docs.map(Category.fromFirestore).toList();
  }
}

class SettingsService {
  final _db = FirebaseFirestore.instance;
  static const _defaults = StoreSettings();

  Future<StoreSettings> getSettings() async {
    try {
      final doc = await _db.collection('settings').doc('general').get();
      if (doc.exists) return StoreSettings.fromFirestore(doc);
      return _defaults;
    } catch (_) {
      return _defaults;
    }
  }

  Stream<StoreSettings> settingsStream() =>
      _db.collection('settings').doc('general').snapshots().map(
        (d) => d.exists ? StoreSettings.fromFirestore(d) : _defaults,
      );

  Stream<PaymentSettings> paymentSettingsStream() =>
      _db.collection('settings').doc('paymentMethods').snapshots().map(
        (d) => d.exists ? PaymentSettings.fromFirestore(d) : const PaymentSettings(),
      );

  Stream<AnnouncementSettings> announcementStream() =>
      _db.collection('settings').doc('announcement').snapshots().map(
        (d) => d.exists ? AnnouncementSettings.fromFirestore(d) : const AnnouncementSettings(),
      );
}

class ReviewService {
  final _db = FirebaseFirestore.instance;

  Future<List<Review>> getProductReviews(String productId, {int limit = 20}) async {
    final snap = await _db.collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(Review.fromFirestore).toList();
  }

  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String title,
    required String body,
  }) async {
    final existing = await _db.collection('reviews')
        .where('productId', isEqualTo: productId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    
    if (existing.docs.isNotEmpty) {
      throw Exception('You have already submitted a review for this product.');
    }

    await _db.collection('reviews').add({
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'title': title,
      'body': body,
      'verified': false,
      'isAnonymous': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

class AddressService {
  final _db = FirebaseFirestore.instance;

  CollectionReference _col(String uid) =>
      _db.collection('users').doc(uid).collection('addresses');

  Future<List<Address>> getAddresses(String uid) async {
    final snap = await _col(uid).get();
    return snap.docs.map(Address.fromFirestore).toList();
  }

  Stream<List<Address>> addressesStream(String uid) {
    return _col(uid).snapshots().map(
      (snap) => snap.docs.map(Address.fromFirestore).toList()
    );
  }

  Future<String> addAddress(String uid, Address address) async {
    final ref = await _col(uid).add(address.toMap());
    return ref.id;
  }

  Future<void> updateAddress(String uid, String addressId, Address address) async {
    await _col(uid).doc(addressId).update(address.toMap());
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    await _col(uid).doc(addressId).delete();
  }

  Future<void> setDefault(String uid, String addressId) async {
    final addresses = await getAddresses(uid);
    final batch = _db.batch();
    for (final a in addresses) {
      batch.update(_col(uid).doc(a.id), {'isDefault': a.id == addressId});
    }
    await batch.commit();
  }
}

class WishlistService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveWishlist(String uid, List<Product> products) async {
    await _db.collection('wishlists').doc(uid).set({
      'userId': uid,
      'items': products.map((p) => p.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Product>> wishlistsStream(String uid) {
    return _db.collection('wishlists').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return [];
      final data = doc.data();
      if (data == null) return [];
      final rawItems = data['items'] as List<dynamic>? ?? [];
      return rawItems.map((item) => Product.fromMap(item as Map<String, dynamic>)).toList();
    });
  }
}

class PromoCodeService {
  final _db = FirebaseFirestore.instance;

  /// Validates a promo code by looking it up as a Firestore document ID.
  /// The promo code IS the document ID — not a field inside the document.
  Future<PromoCode?> validate(String code) async {
    final doc = await _db
        .collection('promoCodes')
        .doc(code.toUpperCase())
        .get();
    if (!doc.exists) return null;
    return PromoCode.fromFirestore(doc);
  }
}
