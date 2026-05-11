import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';
import '../../models/cart_item.dart';
import '../../core/widgets/skeleton_loaders.dart';
import 'widgets/address_book/address_card.dart';
import 'widgets/address_book/address_form_sheet.dart';

class AddressBookScreen extends ConsumerWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: Text('Address Book',
            style: AppTypography.h3(context)
                .copyWith(fontSize: R.sp(context, 16))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: userAsync.when(
        loading: () => ListView.separated(
          padding: EdgeInsets.symmetric(
              horizontal: R.w(context, 16), vertical: R.h(context, 12)),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => SizedBox(height: R.h(context, 12)),
          itemBuilder: (_, __) => const AddressCardSkeleton(),
        ),
        error: (_, __) => const Center(child: Text('Something went wrong')),
        data: (user) {
          if (user == null) {
            return Center(
              child: Text('Please sign in to view your addresses.',
                  style: AppTypography.bodySM(context)),
            );
          }

          final addressesAsync = ref.watch(userAddressesProvider(user.uid));

          return addressesAsync.when(
            loading: () => ListView.separated(
              padding: EdgeInsets.symmetric(
                  horizontal: R.w(context, 16), vertical: R.h(context, 12)),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(height: R.h(context, 12)),
              itemBuilder: (_, __) => const AddressCardSkeleton(),
            ),
            error: (e, __) =>
                Center(child: Text('Error loading addresses: $e')),
            data: (dynamicAddresses) {
              final List<Address> addresses = dynamicAddresses.cast<Address>();

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userAddressesProvider(user.uid));
                  await ref.read(userAddressesProvider(user.uid).future);
                },
                child: addresses.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(R.w(context, 40)),
                        children: [
                          SizedBox(height: R.h(context, 60)),
                          Container(
                            width: R.w(context, 88),
                            height: R.w(context, 88),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.15),
                                  width: 1.5),
                            ),
                            child: Icon(Icons.location_on_outlined,
                                size: R.sp(context, 40),
                                color: AppColors.primary),
                          ),
                          SizedBox(height: R.h(context, 24)),
                          Text('No addresses found',
                              textAlign: TextAlign.center,
                              style: AppTypography.h2(context)
                                  .copyWith(fontSize: R.sp(context, 22))),
                          SizedBox(height: R.h(context, 10)),
                          Text(
                            'Add a delivery address to make checkout faster and easier.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySM(context).copyWith(
                                color: AppColors.neutralGold,
                                height: 1.6,
                                fontSize: R.sp(context, 14)),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(R.w(context, 16)),
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: R.h(context, 16)),
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return AddressCard(
                            address: address,
                            userId: user.uid,
                            onEdit: () => _showAddressForm(
                                context, ref, user.uid,
                                address: address),
                            onDelete: () async {
                              final confirm =
                                  await _showDeleteConfirmation(context);
                              if (confirm == true) {
                                await ref
                                    .read(addressServiceProvider)
                                    .deleteAddress(user.uid, address.id!);
                                ref.invalidate(userAddressesProvider(user.uid));
                              }
                            },
                          );
                        },
                      ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: userAsync.value != null
          ? Container(
              padding: EdgeInsets.only(
                left: R.w(context, 24),
                right: R.w(context, 24),
                top: R.h(context, 16),
                bottom:
                    MediaQuery.of(context).padding.bottom + R.h(context, 24),
              ),
              child: SizedBox(
                width: double.infinity,
                height: R.h(context, 46),
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showAddressForm(context, ref, userAsync.value!.uid),
                  icon: Icon(Icons.add_rounded,
                      size: R.sp(context, 20), color: AppColors.deepCharcoal),
                  label: Text('Add New Address',
                      style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: R.sp(context, 14),
                          color: AppColors.deepCharcoal)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.deepCharcoal,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                        horizontal: R.w(context, 16), vertical: 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 12))),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white),
        title: Text('Delete Address', style: AppTypography.h3(context)),
        content: Text(
            'Are you sure you want to delete this address? This action cannot be undone.',
            style: AppTypography.bodySM(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTypography.bodySM(context).copyWith(
                    color: AppColors.neutralGold, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: AppTypography.bodySM(context).copyWith(
                    color: Colors.red.shade700, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAddressForm(BuildContext context, WidgetRef ref, String userId,
      {Address? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          AddressFormSheet(userId: userId, address: address, parentRef: ref),
    );
  }
}
