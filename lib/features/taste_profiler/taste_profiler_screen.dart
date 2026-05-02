import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/product_card.dart';
import 'taste_profiler_state.dart';
import '../../utils/ai_matcher.dart';

// Quiz Data Structure
class QuizStep {
  final String id;
  final String question;
  final List<QuizOption> options;

  const QuizStep(
      {required this.id, required this.question, required this.options});
}

class QuizOption {
  final String id;
  final String label;
  final IconData icon;
  final String desc;

  const QuizOption(
      {required this.id,
      required this.label,
      required this.icon,
      required this.desc});
}

const List<QuizStep> _steps = [
  QuizStep(
    id: "morning",
    question: "How do you start your morning ritual?",
    options: [
      QuizOption(
          id: "sweet",
          label: "Sweet & Slow",
          icon: Icons.wb_sunny_outlined,
          desc: "A drizzle of liquid gold or sweet berries."),
      QuizOption(
          id: "savory",
          label: "Savory & Strong",
          icon: Icons.restaurant_menu,
          desc: "Hearty flavors that ground your energy."),
      QuizOption(
          id: "fast",
          label: "Quick & Pure",
          icon: Icons.bolt,
          desc: "Minimal effort, maximal nutrition."),
    ],
  ),
  QuizStep(
    id: "texture",
    question: "What is your ideal sensory texture?",
    options: [
      QuizOption(
          id: "smooth",
          label: "Velvety Smooth",
          icon: Icons.auto_awesome,
          desc: "Melt-in-your-mouth refinement."),
      QuizOption(
          id: "stone-ground",
          label: "Stone-Ground & Bold",
          icon: Icons.nights_stay_outlined,
          desc: "Authentic, slightly textured, raw."),
      QuizOption(
          id: "crunchy",
          label: "Natural & Crunch",
          icon: Icons.eco_outlined,
          desc: "The honest snap of whole seeds."),
    ],
  ),
  QuizStep(
    id: "lifestyle",
    question: "What does your body crave most?",
    options: [
      QuizOption(
          id: "energy",
          label: "Physical Fuel",
          icon: Icons.bolt,
          desc: "Sustained power for an active day."),
      QuizOption(
          id: "relaxation",
          label: "Mindful Calm",
          icon: Icons.nights_stay_outlined,
          desc: "Anti-inflammatory peace and rest."),
      QuizOption(
          id: "immunity",
          label: "Ancient Wellness",
          icon: Icons.shield_outlined,
          desc: "Traditional defenses from nature."),
    ],
  ),
  QuizStep(
    id: "vibe",
    question: "Which vibe resonates with your soul?",
    options: [
      QuizOption(
          id: "heritage",
          label: "Heritage & Legacy",
          icon: Icons.favorite_border,
          desc: "Generational secrets of Kashmir."),
      QuizOption(
          id: "artisanal",
          label: "Modern Artisanal",
          icon: Icons.auto_awesome,
          desc: "Small-batch innovation."),
      QuizOption(
          id: "discovery",
          label: "Raw Discovery",
          icon: Icons.arrow_forward,
          desc: "Minimal processing, direct from source."),
    ],
  ),
];

class TasteProfilerScreen extends ConsumerWidget {
  const TasteProfilerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasteProfilerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepCharcoal),
          onPressed: () => context.pop(),
        ),
        title: Text('Taste Profiler', style: AppTypography.h3(context)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, TasteProfilerState state) {
    if (state.isRevealing) {
      return _buildRevealingState(context);
    } else if (state.step < _steps.length) {
      return _buildQuizStep(context, ref, state);
    } else {
      return _buildResults(context, ref, state);
    }
  }

  Widget _buildRevealingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
                  .animate(
                      onPlay: (AnimationController controller) =>
                          controller.repeat())
                  .rotate(duration: const Duration(seconds: 3)),
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 48)
                  .animate(
                      onPlay: (AnimationController controller) =>
                          controller.repeat(reverse: true))
                  .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: const Duration(seconds: 1)),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Analyzing your\nHimalayan Soul Profile...',
            textAlign: TextAlign.center,
            style: AppTypography.h2(context).copyWith(fontStyle: FontStyle.italic),
          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Our AI is matching your sensory preferences with the generational harvests of Kashmir.',
              textAlign: TextAlign.center,
              style: AppTypography.body(context).copyWith(color: AppColors.neutralGold),
            ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStep(
      BuildContext context, WidgetRef ref, TasteProfilerState state) {
    final currentStep = _steps[state.step];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Intro Text
          Text(
            'Artisanal Pulse.',
            textAlign: TextAlign.center,
            style: AppTypography.h2(context).copyWith(color: AppColors.deepCharcoal),
          ),
          const SizedBox(height: 8),
          Text(
            'A sensory journey to find the precise craft that resonates with your profile.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold),
          ),
          const SizedBox(height: 32),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (state.step + 1) / _steps.length,
              backgroundColor: AppColors.primary.withAlpha(25),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'STEP ${state.step + 1} OF ${_steps.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currentStep.question,
            textAlign: TextAlign.center,
            style: AppTypography.h1(context),
          ),
          const SizedBox(height: 48),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentStep.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final option = currentStep.options[index];
              return _OptionCard(
                option: option,
                onTap: () {
                  ref
                      .read(tasteProfilerProvider.notifier)
                      .selectAnswer(currentStep.id, option.id);
                },
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 100 * index))
                  .slideX(begin: 0.1, end: 0);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
      BuildContext context, WidgetRef ref, TasteProfilerState state) {
    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No direct match found.', style: AppTypography.h3(context)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.read(tasteProfilerProvider.notifier).reset(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final topMatch = state.results.first;
    final otherMatches = state.results.skip(1).take(2).toList();
    final message = AiMatcher.getRecommendedMessage(state.profile, topMatch);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: AppColors.primary, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'YOUR SOUL MATCH IS HERE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Crafted for your profile.',
            textAlign: TextAlign.center,
            style: AppTypography.h1(context),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.body(context).copyWith(
              color: AppColors.neutralGold,
              fontStyle: FontStyle.italic,
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
          const SizedBox(height: 48),

          // Top Match
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AspectRatio(
                    aspectRatio: 0.75,
                    child: ProductCard(product: topMatch),
                  ),
                ),
              ),
              Positioned(
                top: -12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 1),
                    ],
                  ),
                  child: const Text(
                    'TOP RECOMMENDATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepCharcoal,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ).animate().scale(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 500)),

          if (otherMatches.isNotEmpty) ...[
            const SizedBox(height: 48),
            Text(
              'Other Perfect Pairings',
              style: AppTypography.h3(context),
            ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: otherMatches.length,
              itemBuilder: (context, index) {
                return ProductCard(product: otherMatches[index])
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 800 + (index * 200)))
                    .slideY(begin: 0.1, end: 0);
              },
            ),
          ],
          const SizedBox(height: 48),
          Center(
            child: TextButton.icon(
              onPressed: () => ref.read(tasteProfilerProvider.notifier).reset(),
              icon: const Icon(Icons.refresh),
              label: const Text('Take the quiz again',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Explore our Full Collection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepCharcoal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final QuizOption option;
  final VoidCallback onTap;

  const _OptionCard({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.primary.withAlpha(38)),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(7),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(option.icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label,
                      style: AppTypography.h3(context).copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                    option.desc,
                    style: AppTypography.bodySM(context)
                        .copyWith(color: AppColors.neutralGold),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.neutralGold),
          ],
        ),
      ),
    );
  }
}
