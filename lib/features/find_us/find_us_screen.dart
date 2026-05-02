import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
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
      SnackBar(
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
      backgroundColor: AppColors.backgroundLight,
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
      expandedHeight: 300,
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
              left: 24,
              bottom: 40,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Presence',
                    style: AppTypography.h1(context).copyWith(color: Colors.white, fontSize: 40),
                  ),
                  const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.language_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Digital Soul, Global Reach',
            style: AppTypography.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildValueCard(
            Icons.shopping_bag_outlined,
            'Seamless Ordering',
            'A refined digital experience tailored for breezy browsing and effortless checkout.',
          ),
          const SizedBox(height: 16),
          _buildValueCard(
            Icons.local_shipping_outlined,
            'Global Shipping',
            'Global delivery partners ensure our craft reaches you safely and swiftly anywhere.',
          ),
          const SizedBox(height: 16),
          _buildValueCard(
            Icons.shield_outlined,
            'Direct Trust',
            'By removing intermediaries, we guarantee the provenance of every piece.',
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildValueCard(IconData icon, String title, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTypography.h3(context)),
          const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const AspectRatio(
              aspectRatio: 4/3,
              child: CustomNetworkImage(
                imageUrl: 'https://res.cloudinary.com/dil7vl8um/image/upload/v1776608658/Gemini_Generated_Image_c8vnllc8vnllc8vn_ccefow.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('ROOTED IN', style: AppTypography.labelGold(context)),
          const SizedBox(height: 8),
          Text('Heritage of Habbakadal', style: AppTypography.h2(context)),
          const SizedBox(height: 16),
          Text(
            'Habbakadal is the heart of Srinagar\'s craftsmanship. In these narrow, storied lanes, tradition meets modern logistics. It is where our master artisans gather, where the threads of tradition are woven into every piece, and where the soul of NutriPump resides.',
            style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, height: 1.6),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => _launchUrl('https://maps.google.com'),
            icon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
            label: Text('Explore Habbakadal, Kashmir', style: AppTypography.labelGold(context)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      color: AppColors.deepCharcoal,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('GET IN TOUCH', style: AppTypography.labelGold(context)),
          const SizedBox(height: 8),
          Text('Contact Us', style: AppTypography.h2(context).copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          Text(
            'Questions, bulk orders, or a simple hello — our team responds personally within 24 hours.',
            style: AppTypography.bodySM(context).copyWith(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 32),

          _buildContactMethods(),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: _sent ? _buildSuccess() : _buildForm(),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildContactMethods() {
    return Column(
      children: [
        _contactCard(Icons.message_outlined, 'WhatsApp Us', 'Instant replies', 'https://wa.me/919149621219'),
        const SizedBox(height: 12),
        _contactCard(Icons.email_outlined, 'support@nutripump.com', 'We reply within 24 hours', 'mailto:support@nutripump.com'),
        const SizedBox(height: 12),
        _contactCard(Icons.phone_outlined, '+91 91496 21219', 'Mon – Sat, 10am – 7pm', 'tel:+919149621219'),
      ],
    );
  }

  Widget _contactCard(IconData icon, String title, String subtitle, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.body(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTypography.bodySM(context).copyWith(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
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
          const SizedBox(height: 24),
          
          _inputLabel('Name *'),
          _buildInput(onSaved: (v) => _name = v!),

          const SizedBox(height: 16),
          _inputLabel('Email *'),
          _buildInput(onSaved: (v) => _email = v!, keyboardType: TextInputType.emailAddress),

          const SizedBox(height: 16),
          _inputLabel('Subject'),
          _buildInput(onSaved: (v) => _subject = v!, isRequired: false),

          const SizedBox(height: 16),
          _inputLabel('Message *'),
          _buildInput(onSaved: (v) => _message = v!, maxLines: 4),

          const SizedBox(height: 32),
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
        const SizedBox(height: 24),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 32),
        ),
        const SizedBox(height: 24),
        Text('Message Delivered', style: AppTypography.labelGold(context)),
        const SizedBox(height: 8),
        Text('We\'ve got your note!', style: AppTypography.h3(context).copyWith(color: Colors.white)),
        const SizedBox(height: 12),
        Text(
          'Our team will personally reply within 24 hours. Thank you for reaching out.',
          style: AppTypography.bodySM(context).copyWith(color: Colors.white70, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => setState(() => _sent = false),
          child: Text('Send another message', style: AppTypography.bodySM(context).copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.label(context).copyWith(color: Colors.white54, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInput({
    required Function(String?) onSaved,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isRequired = true,
  }) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: isRequired ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
      onSaved: onSaved,
    );
  }
}
