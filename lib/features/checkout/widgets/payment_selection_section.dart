import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/providers.dart';
import '../checkout_screen.dart' show paymentMethodProvider;

class PaymentSelectionSection extends ConsumerStatefulWidget {
  const PaymentSelectionSection({super.key});

  @override
  ConsumerState<PaymentSelectionSection> createState() =>
      _PaymentSelectionSectionState();
}

class _PaymentSelectionSectionState
    extends ConsumerState<PaymentSelectionSection> {
  /// Runs the auto-switch check after each dependency change (settings or
  /// cart subtotal). Uses addPostFrameCallback so state mutations happen
  /// after the current frame, never during build.
  void _autoSwitchIfNeeded() {
    final settings = ref.read(paymentSettingsProvider).value;
    if (settings == null) return;

    final selectedMethod = ref.read(paymentMethodProvider);
    final cartSubtotal = ref.read(cartProvider).subtotal;
    final isCodAvailableByAmount =
        cartSubtotal >= settings.codMinOrder || settings.codMinOrder == 0;

    bool isValid = false;
    if (selectedMethod == 'upi' && settings.upi) isValid = true;
    if (selectedMethod == 'card' && settings.card) isValid = true;
    if (selectedMethod == 'netbanking' && settings.netbanking) isValid = true;
    if (selectedMethod == 'cod' && settings.cod && isCodAvailableByAmount) {
      isValid = true;
    }

    if (!isValid && selectedMethod.isNotEmpty) {
      String newMethod = '';
      if (settings.upi) {
        newMethod = 'upi';
      } else if (settings.card) {
        newMethod = 'card';
      } else if (settings.netbanking) {
        newMethod = 'netbanking';
      } else if (settings.cod && isCodAvailableByAmount) {
        newMethod = 'cod';
      }

      if (newMethod.isNotEmpty && newMethod != selectedMethod) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(paymentMethodProvider.notifier).state = newMethod;
          }
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autoSwitchIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMethod = ref.watch(paymentMethodProvider);
    final paymentSettingsAsync = ref.watch(paymentSettingsProvider);
    final cartState = ref.watch(cartProvider);

    return paymentSettingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading payment methods'),
      data: (settings) {
        final isCodAvailableByAmount =
            cartState.subtotal >= settings.codMinOrder ||
                settings.codMinOrder == 0;

        return Column(
          children: [
            _buildMethod(ref,
                id: 'upi',
                title: 'UPI',
                subtitle: 'Google Pay, PhonePe, Paytm',
                icon: Icons.qr_code_2_rounded,
                selectedMethod: selectedMethod,
                isEnabled: settings.upi),
            _buildMethod(ref,
                id: 'card',
                title: 'Credit / Debit Card',
                subtitle: 'Visa, Mastercard, RuPay',
                icon: Icons.credit_card_rounded,
                selectedMethod: selectedMethod,
                isEnabled: settings.card),
            _buildMethod(ref,
                id: 'netbanking',
                title: 'Net Banking',
                subtitle: 'All Indian banks',
                icon: Icons.account_balance_rounded,
                selectedMethod: selectedMethod,
                isEnabled: settings.netbanking),
            _buildMethod(
              ref,
              id: 'cod',
              title: 'Cash on Delivery',
              subtitle: 'Pay via cash or UPI on delivery',
              icon: Icons.payments_outlined,
              selectedMethod: selectedMethod,
              isEnabled: settings.cod && isCodAvailableByAmount,
              lockedReason: (!settings.cod)
                  ? null
                  : (!isCodAvailableByAmount
                      ? 'Min order ₹${settings.codMinOrder.toInt()}'
                      : null),
              codCharge: settings.codCharge,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMethod(
    WidgetRef ref, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required String selectedMethod,
    required bool isEnabled,
    String? lockedReason,
    double codCharge = 0,
  }) {
    final isSelected = selectedMethod == id;
    return GestureDetector(
      onTap: () {
        if (isEnabled) ref.read(paymentMethodProvider.notifier).state = id;
      },
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(context, 12)),
        padding: EdgeInsets.all(R.w(context, 16)),
        decoration: BoxDecoration(
          color: !isEnabled
              ? (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.borderLight.withValues(alpha: 0.3))
              : isSelected
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : Colors.white),
          borderRadius: BorderRadius.circular(R.w(context, 16)),
          border: Border.all(
              color: !isEnabled
                  ? AppColors.borderLight.withValues(alpha: 0.5)
                  : isSelected
                      ? AppColors.primary
                      : AppColors.borderLight,
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(R.w(context, 8)),
              decoration: BoxDecoration(
                  color: !isEnabled
                      ? AppColors.borderLight
                      : isSelected
                          ? AppColors.primary
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).scaffoldBackgroundColor
                              : AppColors.backgroundLight),
                  borderRadius: BorderRadius.circular(R.w(context, 8))),
              child: Icon(!isEnabled ? Icons.lock_outline : icon,
                  color: !isEnabled
                      ? AppColors.neutralGold.withValues(alpha: 0.5)
                      : isSelected
                          ? AppColors.deepCharcoal
                          : AppColors.neutralGold,
                  size: R.sp(context, 20)),
            ),
            SizedBox(width: R.w(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: R.w(context, 8),
                    runSpacing: R.h(context, 4),
                    children: [
                      Text(title,
                          style: AppTypography.bodySM(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: !isEnabled
                                  ? AppColors.neutralGold
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFF5F0E8)
                                      : AppColors.deepCharcoal))),
                      if (!isEnabled)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: R.w(context, 6),
                              vertical: R.h(context, 2)),
                          decoration: BoxDecoration(
                              color: AppColors.borderLight,
                              borderRadius:
                                  BorderRadius.circular(R.w(context, 4))),
                          child: Text(lockedReason ?? 'UNAVAILABLE',
                              style: AppTypography.label(context).copyWith(
                                  fontSize: R.sp(context, 8),
                                  color: AppColors.neutralGold)),
                        ),
                      if (isEnabled &&
                          id == 'cod' &&
                          isSelected &&
                          codCharge > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: R.w(context, 6),
                              vertical: R.h(context, 2)),
                          decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius:
                                  BorderRadius.circular(R.w(context, 4)),
                              border: Border.all(color: Colors.amber.shade300)),
                          child: Text('+₹${codCharge.toInt()} COD charge',
                              style: AppTypography.label(context).copyWith(
                                  fontSize: R.sp(context, 8),
                                  color: Colors.amber.shade900)),
                        ),
                    ],
                  ),
                  Text(subtitle,
                      style: AppTypography.label(context).copyWith(
                          fontSize: R.sp(context, 10),
                          color: !isEnabled
                              ? AppColors.neutralGold.withValues(alpha: 0.5)
                              : AppColors.neutralGold)),
                ],
              ),
            ),
            Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: !isEnabled
                    ? AppColors.borderLight
                    : isSelected
                        ? AppColors.primary
                        : AppColors.borderLight),
          ],
        ),
      ),
    );
  }
}
