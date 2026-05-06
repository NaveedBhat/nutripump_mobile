import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(milliseconds: 2000), 
      content: Text(msg, style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
      appBar: AppBar(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : Colors.white),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Return & Refund', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
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
                padding: EdgeInsets.all(R.w(context, 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Policy Banner (dynamic days from admin) ──────
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(R.w(context, 16)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(R.w(context, 12)),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, size: R.sp(context, 18), color: AppColors.primary),
                          SizedBox(width: R.w(context, 10)),
                          Expanded(
                            child: Text(
                              'Returns accepted within $returnDays days of delivery. '
                              'Refunds are processed within 5–7 business days after approval.',
                              style: AppTypography.bodySM(context).copyWith(fontSize: R.sp(context, 12), height: 1.5, color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: R.h(context, 24)),

                    // ── Order Selection ──────────────────────────
                    Text('Select Order', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
                    SizedBox(height: R.h(context, 12)),

                    if (returnableOrders.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(R.w(context, 20)),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(R.w(context, 12)),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.assignment_return_outlined, size: R.sp(context, 40), color: AppColors.neutralGold),
                            SizedBox(height: R.h(context, 12)),
                            Text('No eligible orders', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700)),
                            SizedBox(height: R.h(context, 4)),
                            Text(
                              'Only delivered orders within the $returnDays-day return window can be returned.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 12)),
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
                      SizedBox(height: R.h(context, 24)),

                      // ── Return Reason ──────────────────────────
                      Text('Reason for Return', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
                      SizedBox(height: R.h(context, 12)),

                      ..._reasons.map((reason) => _ReasonTile(
                        reason: reason,
                        isSelected: _selectedReason == reason,
                        onTap: () => setState(() => _selectedReason = reason),
                      )),

                      if (_selectedReason == 'Other (please describe)') ...[
                        SizedBox(height: R.h(context, 12)),
                        Text('Describe your issue', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 11))),
                        SizedBox(height: R.h(context, 6)),
                        TextFormField(
                          controller: _customReasonCtrl,
                          maxLines: 3,
                          style: AppTypography.bodySM(context),
                          decoration: InputDecoration(
                            hintText: 'Tell us more about the issue...',
                            hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                            contentPadding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 12)),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 12)), borderSide: const BorderSide(color: AppColors.borderLight)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 12)), borderSide: const BorderSide(color: AppColors.primary)),
                          ),
                        ),
                      ],

                      SizedBox(height: R.h(context, 32)),

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
                            padding: EdgeInsets.symmetric(vertical: R.h(context, 14)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 12))),
                          ),
                          child: _isLoading
                              ? SizedBox(width: R.w(context, 24), height: R.w(context, 24), child: CircularProgressIndicator(strokeWidth: 2, color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)))
                              : Text('Submit Return Request', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 15))),
                        ),
                      ),
                      SizedBox(height: R.h(context, 24)),
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
        margin: EdgeInsets.only(bottom: R.h(context, 10)),
        padding: EdgeInsets.all(R.w(context, 14)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [BoxShadow(color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal).withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: R.w(context, 20),
              height: R.w(context, 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: 1.5),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: R.sp(context, 12), color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal))
                  : null,
            ),
            SizedBox(width: R.w(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatOrderId(order.id),
                      style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 13))),
                  SizedBox(height: R.h(context, 2)),
                  Text(
                    order.items.map((i) => i.product.name).where((n) => n.isNotEmpty).take(2).join(', '),
                    style: AppTypography.bodySM(context).copyWith(fontSize: R.sp(context, 11), color: AppColors.neutralGold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(formatPrice(order.total),
                style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 13))),
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
        margin: EdgeInsets.only(bottom: R.h(context, 8)),
        padding: EdgeInsets.symmetric(horizontal: R.w(context, 14), vertical: R.h(context, 12)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 10)),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: R.w(context, 18),
              height: R.w(context, 18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: 1.5),
              ),
              child: isSelected ? Icon(Icons.check_rounded, size: R.sp(context, 10), color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)) : null,
            ),
            SizedBox(width: R.w(context, 10)),
            Text(reason, style: AppTypography.bodySM(context).copyWith(fontSize: R.sp(context, 13))),
          ],
        ),
      ),
    );
  }
}
