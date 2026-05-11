import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/animated_enter.dart';
import '../../core/utils/responsive.dart';
import '../../providers/providers.dart';
import 'widgets/support_success_state.dart';
import 'widgets/support_promise_section.dart';

class SupportScreen extends ConsumerStatefulWidget {
  final String? initialOrderId;
  const SupportScreen({super.key, this.initialOrderId});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _orderId = '';
  String _issueType = 'delivery';
  String _email = '';
  String _message = '';
  bool _isSubmitting = false;
  bool _sent = false;

  final _issueOptions = [
    {'value': 'delivery', 'label': 'Delivery Status / Delayed'},
    {'value': 'missing_item', 'label': 'Missing or Incorrect Item'},
    {'value': 'quality', 'label': 'Quality / Damage Issue'},
    {'value': 'refund', 'label': 'Request Cancellation or Refund'},
    {'value': 'other', 'label': 'Other Inquiry'},
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill orderId if passed from the Orders screen
    if (widget.initialOrderId != null && widget.initialOrderId!.isNotEmpty) {
      _orderId = widget.initialOrderId!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).value;
      if (user != null && mounted) {
        setState(() {
          _email = user.email;
        });
      }
    });
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    try {
      final accessKey = dotenv.env['NEXT_PUBLIC_WEB3FORMS_ACCESS_KEY'] ??
          dotenv.env['WEB3FORMS_ACCESS_KEY'] ??
          '';

      final dio = Dio();
      final response = await dio.post(
        'https://api.web3forms.com/submit',
        data: {
          'access_key': accessKey,
          'email': _email,
          'subject': 'Priority Order Support: [$_orderId] — $_issueType',
          'message':
              'Order ID: $_orderId\nIssue Category: $_issueType\n\nCustomer Message:\n$_message',
        },
      );

      if (response.statusCode == 200) {
        setState(() => _sent = true);
      } else {
        _showError('Failed to submit ticket. Please try again.');
      }
    } catch (e) {
      _showError('Connection error. Please check your network.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 2000),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColors.backgroundLight),
      appBar: AppBar(
        title: Text('Priority Support',
            style: AppTypography.h3(context)
                .copyWith(fontSize: R.sp(context, 16))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _sent ? SupportSuccessState(orderId: _orderId) : _buildFormState(),
            const SupportPromiseSection(),
          ],
        ),
      ),
    );
  }


  Widget _buildFormState() {
    return AnimatedEnter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(R.w(context, 24), R.h(context, 24),
            R.w(context, 24), R.h(context, 48)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 12), vertical: R.h(context, 6)),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(R.w(context, 20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded,
                        color: Colors.red, size: R.sp(context, 14)),
                    SizedBox(width: R.w(context, 6)),
                    Text(
                      'PREMIUM SUPPORT',
                      style: AppTypography.label(context).copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.h(context, 16)),
              Text('How can we help?',
                  style: AppTypography.h1(context)
                      .copyWith(fontSize: R.sp(context, 32))),
              SizedBox(height: R.h(context, 12)),
              Text(
                'Experiencing an issue with your order? Submit a priority ticket below and our harvest concierge will resolve it immediately.',
                style: AppTypography.bodySM(context)
                    .copyWith(color: AppColors.neutralGold, height: 1.5),
              ),
              SizedBox(height: R.h(context, 32)),
              _buildLabel('Order ID'),
              TextFormField(
                initialValue: _orderId,
                decoration: _inputDecoration('NP-XYZ123'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _orderId = v ?? '',
              ),
              SizedBox(height: R.h(context, 20)),
              _buildLabel('Issue Category'),
              DropdownButtonFormField<String>(
                initialValue: _issueType,
                decoration: _inputDecoration(''),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.neutralGold),
                items: _issueOptions.map((opt) {
                  return DropdownMenuItem(
                    value: opt['value']!,
                    child: Text(opt['label']!,
                        style: AppTypography.bodySM(context)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _issueType = v);
                },
              ),
              SizedBox(height: R.h(context, 20)),
              _buildLabel('Contact Email'),
              TextFormField(
                initialValue: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('your@email.com'),
                validator: (v) => v == null || !v.contains('@')
                    ? 'Valid email required'
                    : null,
                onSaved: (v) => _email = v ?? '',
              ),
              SizedBox(height: R.h(context, 20)),
              _buildLabel('Details'),
              TextFormField(
                maxLines: 4,
                decoration:
                    _inputDecoration('Please provide specific details...'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _message = v ?? '',
              ),
              SizedBox(height: R.h(context, 32)),
              PrimaryButton(
                text: 'Submit Priority Ticket',
                isLoading: _isSubmitting,
                onPressed: _submitTicket,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(context, 8), left: R.w(context, 4)),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.labelGold(context)
            .copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySM(context)
          .copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : Colors.white,
      contentPadding: EdgeInsets.symmetric(
          horizontal: R.w(context, 16), vertical: R.h(context, 16)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }


}
