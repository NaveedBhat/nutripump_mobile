import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/custom_network_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/animated_enter.dart';

class OurStoryScreen extends StatelessWidget {
  const OurStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.deepCharcoal,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const CustomNetworkImage(
                    imageUrl: 'https://images.unsplash.com/photo-1596662951362-b48c66a4bc2c?q=80&w=800&auto=format&fit=crop', // Saffron field or Kashmir
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.deepCharcoal.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 24,
                    right: 24,
                    child: AnimatedEnter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OUR HERITAGE', style: AppTypography.labelGold(context).copyWith(letterSpacing: 2)),
                          const SizedBox(height: 8),
                          Text('Rooted in\nthe Valley', style: AppTypography.h1(context).copyWith(color: Colors.white, fontSize: 36, height: 1.1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'NutriPump Artisanal was born from a simple realization: the purest treasures of the Earth are being lost to mass production. We journey to the heart of Kashmir and the high altitudes of the Himalayas to source ingredients exactly as nature intended — unadulterated, raw, and vibrant.',
                      style: AppTypography.bodySM(context).copyWith(fontSize: 15, height: 1.8, color: AppColors.deepCharcoal.withValues(alpha: 0.8)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 200),
                    child: _buildValueProp(
                      context,
                      Icons.thermostat_outlined,
                      'Cold-Pressed Perfection',
                      'Our oils are extracted using ancient wooden presses (kachhi ghani), ensuring no heat destroys the vital nutrients.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 300),
                    child: _buildValueProp(
                      context,
                      Icons.nature_people_outlined,
                      'Heritage Farming',
                      'We partner directly with multi-generational farmers in the Kashmir Valley, ensuring fair trade and sustainable harvesting practices.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 400),
                    child: _buildValueProp(
                      context,
                      Icons.science_outlined,
                      'Uncompromising Purity',
                      'Every single batch is lab-verified. No additives, no synthetic colors, no preservatives. Just 100% natural goodness.',
                    ),
                  ),
                  const SizedBox(height: 56),
                  AnimatedEnter(
                    delay: const Duration(milliseconds: 500),
                    child: PrimaryButton(
                      text: 'Shop the Collection',
                      onPressed: () => context.go('/shop'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueProp(BuildContext context, IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.h3(context).copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Text(
                description,
                style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
