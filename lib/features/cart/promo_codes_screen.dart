import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/models.dart';
import '../../providers/promo_provider.dart';
import '../../providers/cart_provider.dart';

class PromoCodesScreen extends ConsumerStatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  ConsumerState<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends ConsumerState<PromoCodesScreen> {
  final _codeCtrl = TextEditingController();
  Set<String> _usedCodes = {};
  bool _usedCodesLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchUsedCodes();
  }

  Future<void> _fetchUsedCodes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _usedCodesLoaded = true);
      return;
    }
    try {
      // Single-field query — no composite index required
      final snap = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();
      final codes = snap.docs
          .where((d) => (d.data()['status'] as String? ?? '') != 'cancelled')
          .map((d) => (d.data()['appliedPromoCode'] as String? ?? '').toUpperCase())
          .where((c) => c.isNotEmpty)
          .toSet();
      if (mounted) setState(() { _usedCodes = codes; _usedCodesLoaded = true; });
    } catch (e) {
      if (mounted) setState(() => _usedCodesLoaded = true);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyManualCode(List<PromoCode> available, CartState cart) async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final found = available.where((p) => p.code.toUpperCase() == code).firstOrNull;
    if (found != null) {
      await _applyCode(found, cart);
    } else {
      _showError('Invalid promo code');
    }
  }

  Future<void> _applyCode(PromoCode promo, CartState cart) async {
    try {
      final productIds = cart.items.map((i) => i.product.id).toList();
      if (!promo.isValidFor(cart.subtotal, cart.isFirstOrder, productIds)) {
        if (promo.productId != null && !productIds.contains(promo.productId)) {
          final name = promo.productName ?? 'the required product';
          _showError('This code is exclusively for $name. Please add it to your cart to claim this offer.');
          return;
        }
        if (cart.subtotal < promo.minOrderValue) {
          _showError('Minimum order value of ₹${promo.minOrderValue.toInt()} required for this code.');
          return;
        }
        if (promo.isFirstOrderOnly) {
          _showError('This code is only valid for your first order.');
          return;
        }
        _showError('You do not meet the requirements for this code.');
        return;
      }

      // Use the already-loaded _usedCodes set — no extra Firestore query needed here
      if (promo.oneTimeUsePerUser && _usedCodes.contains(promo.code.toUpperCase())) {
        _showError('You have already availed this promo code in a past order.');
        return;
      }

      ref.read(cartProvider.notifier).applyPromo(promo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'${promo.code}' applied successfully!", style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availablePromosAsync = ref.watch(availablePromosProvider);
    final appliedPromo = ref.watch(cartProvider.select((state) => state.appliedPromo));
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Apply Promo Code', style: AppTypography.h3(context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Manual Code Entry ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [BoxShadow(color: AppColors.deepCharcoal.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Have a promo code?', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeCtrl,
                          textCapitalization: TextCapitalization.characters,
                          style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700),
                          decoration: InputDecoration(
                            hintText: 'Enter code here',
                            hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            filled: true,
                            fillColor: AppColors.backgroundLight,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (availablePromosAsync.hasValue) {
                            await _applyManualCode(availablePromosAsync.value!, cartState);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepCharcoal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Apply', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Available Offers ─────────────────────────────────
            Text('Available Offers', style: AppTypography.h3(context)),
            const SizedBox(height: 16),

            availablePromosAsync.when(
              data: (promos) {
                if (promos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text('No promo codes available right now.', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
                    ),
                  );
                }
                return Column(
                  children: promos.map((promo) {
                    final isApplied = appliedPromo?.code == promo.code;
                    final isAlreadyUsed = _usedCodesLoaded &&
                        promo.oneTimeUsePerUser &&
                        _usedCodes.contains(promo.code.toUpperCase());
                    return _PromoCard(
                      promo: promo,
                      isApplied: isApplied,
                      isAlreadyUsed: isAlreadyUsed,
                      onApply: () => _applyCode(promo, cartState),
                      onRemove: () {
                        ref.read(cartProvider.notifier).removePromo();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Promo code removed', style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, stack) => Center(child: Text('Error loading promos', style: AppTypography.bodySM(context).copyWith(color: AppColors.error))),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final PromoCode promo;
  final bool isApplied;
  final bool isAlreadyUsed;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _PromoCard({
    required this.promo,
    required this.isApplied,
    required this.isAlreadyUsed,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isAlreadyUsed ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isApplied ? AppColors.success.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isApplied ? AppColors.success : AppColors.borderLight,
            width: isApplied ? 2 : 1,
          ),
          boxShadow: [BoxShadow(color: AppColors.deepCharcoal.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (Code & Action) ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAlreadyUsed
                          ? AppColors.neutralGold.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isAlreadyUsed
                            ? AppColors.neutralGold.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer_rounded, size: 14,
                            color: isAlreadyUsed ? AppColors.neutralGold : AppColors.primary),
                        const SizedBox(width: 6),
                        Text(promo.code,
                            style: AppTypography.bodySM(context).copyWith(
                                fontWeight: FontWeight.w800,
                                color: isAlreadyUsed ? AppColors.neutralGold : AppColors.primary)),
                      ],
                    ),
                  ),
                  if (isAlreadyUsed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.neutralGold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.neutralGold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 12, color: AppColors.neutralGold),
                          const SizedBox(width: 4),
                          Text('Already Availed',
                              style: AppTypography.label(context).copyWith(
                                  fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.neutralGold)),
                        ],
                      ),
                    )
                  else if (isApplied)
                    TextButton(
                      onPressed: onRemove,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Remove', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, color: AppColors.error)),
                    )
                  else
                    TextButton(
                      onPressed: onApply,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Apply', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                ],
              ),
            ),

            const Divider(color: AppColors.borderLight, height: 1),

            // ── Details ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(promo.title, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
                  if (promo.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(promo.description, style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, height: 1.4)),
                  ],
                  if (promo.productId != null && promo.productName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.deepCharcoal.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Valid only on ${promo.productName}', style: AppTypography.label(context).copyWith(color: AppColors.deepCharcoal, fontWeight: FontWeight.w600)),
                    ),
                  ]
                ],
              ),
            ),

            // ── Footer (Terms) ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.neutralGold),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Min. order: ₹${promo.minOrderValue.toInt()}${promo.expiresAt != null ? ' | Valid till ${_formatDate(promo.expiresAt!)}' : ''}',
                      style: AppTypography.label(context).copyWith(fontSize: 10, color: AppColors.neutralGold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
