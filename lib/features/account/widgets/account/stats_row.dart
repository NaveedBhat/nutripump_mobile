import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../providers/providers.dart';

class StatsRow extends ConsumerWidget {
  final dynamic user;
  const StatsRow({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Live order count
    final ordersAsync = ref.watch(userOrdersProvider(user.uid as String));
    final exactOrderCount = ordersAsync.maybeWhen(
      data: (orders) => orders.length,
      orElse: () => user.totalOrders ?? 0,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
          R.w(context, 16), R.h(context, 12), R.w(context, 16), 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/orders'),
              child: StatChip(
                icon: Icons.receipt_long_outlined,
                label: 'Total Orders',
                value: '$exactOrderCount',
              ),
            ),
          ),
          SizedBox(width: R.w(context, 10)),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/orders'),
              child: const StatChip(
                icon: Icons.local_shipping_outlined,
                label: 'Status',
                value: 'Track',
              ),
            ),
          ),
          SizedBox(width: R.w(context, 10)),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/account/addresses'),
              child: const StatChip(
                icon: Icons.location_on_outlined,
                label: 'Addresses',
                value: 'Manage',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: R.w(context, 12), vertical: R.h(context, 12)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(icon, size: R.sp(context, 16), color: AppColors.primary),
          SizedBox(height: R.h(context, 4)),
          Text(
            value,
            style: AppTypography.bodySM(context).copyWith(
              fontWeight: FontWeight.w800,
              fontSize: R.sp(context, 12),
              color: (Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onSurface
                  : AppColors.deepCharcoal),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: R.h(context, 2)),
          Text(
            label,
            style: AppTypography.labelGold(context)
                .copyWith(fontSize: R.sp(context, 8)),
          ),
        ],
      ),
    );
  }
}
