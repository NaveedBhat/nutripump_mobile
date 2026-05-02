import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final form = FormGroup({
    'name': FormControl<String>(
      validators: [Validators.required, Validators.minLength(2)],
    ),
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(6)],
    ),
    'confirmPassword': FormControl<String>(
      validators: [Validators.required],
    ),
  }, validators: [
    Validators.mustMatch('password', 'confirmPassword')
  ]);

  Future<void> _handleEmailRegister() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    setState(() => _isLoading = true);
    final email = form.control('email').value as String;
    final password = form.control('password').value as String;
    final name = form.control('name').value as String;

    try {
      await ref.read(authServiceProvider).registerWithEmail(email, password, name);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please check your email to verify.')),
        );
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '').split(']').last.trim()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isGoogleLoading = true);
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome to NutriPump! 🌿')),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign up failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepCharcoal,
      body: SafeArea(
        bottom: false,
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            children: [
              // Top Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 8)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/auth/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.h(context, 5)),
              
              // Logo
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/nutripumplogo.webp',
                      height: R.h(context, 50),
                      errorBuilder: (_, __, ___) => Icon(Icons.eco_rounded, size: R.sp(context, 40), color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.h(context, 30)),

              // Bottom Sheet Form
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(R.w(context, 32))),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(R.w(context, 28), R.h(context, 36), R.w(context, 28), R.h(context, 40)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create account', style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 28))),
                        SizedBox(height: R.h(context, 6)),
                        Text('Join to experience premium artisanal sourcing.', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 14))),
                        SizedBox(height: R.h(context, 36)),

                        // Google Button
                        ElevatedButton(
                          onPressed: _isGoogleLoading ? null : _handleGoogleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.deepCharcoal,
                            elevation: 2,
                            shadowColor: Colors.black.withValues(alpha: 0.05),
                            padding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 14))),
                          ),
                          child: _isGoogleLoading
                              ? SizedBox(height: R.h(context, 20), width: R.w(context, 20), child: const CircularProgressIndicator(strokeWidth: 2))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/icons/google.png',
                                      width: R.w(context, 22),
                                      height: R.w(context, 22),
                                    ),
                                    SizedBox(width: R.w(context, 12)),
                                    Text('Sign up with Google', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 14))),
                                  ],
                                ),
                        ),
                        SizedBox(height: R.h(context, 28)),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.2))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: R.w(context, 16)),
                              child: Text('OR SIGN UP WITH EMAIL', style: AppTypography.labelGold(context).copyWith(fontSize: R.sp(context, 10), letterSpacing: 1.5)),
                            ),
                            Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.2))),
                          ],
                        ),
                        SizedBox(height: R.h(context, 28)),

                        // Full Name
                        Text('FULL NAME', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 10))),
                        SizedBox(height: R.h(context, 8)),
                        ReactiveTextField<String>(
                          formControlName: 'name',
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'John Doe',
                            hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                            prefixIcon: Icon(Icons.person_outline_rounded, size: R.sp(context, 18), color: AppColors.neutralGold),
                            filled: true, fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 14)), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 14)), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                        ),
                        SizedBox(height: R.h(context, 20)),

                        // Email
                        Text('EMAIL ADDRESS', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 10))),
                        SizedBox(height: R.h(context, 8)),
                        ReactiveTextField<String>(
                          formControlName: 'email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'you@example.com',
                            hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                            prefixIcon: Icon(Icons.mail_outline_rounded, size: R.sp(context, 18), color: AppColors.neutralGold),
                            filled: true, fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 14)), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 14)), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                        ),
                        SizedBox(height: R.h(context, 20)),

                        // Password
                        Text('PASSWORD', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 10))),
                        SizedBox(height: R.h(context, 8)),
                        ReactiveTextField<String>(
                          formControlName: 'password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleEmailRegister(),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                            prefixIcon: Icon(Icons.lock_outline_rounded, size: R.sp(context, 18), color: AppColors.neutralGold),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: R.sp(context, 18), color: AppColors.neutralGold),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true, fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 14)), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 14)), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                        ),
                        SizedBox(height: R.h(context, 20)),

                        // Confirm Password
                        Text('CONFIRM PASSWORD', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 10))),
                        SizedBox(height: R.h(context, 8)),
                        ReactiveTextField<String>(
                          formControlName: 'confirmPassword',
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleEmailRegister(),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                            prefixIcon: Icon(Icons.lock_outline_rounded, size: R.sp(context, 18), color: AppColors.neutralGold),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: R.sp(context, 18), color: AppColors.neutralGold),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                            filled: true, fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 14)), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 14)), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                        ),
                        SizedBox(height: R.h(context, 36)),

                        // Submit
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.deepCharcoal,
                            elevation: 0,
                            minimumSize: Size(double.infinity, R.h(context, 54)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 14))),
                          ),
                          child: _isLoading
                              ? SizedBox(height: R.h(context, 20), width: R.w(context, 20), child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.deepCharcoal)))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Create Account', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 16))),
                                    SizedBox(width: R.w(context, 8)),
                                    Icon(Icons.arrow_forward_rounded, size: R.sp(context, 18)),
                                  ],
                                ),
                        ),
                        SizedBox(height: R.h(context, 32)),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? ", style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 14))),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Text('Sign In', style: AppTypography.bodySM(context).copyWith(color: AppColors.primaryDark, fontSize: R.sp(context, 14), fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
