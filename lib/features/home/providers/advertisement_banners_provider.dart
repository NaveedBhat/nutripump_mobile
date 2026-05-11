// lib/features/home/providers/advertisement_banners_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/advertisement_banner.dart';

/// Streams advertisement banners from Firestore in real-time.
/// Automatically filters for active banners that are visible on mobile.
/// The stream is managed by Riverpod — no manual controller lifecycle needed.
final advertisementBannersProvider =
    StreamProvider<List<AdvertisementBanner>>((ref) {
  return FirebaseFirestore.instance
      .collection('advertisementBanners')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snap) {
    final banners = snap.docs
        .map((doc) => AdvertisementBanner.fromJson(doc.id, doc.data()))
        .where((b) =>
            b.platformVisibility == 'all' ||
            b.platformVisibility == 'mobile')
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return banners;
  });
});
