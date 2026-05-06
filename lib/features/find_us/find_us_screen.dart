import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_network_image.dart';

class FindUsScreen extends StatefulWidget {
  const FindUsScreen({super.key});

  @override
  State<FindUsScreen> createState() => _FindUsScreenState();
}

class _FindUsScreenState extends State<FindUsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _subject = '';
  String _message = '';
  bool _isSending = false;
  bool _sent = false;

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSending = true);

    try {
      final accessKey = dotenv.env['NEXT_PUBLIC_WEB3FORMS_ACCESS_KEY'] ?? 
                        dotenv.env['WEB3FORMS_ACCESS_KEY'] ?? '';
      
      final dio = Dio();
      final response = await dio.post(
        'https://api.web3forms.com/submit',
        data: {
          'access_key': accessKey,
          'name': _name,
          'email': _email,
          'subject': _subject.isEmpty ? 'New Enquiry from Nutripump App' : _subject,
          'message': _message,
        },
      );

      if (response.statusCode == 200) {
        setState(() => _sent = true);
      } else {
        _showError('Failed to send message.');
      }
    } catch (e) {
      _showError('Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(milliseconds: 2000), 
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).scaffoldBackgroundColor : AppColors.backgroundLight),
      body: CustomScrollView(
        slivers: [
          _buildHero(),
          SliverToBoxAdapter(child: _buildDigitalSoul()),
          SliverToBoxAdapter(child: _buildValuesGrid()),
          SliverToBoxAdapter(child: _buildHabbakadal()),
          SliverToBoxAdapter(child: _buildContactForm()),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return SliverAppBar(
      expandedHeight: R.h(context, 300),
      pinned: true,
      backgroundColor: AppColors.deepCharcoal,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            const CustomNetworkImage(
              imageUrl: 'https://res.cloudinary.com/dil7vl8um/image/upload/v1776608660/Gemini_Generated_Image_rooomqrooomqrooo_hnwsbv.webp',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.black87],
                ),
              ),
            ),
            Positioned(
              left: R.w(context, 24),
              bottom: R.h(context, 40),
              right: R.w(context, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Presence',
                    style: AppTypography.h1(context).copyWith(color: Colors.white, fontSize: R.sp(context, 40)),
                  ),
                  SizedBox(height: R.h(context, 8)),
                  Text(
                    'Where heritage meets the world.',
                    style: AppTypography.body(context).copyWith(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalSoul() {
    return Padding(
      padding: EdgeInsets.all(R.w(context, 24)),
      child: Column(
        children: [
          SizedBox(height: R.h(context, 24)),
          Icon(Icons.language_rounded, size: R.sp(context, 48), color: AppColors.primary),
          SizedBox(height: R.h(context, 24)),
          Text(
            'Digital Soul, Global Reach',
            style: AppTypography.h2(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: R.h(context, 16)),
          Text(
            'NutriPump is an online-first destination, meticulously designed to bring the heritage of Kashmir directly to your doorstep. We\'ve eliminated the traditional storefront to focus entirely on the quality of our craftsmanship and the efficiency of our global delivery.',
            style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildValuesGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 24)),
      child: Column(
        children: [
          _buildValueCard(
            Icons.shopping_bag_outlined,
            'Seamless Ordering',
            'A refined digital experience tailored for breezy browsing and effortless checkout.',
          ),
          SizedBox(height: R.h(context, 16)),
          _buildValueCard(
            Icons.local_shipping_outlined,
            'Global Shipping',
            'Global delivery partners ensure our craft reaches you safely and swiftly anywhere.',
          ),
          SizedBox(height: R.h(context, 16)),
          _buildValueCard(
            Icons.shield_outlined,
            'Direct Trust',
            'By removing intermediaries, we guarantee the provenance of every piece.',
          ),
          SizedBox(height: R.h(context, 48)),
        ],
      ),
    );
  }

  Widget _buildValueCard(IconData icon, String title, String desc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(context, 24)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(R.w(context, 20)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(R.w(context, 12)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(R.w(context, 16)),
            ),
            child: Icon(icon, color: AppColors.primary, size: R.sp(context, 28)),
          ),
          SizedBox(height: R.h(context, 16)),
          Text(title, style: AppTypography.h3(context)),
          SizedBox(height: R.h(context, 8)),
          Text(
            desc,
            style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHabbakadal() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.05),
      padding: EdgeInsets.all(R.w(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: R.h(context, 24)),
          ClipRRect(
            borderRadius: BorderRadius.circular(R.w(context, 20)),
            child: const AspectRatio(
              aspectRatio: 4/3,
              child: CustomNetworkImage(
                imageUrl: 'https://res.cloudinary.com/dil7vl8um/image/upload/v1776608658/Gemini_Generated_Image_c8vnllc8vnllc8vn_ccefow.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: R.h(context, 32)),
          Text('ROOTED IN', style: AppTypography.labelGold(context)),
          SizedBox(height: R.h(context, 8)),
          Text('Heritage of Habbakadal', style: AppTypography.h2(context)),
          SizedBox(height: R.h(context, 16)),
          Text(
            'Habbakadal is the heart of Srinagar\'s craftsmanship. In these narrow, storied lanes, tradition meets modern logistics. It is where our master artisans gather, where the threads of tradition are woven into every piece, and where the soul of NutriPump resides.',
            style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, height: 1.6),
          ),
          SizedBox(height: R.h(context, 24)),
          TextButton.icon(
            onPressed: () => _launchUrl('https://maps.google.com'),
            icon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
            label: Text('Explore Habbakadal, Kashmir', style: AppTypography.labelGold(context)),
          ),
          SizedBox(height: R.h(context, 24)),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      color: AppColors.deepCharcoal,
      padding: EdgeInsets.all(R.w(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: R.h(context, 24)),
          Text('GET IN TOUCH', style: AppTypography.labelGold(context)),
          SizedBox(height: R.h(context, 8)),
          Text('Contact Us', style: AppTypography.h2(context).copyWith(color: Colors.white)),
          SizedBox(height: R.h(context, 16)),
          Text(
            'Questions, bulk orders, or a simple hello — our team responds personally within 24 hours.',
            style: AppTypography.bodySM(context).copyWith(color: Colors.white70, height: 1.5),
          ),
          SizedBox(height: R.h(context, 32)),

          _buildContactMethods(),
          SizedBox(height: R.h(context, 32)),

          Container(
            padding: EdgeInsets.all(R.w(context, 24)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(R.w(context, 20)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: _sent ? _buildSuccess() : _buildForm(),
          ),
          SizedBox(height: R.h(context, 48)),
        ],
      ),
    );
  }

  Widget _buildContactMethods() {
    return Column(
      children: [
        _contactCard(Icons.message_outlined, 'WhatsApp Us', 'Instant replies', 'https://wa.me/919149621219'),
        SizedBox(height: R.h(context, 12)),
        _contactCard(Icons.email_outlined, 'support@nutripump.com', 'We reply within 24 hours', 'mailto:support@nutripump.com'),
        SizedBox(height: R.h(context, 12)),
        _contactCard(Icons.phone_outlined, '+91 91496 21219', 'Mon – Sat, 10am – 7pm', 'tel:+919149621219'),
      ],
    );
  }

  Widget _contactCard(IconData icon, String title, String subtitle, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: EdgeInsets.all(R.w(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(R.w(context, 16)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(R.w(context, 10)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(R.w(context, 12)),
              ),
              child: Icon(icon, color: AppColors.primary, size: R.sp(context, 20)),
            ),
            SizedBox(width: R.w(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.body(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTypography.bodySM(context).copyWith(color: Colors.white54, fontSize: R.sp(context, 12))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: R.sp(context, 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send a Message', style: AppTypography.h3(context).copyWith(color: Colors.white)),
          SizedBox(height: R.h(context, 24)),
          
          _inputLabel('Name *'),
          _buildInput(hintText: 'Jane Doe', onSaved: (v) => _name = v!),

          SizedBox(height: R.h(context, 16)),
          _inputLabel('Email *'),
          _buildInput(hintText: 'jane@example.com', onSaved: (v) => _email = v!, keyboardType: TextInputType.emailAddress),

          SizedBox(height: R.h(context, 16)),
          _inputLabel('Subject'),
          _buildInput(hintText: 'Partnership, Support, etc.', onSaved: (v) => _subject = v!, isRequired: false),

          SizedBox(height: R.h(context, 16)),
          _inputLabel('Message *'),
          _buildInput(hintText: 'How can we help?', onSaved: (v) => _message = v!, maxLines: 4),

          SizedBox(height: R.h(context, 32)),
          PrimaryButton(
            text: 'Send Message',
            isLoading: _isSending,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        SizedBox(height: R.h(context, 24)),
        Container(
          width: R.w(context, 64),
          height: R.w(context, 64),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Icon(Icons.check_rounded, color: AppColors.primary, size: R.sp(context, 32)),
        ),
        SizedBox(height: R.h(context, 24)),
        Text('Message Delivered', style: AppTypography.labelGold(context)),
        SizedBox(height: R.h(context, 8)),
        Text('We\'ve got your note!', style: AppTypography.h3(context).copyWith(color: Colors.white)),
        SizedBox(height: R.h(context, 12)),
        Text(
          'Our team will personally reply within 24 hours. Thank you for reaching out.',
          style: AppTypography.bodySM(context).copyWith(color: Colors.white70, height: 1.5),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: R.h(context, 32)),
        TextButton(
          onPressed: () => setState(() => _sent = false),
          child: Text('Send another message', style: AppTypography.bodySM(context).copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(context, 8)),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.label(context).copyWith(color: Colors.white54, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInput({
    required Function(String?) onSaved,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isRequired = true,
  }) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.bodySM(context).copyWith(color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 16)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: isRequired ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
      onSaved: onSaved,
    );
  }
}
