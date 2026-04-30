import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart'; // Unified PromoCode model

/// Streams all active and non-expired promo codes from Firestore, newest first
final availablePromosProvider = StreamProvider<List<PromoCode>>((ref) {
  return FirebaseFirestore.instance
      .collection('promoCodes')
      .where('active', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final now = DateTime.now();
    return snapshot.docs
        .map((doc) => PromoCode.fromFirestore(doc))
        .where((promo) => promo.expiresAt == null || now.isBefore(promo.expiresAt!))
        .toList();
  });
});

/// Stores the currently applied PromoCode
final appliedPromoCodeProvider = StateProvider<PromoCode?>((ref) => null);
