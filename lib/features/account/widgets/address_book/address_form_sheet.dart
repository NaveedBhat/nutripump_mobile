import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../providers/providers.dart';
import '../../../../models/cart_item.dart';

class AddressFormSheet extends StatefulWidget {
  final String userId;
  final Address? address;
  final WidgetRef parentRef;

  const AddressFormSheet(
      {super.key, required this.userId, this.address, required this.parentRef});

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
  bool _isLocating = false;

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

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      // Check & request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: const Text(
                  'Location permission is permanently denied. Please enable it in Settings.'),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: 'Open Settings',
                textColor: Colors.white,
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        return;
      }
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 2),
              content: Text('Location permission denied.'),
            ),
          );
        }
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Reverse geocode
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 2),
              content: Text('Could not determine address from your location.'),
            ),
          );
        }
        return;
      }

      final Placemark p = placemarks.first;

      // ── Address Line 1: house/flat number + street name ──────────────────
      final String line1 = [
        p.subThoroughfare,
        p.thoroughfare,
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      // ── Address Line 2: neighbourhood / sub-locality only ────────────────
      final String line2 = (p.subLocality ?? '').trim();

      // ── City: locality → subAdministrativeArea fallback ──────────────────
      final String city = [
            p.locality,
            p.subAdministrativeArea,
          ].firstWhere((s) => s != null && s.isNotEmpty, orElse: () => '') ??
          '';

      // ── State: administrativeArea → subAdministrativeArea fallback ────────
      String state = (p.administrativeArea ?? '').trim();
      if (state.isEmpty && city.isNotEmpty) {
        state = (p.subAdministrativeArea ?? '').trim();
      }

      if (mounted) {
        setState(() {
          if (line1.isNotEmpty) _line1Ctrl.text = line1;
          if (line2.isNotEmpty) _line2Ctrl.text = line2;
          // Landmark: prefer subAdministrativeArea (district/county)
          if ((p.subAdministrativeArea ?? '').isNotEmpty) {
            _localityCtrl.text = p.subAdministrativeArea!.trim();
          }
          if ((p.postalCode ?? '').isNotEmpty) {
            _pincodeCtrl.text = p.postalCode!.trim();
          }
          if (city.isNotEmpty) _cityCtrl.text = city;
          if (state.isNotEmpty) _stateCtrl.text = state;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            content: Text('📍 Address filled from your current location!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('Failed to get location: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newAddress = Address(
      id: widget.address?.id,
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      addressLine1: _line1Ctrl.text.trim(),
      addressLine2:
          _line2Ctrl.text.trim().isEmpty ? null : _line2Ctrl.text.trim(),
      locality:
          _localityCtrl.text.trim().isEmpty ? null : _localityCtrl.text.trim(),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Text('Error saving address: $e'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                    Text(
                        widget.address == null
                            ? 'Add New Address'
                            : 'Edit Address',
                        style: AppTypography.h3(context)
                            .copyWith(fontSize: R.sp(context, 16))),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.neutralGold),
                    ),
                  ],
                ),
                SizedBox(height: R.h(context, 16)),

                // ── Use Current Location Button ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLocating ? null : _useCurrentLocation,
                    icon: _isLocating
                        ? SizedBox(
                            width: R.w(context, 16),
                            height: R.w(context, 16),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(Icons.my_location_rounded,
                            size: R.sp(context, 16), color: AppColors.primary),
                    label: Text(
                      _isLocating
                          ? 'Detecting location…'
                          : 'Use My Current Location',
                      style: AppTypography.bodySM(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: R.sp(context, 13),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.05),
                      padding: EdgeInsets.symmetric(
                        vertical: R.h(context, 12),
                        horizontal: R.w(context, 16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 10)),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: R.h(context, 20)),

                Row(
                  children: [
                    Expanded(child: _buildField('Full Name', _nameCtrl)),
                    SizedBox(width: R.w(context, 16)),
                    Expanded(
                        child: _buildField('Phone Number', _phoneCtrl,
                            isPhone: true)),
                  ],
                ),
                SizedBox(height: R.h(context, 16)),
                _buildField(
                    'Address Line 1 (Flat, House no., Building)', _line1Ctrl),
                SizedBox(height: R.h(context, 16)),
                _buildField('Address Line 2 (Area, Street, Sector)', _line2Ctrl,
                    isRequired: false),
                SizedBox(height: R.h(context, 16)),
                Row(
                  children: [
                    Expanded(
                        child: _buildField('Landmark (Locality)', _localityCtrl,
                            isRequired: false)),
                    SizedBox(width: R.w(context, 16)),
                    Expanded(
                        child: _buildField('Pincode', _pincodeCtrl,
                            isNumber: true)),
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
                        onChanged: (v) =>
                            setState(() => _isDefault = v ?? false),
                        activeColor: AppColors.primary,
                        checkColor: AppColors.deepCharcoal,
                      ),
                    ),
                    SizedBox(width: R.w(context, 8)),
                    Text('Make this my default address',
                        style: AppTypography.bodySM(context)),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(context, 16), vertical: 0),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(R.w(context, 12))),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: R.w(context, 24),
                            height: R.w(context, 24),
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Theme.of(context).colorScheme.onSurface
                                    : AppColors.deepCharcoal)))
                        : Text('Save Address',
                            style: AppTypography.bodySM(context).copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: R.sp(context, 16),
                                color: AppColors.deepCharcoal)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool isRequired = true, bool isPhone = false, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.label(context)
                .copyWith(fontSize: R.sp(context, 10))),
        SizedBox(height: R.h(context, 6)),
        TextFormField(
          controller: controller,
          keyboardType: isPhone
              ? TextInputType.phone
              : (isNumber ? TextInputType.number : TextInputType.text),
          validator: isRequired
              ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
              : null,
          style: AppTypography.bodySM(context),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: R.w(context, 12), vertical: R.h(context, 12)),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.backgroundLight,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.w(context, 8)),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.w(context, 8)),
                borderSide: const BorderSide(color: AppColors.primary)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.w(context, 8)),
                borderSide: const BorderSide(color: AppColors.error)),
          ),
        ),
      ],
    );
  }
}
