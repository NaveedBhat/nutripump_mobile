// lib/features/home/models/advertisement_banner.dart

class AdvertisementBanner {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? ctaText;
  final String redirectType; // 'product' | 'category' | 'brand' | 'external' | 'custom'
  final String redirectValue;
  final bool isActive;
  final int sortOrder;
  final String platformVisibility; // 'all' | 'mobile' | 'web'

  const AdvertisementBanner({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.ctaText,
    required this.redirectType,
    required this.redirectValue,
    required this.isActive,
    required this.sortOrder,
    required this.platformVisibility,
  });

  factory AdvertisementBanner.fromJson(String id, Map<String, dynamic> json) {
    return AdvertisementBanner(
      id: id,
      title: (json['title'] as String? ?? '').trim(),
      subtitle: json['subtitle'] as String?,
      imageUrl: (json['imageUrl'] as String? ?? ''),
      ctaText: json['ctaText'] as String?,
      redirectType: json['redirectType'] as String? ?? 'product',
      redirectValue: json['redirectValue'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      platformVisibility: json['platformVisibility'] as String? ?? 'all',
    );
  }
}
