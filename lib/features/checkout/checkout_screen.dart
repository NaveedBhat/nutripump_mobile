import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/providers.dart';
import '../../core/utils/responsive.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'widgets/address_selection_section.dart';
import 'widgets/payment_selection_section.dart';
import 'widgets/checkout_progress_bar.dart';
import 'widgets/checkout_review_step.dart';
import 'widgets/checkout_bottom_actions.dart';

// ── Providers for Checkout State ──────────────────────────────────────────
final checkoutStepProvider = StateProvider.autoDispose<int>((ref) => 0);
final selectedAddressProvider =
    StateProvider.autoDispose<Address?>((ref) => null);
final paymentMethodProvider = StateProvider.autoDispose<String>((ref) => 'upi');
final isProcessingProvider = StateProvider.autoDispose<bool>((ref) => false);

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const steps = ['Details', 'Review', 'Payment'];

  late Razorpay _razorpay;
  String? _pendingFirestoreOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Restore pending order ID in case app was killed by OS while Razorpay was open
    final box = Hive.box('nutripump_settings');
    _pendingFirestoreOrderId = box.get('pending_order_id') as String?;

    // Pre-select default address if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final addresses =
            await ref.read(userAddressesProvider(user.uid).future);
        if (addresses.isNotEmpty) {
          final defaultAddr = addresses.cast<Address>().firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.cast<Address>().first);
          ref.read(selectedAddressProvider.notifier).state = defaultAddr;
        }
      }
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_pendingFirestoreOrderId == null) return;
    try {
      final orderId = await ref.read(checkoutApiProvider).verifyPayment(
            razorpayPaymentId: response.paymentId!,
            razorpayOrderId: response.orderId!,
            razorpaySignature: response.signature!,
            firestoreOrderId: _pendingFirestoreOrderId!,
          );

      Hive.box('nutripump_settings').delete('pending_order_id');
      _pendingFirestoreOrderId = null;

      ref.read(cartProvider.notifier).clearCart();
      ref.read(isProcessingProvider.notifier).state = false;
      if (mounted) {
        context.pushReplacement('/orders/$orderId');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 2000),
          content: Text('Order placed successfully! 🎉',
              style:
                  AppTypography.bodySM(context).copyWith(color: Colors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      ref.read(isProcessingProvider.notifier).state = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Text('Payment verification failed.',
                style: AppTypography.bodySM(context)
                    .copyWith(color: Colors.white)),
            backgroundColor: AppColors.error));
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    if (_pendingFirestoreOrderId != null) {
      try {
        await ref
            .read(checkoutApiProvider)
            .cancelOrder(_pendingFirestoreOrderId!);
      } catch (_) {
        // Best-effort cancel — if network is down the backend will
        // clean up abandoned orders via a scheduled Cloud Function.
      }
      Hive.box('nutripump_settings').delete('pending_order_id');
      _pendingFirestoreOrderId = null;
    }
    if (!mounted) return;
    ref.read(isProcessingProvider.notifier).state = false;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 2000),
          content: Text('Payment cancelled or failed.',
              style:
                  AppTypography.bodySM(context).copyWith(color: Colors.white)),
          backgroundColor: AppColors.error));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
  }

  void _handlePlaceOrder(
      CartState cart, Address address, String paymentMethod) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(milliseconds: 2000),
          content: Text('Please log in to place an order.')));
      return;
    }

    ref.read(isProcessingProvider.notifier).state = true;

    try {
      if (paymentMethod == 'cod') {
        final firestoreOrderId =
            await ref.read(checkoutApiProvider).createCodOrder(
                  items: cart.items,
                  address: address,
                  userId: user.uid,
                  appliedPromoCode: cart.appliedPromo?.code,
                  // Total implicitly uses API endpoint, but if mobile sends total we should add codCharge.
                );
        ref.read(cartProvider.notifier).clearCart();
        ref.read(isProcessingProvider.notifier).state = false;

        if (mounted) {
          context.pushReplacement('/orders/$firestoreOrderId');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Text('Order placed successfully! 🎉',
                style: AppTypography.bodySM(context)
                    .copyWith(color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        // Initialize Razorpay Order via backend
        final orderResponse = await ref.read(checkoutApiProvider).createOrder(
              items: cart.items,
              address: address,
              userId: user.uid,
              appliedPromoCode: cart.appliedPromo?.code,
            );
        _pendingFirestoreOrderId = orderResponse.firestoreOrderId;
        Hive.box('nutripump_settings')
            .put('pending_order_id', _pendingFirestoreOrderId);

        // Use the backend-verified amount (in paise) returned by the server.
        // The backend is the authoritative source — it has already applied promo
        // discounts, GST, shipping, and Razorpay's own rounding. Never recompute
        // this client-side; a mismatch causes a financial data integrity issue.
        final razorpayKey = dotenv.env['RAZORPAY_KEY_ID'];
        if (razorpayKey == null || razorpayKey.isEmpty) {
          throw Exception(
              'Payment configuration missing. Please try again later.');
        }

        final options = {
          'key': razorpayKey,
          'amount': orderResponse.amount,
          'name': 'NutriPump Artisanal',
          'description': 'Payment for Order ${orderResponse.orderId}',
          'order_id': orderResponse.orderId,
          'prefill': {
            'contact': address.phone,
            'email': user.email,
          },
          // Razorpay requires a PUBLIC HTTPS LINK here (it cannot read local app assets).
          // Upload that beautiful gold/black logo from your screenshot to your Firebase Storage and paste the link below!
          'image':
              'https://res.cloudinary.com/dil7vl8um/image/upload/v1778052094/nutripumplogo_j3luzq.webp',
          'theme': {'color': '#C5A866'}
        };

        _razorpay.open(options);
      }
    } catch (e) {
      ref.read(isProcessingProvider.notifier).state = false;
      if (mounted) {
        // Extract the clean backend message if it's a Dio error with a server response
        String errorMsg = 'Failed to place order. Please try again.';
        if (e is DioException && e.message != null && e.message!.isNotEmpty) {
          errorMsg = e.message!;
          // If the error is promo-related, clear the applied promo so user can fix it
          if (errorMsg.toLowerCase().contains('promo') ||
              errorMsg.toLowerCase().contains('code')) {
            ref.read(cartProvider.notifier).removePromo();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Text(errorMsg,
                style: AppTypography.bodySM(context)
                    .copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(checkoutStepProvider);
    final cartState = ref.watch(cartProvider);
    final isProcessing = ref.watch(isProcessingProvider);

    if (cartState.items.isEmpty && !isProcessing) {
      return Scaffold(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : AppColors.backgroundLight),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_checkout_rounded,
                  size: R.sp(context, 64), color: AppColors.borderLight),
              SizedBox(height: R.h(context, 24)),
              Text('Your cart is empty', style: AppTypography.h2(context)),
              SizedBox(height: R.h(context, 24)),
              ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back to Shop')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColors.backgroundLight),
      appBar: AppBar(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Checkout', style: AppTypography.h3(context)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: R.h(context, 24)),
                  Text('Processing your order...',
                      style: AppTypography.bodySM(context)
                          .copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: R.h(context, 8)),
                  Text('Please do not close this screen',
                      style: AppTypography.label(context)
                          .copyWith(color: AppColors.neutralGold)),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: CheckoutProgressBar(
                    currentStep: step,
                    steps: _CheckoutScreenState.steps,
                  ),
                ),
                if (step == 0) _buildStep0Details(),
                if (step == 1) CheckoutReviewStep(cart: cartState),
                SliverToBoxAdapter(
                    child: SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 120)),
              ],
            ),
      bottomSheet: isProcessing || cartState.items.isEmpty
          ? null
          : CheckoutBottomActions(
              step: step,
              cart: cartState,
              onPlaceOrder: () => _handlePlaceOrder(
                  cartState,
                  ref.read(selectedAddressProvider)!,
                  ref.read(paymentMethodProvider)),
            ),
    );
  }



  Widget _buildStep0Details() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(R.w(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Delivery Address', style: AppTypography.h3(context)),
            SizedBox(height: R.h(context, 16)),
            const AddressSelectionSection(),
            SizedBox(height: R.h(context, 32)),
            Text('2. Payment Method', style: AppTypography.h3(context)),
            SizedBox(height: R.h(context, 16)),
            const PaymentSelectionSection(),
          ],
        ),
      ),
    );
  }


}


