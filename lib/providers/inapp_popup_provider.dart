// lib/providers/inapp_popup_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Streams the active in-app popup config from Firestore.
// Tracks which campaign IDs have already been shown using Hive,
// so the same popup is never shown twice on the same device.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InAppPopupData {
  final String campaignId;
  final String title;
  final String body;
  final String? imageUrl;
  final String? ctaLabel;
  final String? deepLink;
  final String? bgColor;
  final DateTime? expiresAt;

  InAppPopupData({
    required this.campaignId,
    required this.title,
    required this.body,
    this.imageUrl,
    this.ctaLabel,
    this.deepLink,
    this.bgColor,
    this.expiresAt,
  });

  factory InAppPopupData.fromMap(Map<String, dynamic> map) {
    DateTime? expiresAt;
    final raw = map['expiresAt'];
    if (raw is Timestamp) {
      expiresAt = raw.toDate();
    } else if (raw is String) {
      expiresAt = DateTime.tryParse(raw);
    }

    return InAppPopupData(
      campaignId: map['campaignId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      ctaLabel: map['ctaLabel'] as String?,
      deepLink: map['deepLink'] as String?,
      bgColor: map['bgColor'] as String?,
      expiresAt: expiresAt,
    );
  }
}

/// Streams the current popup config. Emits `null` when:
/// - No popup is active
/// - Popup has expired
/// - User already saw this campaign
final inAppPopupProvider = StreamProvider<InAppPopupData?>((ref) async* {
  final box = Hive.box('nutripump_notifications');
  const seenKey = 'seen_campaigns';

  await for (final snapshot in FirebaseFirestore.instance
      .collection('settings')
      .doc('inAppPopup')
      .snapshots()) {
    // Not published
    if (!snapshot.exists) {
      yield null;
      continue;
    }

    final data = snapshot.data()!;
    final active = data['active'] as bool? ?? false;
    if (!active) {
      yield null;
      continue;
    }

    final popup = InAppPopupData.fromMap(data);

    // Empty campaign means skip
    if (popup.campaignId.isEmpty || popup.title.isEmpty) {
      yield null;
      continue;
    }

    // Expired
    if (popup.expiresAt != null && popup.expiresAt!.isBefore(DateTime.now())) {
      yield null;
      continue;
    }

    // Already seen on this device
    final seenList = List<String>.from(box.get(seenKey, defaultValue: []));
    if (seenList.contains(popup.campaignId)) {
      yield null;
      continue;
    }

    yield popup;
  }
});

/// Call this after the popup has been displayed to prevent it showing again.
void markCampaignSeen(String campaignId) {
  final box = Hive.box('nutripump_notifications');
  const seenKey = 'seen_campaigns';
  final seenList = List<String>.from(box.get(seenKey, defaultValue: []));
  if (!seenList.contains(campaignId)) {
    seenList.add(campaignId);
    box.put(seenKey, seenList);
  }
}
