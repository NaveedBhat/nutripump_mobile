import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/order.dart';
import '../../../providers/providers.dart';

class CancelOrderDialog extends ConsumerStatefulWidget {
  final Order order;
  const CancelOrderDialog({super.key, required this.order});

  @override
  ConsumerState<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends ConsumerState<CancelOrderDialog> {
  bool _isLoading = false;

  Future<void> _handleCancel() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(orderServiceProvider);
      await service.cancelOrder(
          widget.order.id, 'User cancelled from mobile app');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              duration: Duration(milliseconds: 2000),
              content: Text('Order cancelled successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              duration: const Duration(milliseconds: 2000),
              content: Text('Failed to cancel order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cancel Order?', style: AppTypography.h3(context)),
      content: Text(
        'Are you sure you want to cancel order ${formatOrderId(widget.order.id)}? This action cannot be undone.',
        style: AppTypography.bodySM(context),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.deepCharcoal,
            side: const BorderSide(color: AppColors.borderLight),
            padding: EdgeInsets.symmetric(
                horizontal: R.w(context, 16), vertical: R.h(context, 8)),
            minimumSize: Size(0, R.h(context, 36)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.w(context, 8))),
          ),
          child: Text('Keep Order',
              style: AppTypography.bodySM(context)
                  .copyWith(fontWeight: FontWeight.w700)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
                horizontal: R.w(context, 16), vertical: R.h(context, 8)),
            minimumSize: Size(0, R.h(context, 36)),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.w(context, 8))),
          ),
          child: _isLoading
              ? SizedBox(
                  width: R.w(context, 16),
                  height: R.w(context, 16),
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text('Confirm Cancel',
                  style: AppTypography.bodySM(context).copyWith(
                      fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ],
    );
  }
}
