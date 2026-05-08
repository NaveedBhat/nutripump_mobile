import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String productId;
  final String? userId;
  final String? userName;
  final String? userPhoto;
  final bool isAnonymous;
  final double rating;
  final String title;
  final String body;
  final bool verified;
  final String? adminReply;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.productId,
    this.userId,
    this.userName,
    this.userPhoto,
    this.isAnonymous = false,
    required this.rating,
    required this.title,
    required this.body,
    this.verified = false,
    this.adminReply,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      productId: d['productId'] as String? ?? '',
      userId: d['userId'] as String?,
      userName: d['userName'] as String?,
      userPhoto: d['userPhoto'] as String?,
      isAnonymous: d['isAnonymous'] as bool? ?? false,
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      verified: d['verified'] as bool? ?? false,
      adminReply: d['adminReply'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final String? sublabel;
  final int order;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    this.sublabel,
    this.order = 0,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: d['name']?.toString() ?? d['label']?.toString() ?? d['title']?.toString() ?? '',
      slug: d['slug']?.toString() ?? d['id']?.toString() ?? '',
      image: d['image']?.toString() ?? d['imageUrl']?.toString(),
      description: d['description']?.toString(),
      sublabel: d['sublabel']?.toString(),
      order: (d['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class StoreSettings {
  final String storeName;
  final String storeEmail;
  final String bulkEmail;
  final String storePhone;
  final String storeAddress;
  final String whatsappNumber;
  final String instagramUrl;
  final String facebookUrl;
  final String twitterUrl;
  final double freeShippingThreshold;
  final double shippingCost;
  final double gstRate;
  final bool allowGuestCheckout;
  final bool enableReviews;
  final bool maintenanceMode;
  final int cancellationWindowHours;
  final int returnWindowDays;

  const StoreSettings({
    this.storeName = 'NutriPump Artisanal',
    this.storeEmail = 'hello@nutripump.in',
    this.bulkEmail = 'wholesale@nutripump.in',
    this.storePhone = '+91-99060-00000',
    this.storeAddress = 'Srinagar, J&K',
    this.whatsappNumber = '+919906000000',
    this.instagramUrl = 'https://instagram.com/nutripump',
    this.facebookUrl = 'https://facebook.com/nutripump',
    this.twitterUrl = 'https://twitter.com/nutripump',
    this.freeShippingThreshold = 499,
    this.shippingCost = 99,
    this.gstRate = 5,
    this.allowGuestCheckout = true,
    this.enableReviews = true,
    this.maintenanceMode = false,
    this.cancellationWindowHours = 24,
    this.returnWindowDays = 5,
  });

  factory StoreSettings.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StoreSettings(
      storeName: d['storeName'] as String? ?? 'NutriPump Artisanal',
      storeEmail: d['storeEmail'] as String? ?? 'hello@nutripump.in',
      bulkEmail: d['bulkEmail'] as String? ?? 'wholesale@nutripump.in',
      storePhone: d['storePhone'] as String? ?? '',
      storeAddress: d['storeAddress'] as String? ?? '',
      whatsappNumber: d['whatsappNumber'] as String? ?? '',
      instagramUrl: d['instagramUrl'] as String? ?? '',
      facebookUrl: d['facebookUrl'] as String? ?? '',
      twitterUrl: d['twitterUrl'] as String? ?? '',
      freeShippingThreshold: (d['freeShippingThreshold'] as num?)?.toDouble() ?? 499,
      shippingCost: (d['shippingCost'] as num?)?.toDouble() ?? 99,
      gstRate: (d['gstRate'] as num?)?.toDouble() ?? 5,
      allowGuestCheckout: d['allowGuestCheckout'] as bool? ?? true,
      enableReviews: d['enableReviews'] as bool? ?? true,
      maintenanceMode: d['maintenanceMode'] as bool? ?? false,
      cancellationWindowHours: (d['cancellationWindowHours'] as num?)?.toInt() ?? 24,
      returnWindowDays: (d['returnWindowDays'] as num?)?.toInt() ?? 5,
    );
  }

  double get gstDecimal => gstRate / 100;
}

class PromoCode {
  final String code;
  final String type; // 'percentage' | 'flat'
  final double value;
  final double minOrderValue;
  final String title;
  final String description;
  final double? maxDiscountAmount;
  final bool isFirstOrderOnly;
  final bool oneTimeUsePerUser;
  final String? productId;
  final String? productName;
  final DateTime? expiresAt;
  final bool active;

  const PromoCode({
    required this.code,
    required this.type,
    required this.value,
    this.minOrderValue = 0,
    required this.title,
    required this.description,
    this.maxDiscountAmount,
    this.isFirstOrderOnly = false,
    this.oneTimeUsePerUser = false,
    this.productId,
    this.productName,
    this.expiresAt,
    this.active = true,
  });

  factory PromoCode.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return PromoCode(
      code: doc.id,
      type: d['type'] as String? ?? 'flat',
      value: (d['value'] as num?)?.toDouble() ?? 0,
      minOrderValue: (d['minOrderValue'] as num?)?.toDouble() ?? 0,
      title: d['title'] as String? ?? doc.id,
      description: d['description'] as String? ?? '',
      maxDiscountAmount: (d['maxDiscountAmount'] as num?)?.toDouble(),
      isFirstOrderOnly: d['isFirstOrderOnly'] as bool? ?? false,
      oneTimeUsePerUser: d['oneTimeUsePerUser'] as bool? ?? false,
      productId: d['productId'] as String?,
      productName: d['productName'] as String?,
      expiresAt: d['expiresAt'] != null ? (d['expiresAt'] as Timestamp).toDate() : null,
      active: d['active'] as bool? ?? true,
    );
  }

  /// Returns true if this promo code is superficially valid for the given cart.
  ///
  /// NOTE: `oneTimeUsePerUser` is intentionally NOT checked here. It is enforced
  /// exclusively on the backend. The UI may show a valid discount preview for
  /// a previously-used code; the server will reject it at checkout. Do not add
  /// a client-side check here — that would require an extra Firestore read per
  /// cart update and can be bypassed anyway.
  bool isValidFor(double orderTotal, bool isFirstOrder, List<String> cartProductIds) {
    if (!active) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (orderTotal < minOrderValue) return false;
    if (isFirstOrderOnly && !isFirstOrder) return false;
    if (productId != null && !cartProductIds.contains(productId)) return false;
    return true;
  }

  double calculateDiscount(double subtotal) {
    double discount = 0;
    if (type == 'percentage') {
      discount = (subtotal * value / 100).roundToDouble();
    } else {
      discount = value;
    }
    if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
      return maxDiscountAmount!;
    }
    return discount;
  }
}

class PaymentSettings {
  final bool upi;
  final bool card;
  final bool netbanking;
  final bool cod;
  final double codMinOrder;
  final double codCharge;

  const PaymentSettings({
    this.upi = true,
    this.card = true,
    this.netbanking = true,
    this.cod = true,
    this.codMinOrder = 0,
    this.codCharge = 0,
  });

  factory PaymentSettings.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return PaymentSettings(
      upi: d['upi'] as bool? ?? true,
      card: d['card'] as bool? ?? true,
      netbanking: d['netbanking'] as bool? ?? true,
      cod: d['cod'] as bool? ?? true,
      codMinOrder: (d['codMinOrder'] as num?)?.toDouble() ?? 0,
      codCharge: (d['codCharge'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AnnouncementSettings {
  final bool activeMobile;
  final String text;
  final String bgColor;
  final String textColor;

  const AnnouncementSettings({
    this.activeMobile = true,
    this.text = '🚚 FREE DELIVERY ABOVE ₹499  🌿 100% NATURAL  🏔️ MADE IN KASHMIR',
    this.bgColor = '#ebd177',
    this.textColor = '#1f1f1f',
  });

  factory AnnouncementSettings.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) return const AnnouncementSettings();
    final d = doc.data() as Map<String, dynamic>;
    return AnnouncementSettings(
      activeMobile: d['activeMobile'] as bool? ?? d['active'] as bool? ?? true,
      text: d['text'] as String? ?? '🚚 FREE DELIVERY ABOVE ₹499  🌿 100% NATURAL  🏔️ MADE IN KASHMIR',
      bgColor: d['bgColor'] as String? ?? '#ebd177',
      textColor: d['textColor'] as String? ?? '#1f1f1f',
    );
  }
}
