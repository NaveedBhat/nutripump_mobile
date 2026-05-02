import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _isLoading = true);

    try {
      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordCtrl.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Then update password
      await user.updatePassword(_passwordCtrl.text);
      
      if (mounted) {
        _oldPasswordCtrl.clear();
        _passwordCtrl.clear();
        _confirmPasswordCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully'), backgroundColor: AppColors.success),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = e.message ?? 'An error occurred';
        if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
          msg = 'Incorrect current password.';
        } else if (e.code == 'too-many-requests') {
          msg = 'Too many failed attempts. Please try again later.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Security', style: AppTypography.h3(context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Password', style: AppTypography.h3(context)),
              const SizedBox(height: 8),
              Text(
                'Ensure your account is using a long, random password to stay secure.',
                style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold),
              ),
              const SizedBox(height: 24),

              Text('Current Password', style: AppTypography.label(context).copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _oldPasswordCtrl,
                obscureText: _obscurePassword,
                validator: (val) => val == null || val.isEmpty ? 'Current password is required' : null,
                style: AppTypography.bodySM(context),
                decoration: _inputDecoration('Enter current password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.neutralGold),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 16),

              Text('New Password', style: AppTypography.label(context).copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                validator: (val) => val != null && val.length < 6 ? 'Password must be at least 6 characters' : null,
                style: AppTypography.bodySM(context),
                decoration: _inputDecoration('Enter new password'),
              ),
              const SizedBox(height: 16),

              Text('Confirm New Password', style: AppTypography.label(context).copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmPasswordCtrl,
                obscureText: _obscurePassword,
                validator: (val) => val != _passwordCtrl.text ? 'Passwords do not match' : null,
                style: AppTypography.bodySM(context),
                decoration: _inputDecoration('Confirm new password'),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.deepCharcoal,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deepCharcoal))
                      : Text('Update Password', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
    );
  }
}
