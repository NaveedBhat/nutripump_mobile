import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';
import '../../models/order.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
      appBar: AppBar(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : Colors.white),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: R.sp(context, 16)),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text('My Orders', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Something went wrong')),
        data: (user) {
          if (user == null) {
            return Center(
              child: Text('Please sign in to view your orders.',
                  style: AppTypography.bodySM(context)),
            );
          }

          final ordersAsync = ref.watch(userOrdersProvider(user.uid));

          return ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Error loading orders: $e')),
            data: (dynamicOrders) {
              // provider currently returns List<dynamic> from StreamProvider.family
              // but order_service.dart returns List<Order>
              final List<Order> orders = dynamicOrders.cast<Order>();

              if (orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.w(context, 40)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: R.w(context, 76),
                          height: R.w(context, 76),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                width: 1.5),
                          ),
                          child: Icon(Icons.inventory_2_outlined,
                              size: R.sp(context, 32), color: AppColors.primary),
                        ),
                        SizedBox(height: R.h(context, 20)),
                        Text('No orders yet',
                            style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 18))),
                        SizedBox(height: R.h(context, 8)),
                        Text(
                          'Your artisanal pantry awaits.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySM(context).copyWith(
                            color: AppColors.neutralGold,
                            height: 1.6,
                            fontSize: R.sp(context, 13),
                          ),
                        ),
                        SizedBox(height: R.h(context, 32)),
                        ElevatedButton(
                          onPressed: () => context.go('/shop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.deepCharcoal,
                            padding: EdgeInsets.symmetric(
                                vertical: R.h(context, 14), horizontal: R.w(context, 32)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(R.w(context, 12))),
                            elevation: 0,
                          ),
                          child: Text('Start Shopping',
                              style: AppTypography.bodySM(context).copyWith(
                                  fontWeight: FontWeight.w800, fontSize: R.sp(context, 14))),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 12)),
                itemCount: orders.length,
                separatorBuilder: (_, __) => SizedBox(height: R.h(context, 12)),
                itemBuilder: (context, index) {
                  return _OrderCard(order: orders[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(context, order.status);
    final statusBg = _getStatusBgColor(order.status);
    final statusIcon = _getStatusIcon(order.status);
    
    // Fallback store settings if provider isn't loaded yet
    final settingsAsync = ref.watch(storeSettingsProvider);
    final cancelHours = settingsAsync.valueOrNull?.cancellationWindowHours ?? 24;
    final returnDays = settingsAsync.valueOrNull?.returnWindowDays ?? 5;

    final canCancel = order.canCancel && _isWithinWindow(order.createdAt, cancelHours);
    final canReturn = order.canReturn && _isWithinReturnWindow(order.updatedAt, returnDays);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: R.w(context, 12), vertical: R.h(context, 10)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(R.w(context, 11))),
              border: Border(
                bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              children: [
                _HeaderInfoBlock(
                  label: 'Date Placed',
                  value: _formatDate(order.createdAt),
                ),
                SizedBox(width: R.w(context, 12)),
                _HeaderInfoBlock(
                  label: 'Total',
                  value: formatPrice(order.total),
                ),
                SizedBox(width: R.w(context, 12)),
                _HeaderInfoBlock(
                  label: 'Order #',
                  value: formatOrderId(order.id),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(R.w(context, 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status ──────────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: R.w(context, 32),
                      height: R.w(context, 32),
                      decoration: BoxDecoration(
                        color: statusBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, size: R.sp(context, 16), color: statusColor),
                    ),
                    SizedBox(width: R.w(context, 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.status == OrderStatus.delivered
                                ? 'Delivered near door'
                                : 'Status: ${order.status.label}',
                            style: AppTypography.bodySM(context).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: R.sp(context, 13),
                            ),
                          ),
                          SizedBox(height: R.h(context, 2)),
                          Text(
                            order.status == OrderStatus.delivered
                                ? 'Your order has been delivered. Enjoy!'
                                : order.trackingNumber != null
                                    ? 'Tracking: ${order.trackingNumber}'
                                    : 'Your order is moving through our artisan network.',
                            style: AppTypography.bodySM(context).copyWith(
                              color: AppColors.neutralGold,
                              fontSize: R.sp(context, 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.h(context, 10)),

                // ── Items (Up to 2) ───────────────────────────────────────
                ...order.items.take(2).map((item) {
                  final p = item.product;
                  return Padding(
                    padding: EdgeInsets.only(bottom: R.h(context, 8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: R.w(context, 56),
                          height: R.w(context, 56),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(R.w(context, 8)),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(R.w(context, 8)),
                            child: p.images.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: p.images.first,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image,
                                    color: AppColors.borderLight),
                          ),
                        ),
                        SizedBox(width: R.w(context, 12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: AppTypography.bodySM(context).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: R.sp(context, 13),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: R.h(context, 2)),
                              () {
                                final displayWeight = item.selectedWeight?.isNotEmpty == true
                                    ? item.selectedWeight!
                                    : p.weight.isNotEmpty ? p.weight : null;
                                return Text(
                                  [
                                    'Qty: ${item.quantity}',
                                    if (displayWeight != null) displayWeight,
                                    if (p.category.isNotEmpty) p.category,
                                  ].join(' • '),
                                  style: AppTypography.bodySM(context).copyWith(
                                    color: AppColors.neutralGold,
                                    fontSize: R.sp(context, 11),
                                  ),
                                );
                              }(),
                              SizedBox(height: R.h(context, 4)),
                              Text(
                                formatPrice(item.effectivePrice * item.quantity),
                                style: AppTypography.bodySM(context).copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: R.sp(context, 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // ── More Items indicator ──────────────────────────────────
                if (order.items.length > 2)
                  Row(
                    children: [
                      Container(
                        width: R.w(context, 56),
                        height: R.w(context, 56),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(R.w(context, 8)),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Center(
                          child: Text(
                            '+${order.items.length - 2}',
                            style: AppTypography.h3(context).copyWith(
                              color: AppColors.primaryDark,
                              fontSize: R.sp(context, 16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: R.w(context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'More Items',
                              style: AppTypography.bodySM(context).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: R.sp(context, 13),
                              ),
                            ),
                            SizedBox(height: R.h(context, 2)),
                            Text(
                              'Included in this shipment securely packed.',
                              style: AppTypography.bodySM(context).copyWith(
                                color: AppColors.neutralGold,
                                fontSize: R.sp(context, 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                // ── Action Buttons ─────────────────────────────────────────
                SizedBox(height: R.h(context, 12)),
                
                // Cancellation countdown label
                if (canCancel)
                  Padding(
                    padding: EdgeInsets.only(bottom: R.h(context, 12)),
                    child: _TimeRemainingLabel(
                      icon: Icons.access_time_rounded,
                      text: _getCancelWithinText(order.createdAt, cancelHours),
                      color: Colors.amber.shade700,
                    ),
                  ),

                // Return countdown label
                if (canReturn)
                  Padding(
                    padding: EdgeInsets.only(bottom: R.h(context, 12)),
                    child: _TimeRemainingLabel(
                      icon: Icons.access_time_rounded,
                      text: _getReturnWithinText(order.updatedAt, returnDays),
                      color: Colors.amber.shade700,
                    ),
                  ),

                if (order.status == OrderStatus.delivered)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/orders/${order.id}'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.deepCharcoal,
                            side: BorderSide(color: AppColors.neutralGold.withValues(alpha: 0.3)),
                            backgroundColor: AppColors.neutralGold.withValues(alpha: 0.05),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 6))),
                          ),
                          child: Text('View Details', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 10))),
                        ),
                      ),
                      if (canReturn) ...[
                        SizedBox(width: R.w(context, 8)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/account/returns?orderId=${order.id}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.deepCharcoal,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 32),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 6))),
                            ),
                            child: Text('Return Item', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 10))),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Row(
                    children: [
                      if (order.status != OrderStatus.cancelled) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push('/orders/${order.id}'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.deepCharcoal,
                              side: const BorderSide(color: AppColors.primary),
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 6))),
                            ),
                            child: Text('Track Live', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 10)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        SizedBox(width: R.w(context, 6)),
                      ],
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                          context.push('/support?orderId=${formatOrderId(order.id)}');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.deepCharcoal,
                            side: BorderSide(color: AppColors.neutralGold.withValues(alpha: 0.3)),
                            backgroundColor: AppColors.neutralGold.withValues(alpha: 0.05),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 6))),
                          ),
                          child: Text('Contact', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 10)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      if (canCancel) ...[
                        SizedBox(width: R.w(context, 6)),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showCancelDialog(context, ref, order),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              backgroundColor: Colors.red.withValues(alpha: 0.05),
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 6))),
                            ),
                            child: Text('Cancel', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, color: Colors.red, fontSize: R.sp(context, 10)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
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
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Color _getStatusColor(BuildContext context, OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green.shade700;
      case OrderStatus.shipped:
        return Colors.blue.shade700;
      case OrderStatus.confirmed:
        return (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal);
      case OrderStatus.cancelled:
        return Colors.red.shade700;
      default:
        return (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal);
    }
  }

  Color _getStatusBgColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Colors.green.shade100;
      case OrderStatus.shipped:
        return Colors.blue.shade100;
      case OrderStatus.confirmed:
        return AppColors.primary.withValues(alpha: 0.2);
      case OrderStatus.cancelled:
        return Colors.red.shade100;
      default:
        return AppColors.neutralGold.withValues(alpha: 0.2);
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return Icons.inventory_2_rounded;
      case OrderStatus.shipped:
        return Icons.local_shipping_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.rotate_right_rounded;
    }
  }
}

class _HeaderInfoBlock extends StatelessWidget {
  final String label;
  final String value;
  const _HeaderInfoBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.bodySM(context).copyWith(
              fontWeight: FontWeight.w800,
              fontSize: R.sp(context, 12),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
        Icon(icon, size: R.sp(context, 10), color: color),
        SizedBox(width: R.w(context, 4)),
        Text(
          text,
          style: AppTypography.bodySM(context).copyWith(
            color: color,
            fontSize: R.sp(context, 9),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
      title: Text('Cancel Order?', style: AppTypography.h3(context)),
      content: Text(
        'Are you sure you want to cancel order ${formatOrderId(widget.order.id)}? This action cannot be undone.',
        style: AppTypography.bodySM(context),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.deepCharcoal,
            side: const BorderSide(color: AppColors.borderLight),
            padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 8)),
            minimumSize: Size(0, R.h(context, 36)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 8))),
          ),
          child: Text('Keep Order', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 8)),
            minimumSize: Size(0, R.h(context, 36)),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 8))),
          ),
          child: _isLoading
              ? SizedBox(width: R.w(context, 16), height: R.w(context, 16), child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Confirm Cancel', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ],
    );
  }
}
