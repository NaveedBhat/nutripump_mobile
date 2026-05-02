import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/providers.dart';
import '../../services/api/checkout_api.dart';
import '../account/address_book_screen.dart' show AddressFormSheet;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ── Providers for Checkout State ──────────────────────────────────────────
final checkoutStepProvider = StateProvider<int>((ref) => 0);
final selectedAddressProvider = StateProvider<Address?>((ref) => null);
final paymentMethodProvider = StateProvider<String>((ref) => 'upi');
final isProcessingProvider = StateProvider<bool>((ref) => false);

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
    // Pre-select default address if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        final addresses = await ref.read(userAddressesProvider(user.uid).future);
        if (addresses.isNotEmpty) {
          final defaultAddr = addresses.cast<Address>().firstWhere((a) => a.isDefault, orElse: () => addresses.cast<Address>().first);
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
      final orderId = await CheckoutApi().verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        razorpaySignature: response.signature!,
        firestoreOrderId: _pendingFirestoreOrderId!,
      );
      ref.read(cartProvider.notifier).clearCart();
      ref.read(isProcessingProvider.notifier).state = false;
      if (mounted) {
        context.pushReplacement('/orders/$orderId');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order placed successfully! 🎉', style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    } catch (e) {
      ref.read(isProcessingProvider.notifier).state = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment verification failed.', style: AppTypography.bodySM(context).copyWith(color: Colors.white)), backgroundColor: AppColors.error)
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    if (_pendingFirestoreOrderId != null) {
      await CheckoutApi().cancelOrder(_pendingFirestoreOrderId!);
      _pendingFirestoreOrderId = null;
    }
    ref.read(isProcessingProvider.notifier).state = false;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment cancelled or failed.', style: AppTypography.bodySM(context).copyWith(color: Colors.white)), backgroundColor: AppColors.error)
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
  }

  void _handlePlaceOrder(CartState cart, Address address, String paymentMethod) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to place an order.')));
      return;
    }

    ref.read(isProcessingProvider.notifier).state = true;
    final api = CheckoutApi();

    try {

      if (paymentMethod == 'cod') {
        final firestoreOrderId = await api.createCodOrder(
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
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order placed successfully! 🎉', style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              )
          );
        }
      } else {
        // Initialize Razorpay Order via backend
        final orderResponse = await api.createOrder(
          items: cart.items,
          address: address,
          userId: user.uid,
          appliedPromoCode: cart.appliedPromo?.code,
        );
        _pendingFirestoreOrderId = orderResponse.firestoreOrderId;

        // Use the backend-verified amount (in paise) returned by the server.
        // The backend is the authoritative source — it has already applied promo
        // discounts, GST, shipping, and Razorpay's own rounding. Never recompute
        // this client-side; a mismatch causes a financial data integrity issue.
        final options = {
          'key': dotenv.env['RAZORPAY_KEY_ID'],
          'amount': orderResponse.amount,
          'name': 'NutriPump Artisanal',
          'description': 'Payment for Order ${orderResponse.orderId}',
          'order_id': orderResponse.orderId,
          'prefill': {
            'contact': address.phone,
            'email': user.email,
          },
          'theme': {
            'color': '#C5A866'
          }
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
          if (errorMsg.toLowerCase().contains('promo') || errorMsg.toLowerCase().contains('code')) {
            ref.read(cartProvider.notifier).removePromo();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
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
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_checkout_rounded, size: 64, color: AppColors.borderLight),
              const SizedBox(height: 24),
              Text('Your cart is empty', style: AppTypography.h2(context)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => context.pop(), child: const Text('Back to Shop')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            const SizedBox(height: 24),
            Text('Processing your order...', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Please do not close this screen', style: AppTypography.label(context).copyWith(color: AppColors.neutralGold)),
          ],
        ),
      )
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildProgressBar(step)),
          if (step == 0) _buildStep0Details(),
          if (step == 1) _buildStep1Review(cartState),
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom + 120)),
        ],
      ),
      bottomSheet: isProcessing || cartState.items.isEmpty ? null : _buildBottomActions(step, cartState),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    const steps = _CheckoutScreenState.steps;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ── Background Connector Lines ──
          Positioned(
            top: 15, // Centers the 2px line exactly behind the 32px circles
            left: 16, // Offset by half the circle width
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2,
                    color: 0 < currentStep ? AppColors.primary : AppColors.borderLight,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: 1 < currentStep ? AppColors.primary : AppColors.borderLight,
                  ),
                ),
              ],
            ),
          ),
          // ── Foreground Circles & Labels ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length, (i) {
              final isCompleted = i < currentStep;
              final isActive = i <= currentStep;
              final isCurrent = i == currentStep;

              return GestureDetector(
                  onTap: isCompleted
                      ? () => ref.read(checkoutStepProvider.notifier).state = i
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.white,
                          border: Border.all(
                            color: isActive ? AppColors.primary : AppColors.borderLight,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: isCurrent
                              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1)]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                            : Text(
                          '${i + 1}',
                          style: AppTypography.label(context).copyWith(
                            color: isActive ? Colors.white : AppColors.neutralGold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        steps[i].toUpperCase(),
                        style: AppTypography.label(context).copyWith(
                          fontSize: 8,
                          letterSpacing: 1.2,
                          color: isActive ? AppColors.primary : AppColors.neutralGold,
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ],
                  )
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildStep0Details() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Delivery Address', style: AppTypography.h3(context)),
            const SizedBox(height: 16),
            const _AddressSelectionSection(),
            const SizedBox(height: 32),
            Text('2. Payment Method', style: AppTypography.h3(context)),
            const SizedBox(height: 16),
            const _PaymentSelectionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Review(CartState cart) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Review Order', style: AppTypography.h2(context).copyWith(fontSize: 24)),
                TextButton(
                  onPressed: () => ref.read(checkoutStepProvider.notifier).state = 0,
                  style: TextButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.1), padding: const EdgeInsets.symmetric(horizontal: 16)),
                  child: Text('EDIT DETAILS', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Delivery Review
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 20)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('DELIVERING TO', style: AppTypography.label(context).copyWith(color: AppColors.primary, letterSpacing: 1.5, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                      builder: (context, ref, _) {
                        final address = ref.watch(selectedAddressProvider);
                        if (address == null) return const Text('No address selected');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(address.fullName, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('${address.addressLine1}${address.locality != null ? ', ${address.locality}' : ''}', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
                            Text('${address.city}, ${address.state} - ${address.pincode}', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
                            const SizedBox(height: 6),
                            Text(address.phone, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w600)),
                          ],
                        );
                      }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment Review
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 20)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('PAYMENT METHOD', style: AppTypography.label(context).copyWith(color: AppColors.primary, letterSpacing: 1.5, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                      builder: (context, ref, _) {
                        final method = ref.watch(paymentMethodProvider);
                        final label = method == 'upi' ? 'UPI' : method == 'card' ? 'Credit/Debit Card' : method == 'netbanking' ? 'Net Banking' : 'Cash on Delivery';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(method == 'cod' ? 'Awaiting payment upon confirmed delivery.' : 'Secured digitally via Razorpay gateway.', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
                          ],
                        );
                      }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text('Artisan Products to Ship', style: AppTypography.h3(context)),
            const SizedBox(height: 16),
            ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), image: item.product.primaryImage.isNotEmpty ? DecorationImage(image: NetworkImage(item.product.primaryImage), fit: BoxFit.cover) : null),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${item.selectedWeight ?? item.product.weight} · Qty ${item.quantity}', style: AppTypography.label(context).copyWith(fontSize: 10, color: AppColors.neutralGold, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                  Text(formatPrice(item.effectivePrice * item.quantity), style: AppTypography.price(context).copyWith(fontSize: 14, color: AppColors.deepCharcoal)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(int step, CartState cart) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -10), blurRadius: 30)],
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated Total', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.bold)),
              Consumer(builder: (context, ref, _) {
                final method = ref.watch(paymentMethodProvider);
                final settings = ref.watch(paymentSettingsProvider).value;
                final codCharge = (method == 'cod' && settings != null) ? settings.codCharge : 0.0;
                return Text(formatPrice(cart.total + codCharge), style: AppTypography.h2(context).copyWith(fontSize: 24, height: 1));
              }),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (step == 0) {
                  if (ref.read(selectedAddressProvider) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery address')));
                    return;
                  }
                  ref.read(checkoutStepProvider.notifier).state = 1;
                } else if (step == 1) {
                  // Final Place Order
                  _handlePlaceOrder(cart, ref.read(selectedAddressProvider)!, ref.read(paymentMethodProvider));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.deepCharcoal,
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(step == 0 ? 'Review Order' : 'Place Order & Pay', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(width: 8),
                  Icon(step == 0 ? Icons.arrow_forward_rounded : Icons.lock_outline_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Address Selection Widget ──────────────────────────────────────────────────
class _AddressSelectionSection extends ConsumerWidget {
  const _AddressSelectionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Text('Please log in');

    final addressesAsync = ref.watch(userAddressesProvider(user.uid));
    final selectedAddress = ref.watch(selectedAddressProvider);

    return addressesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading addresses'),
      data: (dynamicAddresses) {
        final List<Address> addresses = dynamicAddresses.cast<Address>();

        return Column(
          children: [
            if (addresses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight, style: BorderStyle.none)),
                child: Column(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 32, color: AppColors.neutralGold),
                    const SizedBox(height: 12),
                    Text('No saved addresses found', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddAddressSheet(context, user.uid, ref),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add New Address'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepCharcoal, foregroundColor: Colors.white),
                    )
                  ],
                ),
              )
            else ...[
              ...addresses.map((addr) {
                final isSelected = selectedAddress?.id == addr.id;
                return GestureDetector(
                  onTap: () => ref.read(selectedAddressProvider.notifier).state = addr,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? AppColors.primary : AppColors.neutralGold, size: 20),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(addr.fullName, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.bold)),
                                  if (addr.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)), child: Text('DEFAULT', style: AppTypography.label(context).copyWith(fontSize: 8, color: AppColors.deepCharcoal))),
                                  ]
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${addr.addressLine1}${addr.locality != null ? ', ${addr.locality}' : ''}', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
                              Text('${addr.city}, ${addr.state} - ${addr.pincode}', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
                              const SizedBox(height: 4),
                              Text(addr.phone, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _showAddAddressSheet(context, user.uid, ref),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                label: Text('Add New Address', style: AppTypography.bodySM(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        );
      },
    );
  }

  void _showAddAddressSheet(BuildContext context, String uid, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressFormSheet(userId: uid, parentRef: ref),
    );
  }
}

// ── Payment Selection Widget ──────────────────────────────────────────────────
//
// Implemented as a ConsumerStatefulWidget so the payment-method auto-switch
// logic runs in didChangeDependencies() rather than inside build().
// Calling addPostFrameCallback inside build() was scheduling a new callback
// on every rebuild triggered by paymentSettingsProvider or cartProvider,
// causing unnecessary extra rebuild cycles. didChangeDependencies() fires
// exactly when a watched dependency changes — the correct hook for this.
class _PaymentSelectionSection extends ConsumerStatefulWidget {
  const _PaymentSelectionSection();

  @override
  ConsumerState<_PaymentSelectionSection> createState() =>
      _PaymentSelectionSectionState();
}

class _PaymentSelectionSectionState
    extends ConsumerState<_PaymentSelectionSection> {
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
            _buildMethod(ref, id: 'upi', title: 'UPI', subtitle: 'Google Pay, PhonePe, Paytm', icon: Icons.qr_code_2_rounded, selectedMethod: selectedMethod, isEnabled: settings.upi),
            _buildMethod(ref, id: 'card', title: 'Credit / Debit Card', subtitle: 'Visa, Mastercard, RuPay', icon: Icons.credit_card_rounded, selectedMethod: selectedMethod, isEnabled: settings.card),
            _buildMethod(ref, id: 'netbanking', title: 'Net Banking', subtitle: 'All Indian banks', icon: Icons.account_balance_rounded, selectedMethod: selectedMethod, isEnabled: settings.netbanking),
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

  Widget _buildMethod(WidgetRef ref, {
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: !isEnabled
              ? AppColors.borderLight.withValues(alpha: 0.3)
              : isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: !isEnabled
                  ? AppColors.borderLight.withValues(alpha: 0.5)
                  : isSelected
                  ? AppColors.primary
                  : AppColors.borderLight,
              width: isSelected ? 2 : 1
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: !isEnabled ? AppColors.borderLight : isSelected ? AppColors.primary : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Icon(
                  !isEnabled ? Icons.lock_outline : icon,
                  color: !isEnabled ? AppColors.neutralGold.withValues(alpha: 0.5) : isSelected ? AppColors.deepCharcoal : AppColors.neutralGold,
                  size: 20
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(title, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.bold, color: !isEnabled ? AppColors.neutralGold : AppColors.deepCharcoal)),
                      if (!isEnabled)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(4)),
                          child: Text(lockedReason ?? 'UNAVAILABLE', style: AppTypography.label(context).copyWith(fontSize: 8, color: AppColors.neutralGold)),
                        ),
                      if (isEnabled && id == 'cod' && isSelected && codCharge > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.amber.shade300)),
                          child: Text('+₹${codCharge.toInt()} COD charge', style: AppTypography.label(context).copyWith(fontSize: 8, color: Colors.amber.shade900)),
                        ),
                    ],
                  ),
                  Text(subtitle, style: AppTypography.label(context).copyWith(fontSize: 10, color: !isEnabled ? AppColors.neutralGold.withValues(alpha: 0.5) : AppColors.neutralGold)),
                ],
              ),
            ),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: !isEnabled ? AppColors.borderLight : isSelected ? AppColors.primary : AppColors.borderLight),
          ],
        ),
      ),
    );
  }
}

