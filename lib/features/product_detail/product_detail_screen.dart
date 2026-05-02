import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/providers.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../../models/models.dart';
import '../../core/utils/formatters.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  final String? promoCode;
  const ProductDetailScreen({super.key, required this.slug, this.promoCode});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final PageController _pageController = PageController();
  ProductSize? _selectedSize;
  int _quantity = 1;
  String _activeTab = 'Description';
  bool _fbtChecked = true;

  @override
  void initState() {
    super.initState();
    // ── Deep Link Promo Handler — fetch & apply the real promo ───────────
    if (widget.promoCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyDeepLinkPromo(widget.promoCode!);
      });
    }
  }

  Future<void> _applyDeepLinkPromo(String rawCode) async {
    if (!mounted) return;
    final code = rawCode.toUpperCase();
    try {
      final snap = await FirebaseFirestore.instance
          .collection('promoCodes')
          .doc(code)
          .get();

      if (!mounted) return;

      if (!snap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Promo code "$code" is not valid.',
              style: AppTypography.bodySM(context).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final promo = PromoCode.fromFirestore(snap);

      if (!promo.active ||
          (promo.expiresAt != null && DateTime.now().isAfter(promo.expiresAt!))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Promo code "$code" has expired.',
              style: AppTypography.bodySM(context).copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ref.read(cartProvider.notifier).applyPromo(promo);

      final discountLabel = promo.type == 'percentage'
          ? '${promo.value.toInt()}% off'
          : '₹${promo.value.toInt()} off';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.local_offer_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Promo "$code" applied — $discountLabel!',
                  style: AppTypography.bodySM(context).copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (_) {
      // Network error — silently ignore, the user can apply manually from cart
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productBySlugProvider(widget.slug));

    return Scaffold(
      backgroundColor: Colors.white,
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Product not found')),
            );
          }

          if (_selectedSize == null && product.sizes != null && product.sizes!.isNotEmpty) {
            _selectedSize = product.sizes!.first;
          }

          final displayPrice = _selectedSize?.price ?? product.price;
          final displayCompareAt = _selectedSize?.compareAtPrice ?? product.compareAtPrice;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildSliverAppBar(product),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(product, displayPrice, displayCompareAt),
                          const SizedBox(height: 24),
                          if (product.sizes != null && product.sizes!.isNotEmpty)
                            _buildSizeSelector(product.sizes!),
                          _buildTrustBadges(),
                          _buildTabs(product),
                          _buildFrequentlyBoughtTogether(product),
                          _buildReviewsSection(product),
                          _buildYouMayAlsoLike(product),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildBottomBar(product, displayPrice),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSliverAppBar(Product product) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        // ── Share button ─────────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.ios_share_rounded, size: 20, color: AppColors.deepCharcoal),
            tooltip: 'Share product',
            onPressed: () {
              final url = 'https://nutripump.store/product/${product.slug}';
              SharePlus.instance.share(
                ShareParams(
                  text: '🌿 ${product.name} — Pure Kashmiri Artisanal.\n\nCheck it out on NutriPump: $url',
                  subject: product.name,
                ),
              );
            },
          ),
        ),
        // ── Wishlist button ──────────────────────────────────────────────────
        Consumer(
          builder: (context, ref, _) {
            final wishlist = ref.watch(wishlistProvider);
            final isWishlisted = wishlist.any((p) => p.id == product.id);
            return Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? AppColors.error : AppColors.deepCharcoal,
                  size: 20,
                ),
                onPressed: () {
                  ref.read(wishlistProvider.notifier).toggle(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isWishlisted ? 'Removed from wishlist' : 'Added to wishlist')),
                  );
                },
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: product.images.length,
              itemBuilder: (context, index) {
                return CustomNetworkImage(
                  imageUrl: product.images[index],
                  fit: BoxFit.cover,
                );
              },
            ),
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.25), Colors.transparent],
                ),
              ),
            ),
            if (product.images.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: product.images.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 5,
                    dotWidth: 5,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Product product, double price, double? compareAt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.shortDescription.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Text(
              product.shortDescription.toUpperCase(),
              style: AppTypography.label(context).copyWith(
                color: AppColors.primary,
                letterSpacing: 2.0,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        Text(product.name, style: AppTypography.h1(context).copyWith(fontSize: 26, height: 1.1)),
        const SizedBox(height: 12),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Text(formatPrice(price), style: AppTypography.h2(context).copyWith(fontSize: 24)),
            if (compareAt != null && compareAt > price) ...[
              Text(
                formatPrice(compareAt),
                style: AppTypography.priceStrike(context).copyWith(fontSize: 16, decorationThickness: 2),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${calculateDiscount(compareAt, price)}% OFF',
                  style: AppTypography.label(context).copyWith(
                    color: AppColors.error,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Row(
              children: List.generate(5, (index) => Icon(
                Icons.star,
                size: 14,
                color: index < (product.rating.floor()) ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2),
              )),
            ),
            const SizedBox(width: 6),
            Text(
              '${product.reviewCount} REVIEWS',
              style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: 9, letterSpacing: 1.0, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSelector(List<ProductSize> sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SELECT JAR SIZE', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, letterSpacing: 1.5, fontSize: 10)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('SMALL BATCH FRESH', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontSize: 8)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: sizes.length,
          itemBuilder: (context, idx) {
            final size = sizes[idx];
            final isSelected = _selectedSize?.label == size.label;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      size.label,
                      style: AppTypography.bodySM(context).copyWith(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? AppColors.deepCharcoal : AppColors.neutralGold, fontSize: 12),
                    ),
                    Text(
                      formatPrice(size.price),
                      style: AppTypography.label(context).copyWith(fontWeight: FontWeight.w800, color: isSelected ? AppColors.primary : AppColors.neutralGold, fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrustBadges() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PURITY GUARANTEED', style: AppTypography.label(context).copyWith(fontSize: 7, letterSpacing: 1.0)),
                        const SizedBox(height: 2),
                        Text('100% Cold-Pressed', style: AppTypography.bodySM(context).copyWith(fontSize: 9, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.verified_outlined, color: AppColors.primary, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FROM SRINAGAR', style: AppTypography.label(context).copyWith(fontSize: 7, letterSpacing: 1.0)),
                        const SizedBox(height: 2),
                        Text('Arrives in 3-5 Days', style: AppTypography.bodySM(context).copyWith(fontSize: 9, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Product product) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Description', 'Ingredients', 'Nutrition'].map((tab) {
                final isActive = _activeTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: Container(
                    margin: const EdgeInsets.only(right: 24),
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isActive ? AppColors.primary : Colors.transparent, width: 2)),
                    ),
                    child: Text(
                      tab.toUpperCase(),
                      style: AppTypography.label(context).copyWith(
                        color: isActive ? AppColors.primary : AppColors.neutralGold,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildTabContent(product, key: ValueKey(_activeTab)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(Product product, {Key? key}) {
    if (_activeTab == 'Description') {
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deeply Sourced & Crafted', style: AppTypography.h3(context).copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          Text(product.description, style: AppTypography.bodySM(context).copyWith(height: 1.6, color: AppColors.neutralGold, fontSize: 13)),
        ],
      );
    } else if (_activeTab == 'Ingredients') {
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What\'s Inside', style: AppTypography.h3(context).copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text('100% Transparent. No hidden preservatives.', style: AppTypography.bodySM(context).copyWith(fontStyle: FontStyle.italic, color: AppColors.neutralGold, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    product.ingredients ?? 'Crafted with 100% natural ingredients. Check packaging for specific list.',
                    style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w600, height: 1.5, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nutrition per 100g', style: AppTypography.h3(context).copyWith(fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(100)),
                child: Text('VERIFIED', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontSize: 7, letterSpacing: 1.5)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _buildNutritionCard('Calories', product.calories ?? '654', 'kcal'),
              _buildNutritionCard('Total Fat', product.fat ?? '65g', '9g Omega-3'),
              _buildNutritionCard('Protein', product.protein ?? '15g', 'per 100g'),
              _buildNutritionCard('Carbs', product.carbs ?? '14g', '2g sugar'),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildNutritionCard(String label, String value, String sub) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: AppTypography.h2(context).copyWith(fontSize: 20, color: const Color(0xFF1B3B36))),
          const SizedBox(height: 2),
          Text(label.toUpperCase(), style: AppTypography.label(context).copyWith(fontSize: 8, letterSpacing: 1.0, color: const Color(0xFF1B3B36).withValues(alpha: 0.7))),
          const SizedBox(height: 2),
          Text(sub, style: AppTypography.label(context).copyWith(fontSize: 7, color: const Color(0xFF1B3B36).withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool value) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: value ? AppColors.primary : Colors.white,
        border: Border.all(color: value ? AppColors.primary : AppColors.borderLight, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: value ? const Icon(Icons.check, color: AppColors.deepCharcoal, size: 14) : null,
    );
  }

  bool _fbtThisItem = true;

  Widget _buildFrequentlyBoughtTogether(Product product) {
    final relatedAsync = ref.watch(allProductsProvider);
    return relatedAsync.when(
      data: (allProducts) {
        final related = allProducts.where((p) => p.id != product.id).take(2).toList();
        if (related.isEmpty) return const SizedBox.shrink();

        final fbtProduct = related.first;
        final discountedFbtPrice = fbtProduct.price * 0.9;

        double totalPrice = 0;
        if (_fbtThisItem) totalPrice += product.price;
        if (_fbtChecked) totalPrice += discountedFbtPrice;

        int itemCount = (_fbtThisItem ? 1 : 0) + (_fbtChecked ? 1 : 0);

        return Container(
          margin: const EdgeInsets.only(top: 32),
          padding: const EdgeInsets.only(top: 32),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Frequently Bought Together', style: AppTypography.h2(context).copyWith(fontSize: 20)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    // Product image strip
                    Row(
                      children: [
                        AnimatedOpacity(
                          opacity: _fbtThisItem ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 200),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomNetworkImage(imageUrl: product.images.first, width: 64, height: 64, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: AppColors.neutralGold, size: 16),
                        ),
                        const SizedBox(width: 10),
                        AnimatedOpacity(
                          opacity: _fbtChecked ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 200),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomNetworkImage(imageUrl: fbtProduct.images.first, width: 64, height: 64, fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 12),
                    // This item row
                    GestureDetector(
                      onTap: () => setState(() => _fbtThisItem = !_fbtThisItem),
                      child: Row(
                        children: [
                          _buildCheckbox(_fbtThisItem),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: Text(product.name, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: 12), overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 8),
                                Text(formatPrice(product.price), style: AppTypography.label(context).copyWith(color: const Color(0xFF1A7A42), fontWeight: FontWeight.w800, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // FBT product row
                    GestureDetector(
                      onTap: () => setState(() => _fbtChecked = !_fbtChecked),
                      child: Row(
                        children: [
                          _buildCheckbox(_fbtChecked),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: Text(fbtProduct.name, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w600, fontSize: 12), overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    Text(formatPrice(discountedFbtPrice), style: AppTypography.label(context).copyWith(color: const Color(0xFF1A7A42), fontWeight: FontWeight.w800, fontSize: 11)),
                                    const SizedBox(width: 4),
                                    Text(formatPrice(fbtProduct.price), style: AppTypography.priceStrike(context).copyWith(fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: 9, letterSpacing: 2.0)),
                        Text(itemCount == 0 ? '—' : formatPrice(totalPrice), style: AppTypography.h3(context).copyWith(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: itemCount == 0 ? AppColors.borderLight : AppColors.primary,
                          foregroundColor: AppColors.deepCharcoal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: itemCount == 0 ? null : () {
                          if (_fbtThisItem) ref.read(cartProvider.notifier).addItem(product, qty: 1);
                          if (_fbtChecked) ref.read(cartProvider.notifier).addItem(fbtProduct, qty: 1, bundlePrice: discountedFbtPrice);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$itemCount item${itemCount == 1 ? '' : 's'} added to cart')));
                        },
                        child: Text(
                          itemCount == 0 ? 'Select at least one item' : 'Add $itemCount Item${itemCount == 1 ? '' : 's'} to Cart',
                          style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),

      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildReviewsSection(Product product) {
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.only(top: 32),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What people are saying', style: AppTypography.h2(context).copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.star, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.rating > 0 ? product.rating.toStringAsFixed(1) : '—',
                    style: AppTypography.h2(context).copyWith(fontSize: 24),
                  ),
                  Text(
                    '${product.reviewCount} Global Ratings',
                    style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer Reviews', style: AppTypography.h2(context).copyWith(fontSize: 18)),
              GestureDetector(
                onTap: () => _showReviewBottomSheet(context, product),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.deepCharcoal,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('Write a Review', style: AppTypography.label(context).copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          reviewsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
            data: (reviews) {
              if (reviews.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.rate_review_outlined, size: 32, color: AppColors.neutralGold),
                      const SizedBox(height: 12),
                      Text('No reviews yet', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Be the first to review this product!', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 12)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final displayName = review.isAnonymous ? 'Anonymous' : (review.userName ?? 'Customer');
    final ago = _timeAgo(review.createdAt);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(5, (index) => Icon(
                  index < review.rating.floor() ? Icons.star : Icons.star_border,
                  color: AppColors.primary,
                  size: 12,
                )),
              ),
              if (review.verified) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFE6F4EA), borderRadius: BorderRadius.circular(100)),
                  child: Text('Verified', style: AppTypography.label(context).copyWith(color: const Color(0xFF137333), fontSize: 8)),
                ),
              ],
              const Spacer(),
              Text(ago, style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 8),
          if (review.title.isNotEmpty)
            Text(review.title, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: 12)),
          if (review.title.isNotEmpty) const SizedBox(height: 4),
          Text(review.body, style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 12, height: 1.4)),
          const SizedBox(height: 8),
          Text('— $displayName', style: AppTypography.label(context).copyWith(color: AppColors.deepCharcoal, fontSize: 10)),
          if (review.adminReply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NutriPump Team', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(review.adminReply!, style: AppTypography.bodySM(context).copyWith(fontSize: 11, height: 1.4)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  void _showReviewBottomSheet(BuildContext context, Product product) {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to write a review')),
      );
      context.push('/auth/login');
      return;
    }

    int rating = 5;
    bool isAnonymous = false;
    bool isSubmitting = false;
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Write a Review', style: AppTypography.h2(context).copyWith(fontSize: 22)),
                const SizedBox(height: 24),
                Text('Your Rating', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: 10, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setModalState(() => rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Text('Review Title', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: 10, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'Sum up your experience',
                    hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderLight)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderLight)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Review Details', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: 10, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'What did you love about it?',
                    hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderLight)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderLight)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setModalState(() => isAnonymous = !isAnonymous),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isAnonymous ? AppColors.primary : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: isAnonymous ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Post Anonymously', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.deepCharcoal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: isSubmitting ? null : () async {
                      final title = titleCtrl.text.trim();
                      final body = bodyCtrl.text.trim();
                      if (title.isEmpty || body.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
                        return;
                      }
                      setModalState(() => isSubmitting = true);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref.read(reviewServiceProvider).addReview(
                          productId: product.id,
                          userId: user.uid,
                          userName: user.displayName ?? 'Customer',
                          rating: rating.toDouble(),
                          title: title,
                          body: body,
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (mounted) {
                          ref.invalidate(productReviewsProvider(product.id));
                          messenger.showSnackBar(const SnackBar(content: Text('Review submitted! Thank you.')));
                        }
                      } catch (e) {
                        setModalState(() => isSubmitting = false);
                        if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Failed to submit review. Please try again.')));
                      }
                    },
                    child: isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deepCharcoal))
                        : Text('Submit Review', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYouMayAlsoLike(Product product) {
    final productsAsync = ref.watch(allProductsProvider);
    
    return productsAsync.when(
      data: (products) {
        final related = products.where((p) => p.id != product.id).toList();
        if (related.isEmpty) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.only(top: 32),
          padding: const EdgeInsets.only(top: 32),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You May Also Like', style: AppTypography.h2(context).copyWith(fontSize: 20)),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: related.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 160,
                      child: ProductCard(product: related[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBottomBar(Product product, double price) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.borderLight)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), offset: const Offset(0, -5), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: () => setState(() { if (_quantity > 1) _quantity--; }),
                    color: AppColors.neutralGold,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  Text('$_quantity', style: AppTypography.h3(context).copyWith(fontSize: 14)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: _quantity < product.stockCount
                        ? () => setState(() { _quantity++; })
                        : null,
                    color: _quantity < product.stockCount
                        ? AppColors.neutralGold
                        : AppColors.borderLight,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).addItem(
                    product,
                    qty: _quantity,
                    weight: _selectedSize?.label ?? product.weight,
                    bundlePrice: _selectedSize?.price ?? product.price,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added to cart'),
                      action: SnackBarAction(label: 'VIEW CART', onPressed: () => context.push('/cart')),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.deepCharcoal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text('Add to Bag — ${formatPrice(price * _quantity)}', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
