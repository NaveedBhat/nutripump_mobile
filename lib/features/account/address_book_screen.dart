import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';
import '../../models/cart_item.dart';
import '../../core/widgets/skeleton_loaders.dart';

class AddressBookScreen extends ConsumerWidget {
  const AddressBookScreen({super.key});

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
        title: Text('Address Book', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: userAsync.when(
        loading: () => ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 12)),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => SizedBox(height: R.h(context, 12)),
          itemBuilder: (_, __) => const AddressCardSkeleton(),
        ),
        error: (_, __) => const Center(child: Text('Something went wrong')),
        data: (user) {
          if (user == null) {
            return Center(
              child: Text('Please sign in to view your addresses.', style: AppTypography.bodySM(context)),
            );
          }

          final addressesAsync = ref.watch(userAddressesProvider(user.uid));

          return addressesAsync.when(
            loading: () => ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 12)),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(height: R.h(context, 12)),
              itemBuilder: (_, __) => const AddressCardSkeleton(),
            ),
            error: (e, __) => Center(child: Text('Error loading addresses: $e')),
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
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
                            ),
                            child: Icon(Icons.location_on_outlined, size: R.sp(context, 40), color: AppColors.primary),
                          ),
                          SizedBox(height: R.h(context, 24)),
                          Text('No addresses found', textAlign: TextAlign.center, style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 22))),
                          SizedBox(height: R.h(context, 10)),
                          Text(
                            'Add a delivery address to make checkout faster and easier.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, height: 1.6, fontSize: R.sp(context, 14)),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(R.w(context, 16)),
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) => SizedBox(height: R.h(context, 16)),
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return _AddressCard(
                            address: address,
                            userId: user.uid,
                            onEdit: () => _showAddressForm(context, ref, user.uid, address: address),
                            onDelete: () async {
                              final confirm = await _showDeleteConfirmation(context);
                              if (confirm == true) {
                                await ref.read(addressServiceProvider).deleteAddress(user.uid, address.id!);
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
                bottom: MediaQuery.of(context).padding.bottom + R.h(context, 24),
              ),
              child: SizedBox(
                width: double.infinity,
                height: R.h(context, 46),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddressForm(context, ref, userAsync.value!.uid),
                  icon: Icon(Icons.add_rounded, size: R.sp(context, 20), color: AppColors.deepCharcoal),
                  label: Text('Add New Address', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 14), color: AppColors.deepCharcoal)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.deepCharcoal,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 12))),
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
        backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : Colors.white),
        title: Text('Delete Address', style: AppTypography.h3(context)),
        content: Text('Are you sure you want to delete this address? This action cannot be undone.', style: AppTypography.bodySM(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: AppTypography.bodySM(context).copyWith(color: Colors.red.shade700, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAddressForm(BuildContext context, WidgetRef ref, String userId, {Address? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressFormSheet(userId: userId, address: address, parentRef: ref),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final String userId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
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
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        border: Border.all(color: address.isDefault ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderLight),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      address.fullName,
                      style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 15)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address.isDefault) ...[
                      SizedBox(width: R.w(context, 8)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: R.w(context, 6), vertical: R.h(context, 2)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(R.w(context, 4)),
                        ),
                        child: Text('DEFAULT', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 9), color: AppColors.primaryDark)),
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
                      child: Icon(Icons.edit_outlined, size: R.sp(context, 18), color: AppColors.neutralGold),
                    ),
                  ),
                  SizedBox(width: R.w(context, 8)),
                  GestureDetector(
                    onTap: onDelete,
                    child: Padding(
                      padding: EdgeInsets.all(R.w(context, 4)),
                      child: Icon(Icons.delete_outline_rounded, size: R.sp(context, 18), color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(context, 12)),
          Text(address.phone, style: AppTypography.bodySM(context).copyWith(fontSize: R.sp(context, 13))),
          SizedBox(height: R.h(context, 6)),
          Text(address.oneLineAddress, style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 13), height: 1.4)),
          
          if (!address.isDefault) ...[
            SizedBox(height: R.h(context, 16)),
            Consumer(
              builder: (context, ref, child) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref.read(addressServiceProvider).setDefault(userId, address.id!);
                      ref.invalidate(userAddressesProvider(userId));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepCharcoal,
                      side: const BorderSide(color: AppColors.borderLight),
                      padding: EdgeInsets.symmetric(vertical: R.h(context, 8)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 6))),
                    ),
                    child: Text(
                      'Set as Default',
                      style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 12)),
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

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet Form
// ─────────────────────────────────────────────────────────────────────────────

class AddressFormSheet extends StatefulWidget {
  final String userId;
  final Address? address;
  final WidgetRef parentRef;

  const AddressFormSheet({super.key, required this.userId, this.address, required this.parentRef});

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _line1Ctrl;
  late TextEditingController _line2Ctrl;
  late TextEditingController _localityCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _pincodeCtrl;
  bool _isDefault = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _nameCtrl = TextEditingController(text: a?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: a?.phone ?? '');
    _line1Ctrl = TextEditingController(text: a?.addressLine1 ?? '');
    _line2Ctrl = TextEditingController(text: a?.addressLine2 ?? '');
    _localityCtrl = TextEditingController(text: a?.locality ?? '');
    _cityCtrl = TextEditingController(text: a?.city ?? '');
    _stateCtrl = TextEditingController(text: a?.state ?? '');
    _pincodeCtrl = TextEditingController(text: a?.pincode ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _localityCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newAddress = Address(
      id: widget.address?.id,
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      addressLine1: _line1Ctrl.text.trim(),
      addressLine2: _line2Ctrl.text.trim().isEmpty ? null : _line2Ctrl.text.trim(),
      locality: _localityCtrl.text.trim().isEmpty ? null : _localityCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      isDefault: _isDefault,
    );

    try {
      final srv = widget.parentRef.read(addressServiceProvider);
      if (widget.address == null) {
        // Adding a new address
        final newId = await srv.addAddress(widget.userId, newAddress);
        // If flagged as default, batch-update all other addresses to isDefault=false
        if (_isDefault) {
          await srv.setDefault(widget.userId, newId);
        }
      } else {
        // Editing an existing address
        await srv.updateAddress(widget.userId, widget.address!.id!, newAddress);
        // If the user toggled this address to default, clear others
        if (_isDefault) {
          await srv.setDefault(widget.userId, widget.address!.id!);
        }
      }

      widget.parentRef.invalidate(userAddressesProvider(widget.userId));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(milliseconds: 2000), content: Text('Error saving address: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.w(context, 20))),
      ),
      padding: EdgeInsets.only(
        left: R.w(context, 24),
        right: R.w(context, 24),
        top: R.h(context, 24),
        bottom: MediaQuery.of(context).viewInsets.bottom + R.h(context, 24),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.address == null ? 'Add New Address' : 'Edit Address', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded, color: AppColors.neutralGold),
                    ),
                  ],
                ),
                SizedBox(height: R.h(context, 24)),
                
                Row(
                  children: [
                    Expanded(child: _buildField('Full Name', _nameCtrl)),
                    SizedBox(width: R.w(context, 16)),
                    Expanded(child: _buildField('Phone Number', _phoneCtrl, isPhone: true)),
                  ],
                ),
                SizedBox(height: R.h(context, 16)),
                _buildField('Address Line 1 (Flat, House no., Building)', _line1Ctrl),
                SizedBox(height: R.h(context, 16)),
                _buildField('Address Line 2 (Area, Street, Sector)', _line2Ctrl, isRequired: false),
                SizedBox(height: R.h(context, 16)),
                Row(
                  children: [
                    Expanded(child: _buildField('Landmark (Locality)', _localityCtrl, isRequired: false)),
                    SizedBox(width: R.w(context, 16)),
                    Expanded(child: _buildField('Pincode', _pincodeCtrl, isNumber: true)),
                  ],
                ),
                SizedBox(height: R.h(context, 16)),
                Row(
                  children: [
                    Expanded(child: _buildField('City', _cityCtrl)),
                    SizedBox(width: R.w(context, 16)),
                    Expanded(child: _buildField('State', _stateCtrl)),
                  ],
                ),
                SizedBox(height: R.h(context, 16)),
                
                Row(
                  children: [
                    SizedBox(
                      height: R.w(context, 24),
                      width: R.w(context, 24),
                      child: Checkbox(
                        value: _isDefault,
                        onChanged: (v) => setState(() => _isDefault = v ?? false),
                        activeColor: AppColors.primary,
                        checkColor: AppColors.deepCharcoal,
                      ),
                    ),
                    SizedBox(width: R.w(context, 8)),
                    Text('Make this my default address', style: AppTypography.bodySM(context)),
                  ],
                ),
                
                SizedBox(height: R.h(context, 32)),
                SizedBox(
                  width: double.infinity,
                  height: R.h(context, 46),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.deepCharcoal,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 12))),
                    ),
                    child: _isLoading
                        ? SizedBox(width: R.w(context, 24), height: R.w(context, 24), child: CircularProgressIndicator(strokeWidth: 2, color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)))
                        : Text('Save Address', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 16), color: AppColors.deepCharcoal)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isRequired = true, bool isPhone = false, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10))),
        SizedBox(height: R.h(context, 6)),
        TextFormField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : (isNumber ? TextInputType.number : TextInputType.text),
          validator: isRequired ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
          style: AppTypography.bodySM(context),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: R.w(context, 12), vertical: R.h(context, 12)),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : AppColors.backgroundLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 8)), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 8)), borderSide: const BorderSide(color: AppColors.primary)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 8)), borderSide: const BorderSide(color: AppColors.error)),
          ),
        ),
      ],
    );
  }
}
