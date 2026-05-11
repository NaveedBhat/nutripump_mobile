import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/cart_provider.dart';
import '../checkout_screen.dart';

class CheckoutReviewStep extends ConsumerWidget {
  final CartState cart;

  const CheckoutReviewStep({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(R.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Review Order',
                    style: AppTypography.h2(context)
                        .copyWith(fontSize: R.sp(context, 24))),
                TextButton(
                  onPressed: () =>
                      ref.read(checkoutStepProvider.notifier).state = 0,
                  style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      padding:
                          EdgeInsets.symmetric(horizontal: R.w(context, 16))),
                  child: Text('EDIT DETAILS',
                      style: AppTypography.label(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800)),
                )
              ],
            ),
            SizedBox(height: R.h(context, 24)),

            // Delivery Review
            Container(
              padding: EdgeInsets.all(R.w(context, 20)),
              decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  borderRadius: BorderRadius.circular(R.w(context, 20)),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 20)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          size: R.sp(context, 16), color: AppColors.primary),
                      SizedBox(width: R.w(context, 8)),
                      Text('DELIVERING TO',
                          style: AppTypography.label(context).copyWith(
                              color: AppColors.primary,
                              letterSpacing: 1.5,
                              fontSize: R.sp(context, 10))),
                    ],
                  ),
                  SizedBox(height: R.h(context, 12)),
                  Consumer(builder: (context, ref, _) {
                    final address = ref.watch(selectedAddressProvider);
                    if (address == null) {
                      return const Text('No address selected');
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address.fullName,
                            style: AppTypography.bodySM(context).copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: R.sp(context, 15))),
                        SizedBox(height: R.h(context, 4)),
                        Text(
                            '${address.addressLine1}${address.locality != null ? ', ${address.locality}' : ''}',
                            style: AppTypography.bodySM(context)
                                .copyWith(color: AppColors.neutralGold)),
                        Text(
                            '${address.city}, ${address.state} - ${address.pincode}',
                            style: AppTypography.bodySM(context)
                                .copyWith(color: AppColors.neutralGold)),
                        SizedBox(height: R.h(context, 6)),
                        Text(address.phone,
                            style: AppTypography.bodySM(context)
                                .copyWith(fontWeight: FontWeight.w600)),
                      ],
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: R.h(context, 16)),

            // Payment Review
            Container(
              padding: EdgeInsets.all(R.w(context, 20)),
              decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  borderRadius: BorderRadius.circular(R.w(context, 20)),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 20)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          size: R.sp(context, 16), color: AppColors.primary),
                      SizedBox(width: R.w(context, 8)),
                      Text('PAYMENT METHOD',
                          style: AppTypography.label(context).copyWith(
                              color: AppColors.primary,
                              letterSpacing: 1.5,
                              fontSize: R.sp(context, 10))),
                    ],
                  ),
                  SizedBox(height: R.h(context, 12)),
                  Consumer(builder: (context, ref, _) {
                    final method = ref.watch(paymentMethodProvider);
                    final label = method == 'upi'
                        ? 'UPI'
                        : method == 'card'
                            ? 'Credit/Debit Card'
                            : method == 'netbanking'
                                ? 'Net Banking'
                                : 'Cash on Delivery';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: AppTypography.bodySM(context).copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: R.sp(context, 15))),
                        SizedBox(height: R.h(context, 4)),
                        Text(
                            method == 'cod'
                                ? 'Awaiting payment upon confirmed delivery.'
                                : 'Secured digitally via Razorpay gateway.',
                            style: AppTypography.bodySM(context)
                                .copyWith(color: AppColors.neutralGold)),
                      ],
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: R.h(context, 32)),

            Text('Artisan Products to Ship', style: AppTypography.h3(context)),
            SizedBox(height: R.h(context, 16)),
            ...cart.items.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: R.h(context, 16)),
                  child: Row(
                    children: [
                      Container(
                        width: R.w(context, 64),
                        height: R.w(context, 64),
                        decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius:
                                BorderRadius.circular(R.w(context, 12)),
                            image: item.product.primaryImage.isNotEmpty
                                ? DecorationImage(
                                    image:
                                        NetworkImage(item.product.primaryImage),
                                    fit: BoxFit.cover)
                                : null),
                      ),
                      SizedBox(width: R.w(context, 16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySM(context)
                                    .copyWith(fontWeight: FontWeight.bold)),
                            SizedBox(height: R.h(context, 4)),
                            Text(
                                '${item.selectedWeight ?? item.product.weight} · Qty ${item.quantity}',
                                style: AppTypography.label(context).copyWith(
                                    fontSize: R.sp(context, 10),
                                    color: AppColors.neutralGold,
                                    letterSpacing: 1.2)),
                          ],
                        ),
                      ),
                      Text(formatPrice(item.effectivePrice * item.quantity),
                          style: AppTypography.price(context).copyWith(
                              fontSize: R.sp(context, 14),
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFFF5F0E8)
                                  : AppColors.deepCharcoal)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
