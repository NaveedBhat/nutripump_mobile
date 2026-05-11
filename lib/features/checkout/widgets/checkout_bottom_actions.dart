import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/providers.dart';
import '../checkout_screen.dart';

class CheckoutBottomActions extends ConsumerWidget {
  final int step;
  final CartState cart;
  final VoidCallback onPlaceOrder;

  const CheckoutBottomActions({
    super.key,
    required this.step,
    required this.cart,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -10),
              blurRadius: 30)
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          R.w(context, 24),
          R.h(context, 20),
          R.w(context, 24),
          MediaQuery.of(context).padding.bottom + R.h(context, 20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated Total',
                  style: AppTypography.bodySM(context)
                      .copyWith(fontWeight: FontWeight.bold)),
              Consumer(builder: (context, ref, _) {
                final method = ref.watch(paymentMethodProvider);
                final settings = ref.watch(paymentSettingsProvider).value;
                final codCharge = (method == 'cod' && settings != null)
                    ? settings.codCharge
                    : 0.0;
                return Text(formatPrice(cart.total + codCharge),
                    style: AppTypography.h2(context)
                        .copyWith(fontSize: R.sp(context, 24), height: 1));
              }),
            ],
          ),
          SizedBox(height: R.h(context, 16)),
          SizedBox(
            width: double.infinity,
            height: R.h(context, 56),
            child: ElevatedButton(
              onPressed: () {
                if (step == 0) {
                  if (ref.read(selectedAddressProvider) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        duration: Duration(milliseconds: 2000),
                        content: Text('Please select a delivery address')));
                    return;
                  }
                  ref.read(checkoutStepProvider.notifier).state = 1;
                } else if (step == 1) {
                  // Final Place Order
                  onPlaceOrder();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.deepCharcoal,
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.w(context, 16))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(step == 0 ? 'Review Order' : 'Place Order & Pay',
                      style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: R.sp(context, 16),
                          color: AppColors.deepCharcoal)),
                  SizedBox(width: R.w(context, 8)),
                  Icon(
                      step == 0
                          ? Icons.arrow_forward_rounded
                          : Icons.lock_outline_rounded,
                      size: R.sp(context, 20),
                      color: AppColors.deepCharcoal),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
