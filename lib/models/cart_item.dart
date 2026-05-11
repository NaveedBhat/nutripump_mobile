import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class CartItem {
  final String cartItemId;
  final Product product;
  final int quantity;
  final String? selectedWeight;
  final double? bundlePrice;
  final bool isGiftBox;
  final String? giftNote;

  const CartItem({
    required this.cartItemId,
    required this.product,
    required this.quantity,
    this.selectedWeight,
    this.bundlePrice,
    this.isGiftBox = false,
    this.giftNote,
  });

  double get effectivePrice => bundlePrice ?? product.price;
  double get lineTotal => effectivePrice * quantity;

  factory CartItem.fromMap(Map<String, dynamic> d) {
    return CartItem(
      cartItemId:
          d['cartItemId'] as String? ?? d['product']?['id'] as String? ?? '',
      product: Product.fromMap(d['product'] as Map<String, dynamic>? ?? {}),
      quantity: (d['quantity'] as num?)?.toInt() ?? 1,
      selectedWeight: d['selectedWeight'] as String?,
      bundlePrice: (d['bundlePrice'] as num?)?.toDouble(),
      isGiftBox: d['isGiftBox'] as bool? ?? false,
      giftNote: d['giftNote'] as String?,
    );
  }

  CartItem copyWith({
    int? quantity,
    String? selectedWeight,
    double? bundlePrice,
    bool? isGiftBox,
    String? giftNote,
  }) =>
      CartItem(
        cartItemId: cartItemId,
        product: product,
        quantity: quantity ?? this.quantity,
        selectedWeight: selectedWeight ?? this.selectedWeight,
        bundlePrice: bundlePrice ?? this.bundlePrice,
        isGiftBox: isGiftBox ?? this.isGiftBox,
        giftNote: giftNote ?? this.giftNote,
      );

  Map<String, dynamic> toMap() => {
        'cartItemId': cartItemId,
        'product': product.toMap(),
        'quantity': quantity,
        if (selectedWeight != null) 'selectedWeight': selectedWeight,
        if (bundlePrice != null) 'bundlePrice': bundlePrice,
        'isGiftBox': isGiftBox,
        if (giftNote != null) 'giftNote': giftNote,
      };
}

class Address {
  final String? id;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? locality;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final bool isDefault;

  const Address({
    this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.locality,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
    this.isDefault = false,
  });

  factory Address.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Address(
      id: doc.id,
      fullName: d['fullName'] as String? ?? '',
      phone: d['phone'] as String? ?? '',
      addressLine1: d['addressLine1'] as String? ?? '',
      locality: d['locality'] as String?,
      addressLine2: d['addressLine2'] as String?,
      city: d['city'] as String? ?? '',
      state: d['state'] as String? ?? '',
      pincode: d['pincode'] as String? ?? '',
      country: d['country'] as String? ?? 'India',
      isDefault: d['isDefault'] as bool? ?? false,
    );
  }

  factory Address.fromMap(Map<String, dynamic> d, {String? id}) => Address(
        id: id,
        fullName: d['fullName'] as String? ?? '',
        phone: d['phone'] as String? ?? '',
        addressLine1: d['addressLine1'] as String? ?? '',
        locality: d['locality'] as String?,
        addressLine2: d['addressLine2'] as String?,
        city: d['city'] as String? ?? '',
        state: d['state'] as String? ?? '',
        pincode: d['pincode'] as String? ?? '',
        country: d['country'] as String? ?? 'India',
        isDefault: d['isDefault'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'phone': phone,
        'addressLine1': addressLine1,
        if (locality != null) 'locality': locality,
        if (addressLine2 != null) 'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
        'isDefault': isDefault,
      };

  String get oneLineAddress =>
      '$addressLine1${locality != null ? ', $locality' : ''}, $city, $state — $pincode';
}
