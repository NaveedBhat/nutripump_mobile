import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../../providers/providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String id;
  const OrderDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(id));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Order Details', style: AppTypography.h3),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
        data: (dynamic rawOrder) {
          if (rawOrder == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: AppColors.neutralGold),
                  const SizedBox(height: 12),
                  Text('Order not found', style: AppTypography.h3),
                ],
              ),
            );
          }
          final order = rawOrder as Order;
          return _OrderDetailBody(order: order);
        },
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  final Order order;
  const _OrderDetailBody({required this.order});

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCancelled = order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.refunded;
    final currentIndex = isCancelled ? -1 : _steps.indexOf(order.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Order Header Card ─────────────────────────────────
          _SectionCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatOrderId(order.id),
                          style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        'Placed on ${_formatDate(order.createdAt)}',
                        style: AppTypography.bodySM.copyWith(color: AppColors.neutralGold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
          ),
          
          // Cancellation countdown label
          if (order.canCancel && _isWithinWindow(order.createdAt, ref.watch(storeSettingsProvider).valueOrNull?.cancellationWindowHours ?? 24))
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 4),
              child: _TimeRemainingLabel(
                icon: Icons.access_time_rounded,
                text: _getCancelWithinText(order.createdAt, ref.watch(storeSettingsProvider).valueOrNull?.cancellationWindowHours ?? 24),
                color: Colors.amber.shade700,
              ),
            ),

          // Return countdown label
          if (order.status == OrderStatus.delivered && order.canReturn && _isWithinReturnWindow(order.updatedAt, ref.watch(storeSettingsProvider).valueOrNull?.returnWindowDays ?? 5))
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 4),
              child: _TimeRemainingLabel(
                icon: Icons.access_time_rounded,
                text: _getReturnWithinText(order.updatedAt, ref.watch(storeSettingsProvider).valueOrNull?.returnWindowDays ?? 5),
                color: Colors.amber.shade700,
              ),
            ),

          const SizedBox(height: 16),

          // ── Tracking Timeline ─────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Progress', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 20),
                if (isCancelled)
                  _CancelledBanner(order: order)
                else
                  _TrackingTimeline(currentIndex: currentIndex, steps: _steps, order: order),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Tracking Number ───────────────────────────────────
          if (order.trackingNumber != null) ...[
            _SectionCard(
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tracking Number', style: AppTypography.label.copyWith(fontSize: 10)),
                        const SizedBox(height: 2),
                        Text(order.trackingNumber!, style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Items ─────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items Ordered', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 12),
                ...order.items.map((item) => _ItemRow(item: item)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Price Summary ─────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price Breakdown', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 12),
                _PriceRow(label: 'Subtotal', value: formatPrice(order.subtotal)),
                _PriceRow(label: 'GST (${order.subtotal > 0 ? (order.gst / order.subtotal * 100).round() : 0}%)', value: formatPrice(order.gst)),
                _PriceRow(label: 'Shipping', value: order.shipping == 0 ? 'Free' : formatPrice(order.shipping)),
                if (order.discount != null && order.discount! > 0)
                  _PriceRow(label: 'Discount (${order.appliedPromoCode ?? ""})', value: '− ${formatPrice(order.discount!)}', isDiscount: true),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: AppColors.borderLight),
                ),
                _PriceRow(label: 'Total', value: formatPrice(order.total), isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Delivery Address ──────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Address', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.location_on_outlined, size: 18, color: AppColors.neutralGold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.address.fullName,
                              style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(order.address.phone,
                              style: AppTypography.bodySM.copyWith(fontSize: 12, color: AppColors.neutralGold)),
                          const SizedBox(height: 4),
                          Text(order.address.oneLineAddress,
                              style: AppTypography.bodySM.copyWith(fontSize: 12, color: AppColors.neutralGold, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Return Status ─────────────────────────────────────
          if (order.returnStatus != ReturnStatus.none)
            _SectionCard(
              child: _ReturnStatusCard(order: order),
            ),

          // ── Actions ───────────────────────────────────────────
          if (order.status == OrderStatus.delivered) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/shop'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepCharcoal,
                      side: BorderSide(color: AppColors.neutralGold.withValues(alpha: 0.3)),
                      backgroundColor: AppColors.neutralGold.withValues(alpha: 0.05),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text('Buy Again', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700, fontSize: 10)),
                  ),
                ),
                if (order.canReturn) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push('/account/returns?orderId=${order.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.deepCharcoal,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text('Return Item', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700, fontSize: 10)),
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/contact'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepCharcoal,
                      side: BorderSide(color: AppColors.neutralGold.withValues(alpha: 0.3)),
                      backgroundColor: AppColors.neutralGold.withValues(alpha: 0.05),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text('Contact', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700, fontSize: 10)),
                  ),
                ),
                if (order.canCancel) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(context, ref, order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        backgroundColor: Colors.red.withValues(alpha: 0.05),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text('Cancel', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700, color: Colors.red, fontSize: 10)),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, Order order) {
    showDialog(
      context: context,
      builder: (ctx) => _CancelOrderDialog(order: order),
    );
  }

  String _getCancelWithinText(DateTime createdAt, int cancelHours) {
    final windowMs = cancelHours * 60 * 60 * 1000;
    final expiresAt = createdAt.millisecondsSinceEpoch + windowMs;
    final remainingMs = expiresAt - DateTime.now().millisecondsSinceEpoch;
    if (remainingMs <= 0) return 'Cancellation window expired';
    final remainHrs = remainingMs ~/ (1000 * 60 * 60);
    final remainMins = (remainingMs % (1000 * 60 * 60)) ~/ (1000 * 60);
    return remainHrs > 0 ? 'Cancel within ${remainHrs}h ${remainMins}m' : 'Cancel within ${remainMins}m';
  }

  String _getReturnWithinText(DateTime updatedAt, int returnDays) {
    final windowMs = returnDays * 24 * 60 * 60 * 1000;
    final expiresAt = updatedAt.millisecondsSinceEpoch + windowMs;
    final remainingMs = expiresAt - DateTime.now().millisecondsSinceEpoch;
    if (remainingMs <= 0) return 'Return window expired';
    final remainDays = remainingMs ~/ (1000 * 60 * 60 * 24);
    final remainHrs = (remainingMs % (1000 * 60 * 60 * 24)) ~/ (1000 * 60 * 60);
    if (remainDays > 0) return 'Return within ${remainDays}d ${remainHrs}h';
    if (remainHrs > 0) return 'Return window closes in ${remainHrs}h';
    return 'Return window closing soon';
  }

  bool _isWithinWindow(DateTime date, int hours) {
    return DateTime.now().difference(date).inHours < hours;
  }

  bool _isWithinReturnWindow(DateTime date, int days) {
    return DateTime.now().difference(date).inDays < days;
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _TimeRemainingLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _TimeRemainingLabel({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.bodySM.copyWith(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Tracking Timeline ──────────────────────────────────────────────────────
class _TrackingTimeline extends StatelessWidget {
  final int currentIndex;
  final List<OrderStatus> steps;
  final Order order;
  const _TrackingTimeline({required this.currentIndex, required this.steps, required this.order});

  static const _labels = ['Order Placed', 'Confirmed', 'Processing', 'Shipped', 'Delivered'];
  static const _icons = [
    Icons.receipt_outlined,
    Icons.check_circle_outline,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.home_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final isDone = i <= currentIndex;
        final isActive = i == currentIndex;
        final isLast = i == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? (isActive ? AppColors.primary : AppColors.primary.withValues(alpha: 0.7))
                            : Colors.white,
                        border: Border.all(
                          color: isDone ? AppColors.primary : AppColors.borderLight,
                          width: isActive ? 2.5 : 1.5,
                        ),
                      ),
                      child: Icon(
                        _icons[i],
                        size: 16,
                        color: isDone ? AppColors.deepCharcoal : AppColors.neutralGold,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: isDone ? AppColors.primary.withValues(alpha: 0.4) : AppColors.borderLight,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Label
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        _labels[i],
                        style: AppTypography.bodySM.copyWith(
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                          color: isDone ? AppColors.deepCharcoal : AppColors.neutralGold,
                        ),
                      ),
                      if (isActive && order.status == OrderStatus.shipped && order.trackingNumber != null) ...[
                        const SizedBox(height: 2),
                        Text('AWB: ${order.trackingNumber}',
                            style: AppTypography.bodySM.copyWith(fontSize: 11, color: AppColors.neutralGold)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────
class _CancelledBanner extends StatelessWidget {
  final Order order;
  const _CancelledBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined, size: 20, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Cancelled', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w800, color: AppColors.error)),
                if (order.cancellationReason != null) ...[
                  const SizedBox(height: 4),
                  Text('Reason: ${order.cancellationReason}',
                      style: AppTypography.bodySM.copyWith(fontSize: 12, color: AppColors.neutralGold)),
                ],
                if (order.cancelledBy != null) ...[
                  const SizedBox(height: 2),
                  Text('Cancelled by: ${order.cancelledBy}',
                      style: AppTypography.bodySM.copyWith(fontSize: 11, color: AppColors.neutralGold)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReturnStatusCard extends StatelessWidget {
  final Order order;
  const _ReturnStatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (order.returnStatus) {
      ReturnStatus.requested => (Colors.orange, Icons.pending_outlined, 'Return Requested'),
      ReturnStatus.approved  => (AppColors.success, Icons.check_circle_outline, 'Return Approved'),
      ReturnStatus.rejected  => (AppColors.error, Icons.cancel_outlined, 'Return Rejected'),
      ReturnStatus.refunded  => (AppColors.success, Icons.currency_rupee_rounded, 'Refunded'),
      ReturnStatus.none      => (AppColors.neutralGold, Icons.info_outline, ''),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w800, color: color, fontSize: 14)),
              if (order.returnReason != null) ...[
                const SizedBox(height: 4),
                Text('Reason: ${order.returnReason}',
                    style: AppTypography.bodySM.copyWith(fontSize: 12, color: AppColors.neutralGold)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, text) = switch (status) {
      OrderStatus.pending    => (Colors.orange.shade50, Colors.orange.shade700),
      OrderStatus.confirmed  => (Colors.blue.shade50, Colors.blue.shade700),
      OrderStatus.processing => (Colors.purple.shade50, Colors.purple.shade700),
      OrderStatus.shipped    => (Colors.indigo.shade50, Colors.indigo.shade700),
      OrderStatus.delivered  => (AppColors.success.withValues(alpha: 0.1), AppColors.success),
      OrderStatus.cancelled  => (AppColors.error.withValues(alpha: 0.08), AppColors.error),
      OrderStatus.refunded   => (Colors.teal.shade50, Colors.teal.shade700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: AppTypography.label.copyWith(fontSize: 10, color: text)),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: AppColors.deepCharcoal.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CartItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.product.primaryImage.isNotEmpty
                ? Image.network(item.product.primaryImage, width: 52, height: 52, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                    () {
                      final w = (item.selectedWeight?.isNotEmpty == true
                          ? item.selectedWeight!
                          : item.product.weight.isNotEmpty
                              ? item.product.weight
                              : null);
                      return w != null ? '$w · Qty: ${item.quantity}' : 'Qty: ${item.quantity}';
                    }(),
                    style: AppTypography.bodySM.copyWith(fontSize: 12, color: AppColors.neutralGold)),
              ],
            ),
          ),
          Text(formatPrice(item.effectivePrice * item.quantity),
              style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 52, height: 52,
    color: AppColors.backgroundLight,
    child: const Icon(Icons.image_outlined, size: 24, color: AppColors.neutralGold),
  );
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isDiscount;
  const _PriceRow({required this.label, required this.value, this.isBold = false, this.isDiscount = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySM.copyWith(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.normal,
            color: isBold ? AppColors.deepCharcoal : AppColors.neutralGold,
          )),
          Text(value, style: AppTypography.bodySM.copyWith(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isDiscount ? AppColors.success : AppColors.deepCharcoal,
          )),
        ],
      ),
    );
  }
}

class _CancelOrderDialog extends ConsumerStatefulWidget {
  final Order order;
  const _CancelOrderDialog({required this.order});

  @override
  ConsumerState<_CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends ConsumerState<_CancelOrderDialog> {
  bool _isLoading = false;

  Future<void> _handleCancel() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(orderServiceProvider);
      await service.cancelOrder(widget.order.id, 'User cancelled from mobile app');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cancel Order?', style: AppTypography.h3),
      content: Text(
        'Are you sure you want to cancel order ${formatOrderId(widget.order.id)}? This action cannot be undone.',
        style: AppTypography.bodySM,
      ),
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.deepCharcoal,
            side: const BorderSide(color: AppColors.borderLight),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Keep Order', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 36),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Confirm Cancel', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ],
    );
  }
}
