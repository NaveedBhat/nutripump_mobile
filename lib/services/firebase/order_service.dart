import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../models/order.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  static const _col = 'orders';

  Future<Order?> getOrderById(String id) async {
    final doc = await _db.collection(_col).doc(id).get();
    if (!doc.exists) return null;
    return Order.fromFirestore(doc);
  }

  Future<String> createOrder(Order order) async {
    final docRef = _db.collection(_col).doc();
    final newOrder = order.copyWith(id: docRef.id);
    await docRef.set(newOrder.toFirestore());
    return docRef.id;
  }

  /// Stream of a single order (for real-time status updates)
  Stream<Order?> orderStream(String id) => _db.collection(_col).doc(id)
      .snapshots()
      .map((d) => d.exists ? Order.fromFirestore(d) : null);

  /// Get all orders for a user
  Future<List<Order>> getUserOrders(String userId) async {
    final snap = await _db.collection(_col)
        .where('userId', isEqualTo: userId)
        .get();
    return snap.docs.map(Order.fromFirestore).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Stream of user orders (real-time)
  Stream<List<Order>> userOrdersStream(String userId) =>
      _db.collection(_col)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((s) {
        final orders = s.docs.map(Order.fromFirestore).toList();
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      });

  Future<void> cancelOrder(String orderId, String reason) async {
    await _db.collection(_col).doc(orderId).update({
      'status': 'cancelled',
      'cancelledBy': 'user',
      'cancellationReason': reason,
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> requestReturn(String orderId, String reason) async {
    await _db.collection(_col).doc(orderId).update({
      'returnStatus': 'requested',
      'returnReason': reason,
      'returnRequestedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
