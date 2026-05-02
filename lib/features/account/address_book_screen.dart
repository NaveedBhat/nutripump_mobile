import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/providers.dart';
import '../../models/cart_item.dart';

class AddressBookScreen extends ConsumerWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Address Book', style: AppTypography.h3(context)),
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
              child: Text('Please sign in to view your addresses.', style: AppTypography.bodySM(context)),
            );
          }

          final addressesAsync = ref.watch(userAddressesProvider(user.uid));

          return addressesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
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
                        padding: const EdgeInsets.all(40),
                        children: [
                          const SizedBox(height: 60),
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
                            ),
                            child: const Icon(Icons.location_on_outlined, size: 40, color: AppColors.primary),
                          ),
                          const SizedBox(height: 24),
                          Text('No addresses found', textAlign: TextAlign.center, style: AppTypography.h2(context).copyWith(fontSize: 22)),
                          const SizedBox(height: 10),
                          Text(
                            'Add a delivery address to make checkout faster and easier.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, height: 1.6, fontSize: 14),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
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
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddressForm(context, ref, userAsync.value!.uid),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text('Add New Address', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.deepCharcoal,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        backgroundColor: Colors.white,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: address.isDefault ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepCharcoal.withValues(alpha: 0.02),
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
                      style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('DEFAULT', style: AppTypography.label(context).copyWith(fontSize: 9, color: AppColors.primaryDark)),
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
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.edit_outlined, size: 18, color: AppColors.neutralGold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(address.phone, style: AppTypography.bodySM(context).copyWith(fontSize: 13)),
          const SizedBox(height: 6),
          Text(address.oneLineAddress, style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 13, height: 1.4)),
          
          if (!address.isDefault) ...[
            const SizedBox(height: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      'Set as Default',
                      style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: 12),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving address: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                    Text(widget.address == null ? 'Add New Address' : 'Edit Address', style: AppTypography.h3(context)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded, color: AppColors.neutralGold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(child: _buildField('Full Name', _nameCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildField('Phone Number', _phoneCtrl, isPhone: true)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField('Address Line 1 (Flat, House no., Building)', _line1Ctrl),
                const SizedBox(height: 16),
                _buildField('Address Line 2 (Area, Street, Sector)', _line2Ctrl, isRequired: false),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildField('Landmark (Locality)', _localityCtrl, isRequired: false)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildField('Pincode', _pincodeCtrl, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildField('City', _cityCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildField('State', _stateCtrl)),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isDefault,
                        onChanged: (v) => setState(() => _isDefault = v ?? false),
                        activeColor: AppColors.primary,
                        checkColor: AppColors.deepCharcoal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Make this my default address', style: AppTypography.bodySM(context)),
                  ],
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.deepCharcoal,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deepCharcoal))
                        : Text('Save Address', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 16)),
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
        Text(label, style: AppTypography.label(context).copyWith(fontSize: 10)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : (isNumber ? TextInputType.number : TextInputType.text),
          validator: isRequired ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null,
          style: AppTypography.bodySM(context),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: AppColors.backgroundLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.error)),
          ),
        ),
      ],
    );
  }
}
