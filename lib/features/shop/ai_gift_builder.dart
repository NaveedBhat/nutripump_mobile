import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../models/product.dart';
import '../../providers/providers.dart';
import '../../core/utils/formatters.dart';

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
  if (results.length < limit) {
    final ids = results.map((p) => p.id).toSet();
    final supplement = inStock.where((p) => !ids.contains(p.id)).take(limit - results.length);
    results = [...results, ...supplement];
  }
  return results.map((p) => p.copyWithBundlePrice((p.price * 0.85).floor().toDouble())).toList();
}

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
        final bundle = getGiftingRecommendations(allProducts, persona: _persona, budget: _budget);
        final bundleTotal = bundle.fold<double>(0, (acc, p) => acc + (p.bundlePrice ?? p.price));
        final originalTotal = bundle.fold<double>(0, (acc, p) => acc + p.price);

        return SingleChildScrollView(
          padding: EdgeInsets.all(R.w(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.card_giftcard_rounded, color: AppColors.primary, size: R.sp(context, 22)),
                  SizedBox(width: R.w(context, 10)),
                  Expanded(
                    child: Text('Build an Artisanal Gift Box', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 18))),
                  ),
                ],
              ),
              SizedBox(height: R.h(context, 8)),
              Text(
                'Tell us about the recipient and our intelligence will curate an exquisite Himalayan bundle at a 15% combo concession.',
                style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 12)),
              ),
              SizedBox(height: R.h(context, 28)),

              _stepLabel('🎨', '1. SELECT PERSONA'),
              SizedBox(height: R.h(context, 10)),
              Column(
                children: ['The Health Nut', 'The Traditionalist', 'The Luxury Connoisseur'].map((p) {
                  final selected = _persona == p;
                  return GestureDetector(
                    onTap: () { setState(() => _persona = p); _curate(); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: R.h(context, 10)),
                      padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 13)),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.white,
                        border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight, width: selected ? 1.5 : 1),
                        borderRadius: BorderRadius.circular(R.w(context, 12)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(p, style: AppTypography.bodySM(context).copyWith(
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              color: selected ? AppColors.deepCharcoal : AppColors.neutralGold,
                              fontSize: R.sp(context, 13),
                            )),
                          ),
                          if (selected) Icon(Icons.check_circle_rounded, size: R.sp(context, 18), color: AppColors.primary),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: R.h(context, 24)),

              _stepLabel('💰', '2. SELECT SCALE'),
              SizedBox(height: R.h(context, 10)),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F5),
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(R.w(context, 12)),
                ),
                padding: EdgeInsets.all(R.w(context, 4)),
                child: Row(
                  children: ['Petite', 'Signature', 'Grand'].map((b) {
                    final selected = _budget == b;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () { setState(() => _budget = b); _curate(); },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: R.h(context, 10)),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(R.w(context, 9)),
                            border: selected ? Border.all(color: AppColors.borderLight) : null,
                            boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)] : null,
                          ),
                          child: Center(
                            child: Text(b, style: AppTypography.bodySM(context).copyWith(
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              color: selected ? AppColors.deepCharcoal : AppColors.neutralGold,
                              fontSize: R.sp(context, 12),
                            )),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: R.h(context, 24)),

              _stepLabel('✍️', '3. ADD A PERSONAL NOTE'),
              SizedBox(height: R.h(context, 10)),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Wishing you a joyous harvest season...',
                  hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.6), fontSize: R.sp(context, 12)),
                  filled: true,
                  fillColor: const Color(0xFFF8F8F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 12)), borderSide: const BorderSide(color: AppColors.borderLight)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 12)), borderSide: const BorderSide(color: AppColors.borderLight)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 12)), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  contentPadding: EdgeInsets.all(R.w(context, 14)),
                ),
              ),
              SizedBox(height: R.h(context, 28)),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.deepCharcoal,
                  borderRadius: BorderRadius.circular(R.w(context, 20)),
                ),
                padding: EdgeInsets.all(R.w(context, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('The $_budget Box', style: AppTypography.h3(context).copyWith(color: Colors.white, fontSize: R.sp(context, 18))),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: R.w(context, 10), vertical: R.h(context, 5)),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(R.w(context, 8)),
                          ),
                          child: Text(_persona, style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 9), color: AppColors.primary, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(context, 16)),

                    if (_isCurating)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: R.h(context, 24)),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: R.sp(context, 28)),
                              SizedBox(height: R.h(context, 12)),
                              Text('Curating your Himalayan assortment...', style: AppTypography.bodySM(context).copyWith(color: Colors.white70, fontSize: R.sp(context, 12))),
                            ],
                          ),
                        ),
                      )
                    else
                      ...bundle.map((item) => Container(
                        margin: EdgeInsets.only(bottom: R.h(context, 10)),
                        padding: EdgeInsets.all(R.w(context, 10)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(R.w(context, 12)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(R.w(context, 8)),
                              child: SizedBox(
                                width: R.w(context, 48), height: R.w(context, 48),
                                child: CustomNetworkImage(imageUrl: item.primaryImage, fit: BoxFit.cover),
                              ),
                            ),
                            SizedBox(width: R.w(context, 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: AppTypography.bodySM(context).copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: R.sp(context, 12)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  SizedBox(height: R.h(context, 2)),
                                  Text(item.category.toUpperCase(), style: AppTypography.label(context).copyWith(color: Colors.white38, fontSize: R.sp(context, 8), letterSpacing: 0.8)),
                                ],
                              ),
                            ),
                            Text(formatPrice(item.bundlePrice ?? item.price), style: AppTypography.priceSM(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 13))),
                          ],
                        ),
                      )),

                    if (!_isCurating) ...[
                      SizedBox(height: R.h(context, 12)),
                      const Divider(color: Colors.white12),
                      SizedBox(height: R.h(context, 12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Standard Value', style: AppTypography.bodySM(context).copyWith(color: Colors.white54, fontSize: R.sp(context, 12))),
                          Text(formatPrice(originalTotal), style: AppTypography.bodySM(context).copyWith(color: Colors.white38, fontSize: R.sp(context, 12), decoration: TextDecoration.lineThrough)),
                        ],
                      ),
                      SizedBox(height: R.h(context, 6)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Curated Combo Total', style: AppTypography.bodySM(context).copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: R.sp(context, 13))),
                          Row(
                            children: [
                              Text(formatPrice(bundleTotal), style: AppTypography.priceSM(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 20))),
                              SizedBox(width: R.w(context, 6)),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: R.w(context, 6), vertical: R.h(context, 2)),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(R.w(context, 5)),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Text('-15%', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 9), fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: R.h(context, 16)),
                      GestureDetector(
                        onTap: bundle.isNotEmpty ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gift Box added to cart!', style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
                              backgroundColor: AppColors.deepCharcoal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 10))),
                            ),
                          );
                        } : null,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
                          decoration: BoxDecoration(
                            color: bundle.isNotEmpty ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(R.w(context, 14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, size: R.sp(context, 18), color: AppColors.deepCharcoal),
                              SizedBox(width: R.w(context, 8)),
                              Text('Add Curated Box to Cart', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 14))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: R.h(context, 20)),
            ],
          ),
        );
      },
      loading: () => Center(child: Padding(padding: EdgeInsets.all(R.w(context, 60)), child: const CircularProgressIndicator())),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _stepLabel(String emoji, String label) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: R.sp(context, 14))),
        SizedBox(width: R.w(context, 8)),
        Text(label, style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10), color: AppColors.neutralGold, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
