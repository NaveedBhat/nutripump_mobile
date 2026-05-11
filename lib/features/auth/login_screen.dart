import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
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
      final user =
          await ref.read(authServiceProvider).signInWithEmail(email, password);

      if (!user.emailVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                duration: Duration(milliseconds: 2000),
                content: Text('Please verify your email first.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                duration: Duration(milliseconds: 2000),
                content: Text('Welcome back! 🌿')),
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
        } else if (errorString.contains('network-request-failed') ||
            errorString.contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (errorString.contains('too-many-requests')) {
          errorMessage = 'Too many attempts. Please try again later.';
        } else {
          // Fallback for other errors, cleanly formatted
          errorMessage =
              e.toString().replaceAll('Exception: ', '').split(']').last.trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(errorMessage,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500))),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F), // Material Red 700
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
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
          const SnackBar(
              duration: Duration(milliseconds: 2000),
              content: Text('Welcome! 🌿')),
        );
        _navigateSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: const Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                    child: Text('Google sign in failed. Please try again.',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500))),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.deepCharcoal,
      body: SafeArea(
        bottom: false,
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            children: [
              // Top Header
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 16), vertical: R.h(context, 8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final themeMode = ref.watch(themeProvider);
                        final isDark = themeMode == ThemeMode.dark ||
                            (themeMode == ThemeMode.system &&
                                MediaQuery.platformBrightnessOf(context) ==
                                    Brightness.dark);
                        return GestureDetector(
                          onTap: () {
                            ref.read(themeProvider.notifier).setTheme(
                                isDark ? ThemeMode.light : ThemeMode.dark);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(R.w(context, 8)),
                            child: Icon(
                              isDark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.h(context, 10)),

              // Logo
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/nutripumplogo.webp',
                      height: R.h(context, 60),
                      errorBuilder: (_, __, ___) => Icon(Icons.eco_rounded,
                          size: R.sp(context, 50), color: AppColors.primary),
                    ),
                    SizedBox(height: R.h(context, 12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('NUTRIPUMP',
                            style: AppTypography.h3(context).copyWith(
                                color: Colors.white,
                                letterSpacing: 2,
                                fontSize: R.sp(context, 18))),
                        SizedBox(width: R.w(context, 4)),
                        Text('Artisanal',
                            style: AppTypography.labelGold(context).copyWith(
                                letterSpacing: 0,
                                fontSize: R.sp(context, 14),
                                fontStyle: FontStyle.italic,
                                textBaseline: TextBaseline.alphabetic)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.h(context, 40)),

              // Bottom Sheet Form
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(R.w(context, 32))),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(R.w(context, 28),
                        R.h(context, 36), R.w(context, 28), R.h(context, 40)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back',
                            style: AppTypography.h2(context)
                                .copyWith(fontSize: R.sp(context, 28))),
                        SizedBox(height: R.h(context, 6)),
                        Text('Sign in to your artisan pantry account.',
                            style: AppTypography.bodySM(context).copyWith(
                                color: AppColors.neutralGold,
                                fontSize: R.sp(context, 14))),
                        SizedBox(height: R.h(context, 36)),

                        // Google Button
                        ElevatedButton(
                          onPressed:
                              _isGoogleLoading ? null : _handleGoogleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            foregroundColor: AppColors.deepCharcoal,
                            elevation: 2,
                            shadowColor: Colors.black.withValues(alpha: 0.05),
                            padding: EdgeInsets.symmetric(
                                vertical: R.h(context, 16)),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(R.w(context, 14))),
                          ),
                          child: _isGoogleLoading
                              ? SizedBox(
                                  height: R.h(context, 20),
                                  width: R.w(context, 20),
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/icons/google.png',
                                      width: R.w(context, 22),
                                      height: R.w(context, 22),
                                    ),
                                    SizedBox(width: R.w(context, 12)),
                                    Text('Continue with Google',
                                        style: AppTypography.bodySM(context)
                                            .copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: R.sp(context, 14))),
                                  ],
                                ),
                        ),
                        SizedBox(height: R.h(context, 28)),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.2))),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: R.w(context, 16)),
                              child: Text('OR SIGN IN WITH EMAIL',
                                  style: AppTypography.labelGold(context)
                                      .copyWith(
                                          fontSize: R.sp(context, 10),
                                          letterSpacing: 1.5)),
                            ),
                            Expanded(
                                child: Divider(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.2))),
                          ],
                        ),
                        SizedBox(height: R.h(context, 28)),

                        // Email
                        Text('EMAIL ADDRESS',
                            style: AppTypography.label(context).copyWith(
                                color: AppColors.neutralGold,
                                fontSize: R.sp(context, 10))),
                        SizedBox(height: R.h(context, 8)),
                        ReactiveTextField<String>(
                          formControlName: 'email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onTapOutside: (event) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          onTap: (control) {
                            if (control.hasFocus) {
                              control.unfocus();
                              Future.delayed(const Duration(milliseconds: 50),
                                  () => control.focus());
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'you@example.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded,
                                size: R.sp(context, 18),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFF5F0E8)
                                    : AppColors.neutralGold),
                          ),
                        ),
                        SizedBox(height: R.h(context, 20)),

                        // Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PASSWORD',
                                style: AppTypography.label(context).copyWith(
                                    color: AppColors.neutralGold,
                                    fontSize: R.sp(context, 10))),
                            GestureDetector(
                              onTap: () =>
                                  context.push('/auth/forgot-password'),
                              child: Text('Forgot password?',
                                  style: AppTypography.bodySM(context).copyWith(
                                      color: AppColors.primaryDark,
                                      fontSize: R.sp(context, 12),
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        SizedBox(height: R.h(context, 8)),
                        ReactiveTextField<String>(
                          formControlName: 'password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onTapOutside: (event) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          onTap: (control) {
                            if (control.hasFocus) {
                              control.unfocus();
                              Future.delayed(const Duration(milliseconds: 50),
                                  () => control.focus());
                            }
                          },
                          onSubmitted: (_) => _handleEmailLogin(),
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: Icon(Icons.lock_outline_rounded,
                                size: R.sp(context, 18),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFF5F0E8)
                                    : AppColors.neutralGold),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: R.sp(context, 18),
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFF5F0E8)
                                      : AppColors.neutralGold),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        SizedBox(height: R.h(context, 36)),

                        // Submit
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.deepCharcoal,
                            elevation: 0,
                            minimumSize:
                                Size(double.infinity, R.h(context, 54)),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(R.w(context, 14))),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: R.h(context, 20),
                                  width: R.w(context, 20),
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                          AppColors.deepCharcoal)))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Sign In',
                                        style: AppTypography.bodySM(context)
                                            .copyWith(
                                                fontWeight: FontWeight.w800,
                                                fontSize: R.sp(context, 16),
                                                color: AppColors.deepCharcoal)),
                                    SizedBox(width: R.w(context, 8)),
                                    Icon(Icons.arrow_forward_rounded,
                                        size: R.sp(context, 18),
                                        color: AppColors.deepCharcoal),
                                  ],
                                ),
                        ),
                        SizedBox(height: R.h(context, 32)),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ",
                                style: AppTypography.bodySM(context).copyWith(
                                    color: AppColors.neutralGold,
                                    fontSize: R.sp(context, 14))),
                            GestureDetector(
                              onTap: () => context.push('/auth/register'),
                              child: Text('Create one',
                                  style: AppTypography.bodySM(context).copyWith(
                                      color: AppColors.primaryDark,
                                      fontSize: R.sp(context, 14),
                                      fontWeight: FontWeight.w700)),
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
