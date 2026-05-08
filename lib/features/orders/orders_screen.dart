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
import '../../core/widgets/skeleton_loaders.dart';

// ── Order filter options ────────────────────────────────────────────────────
enum _OrderFilter { all, active, delivered, cancelled, paymentFailed }
enum _DateFilter  { all, last30Days, last3Months, last6Months, thisYear }

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  _OrderFilter _selectedFilter     = _OrderFilter.all;
  _DateFilter  _selectedDateFilter = _DateFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _filterLabel(_OrderFilter f) => switch (f) {
    _OrderFilter.all           => 'All Orders',
    _OrderFilter.active        => 'Active',
    _OrderFilter.delivered     => 'Delivered',
    _OrderFilter.cancelled     => 'Cancelled',
    _OrderFilter.paymentFailed => 'Payment Failed',
  };

  String _dateFilterLabel(_DateFilter f) => switch (f) {
    _DateFilter.all         => 'All Time',
    _DateFilter.last30Days  => 'Last 30 Days',
    _DateFilter.last3Months => 'Last 3 Months',
    _DateFilter.last6Months => 'Last 6 Months',
    _DateFilter.thisYear    => 'This Year (${DateTime.now().year})',
  };

  // Pure client-side filter — no providers touched
  List<Order> _applyFilters(List<Order> orders) {
    // Step 1: status filter
    final List<Order> statusFiltered = switch (_selectedFilter) {
      _OrderFilter.all => orders,
      _OrderFilter.active => orders
          .where((o) =>
              o.status == OrderStatus.pending ||
              o.status == OrderStatus.confirmed ||
              o.status == OrderStatus.processing ||
              o.status == OrderStatus.shipped)
          .toList(),
      _OrderFilter.delivered =>
          orders.where((o) => o.status == OrderStatus.delivered).toList(),
      _OrderFilter.cancelled => orders
          .where((o) =>
              o.status == OrderStatus.cancelled &&
              o.paymentStatus != PaymentStatus.failed)
          .toList(),
      _OrderFilter.paymentFailed => orders
          .where((o) =>
              o.status == OrderStatus.cancelled &&
              o.paymentStatus == PaymentStatus.failed)
          .toList(),
    };

    // Step 2: date filter
    final now = DateTime.now();
    final List<Order> dateFiltered = switch (_selectedDateFilter) {
      _DateFilter.all         => statusFiltered,
      _DateFilter.last30Days  => statusFiltered
          .where((o) => now.difference(o.createdAt).inDays <= 30)
          .toList(),
      _DateFilter.last3Months => statusFiltered
          .where((o) => now.difference(o.createdAt).inDays <= 90)
          .toList(),
      _DateFilter.last6Months => statusFiltered
          .where((o) => now.difference(o.createdAt).inDays <= 180)
          .toList(),
      _DateFilter.thisYear    => statusFiltered
          .where((o) => o.createdAt.year == now.year)
          .toList(),
    };

    // Step 3: search filter (order ID or product name)
    if (_searchQuery.isEmpty) return dateFiltered;
    final q = _searchQuery.toLowerCase();
    return dateFiltered.where((o) {
      if (formatOrderId(o.id).toLowerCase().contains(q)) return true;
      return o.items.any((i) => i.product.name.toLowerCase().contains(q));
    }).toList();
  }

  bool get _hasActiveFilter =>
      _selectedFilter != _OrderFilter.all ||
      _selectedDateFilter != _DateFilter.all ||
      _searchQuery.isNotEmpty;

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedFilter     = _OrderFilter.all;
      _selectedDateFilter = _DateFilter.all;
    });
  }

  void _showDateFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DateFilterSheet(
        current: _selectedDateFilter,
        labelFn: _dateFilterLabel,
        onApply: (f) { if (mounted) setState(() => _selectedDateFilter = f); },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColors.backgroundLight),
      appBar: AppBar(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: R.sp(context, 16)),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text('My Orders',
            style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: userAsync.when(
        loading: () => const OrdersListSkeleton(),
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
            loading: () => const OrdersListSkeleton(),
            error: (e, __) => Center(child: Text('Error loading orders: $e')),
            data: (dynamicOrders) {
              // All orders — payment-abandoned ones use dedicated 'Payment Failed' UI
              final List<Order> allOrders = dynamicOrders.cast<Order>().toList();
              final List<Order> orders = _applyFilters(allOrders);

              return Column(
                children: [
                  // ── Search Bar + Date-Filter Button ──────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(R.w(context, 16),
                        R.h(context, 12), R.w(context, 16), R.h(context, 8)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.surfaceDark
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(R.w(context, 12)),
                              border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.25)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepCharcoal
                                      .withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v.trim()),
                              style: AppTypography.bodySM(context)
                                  .copyWith(fontSize: R.sp(context, 13)),
                              decoration: InputDecoration(
                                hintText: 'Search by order ID or product...',
                                hintStyle:
                                    AppTypography.bodySM(context).copyWith(
                                  color: AppColors.neutralGold,
                                  fontSize: R.sp(context, 12),
                                ),
                                prefixIcon: Icon(Icons.search_rounded,
                                    size: R.sp(context, 18),
                                    color: AppColors.neutralGold),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.close_rounded,
                                            size: R.sp(context, 16),
                                            color: AppColors.neutralGold),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: R.h(context, 12),
                                    horizontal: R.w(context, 4)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: R.w(context, 8)),
                        // Date-filter button — highlighted when active
                        GestureDetector(
                          onTap: () => _showDateFilterSheet(context),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: R.w(context, 46),
                            height: R.w(context, 46),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedDateFilter != _DateFilter.all
                                  ? AppColors.primary
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.surfaceDark
                                      : Colors.white),
                              borderRadius:
                                  BorderRadius.circular(R.w(context, 12)),
                              border: Border.all(
                                color: _selectedDateFilter != _DateFilter.all
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.25),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepCharcoal
                                      .withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              size: R.sp(context, 18),
                              color: _selectedDateFilter != _DateFilter.all
                                  ? AppColors.deepCharcoal
                                  : AppColors.neutralGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Filter Chips ─────────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                        horizontal: R.w(context, 16)),
                    child: Row(
                      children: _OrderFilter.values.map((f) {
                        final isSelected = _selectedFilter == f;
                        return Padding(
                          padding: EdgeInsets.only(right: R.w(context, 8)),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                  horizontal: R.w(context, 14),
                                  vertical: R.h(context, 7)),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.surfaceDark
                                        : Colors.white),
                                borderRadius:
                                    BorderRadius.circular(R.w(context, 20)),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.primary
                                          .withValues(alpha: 0.25),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                _filterLabel(f),
                                style: AppTypography.bodySM(context).copyWith(
                                  fontSize: R.sp(context, 11),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.deepCharcoal
                                      : AppColors.neutralGold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: R.h(context, 10)),

                  // ── Orders List / Empty State ─────────────────────────────
                  Expanded(
                    child: orders.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: R.w(context, 40)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: R.w(context, 76),
                                    height: R.w(context, 76),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.10),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.15),
                                          width: 1.5),
                                    ),
                                    child: Icon(
                                      _hasActiveFilter
                                          ? Icons.search_off_rounded
                                          : Icons.inventory_2_outlined,
                                      size: R.sp(context, 32),
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(height: R.h(context, 20)),
                                  Text(
                                    _hasActiveFilter
                                        ? 'No orders found'
                                        : 'No orders yet',
                                    style: AppTypography.h2(context)
                                        .copyWith(fontSize: R.sp(context, 18)),
                                  ),
                                  SizedBox(height: R.h(context, 8)),
                                  Text(
                                    _hasActiveFilter
                                        ? 'Try adjusting your search or filter.'
                                        : 'Your artisanal pantry awaits.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodySM(context)
                                        .copyWith(
                                      color: AppColors.neutralGold,
                                      height: 1.6,
                                      fontSize: R.sp(context, 13),
                                    ),
                                  ),
                                  SizedBox(height: R.h(context, 28)),
                                  if (_hasActiveFilter)
                                    OutlinedButton(
                                      onPressed: _clearFilters,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.deepCharcoal,
                                        side: const BorderSide(
                                            color: AppColors.primary),
                                        padding: EdgeInsets.symmetric(
                                            vertical: R.h(context, 10),
                                            horizontal: R.w(context, 24)),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                R.w(context, 10))),
                                      ),
                                      child: Text('Clear Filters',
                                          style: AppTypography.bodySM(context)
                                              .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize:
                                                      R.sp(context, 13))),
                                    )
                                  else
                                    ElevatedButton(
                                      onPressed: () => context.go('/shop'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.deepCharcoal,
                                        padding: EdgeInsets.symmetric(
                                            vertical: R.h(context, 14),
                                            horizontal: R.w(context, 32)),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                R.w(context, 12))),
                                        elevation: 0,
                                      ),
                                      child: Text('Start Shopping',
                                          style: AppTypography.bodySM(context)
                                              .copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize:
                                                      R.sp(context, 14))),
                                    ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(
                                horizontal: R.w(context, 16),
                                vertical: R.h(context, 4)),
                            itemCount: orders.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: R.h(context, 12)),
                            itemBuilder: (context, index) {
                              return _OrderCard(order: orders[index]);
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ── Date Filter Bottom Sheet ────────────────────────────────────────────────
class _DateFilterSheet extends StatefulWidget {
  final _DateFilter current;
  final String Function(_DateFilter) labelFn;
  final void Function(_DateFilter) onApply;
  const _DateFilterSheet({
    required this.current,
    required this.labelFn,
    required this.onApply,
  });

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  late _DateFilter _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(R.w(context, 20))),
      ),
      padding: EdgeInsets.fromLTRB(
          R.w(context, 20), R.h(context, 16),
          R.w(context, 20), R.h(context, 32)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: R.w(context, 36),
              height: R.h(context, 4),
              margin: EdgeInsets.only(bottom: R.h(context, 16)),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(R.w(context, 2)),
              ),
            ),
          ),
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter by Date',
                  style: AppTypography.h3(context)
                      .copyWith(fontSize: R.sp(context, 16))),
              if (_selected != _DateFilter.all)
                GestureDetector(
                  onTap: () {
                    setState(() => _selected = _DateFilter.all);
                    widget.onApply(_DateFilter.all);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Clear',
                    style: AppTypography.bodySM(context).copyWith(
                      color: AppColors.neutralGold,
                      fontSize: R.sp(context, 12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: R.h(context, 12)),
          // Options
          ..._DateFilter.values.map((f) {
            final isSelected = _selected == f;
            return InkWell(
              onTap: () => setState(() => _selected = f),
              borderRadius: BorderRadius.circular(R.w(context, 8)),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: R.h(context, 13)),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: R.w(context, 20),
                      height: R.w(context, 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderLight,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check_rounded,
                              size: R.sp(context, 12),
                              color: AppColors.deepCharcoal)
                          : null,
                    ),
                    SizedBox(width: R.w(context, 14)),
                    Expanded(
                      child: Text(
                        widget.labelFn(f),
                        style: AppTypography.bodySM(context).copyWith(
                          fontSize: R.sp(context, 14),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (f == _DateFilter.last30Days)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: R.w(context, 8),
                            vertical: R.h(context, 3)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(R.w(context, 20)),
                        ),
                        child: Text(
                          'Popular',
                          style: AppTypography.bodySM(context).copyWith(
                            fontSize: R.sp(context, 10),
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          Divider(
              color: AppColors.borderLight, height: R.h(context, 24)),
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selected);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.deepCharcoal,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: R.h(context, 14)),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(R.w(context, 12))),
              ),
              child: Text(
                'Apply Filter',
                style: AppTypography.bodySM(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: R.sp(context, 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Detect payment-abandoned orders:
    // Backend sets paymentStatus='failed' when the Razorpay payment is
    // cancelled or fails. COD cancellations always have paymentStatus='pending'.
    // This is the reliable, backend-verified discriminator.
    final bool isPaymentAbandoned =
        order.status == OrderStatus.cancelled &&
        order.paymentStatus == PaymentStatus.failed;

    final statusColor = isPaymentAbandoned
        ? Colors.orange.shade700
        : _getStatusColor(context, order.status);
    final statusBg = isPaymentAbandoned
        ? Colors.orange.shade100
        : _getStatusBgColor(order.status);
    final statusIcon = isPaymentAbandoned
        ? Icons.payment_rounded
        : _getStatusIcon(order.status);

    // Fallback store settings if provider isn't loaded yet
    final settingsAsync = ref.watch(storeSettingsProvider);
    final cancelHours = settingsAsync.valueOrNull?.cancellationWindowHours ?? 24;
    final returnDays = settingsAsync.valueOrNull?.returnWindowDays ?? 5;

    // Payment-abandoned orders must not show the regular Cancel button
    final canCancel = !isPaymentAbandoned &&
        order.canCancel && _isWithinWindow(order.createdAt, cancelHours);
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
                            isPaymentAbandoned
                                ? 'Payment Failed'
                                : order.status == OrderStatus.delivered
                                    ? 'Delivered near door'
                                    : 'Status: ${order.status.label}',
                            style: AppTypography.bodySM(context).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: R.sp(context, 13),
                            ),
                          ),
                          SizedBox(height: R.h(context, 2)),
                          Text(
                            isPaymentAbandoned
                                ? 'Revise your payment to complete this order'
                                : order.status == OrderStatus.delivered
                                    ? 'Your order has been delivered. Enjoy!'
                                    : order.status == OrderStatus.cancelled
                                        ? 'This order has been cancelled.'
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

                if (isPaymentAbandoned) ...[
                  // Payment-abandoned: full-width Retry Payment CTA (Flipkart-style)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/checkout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.deepCharcoal,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.w(context, 8))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded,
                              size: R.sp(context, 14),
                              color: AppColors.deepCharcoal),
                          SizedBox(width: R.w(context, 6)),
                          Text(
                            'Retry Payment',
                            style: AppTypography.bodySM(context).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: R.sp(context, 12),
                              color: AppColors.deepCharcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
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
                        if (order.status == OrderStatus.cancelled) ...[
                          // Cancelled orders: View Details → shows full invoice + cancellation reason
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
                              child: Text('View Details', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 10)), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          SizedBox(width: R.w(context, 6)),
                        ] else ...[
                          // Active orders: Track Live
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
                            onPressed: () =>
                                context.push('/support?orderId=${formatOrderId(order.id)}'),
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
          const SnackBar(duration: Duration(milliseconds: 2000), content: Text('Order cancelled successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(duration: const Duration(milliseconds: 2000), content: Text('Failed to cancel order: $e')),
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
