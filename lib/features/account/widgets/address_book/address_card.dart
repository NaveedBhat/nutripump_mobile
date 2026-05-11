import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../models/cart_item.dart';
import '../../../../providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final String userId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.userId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.w(context, 16)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        border: Border.all(
            color: address.isDefault
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.deepCharcoal)
                .withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      address.fullName,
                      style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: R.sp(context, 15)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address.isDefault) ...[
                      SizedBox(width: R.w(context, 8)),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: R.w(context, 6),
                            vertical: R.h(context, 2)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(R.w(context, 4)),
                        ),
                        child: Text('DEFAULT',
                            style: AppTypography.label(context).copyWith(
                                fontSize: R.sp(context, 9),
                                color: AppColors.primaryDark)),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Padding(
                      padding: EdgeInsets.all(R.w(context, 4)),
                      child: Icon(Icons.edit_outlined,
                          size: R.sp(context, 18),
                          color: AppColors.neutralGold),
                    ),
                  ),
                  SizedBox(width: R.w(context, 8)),
                  GestureDetector(
                    onTap: onDelete,
                    child: Padding(
                      padding: EdgeInsets.all(R.w(context, 4)),
                      child: Icon(Icons.delete_outline_rounded,
                          size: R.sp(context, 18), color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(context, 12)),
          Text(address.phone,
              style: AppTypography.bodySM(context)
                  .copyWith(fontSize: R.sp(context, 13))),
          SizedBox(height: R.h(context, 6)),
          Text(address.oneLineAddress,
              style: AppTypography.bodySM(context).copyWith(
                  color: AppColors.neutralGold,
                  fontSize: R.sp(context, 13),
                  height: 1.4)),
          if (!address.isDefault) ...[
            SizedBox(height: R.h(context, 16)),
            Consumer(
              builder: (context, ref, child) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(addressServiceProvider)
                          .setDefault(userId, address.id!);
                      ref.invalidate(userAddressesProvider(userId));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepCharcoal,
                      side: const BorderSide(color: AppColors.borderLight),
                      padding: EdgeInsets.symmetric(vertical: R.h(context, 8)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.w(context, 6))),
                    ),
                    child: Text(
                      'Set as Default',
                      style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(context, 12)),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
