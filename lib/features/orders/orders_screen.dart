import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';
import '../../models/order.dart';
import '../../core/widgets/skeleton_loaders.dart';

import 'orders_filters.dart';
import 'widgets/order_card.dart';
import 'widgets/date_filter_sheet.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  OrderStatusFilter _selectedFilter = OrderStatusFilter.all;
  OrderDateFilter _selectedDateFilter = OrderDateFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _filterLabel(OrderStatusFilter f) => switch (f) {
        OrderStatusFilter.all => 'All Orders',
        OrderStatusFilter.active => 'Active',
        OrderStatusFilter.delivered => 'Delivered',
        OrderStatusFilter.cancelled => 'Cancelled',
        OrderStatusFilter.paymentFailed => 'Payment Failed',
      };

  String _dateFilterLabel(OrderDateFilter f) => switch (f) {
        OrderDateFilter.all => 'All Time',
        OrderDateFilter.last30Days => 'Last 30 Days',
        OrderDateFilter.last3Months => 'Last 3 Months',
        OrderDateFilter.last6Months => 'Last 6 Months',
        OrderDateFilter.thisYear => 'This Year (${DateTime.now().year})',
      };

  // Pure client-side filter — no providers touched
  List<Order> _applyFilters(List<Order> orders) {
    // Step 1: status filter
    final List<Order> statusFiltered = switch (_selectedFilter) {
      OrderStatusFilter.all => orders,
      OrderStatusFilter.active => orders
          .where((o) =>
              o.status == OrderStatus.pending ||
              o.status == OrderStatus.confirmed ||
              o.status == OrderStatus.processing ||
              o.status == OrderStatus.shipped)
          .toList(),
      OrderStatusFilter.delivered =>
        orders.where((o) => o.status == OrderStatus.delivered).toList(),
      OrderStatusFilter.cancelled => orders
          .where((o) =>
              o.status == OrderStatus.cancelled &&
              o.paymentStatus != PaymentStatus.failed)
          .toList(),
      OrderStatusFilter.paymentFailed => orders
          .where((o) =>
              o.status == OrderStatus.cancelled &&
              o.paymentStatus == PaymentStatus.failed)
          .toList(),
    };

    // Step 2: date filter
    final now = DateTime.now();
    final List<Order> dateFiltered = switch (_selectedDateFilter) {
      OrderDateFilter.all => statusFiltered,
      OrderDateFilter.last30Days => statusFiltered
          .where((o) => now.difference(o.createdAt).inDays <= 30)
          .toList(),
      OrderDateFilter.last3Months => statusFiltered
          .where((o) => now.difference(o.createdAt).inDays <= 90)
          .toList(),
      OrderDateFilter.last6Months => statusFiltered
          .where((o) => now.difference(o.createdAt).inDays <= 180)
          .toList(),
      OrderDateFilter.thisYear =>
        statusFiltered.where((o) => o.createdAt.year == now.year).toList(),
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
      _selectedFilter != OrderStatusFilter.all ||
      _selectedDateFilter != OrderDateFilter.all ||
      _searchQuery.isNotEmpty;

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedFilter = OrderStatusFilter.all;
      _selectedDateFilter = OrderDateFilter.all;
    });
  }

  void _showDateFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        current: _selectedDateFilter,
        labelFn: _dateFilterLabel,
        onApply: (f) {
          if (mounted) setState(() => _selectedDateFilter = f);
        },
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
            style: AppTypography.h3(context)
                .copyWith(fontSize: R.sp(context, 16))),
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
              final List<Order> allOrders =
                  dynamicOrders.cast<Order>().toList();
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
                                  color: AppColors.primary
                                      .withValues(alpha: 0.25)),
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
                              color: _selectedDateFilter != OrderDateFilter.all
                                  ? AppColors.primary
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.surfaceDark
                                      : Colors.white),
                              borderRadius:
                                  BorderRadius.circular(R.w(context, 12)),
                              border: Border.all(
                                color: _selectedDateFilter != OrderDateFilter.all
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
                              color: _selectedDateFilter != OrderDateFilter.all
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
                    padding: EdgeInsets.symmetric(horizontal: R.w(context, 16)),
                    child: Row(
                      children: OrderStatusFilter.values.map((f) {
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
                                    style:
                                        AppTypography.bodySM(context).copyWith(
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
                                                  fontSize: R.sp(context, 13))),
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
                                                  fontSize: R.sp(context, 14))),
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
                              return OrderCard(order: orders[index]);
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
