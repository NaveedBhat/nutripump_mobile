import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/cart_item.dart';

class CheckoutApi {
  late final Dio _dio;

  CheckoutApi() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://www.nutripump.store';
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    // ── Surface backend error messages (e.g. promo validation) cleanly ──
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          // Extract the `error` field from our JSON responses (e.g. { error: "You have already used..." })
          final serverMessage = e.response?.data is Map
              ? e.response!.data['error'] as String?
              : null;
          if (serverMessage != null) {
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e.response,
                type: e.type,
                error: serverMessage,
                message: serverMessage,
              ),
            );
          }
          handler.next(e);
        },
      ),
    );
  }

  /// Create Razorpay order — mirrors POST /api/checkout/create-order
  ///
  /// Returns the Razorpay [orderId], Firestore [firestoreOrderId], and the
  /// backend-verified [amount] in paise (already post-promo / post-shipping).
  /// The caller MUST use [amount] when opening the Razorpay SDK — never
  /// recompute it client-side, as the backend is the authoritative source.
  Future<({String orderId, String firestoreOrderId, int amount})> createOrder({
    required List<CartItem> items,
    required Address address,
    required String userId,
    String? appliedPromoCode,
  }) async {
    final response = await _dio.post('/api/checkout/create-order', data: {
      'items': items
          .map((i) => {
                'product': {
                  'id': i.product.id,
                  'name': i.product.name,
                  'price': i.product.price,
                  'images': i.product.images,
                  'weight': i.product.weight,
                },
                'quantity': i.quantity,
                'selectedWeight': i.selectedWeight ?? i.product.weight,
                if (i.bundlePrice != null) 'bundlePrice': i.bundlePrice,
              })
          .toList(),
      'address': address.toMap(),
      'userId': userId,
      if (appliedPromoCode != null) 'appliedPromoCode': appliedPromoCode,
    });

    // The backend returns amount in paise (Razorpay's unit), already
    // accounting for promo discount, GST, and shipping.
    final int backendAmount = (response.data['amount'] as num).toInt();

    return (
      orderId: response.data['orderId'] as String,
      firestoreOrderId: response.data['firestoreOrderId'] as String,
      amount: backendAmount,
    );
  }

  /// Verify Razorpay payment — mirrors POST /api/checkout/verify
  Future<String> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    required String firestoreOrderId,
  }) async {
    final response = await _dio.post('/api/checkout/verify', data: {
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
      'firestoreOrderId': firestoreOrderId,
    });
    return response.data['orderId'] as String? ?? firestoreOrderId;
  }

  /// Create COD order — mirrors POST /api/checkout/create-cod-order
  Future<String> createCodOrder({
    required List<CartItem> items,
    required Address address,
    required String userId,
    String? appliedPromoCode,
  }) async {
    final response = await _dio.post('/api/checkout/create-cod-order', data: {
      'items': items
          .map((i) => {
                'product': {
                  'id': i.product.id,
                  'name': i.product.name,
                  'price': i.product.price,
                  'images': i.product.images,
                  'weight': i.product.weight,
                },
                'quantity': i.quantity,
                'selectedWeight': i.selectedWeight ?? i.product.weight,
                if (i.bundlePrice != null) 'bundlePrice': i.bundlePrice,
              })
          .toList(),
      'address': address.toMap(),
      'userId': userId,
      if (appliedPromoCode != null) 'appliedPromoCode': appliedPromoCode,
    });
    return response.data['firestoreOrderId'] as String;
  }

  /// Cancel abandoned order — mirrors POST /api/checkout/cancel-order
  Future<void> cancelOrder(String firestoreOrderId) async {
    await _dio.post('/api/checkout/cancel-order',
        data: {'firestoreOrderId': firestoreOrderId});
  }
}
