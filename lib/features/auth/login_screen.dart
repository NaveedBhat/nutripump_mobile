import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? from;
  const LoginScreen({super.key, this.from});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final form = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(6)],
    ),
  });

  Future<void> _handleEmailLogin() async {
    if (form.invalid) {
      form.markAllAsTouched();
      return;
    }

    setState(() => _isLoading = true);
    final email = form.control('email').value as String;
    final password = form.control('password').value as String;

    try {
      final user = await ref.read(authServiceProvider).signInWithEmail(email, password);

      if (!user.emailVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please verify your email first.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Welcome back! 🌿')),
          );
          _navigateSuccess();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An unexpected error occurred. Please try again.';
        final errorString = e.toString().toLowerCase();
        
        if (errorString.contains('invalid-credential') || 
            errorString.contains('wrong-password') || 
            errorString.contains('user-not-found') ||
            errorString.contains('incorrect')) {
          errorMessage = 'Incorrect email or password.';
        } else if (errorString.contains('network-request-failed') || errorString.contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (errorString.contains('too-many-requests')) {
          errorMessage = 'Too many attempts. Please try again later.';
        } else {
           // Fallback for other errors, cleanly formatted
           errorMessage = e.toString().replaceAll('Exception: ', '').split(']').last.trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F), // Material Red 700
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            elevation: 4,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome! 🌿')),
        );
        _navigateSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text('Google sign in failed. Please try again.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            elevation: 4,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _navigateSuccess() {
    if (widget.from != null && widget.from!.isNotEmpty) {
      context.go(widget.from!);
    } else {
      context.go('/');
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Logo
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/nutripumplogo.webp',
                      height: 60,
                      errorBuilder: (_, __, ___) => const Icon(Icons.eco_rounded, size: 50, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('NUTRIPUMP', style: AppTypography.h3.copyWith(color: Colors.white, letterSpacing: 2, fontSize: 18)),
                        const SizedBox(width: 4),
                        Text('Artisanal', style: AppTypography.labelGold.copyWith(letterSpacing: 0, fontSize: 14, fontStyle: FontStyle.italic, textBaseline: TextBaseline.alphabetic)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Bottom Sheet Form
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back', style: AppTypography.h2.copyWith(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text('Sign in to your artisan pantry account.', style: AppTypography.bodySM.copyWith(color: AppColors.neutralGold, fontSize: 14)),
                        const SizedBox(height: 36),

                        // Google Button
                        ElevatedButton(
                          onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.deepCharcoal,
                            elevation: 2,
                            shadowColor: Colors.black.withValues(alpha: 0.05),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isGoogleLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/icons/google.png',
                                      width: 22,
                                      height: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text('Continue with Google', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 28),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.2))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR SIGN IN WITH EMAIL', style: AppTypography.labelGold.copyWith(fontSize: 10, letterSpacing: 1.5)),
                            ),
                            Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.2))),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Email
                        Text('EMAIL ADDRESS', style: AppTypography.label.copyWith(color: AppColors.neutralGold, fontSize: 10)),
                        const SizedBox(height: 8),
                        ReactiveTextField<String>(
                          formControlName: 'email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'you@example.com',
                            hintStyle: AppTypography.bodySM.copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.neutralGold),
                            filled: true, fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PASSWORD', style: AppTypography.label.copyWith(color: AppColors.neutralGold, fontSize: 10)),
                            GestureDetector(
                              onTap: () => context.push('/auth/forgot-password'),
                              child: Text('Forgot password?', style: AppTypography.bodySM.copyWith(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ReactiveTextField<String>(
                          formControlName: 'password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleEmailLogin(),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            hintStyle: AppTypography.bodySM.copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.neutralGold),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.neutralGold),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true, fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Submit
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.deepCharcoal,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.deepCharcoal)))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Sign In', style: AppTypography.bodySM.copyWith(fontWeight: FontWeight.w800, fontSize: 16)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 32),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: AppTypography.bodySM.copyWith(color: AppColors.neutralGold, fontSize: 14)),
                            GestureDetector(
                              onTap: () => context.push('/auth/register'),
                              child: Text('Create one', style: AppTypography.bodySM.copyWith(color: AppColors.primaryDark, fontSize: 14, fontWeight: FontWeight.w700)),
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
