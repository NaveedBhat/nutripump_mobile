import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
          const SnackBar(duration: Duration(milliseconds: 2000), content: Text('Could not open link'), backgroundColor: AppColors.error),
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
          'message': 'Inquiry Type: $_inquiryType\n${_companyCtrl.text.trim().isNotEmpty ? "Company: ${_companyCtrl.text.trim()}\n" : ""}Message:\n${_messageCtrl.text.trim()}',
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
          const SnackBar(duration: Duration(milliseconds: 2000), content: Text('Could not send message. Please try again.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
      appBar: AppBar(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : Colors.white),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Contact Us', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
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
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(R.w(context, 20)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(R.w(context, 16)),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    width: R.w(context, 48),
                    height: R.w(context, 48),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.support_agent_rounded, size: R.sp(context, 26), color: AppColors.primary),
                  ),
                  SizedBox(width: R.w(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('We\'re here to help!', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 15))),
                        SizedBox(height: R.h(context, 4)),
                        Text('Typically reply within 2–4 hours', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 12))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(context, 32)),

            // Quick contact options
            Text('Reach Us Directly', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
            SizedBox(height: R.h(context, 16)),

            _ContactTile(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@nutripump.store',
              onTap: () => _launchUrl('mailto:support@nutripump.store'),
              trailingIcon: Icons.open_in_new_rounded,
            ),
            SizedBox(height: R.h(context, 12)),
            _ContactTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'WhatsApp',
              subtitle: 'Chat with us instantly',
              onTap: () => _launchUrl('https://wa.me/919149621219'),
              trailingIcon: Icons.open_in_new_rounded,
            ),
            SizedBox(height: R.h(context, 12)),
            _ContactTile(
              icon: Icons.language_rounded,
              title: 'Help Centre',
              subtitle: 'FAQs & Guides',
              onTap: () => _launchUrl('https://nutripump.store/support'),
              trailingIcon: Icons.open_in_new_rounded,
            ),
            SizedBox(height: R.h(context, 12)),
            _ContactTile(
              icon: Icons.alternate_email_rounded,
              title: 'Instagram',
              subtitle: '@nutripump.store',
              onTap: () => _launchUrl('https://instagram.com/nutripump.store'),
              trailingIcon: Icons.open_in_new_rounded,
            ),

            SizedBox(height: R.h(context, 40)),

            // Email compose form
            Text('Send a Message', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
            SizedBox(height: R.h(context, 8)),
            Text('Fill in the form and we\'ll reply to your registered email address.',
                style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
            SizedBox(height: R.h(context, 24)),

            if (_isSuccess)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: R.h(context, 40), horizontal: R.w(context, 20)),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(R.w(context, 16)),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Container(
                      width: R.w(context, 64),
                      height: R.w(context, 64),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: R.sp(context, 32)),
                    ),
                    SizedBox(height: R.h(context, 24)),
                    Text('Message Delivered', style: AppTypography.label(context).copyWith(color: AppColors.primary, fontSize: R.sp(context, 11))),
                    SizedBox(height: R.h(context, 8)),
                    Text('We\'ve got your note!', style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16))),
                    SizedBox(height: R.h(context, 8)),
                    Text('Our team will personally reply within 24 hours. Thank you for reaching out.', textAlign: TextAlign.center, style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
                    SizedBox(height: R.h(context, 24)),
                    TextButton.icon(
                      onPressed: () => setState(() => _isSuccess = false),
                      icon: Icon(Icons.send_rounded, size: R.sp(context, 14)),
                      label: Text('Send another message', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700)),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
                    ),
                  ],
                ),
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
                              Text('FIRST NAME', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10))),
                              SizedBox(height: R.h(context, 6)),
                              TextFormField(
                                controller: _firstNameCtrl,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
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
                              Text('LAST NAME', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10))),
                              SizedBox(height: R.h(context, 6)),
                              TextFormField(
                                controller: _lastNameCtrl,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                style: AppTypography.bodySM(context),
                                decoration: _inputDecoration('Doe'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(context, 16)),

                    Text('EMAIL ADDRESS', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10))),
                    SizedBox(height: R.h(context, 6)),
                    TextFormField(
                      controller: _emailCtrl,
                      validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                      style: AppTypography.bodySM(context),
                      decoration: _inputDecoration('jane@example.com'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: R.h(context, 16)),

                    Text('INQUIRY TYPE', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10))),
                    SizedBox(height: R.h(context, 6)),
                    DropdownButtonFormField<String>(
                      initialValue: _inquiryType,
                      decoration: _inputDecoration(''),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutralGold),
                      style: AppTypography.bodySM(context).copyWith(color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)),
                      items: const [
                        DropdownMenuItem(value: 'general', child: Text('General Support')),
                        DropdownMenuItem(value: 'wholesale', child: Text('B2B & Wholesale')),
                        DropdownMenuItem(value: 'press', child: Text('Press & Media')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _inquiryType = v);
                      },
                    ),
                    SizedBox(height: R.h(context, 16)),

                    if (_inquiryType == 'wholesale') ...[
                      Text('COMPANY / RESTAURANT NAME', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10))),
                      SizedBox(height: R.h(context, 6)),
                      TextFormField(
                        controller: _companyCtrl,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        style: AppTypography.bodySM(context),
                        decoration: _inputDecoration('The Heritage Hotel'),
                      ),
                      SizedBox(height: R.h(context, 16)),
                    ],

                    Text('MESSAGE', style: AppTypography.label(context).copyWith(fontSize: R.sp(context, 10))),
                    SizedBox(height: R.h(context, 6)),
                    TextFormField(
                      controller: _messageCtrl,
                      validator: (v) => v == null || v.trim().length < 10 ? 'Please enter at least 10 characters' : null,
                      maxLines: 5,
                      style: AppTypography.bodySM(context),
                      decoration: _inputDecoration(_inquiryType == 'wholesale' ? 'Tell us about your volume needs...' : 'How can we help?'),
                    ),
                    SizedBox(height: R.h(context, 24)),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : _submitForm,
                        icon: _isSending
                            ? SizedBox(width: R.w(context, 18), height: R.w(context, 18), child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.deepCharcoal))
                            : Icon(Icons.send_rounded, size: R.sp(context, 18), color: AppColors.deepCharcoal),
                        label: Text(
                          _isSending ? 'Sending...' : (_inquiryType == 'wholesale' ? 'Request Kit' : 'Send Message'),
                          style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: R.sp(context, 15), color: AppColors.deepCharcoal),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.deepCharcoal,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: R.h(context, 14)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.w(context, 12))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: R.h(context, 40)),

            // Business hours
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(R.w(context, 20)),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(R.w(context, 12)),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: R.sp(context, 18), color: AppColors.neutralGold),
                      SizedBox(width: R.w(context, 8)),
                      Text('Business Hours', style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  SizedBox(height: R.h(context, 12)),
                  const _HoursRow(day: 'Mon – Fri', hours: '10:00 AM – 7:00 PM'),
                  SizedBox(height: R.h(context, 6)),
                  const _HoursRow(day: 'Saturday', hours: '10:00 AM – 4:00 PM'),
                  SizedBox(height: R.h(context, 6)),
                  const _HoursRow(day: 'Sunday', hours: 'Closed'),
                ],
              ),
            ),
            SizedBox(height: R.h(context, 24)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
      contentPadding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 14)),
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 12)), borderSide: const BorderSide(color: AppColors.borderLight)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 12)), borderSide: const BorderSide(color: AppColors.borderLight)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 12)), borderSide: const BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.w(context, 12)), borderSide: const BorderSide(color: AppColors.error)),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData trailingIcon;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 14)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal).withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: R.w(context, 40),
              height: R.w(context, 40),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(R.w(context, 10)),
              ),
              child: Icon(icon, size: R.sp(context, 20), color: AppColors.primary),
            ),
            SizedBox(width: R.w(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 14))),
                  SizedBox(height: R.h(context, 2)),
                  Text(subtitle, style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 12))),
                ],
              ),
            ),
            Icon(trailingIcon, size: R.sp(context, 16), color: AppColors.neutralGold),
          ],
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String hours;
  const _HoursRow({required this.day, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: R.sp(context, 13))),
        Text(hours, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: R.sp(context, 13))),
      ],
    );
  }
}
