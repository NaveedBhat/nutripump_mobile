import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  bool _isLoading = false;

  final form = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
  });

  Future<void> _handleResetPassword() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    setState(() => _isLoading = true);
    final email = form.control('email').value as String;

    try {
      await ref.read(authServiceProvider).sendPasswordReset(email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(duration: Duration(milliseconds: 2000), content: Text('Password reset email sent! Please check your inbox.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(duration: const Duration(milliseconds: 2000), content: Text('Error: ${e.toString().replaceAll('Exception: ', '').split(']').last.trim()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(R.w(context, 32))),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(R.w(context, 28), R.h(context, 36), R.w(context, 28), R.h(context, 40)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reset Password', style: AppTypography.h2(context).copyWith(fontSize: R.sp(context, 28))),
                        SizedBox(height: R.h(context, 6)),
                        Text('Enter your email to receive a password reset link.', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 14), height: 1.5)),
                        SizedBox(height: R.h(context, 36)),

                        // Email
                        Text('EMAIL ADDRESS', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 10))),
                        SizedBox(height: R.h(context, 8)),
                        ReactiveTextField<String>(
                          formControlName: 'email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleResetPassword(),
                          decoration: InputDecoration(
                            hintText: 'you@example.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded, size: R.sp(context, 18), color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFF5F0E8) : AppColors.neutralGold),
                          ),
                        ),
                        SizedBox(height: R.h(context, 36)),

                        // Submit
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleResetPassword,
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
                                    Text('Send Reset Link', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 16))),
                                    SizedBox(width: R.w(context, 8)),
                                    Icon(Icons.arrow_forward_rounded, size: R.sp(context, 18)),
                                  ],
                                ),
                        ),
                        SizedBox(height: R.h(context, 32)),
                        
                        // Back to login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Remembered your password? ", style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 14))),
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
