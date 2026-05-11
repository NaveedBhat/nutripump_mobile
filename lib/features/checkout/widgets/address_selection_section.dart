import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/account/widgets/address_book/address_form_sheet.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/providers.dart';
import '../../../models/cart_item.dart' show Address;
import '../checkout_screen.dart' show selectedAddressProvider;

class AddressSelectionSection extends ConsumerWidget {
  const AddressSelectionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Text('Please log in');

    final addressesAsync = ref.watch(userAddressesProvider(user.uid));
    final selectedAddress = ref.watch(selectedAddressProvider);

    return addressesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading addresses'),
      data: (dynamicAddresses) {
        final List<Address> addresses = dynamicAddresses.cast<Address>();

        return Column(
          children: [
            if (addresses.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(R.w(context, 24)),
                decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(R.w(context, 16)),
                    border: Border.all(
                        color: AppColors.borderLight, style: BorderStyle.none)),
                child: Column(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: R.sp(context, 32), color: AppColors.neutralGold),
                    SizedBox(height: R.h(context, 12)),
                    Text('No saved addresses found',
                        style: AppTypography.bodySM(context)
                            .copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: R.h(context, 16)),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showAddAddressSheet(context, user.uid, ref),
                      icon: Icon(Icons.add, size: R.sp(context, 16)),
                      label: const Text('Add New Address'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepCharcoal,
                          foregroundColor: Colors.white),
                    )
                  ],
                ),
              )
            else ...[
              ...addresses.map((addr) {
                final isSelected = selectedAddress?.id == addr.id;
                return GestureDetector(
                  onTap: () =>
                      ref.read(selectedAddressProvider.notifier).state = addr,
                  child: Container(
                    margin: EdgeInsets.only(bottom: R.h(context, 12)),
                    padding: EdgeInsets.all(R.w(context, 16)),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.surfaceDark
                              : Colors.white),
                      borderRadius: BorderRadius.circular(R.w(context, 16)),
                      border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderLight,
                          width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.neutralGold,
                            size: R.sp(context, 20)),
                        SizedBox(width: R.w(context, 16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(addr.fullName,
                                      style: AppTypography.bodySM(context)
                                          .copyWith(
                                              fontWeight: FontWeight.bold)),
                                  if (addr.isDefault) ...[
                                    SizedBox(width: R.w(context, 8)),
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: R.w(context, 6),
                                            vertical: R.h(context, 2)),
                                        decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                                R.w(context, 4))),
                                        child: Text('DEFAULT',
                                            style: AppTypography.label(context)
                                                .copyWith(
                                                    fontSize: R.sp(context, 8),
                                                    color: AppColors
                                                        .deepCharcoal))),
                                  ]
                                ],
                              ),
                              SizedBox(height: R.h(context, 4)),
                              Text(
                                  '${addr.addressLine1}${addr.locality != null ? ', ${addr.locality}' : ''}',
                                  style: AppTypography.bodySM(context)
                                      .copyWith(color: AppColors.neutralGold)),
                              Text(
                                  '${addr.city}, ${addr.state} - ${addr.pincode}',
                                  style: AppTypography.bodySM(context)
                                      .copyWith(color: AppColors.neutralGold)),
                              SizedBox(height: R.h(context, 4)),
                              Text(addr.phone,
                                  style: AppTypography.bodySM(context)
                                      .copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: R.h(context, 12)),
              TextButton.icon(
                onPressed: () => _showAddAddressSheet(context, user.uid, ref),
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary),
                label: Text('Add New Address',
                    style: AppTypography.bodySM(context).copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        );
      },
    );
  }

  void _showAddAddressSheet(BuildContext context, String uid, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressFormSheet(userId: uid, parentRef: ref),
    );
  }
}
