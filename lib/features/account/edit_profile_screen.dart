import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;
  String? _selectedGender;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize fields with current user data synchronously
    // By the time we hit this screen, the authStateProvider should already have the user.
    final user = ref.read(authStateProvider).value;
    
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _dobCtrl = TextEditingController(text: user?.dob ?? '');
    _selectedGender = user?.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'displayName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'dob': _dobCtrl.text.trim(),
        if (_selectedGender != null) 'gender': _selectedGender,
      };

      await ref.read(authServiceProvider).updateProfile(user.uid, data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully', style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e', style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
              onSurface: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
      appBar: AppBar(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : Colors.white),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Edit Profile', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(context, 24)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personal Information', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
              SizedBox(height: R.h(context, 8)),
              Text(
                'Update your details to ensure smooth deliveries and personalized recommendations.',
                style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold),
              ),
              SizedBox(height: R.h(context, 32)),

              // Full Name
              _buildLabel('Full Name'),
              TextFormField(
                controller: _nameCtrl,
                validator: (val) => val == null || val.trim().isEmpty ? 'Name cannot be empty' : null,
                style: AppTypography.bodySM(context),
                decoration: _inputDecoration('e.g. Naveed Bhat'),
              ),
              SizedBox(height: R.h(context, 20)),

              // Phone Number
              _buildLabel('Phone Number'),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: AppTypography.bodySM(context),
                decoration: _inputDecoration('e.g. +91 9876543210'),
              ),
              SizedBox(height: R.h(context, 20)),

              // Date of Birth
              _buildLabel('Date of Birth'),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dobCtrl,
                    style: AppTypography.bodySM(context),
                    decoration: _inputDecoration('YYYY-MM-DD').copyWith(
                      suffixIcon: Icon(Icons.calendar_today_rounded, size: R.sp(context, 20), color: AppColors.neutralGold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(context, 20)),

              // Gender
              _buildLabel('Gender (Optional)'),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (val) => setState(() => _selectedGender = val),
                style: AppTypography.bodySM(context).copyWith(color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
                decoration: _inputDecoration('Select gender'),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutralGold),
              ),

              SizedBox(height: R.h(context, 48)),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: R.h(context, 54),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.deepCharcoal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 12))),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: R.w(context, 24), height: R.w(context, 24),
                          child: CircularProgressIndicator(strokeWidth: 2, color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
                        )
                      : Text('Save Changes', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 16), color: AppColors.deepCharcoal)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(context, 8)),
      child: Text(text, style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 11))),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
      contentPadding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 16)),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
