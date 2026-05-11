import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../orders_filters.dart' show OrderDateFilter;

class DateFilterSheet extends StatefulWidget {
  final OrderDateFilter current;
  final String Function(OrderDateFilter) labelFn;
  final void Function(OrderDateFilter) onApply;
  const DateFilterSheet({
    super.key,
    required this.current,
    required this.labelFn,
    required this.onApply,
  });

  @override
  State<DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<DateFilterSheet> {
  late OrderDateFilter _selected;

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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(R.w(context, 20))),
      ),
      padding: EdgeInsets.fromLTRB(R.w(context, 20), R.h(context, 16),
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
              if (_selected != OrderDateFilter.all)
                GestureDetector(
                  onTap: () {
                    setState(() => _selected = OrderDateFilter.all);
                    widget.onApply(OrderDateFilter.all);
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
          ...OrderDateFilter.values.map((f) {
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
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
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
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (f == OrderDateFilter.last30Days)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: R.w(context, 8),
                            vertical: R.h(context, 3)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(R.w(context, 20)),
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
          Divider(color: AppColors.borderLight, height: R.h(context, 24)),
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
                    borderRadius: BorderRadius.circular(R.w(context, 12))),
              ),
              child: Text(
                'Apply Filter',
                style: AppTypography.bodySM(context).copyWith(
                    fontWeight: FontWeight.w800, fontSize: R.sp(context, 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
