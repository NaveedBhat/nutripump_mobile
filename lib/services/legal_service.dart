import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/legal/legal_defaults.dart';

class LegalItem {
  final String subtitle;
  final String text;

  LegalItem({required this.subtitle, required this.text});

  factory LegalItem.fromMap(Map<String, dynamic> map) {
    return LegalItem(
      subtitle: map['subtitle'] ?? '',
      text: map['text'] ?? '',
    );
  }
}

class LegalSection {
  final String icon;
  final String title;
  final List<LegalItem> items;

  LegalSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  factory LegalSection.fromMap(Map<String, dynamic> map) {
    return LegalSection(
      icon: map['icon'] ?? 'shield',
      title: map['title'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => LegalItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LegalPage {
  final String title;
  final String intro;
  final DateTime? lastUpdated;
  final List<LegalSection> sections;

  LegalPage({
    required this.title,
    required this.intro,
    this.lastUpdated,
    required this.sections,
  });

  factory LegalPage.fromMap(Map<String, dynamic> map) {
    return LegalPage(
      title: map['title'] ?? '',
      intro: map['intro'] ?? '',
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
      sections: (map['sections'] as List<dynamic>?)
              ?.map((sec) => LegalSection.fromMap(sec as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LegalService {
  final FirebaseFirestore _firestore;

  LegalService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<LegalPage?> getLegalPage(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection('legal_pages').doc(id).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return LegalPage.fromMap(docSnapshot.data()!);
      }
      return id == 'privacy_policy' ? defaultPrivacyPage : defaultTermsPage;
    } catch (e) {
      debugPrint('Error fetching legal page $id: $e');
      return id == 'privacy_policy' ? defaultPrivacyPage : defaultTermsPage;
    }
  }
}
