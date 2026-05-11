import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded;

  String get label => name[0].toUpperCase() + name.substring(1);

  static OrderStatus fromString(String s) => OrderStatus.values
      .firstWhere((e) => e.name == s, orElse: () => OrderStatus.pending);
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded;

  static PaymentStatus fromString(String s) => PaymentStatus.values
      .firstWhere((e) => e.name == s, orElse: () => PaymentStatus.pending);
}

enum ReturnStatus {
  none,
  requested,
  approved,
  rejected,
  refunded;

  static ReturnStatus fromString(String s) => ReturnStatus.values
      .firstWhere((e) => e.name == s, orElse: () => ReturnStatus.none);
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final Address address;
  final double subtotal;
  final double gst;
  final double shipping;
  final double? discount;
  final String? appliedPromoCode;
  final double total;
  final OrderStatus status;
  final String? paymentId;
  final PaymentStatus paymentStatus;
  final String? razorpayOrderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? trackingNumber;
  final ReturnStatus returnStatus;
  final String? returnReason;
  final String? cancelledBy;
  final String? cancellationReason;
  final DateTime? cancelledAt;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.address,
    required this.subtotal,
    required this.gst,
    required this.shipping,
    this.discount,
    this.appliedPromoCode,
    required this.total,
    required this.status,
    this.paymentId,
    required this.paymentStatus,
    this.razorpayOrderId,
    required this.createdAt,
    required this.updatedAt,
    this.trackingNumber,
    this.returnStatus = ReturnStatus.none,
    this.returnReason,
    this.cancelledBy,
    this.cancellationReason,
    this.cancelledAt,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      items: (d['items'] as List?)
              ?.map((i) => CartItem.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      address: Address.fromMap(d['address'] as Map<String, dynamic>? ?? {}),
      subtotal: (d['subtotal'] as num?)?.toDouble() ?? 0,
      gst: (d['gst'] as num?)?.toDouble() ?? 0,
      shipping: (d['shipping'] as num?)?.toDouble() ?? 0,
      discount: (d['discount'] as num?)?.toDouble(),
      appliedPromoCode: d['appliedPromoCode'] as String?,
      total: (d['total'] as num?)?.toDouble() ?? 0,
      status: OrderStatus.fromString(d['status'] as String? ?? 'pending'),
      paymentId: d['paymentId'] as String?,
      paymentStatus:
          PaymentStatus.fromString(d['paymentStatus'] as String? ?? 'pending'),
      razorpayOrderId: d['razorpayOrderId'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      trackingNumber: d['trackingNumber'] as String?,
      returnStatus:
          ReturnStatus.fromString(d['returnStatus'] as String? ?? 'none'),
      returnReason: d['returnReason'] as String?,
      cancelledBy: d['cancelledBy'] as String?,
      cancellationReason: d['cancellationReason'] as String?,
      cancelledAt: (d['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  bool get canReturn =>
      status == OrderStatus.delivered && returnStatus == ReturnStatus.none;

  Order copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    Address? address,
    double? subtotal,
    double? gst,
    double? shipping,
    double? discount,
    String? appliedPromoCode,
    double? total,
    OrderStatus? status,
    String? paymentId,
    PaymentStatus? paymentStatus,
    String? razorpayOrderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? trackingNumber,
    ReturnStatus? returnStatus,
    String? returnReason,
    String? cancelledBy,
    String? cancellationReason,
    DateTime? cancelledAt,
  }) =>
      Order(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        items: items ?? this.items,
        address: address ?? this.address,
        subtotal: subtotal ?? this.subtotal,
        gst: gst ?? this.gst,
        shipping: shipping ?? this.shipping,
        discount: discount ?? this.discount,
        appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
        total: total ?? this.total,
        status: status ?? this.status,
        paymentId: paymentId ?? this.paymentId,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        trackingNumber: trackingNumber ?? this.trackingNumber,
        returnStatus: returnStatus ?? this.returnStatus,
        returnReason: returnReason ?? this.returnReason,
        cancelledBy: cancelledBy ?? this.cancelledBy,
        cancellationReason: cancellationReason ?? this.cancellationReason,
        cancelledAt: cancelledAt ?? this.cancelledAt,
      );

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'items': items.map((i) => i.toMap()).toList(),
        'address': address.toMap(),
        'subtotal': subtotal,
        'gst': gst,
        'shipping': shipping,
        if (discount != null) 'discount': discount,
        if (appliedPromoCode != null) 'appliedPromoCode': appliedPromoCode,
        'total': total,
        'status': status.name,
        if (paymentId != null) 'paymentId': paymentId,
        'paymentStatus': paymentStatus.name,
        if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        'returnStatus': returnStatus.name,
        if (returnReason != null) 'returnReason': returnReason,
        if (cancelledBy != null) 'cancelledBy': cancelledBy,
        if (cancellationReason != null)
          'cancellationReason': cancellationReason,
        if (cancelledAt != null)
          'cancelledAt': Timestamp.fromDate(cancelledAt!),
      };
}
