import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../models/product.dart';
import '../../providers/providers.dart';
import '../../core/utils/formatters.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Gifting Recommendation Engine (ported from recommendation.ts)
// ─────────────────────────────────────────────────────────────────────────────
List<Product> getGiftingRecommendations(
  List<Product> allProducts, {
  String persona = 'The Luxury Connoisseur',
  String budget = 'Signature',
  int limit = 3,
}) {
  const personaTags = <String, List<String>>{
    'The Health Nut': ['wellness', 'health', 'immunity', 'honey', 'seeds', 'nuts', 'organic'],
    'The Traditionalist': ['heritage', 'traditional', 'kashmiri', 'spices', 'tea', 'kahwa', 'culture'],
    'The Luxury Connoisseur': ['luxury', 'rare', 'saffron', 'reserve', 'artisanal', 'premium', 'exclusive'],
  };

  final targetTags = personaTags[persona] ?? personaTags['The Luxury Connoisseur']!;
  final inStock = allProducts.where((p) => p.inStock).toList();
  if (inStock.isEmpty) return [];

  final sorted = List<Product>.from(inStock)..sort((a, b) => a.price.compareTo(b.price));
  final total = sorted.length;
  final tierSize = (total / 3).ceil().clamp(1, total);

  final petite    = sorted.sublist(0, tierSize);
  final signature = sorted.sublist(tierSize.clamp(0, total), (tierSize * 2).clamp(0, total));
  final grand     = sorted.sublist((tierSize * 2).clamp(0, total));

  var tierPool = budget == 'Petite' ? petite : budget == 'Grand' ? grand : signature;
  if (tierPool.isEmpty) tierPool = sorted;

  // Score within tier by persona affinity
  final scored = tierPool.map((p) {
    double score = 0;
    final pTags = (p.tags).map((t) => t.toLowerCase()).toList();
    final catLower = p.category.toLowerCase();

    for (final tag in targetTags) {
      final tl = tag.toLowerCase();
      if (pTags.contains(tl)) score += 5;
      if (catLower.contains(tl)) score += 3;
      if (p.name.toLowerCase().contains(tl)) score += 2;
    }
    score += p.rating * 0.5;
    if (p.featured) score += 2;
    return (product: p, score: score);
  }).toList()..sort((a, b) => b.score.compareTo(a.score));

  var results = scored.take(limit).map((s) => s.product).toList();

  // Pad with adjacent tier items if needed
  if (results.length < limit) {
    final ids = results.map((p) => p.id).toSet();
    final supplement = inStock.where((p) => !ids.contains(p.id)).take(limit - results.length);
    results = [...results, ...supplement];
  }

  // Apply 15% bundle discount
  return results.map((p) => p.copyWithBundlePrice((p.price * 0.85).floor().toDouble())).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Gift Builder Widget
// ─────────────────────────────────────────────────────────────────────────────
class AIGiftBuilder extends ConsumerStatefulWidget {
  const AIGiftBuilder({super.key});

  @override
  ConsumerState<AIGiftBuilder> createState() => _AIGiftBuilderState();
}

class _AIGiftBuilderState extends ConsumerState<AIGiftBuilder> {
  String _persona = 'The Luxury Connoisseur';
  String _budget = 'Signature';
  final _noteController = TextEditingController();
  bool _isCurating = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _curate() {
    setState(() => _isCurating = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _isCurating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    return productsAsync.when(
      data: (allProducts) {
        final bundle = getGiftingRecommendations(
          allProducts,
          persona: _persona,
          budget: _budget,
        );
        final bundleTotal = bundle.fold<double>(0, (acc, p) => acc + (p.bundlePrice ?? p.price));
        final originalTotal = bundle.fold<double>(0, (acc, p) => acc + p.price);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.card_giftcard_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Build an Artisanal Gift Box', style: AppTypography.h3.copyWith(fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us about the recipient and our intelligence will curate an exquisite Himalayan bundle at a 15% combo concession.',
                style: AppTypography.bodySM.copyWith(color: AppColors.neutralGold, fontSize: 12),
              ),
              const SizedBox(height: 28),

              // ── Step 1: Persona ────────────────────────────────
              _stepLabel('🎨', '1. SELECT PERSONA'),
              const SizedBox(height: 10),
              Column(
                children: [
                  'The Health Nut',
                  'The Traditionalist',
                  'The Luxury Connoisseur',
                ].map((p) {
                  final selected = _persona == p;
                  return GestureDetector(
                    onTap: () { setState(() => _persona = p); _curate(); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.white,
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.borderLight,
                          width: selected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              p,
                              style: AppTypography.bodySM.copyWith(
                                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                color: selected ? AppColors.deepCharcoal : AppColors.neutralGold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (selected) const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Step 2: Scale ──────────────────────────────────
              _stepLabel('💰', '2. SELECT SCALE'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F5),
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: ['Petite', 'Signature', 'Grand'].map((b) {
                    final selected = _budget == b;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () { setState(() => _budget = b); _curate(); },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            border: selected ? Border.all(color: AppColors.borderLight) : null,
                            boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)] : null,
                          ),
                          child: Center(
                            child: Text(
                              b,
                              style: AppTypography.bodySM.copyWith(
                                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                color: selected ? AppColors.deepCharcoal : AppColors.neutralGold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // ── Step 3: Personal Note ──────────────────────────
              _stepLabel('✍️', '3. ADD A PERSONAL NOTE'),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Wishing you a joyous harvest season...',
                  hintStyle: AppTypography.bodySM.copyWith(color: AppColors.neutralGold.withValues(alpha: 0.6), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 28),

              // ── Curated Box Preview ────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.deepCharcoal,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'The $_budget Box',
                            style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _persona,
                            style: AppTypography.label.copyWith(fontSize: 9, color: AppColors.primary, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Product list
                    if (_isCurating)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 28),
                              const SizedBox(height: 12),
                              Text(
                                'Curating your Himalayan assortment...',
                                style: AppTypography.bodySM.copyWith(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...bundle.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 48, height: 48,
                                child: CustomNetworkImage(imageUrl: item.primaryImage, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: AppTypography.bodySM.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(item.category.toUpperCase(), style: AppTypography.label.copyWith(color: Colors.white38, fontSize: 8, letterSpacing: 0.8)),
                                ],
                              ),
                            ),
                            Text(
                              formatPrice(item.bundlePrice ?? item.price),
                              style: AppTypography.priceSM.copyWith(color: AppColors.primary, fontSize: 13),
                            ),
                          ],
                        ),
                      )),

                    if (!_isCurating) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Standard Value', style: AppTypography.bodySM.copyWith(color: Colors.white54, fontSize: 12)),
                          Text(
                            formatPrice(originalTotal),
                            style: AppTypography.bodySM.copyWith(
                              color: Colors.white38,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Curated Combo Total', style: AppTypography.bodySM.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(formatPrice(bundleTotal), style: AppTypography.priceSM.copyWith(color: AppColors.primary, fontSize: 20)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Text('-15%', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: bundle.isNotEmpty ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gift Box added to cart!', style: AppTypography.bodySM.copyWith(color: Colors.white)),
                              backgroundColor: AppColors.deepCharcoal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        } : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: bundle.isNotEmpty ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded, size: 18, color: AppColors.deepCharcoal),
                              const SizedBox(width: 8),
                              Text('Add Curated Box to Cart', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(60), child: CircularProgressIndicator())),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _stepLabel(String emoji, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.neutralGold, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
