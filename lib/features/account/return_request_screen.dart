import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/order.dart';
import '../../providers/providers.dart';

class ReturnRequestScreen extends ConsumerStatefulWidget {
  final String? preselectedOrderId;
  const ReturnRequestScreen({super.key, this.preselectedOrderId});

  @override
  ConsumerState<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends ConsumerState<ReturnRequestScreen> {
  Order? _selectedOrder;
  String? _selectedReason;
  final _customReasonCtrl = TextEditingController();
  bool _isLoading = false;

  static const _reasons = [
    'Received wrong item',
    'Item is damaged / defective',
    'Item does not match description',
    'Changed my mind',
    'Product expired or near expiry',
    'Other (please describe)',
  ];

  @override
  void dispose() {
    _customReasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReturn() async {
    if (_selectedOrder == null) {
      _showSnack('Please select an order first', isError: true);
      return;
    }
    if (_selectedReason == null) {
      _showSnack('Please select a return reason', isError: true);
      return;
    }
    final reason = _selectedReason == 'Other (please describe)'
        ? _customReasonCtrl.text.trim()
        : _selectedReason!;
    if (reason.isEmpty) {
      _showSnack('Please describe your reason', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(orderServiceProvider).requestReturn(_selectedOrder!.id, reason);
      ref.invalidate(userOrdersProvider(_selectedOrder!.userId));
      if (mounted) {
        _showSnack('Return request submitted! We\'ll review it within 48 hours.');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to submit: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Return & Refund', style: AppTypography.h3(context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Something went wrong')),
        data: (user) {
          if (user == null) return const Center(child: Text('Please sign in'));

          // ── Read admin-configured return window ──────────────────────
          final settingsAsync = ref.watch(storeSettingsProvider);
          final returnDays = settingsAsync.valueOrNull?.returnWindowDays ?? 5;

          final ordersAsync = ref.watch(userOrdersProvider(user.uid));

          return ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Error: $e')),
            data: (dynamic raw) {
              final allOrders = (raw as List).cast<Order>();

              // Only show delivered orders within the admin-configured return window
              // that haven't already had a return requested
              final now = DateTime.now();
              final returnableOrders = allOrders.where((o) {
                if (!o.canReturn) return false;
                final daysSinceDelivery = now.difference(o.updatedAt).inDays;
                return daysSinceDelivery <= returnDays;
              }).toList();

              // Pre-select order from query param
              if (_selectedOrder == null && widget.preselectedOrderId != null) {
                try {
                  final preselected = allOrders.firstWhere(
                    (o) => o.id == widget.preselectedOrderId,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedOrder = preselected);
                  });
                } catch (_) {}
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Policy Banner (dynamic days from admin) ──────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Returns accepted within $returnDays days of delivery. '
                              'Refunds are processed within 5–7 business days after approval.',
                              style: AppTypography.bodySM(context).copyWith(fontSize: 12, height: 1.5, color: AppColors.deepCharcoal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Order Selection ──────────────────────────
                    Text('Select Order', style: AppTypography.h3(context)),
                    const SizedBox(height: 12),

                    if (returnableOrders.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.assignment_return_outlined, size: 40, color: AppColors.neutralGold),
                            const SizedBox(height: 12),
                            Text('No eligible orders', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              'Only delivered orders within the $returnDays-day return window can be returned.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    else
                      ...returnableOrders.map((order) => _OrderSelectionCard(
                        order: order,
                        isSelected: _selectedOrder?.id == order.id,
                        onTap: () => setState(() => _selectedOrder = order),
                      )),

                    if (returnableOrders.isNotEmpty) ...[
                      const SizedBox(height: 24),

                      // ── Return Reason ──────────────────────────
                      Text('Reason for Return', style: AppTypography.h3(context)),
                      const SizedBox(height: 12),

                      ..._reasons.map((reason) => _ReasonTile(
                        reason: reason,
                        isSelected: _selectedReason == reason,
                        onTap: () => setState(() => _selectedReason = reason),
                      )),

                      if (_selectedReason == 'Other (please describe)') ...[
                        const SizedBox(height: 12),
                        Text('Describe your issue', style: AppTypography.label(context).copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _customReasonCtrl,
                          maxLines: 3,
                          style: AppTypography.bodySM(context),
                          decoration: InputDecoration(
                            hintText: 'Tell us more about the issue...',
                            hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // ── Submit Button ──────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isLoading || _selectedOrder == null || _selectedReason == null)
                              ? null
                              : _submitReturn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.deepCharcoal,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deepCharcoal))
                              : Text('Submit Return Request', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Order Selection Card ───────────────────────────────────────────────────
class _OrderSelectionCard extends StatelessWidget {
  final Order order;
  final bool isSelected;
  final VoidCallback onTap;
  const _OrderSelectionCard({required this.order, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [BoxShadow(color: AppColors.deepCharcoal.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: 1.5),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 12, color: AppColors.deepCharcoal)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatOrderId(order.id),
                      style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    order.items.map((i) => i.product.name).where((n) => n.isNotEmpty).take(2).join(', '),
                    style: AppTypography.bodySM(context).copyWith(fontSize: 11, color: AppColors.neutralGold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(formatPrice(order.total),
                style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ── Reason Tile ────────────────────────────────────────────────────────────
class _ReasonTile extends StatelessWidget {
  final String reason;
  final bool isSelected;
  final VoidCallback onTap;
  const _ReasonTile({required this.reason, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: 1.5),
              ),
              child: isSelected ? const Icon(Icons.check_rounded, size: 10, color: AppColors.deepCharcoal) : null,
            ),
            const SizedBox(width: 10),
            Text(reason, style: AppTypography.bodySM(context).copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
