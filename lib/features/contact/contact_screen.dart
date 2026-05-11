import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/contact_header_banner.dart';
import 'widgets/contact_quick_options.dart';
import 'widgets/contact_success_message.dart';
import 'widgets/contact_business_hours.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _inquiryType = 'general';
  bool _isSending = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _companyCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              duration: Duration(milliseconds: 2000),
              content: Text('Could not open link'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    try {
      final accessKey = dotenv.env['WEB3FORMS_ACCESS_KEY'];
      if (accessKey == null || accessKey.isEmpty) {
        throw Exception('API Key not found');
      }

      final dio = Dio();
      final response = await dio.post(
        'https://api.web3forms.com/submit',
        data: {
          'access_key': accessKey,
          'name': '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}',
          'email': _emailCtrl.text.trim(),
          'subject': _inquiryType == 'wholesale'
              ? 'B2B Partnership Enquiry — ${_companyCtrl.text.trim().isEmpty ? "Unknown Company" : _companyCtrl.text.trim()}'
              : 'General Contact — NutriPump',
          'message':
              'Inquiry Type: $_inquiryType\n${_companyCtrl.text.trim().isNotEmpty ? "Company: ${_companyCtrl.text.trim()}\n" : ""}Message:\n${_messageCtrl.text.trim()}',
          'botcheck': false,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          _firstNameCtrl.clear();
          _lastNameCtrl.clear();
          _emailCtrl.clear();
          _companyCtrl.clear();
          _messageCtrl.clear();
          setState(() {
            _inquiryType = 'general';
            _isSuccess = true;
          });
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              duration: Duration(milliseconds: 2000),
              content: Text('Could not send message. Please try again.'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        centerTitle: true,
        title: Text('Contact Us',
            style: AppTypography.h3(context)
                .copyWith(fontSize: R.sp(context, 16))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(context, 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            const ContactHeaderBanner(),
            SizedBox(height: R.h(context, 32)),

            // Quick contact options
            ContactQuickOptions(onLaunchUrl: _launchUrl),

            SizedBox(height: R.h(context, 40)),

            // Email compose form
            Text('Send a Message',
                style: AppTypography.h3(context)
                    .copyWith(fontSize: R.sp(context, 16))),
            SizedBox(height: R.h(context, 8)),
            Text(
                'Fill in the form and we\'ll reply to your registered email address.',
                style: AppTypography.bodySM(context)
                    .copyWith(color: AppColors.neutralGold)),
            SizedBox(height: R.h(context, 24)),

            if (_isSuccess)
              ContactSuccessMessage(
                onReset: () => setState(() => _isSuccess = false),
              )
            else
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FIRST NAME',
                                  style: AppTypography.label(context)
                                      .copyWith(fontSize: R.sp(context, 10))),
                              SizedBox(height: R.h(context, 6)),
                              TextFormField(
                                controller: _firstNameCtrl,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                                style: AppTypography.bodySM(context),
                                decoration: _inputDecoration('Jane'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: R.w(context, 16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LAST NAME',
                                  style: AppTypography.label(context)
                                      .copyWith(fontSize: R.sp(context, 10))),
                              SizedBox(height: R.h(context, 6)),
                              TextFormField(
                                controller: _lastNameCtrl,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                                style: AppTypography.bodySM(context),
                                decoration: _inputDecoration('Doe'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(context, 16)),
                    Text('EMAIL ADDRESS',
                        style: AppTypography.label(context)
                            .copyWith(fontSize: R.sp(context, 10))),
                    SizedBox(height: R.h(context, 6)),
                    TextFormField(
                      controller: _emailCtrl,
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Valid email required'
                          : null,
                      style: AppTypography.bodySM(context),
                      decoration: _inputDecoration('jane@example.com'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: R.h(context, 16)),
                    Text('INQUIRY TYPE',
                        style: AppTypography.label(context)
                            .copyWith(fontSize: R.sp(context, 10))),
                    SizedBox(height: R.h(context, 6)),
                    DropdownButtonFormField<String>(
                      initialValue: _inquiryType,
                      decoration: _inputDecoration(''),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.neutralGold),
                      style: AppTypography.bodySM(context).copyWith(
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.onSurface
                                  : AppColors.deepCharcoal)),
                      items: const [
                        DropdownMenuItem(
                            value: 'general', child: Text('General Support')),
                        DropdownMenuItem(
                            value: 'wholesale', child: Text('B2B & Wholesale')),
                        DropdownMenuItem(
                            value: 'press', child: Text('Press & Media')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _inquiryType = v);
                      },
                    ),
                    SizedBox(height: R.h(context, 16)),
                    if (_inquiryType == 'wholesale') ...[
                      Text('COMPANY / RESTAURANT NAME',
                          style: AppTypography.label(context)
                              .copyWith(fontSize: R.sp(context, 10))),
                      SizedBox(height: R.h(context, 6)),
                      TextFormField(
                        controller: _companyCtrl,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                        style: AppTypography.bodySM(context),
                        decoration: _inputDecoration('The Heritage Hotel'),
                      ),
                      SizedBox(height: R.h(context, 16)),
                    ],
                    Text('MESSAGE',
                        style: AppTypography.label(context)
                            .copyWith(fontSize: R.sp(context, 10))),
                    SizedBox(height: R.h(context, 6)),
                    TextFormField(
                      controller: _messageCtrl,
                      validator: (v) => v == null || v.trim().length < 10
                          ? 'Please enter at least 10 characters'
                          : null,
                      maxLines: 5,
                      style: AppTypography.bodySM(context),
                      decoration: _inputDecoration(_inquiryType == 'wholesale'
                          ? 'Tell us about your volume needs...'
                          : 'How can we help?'),
                    ),
                    SizedBox(height: R.h(context, 24)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : _submitForm,
                        icon: _isSending
                            ? SizedBox(
                                width: R.w(context, 18),
                                height: R.w(context, 18),
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.deepCharcoal))
                            : Icon(Icons.send_rounded,
                                size: R.sp(context, 18),
                                color: AppColors.deepCharcoal),
                        label: Text(
                          _isSending
                              ? 'Sending...'
                              : (_inquiryType == 'wholesale'
                                  ? 'Request Kit'
                                  : 'Send Message'),
                          style: AppTypography.bodySM(context).copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: R.sp(context, 15),
                              color: AppColors.deepCharcoal),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.deepCharcoal,
                          elevation: 0,
                          padding:
                              EdgeInsets.symmetric(vertical: R.h(context, 14)),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(R.w(context, 12))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: R.h(context, 40)),

            // Business hours
            const ContactBusinessHours(),
            SizedBox(height: R.h(context, 24)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySM(context)
          .copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
      contentPadding: EdgeInsets.symmetric(
          horizontal: R.w(context, 16), vertical: R.h(context, 14)),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          borderSide: const BorderSide(color: AppColors.borderLight)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          borderSide: const BorderSide(color: AppColors.borderLight)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          borderSide: const BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          borderSide: const BorderSide(color: AppColors.error)),
    );
  }
}
