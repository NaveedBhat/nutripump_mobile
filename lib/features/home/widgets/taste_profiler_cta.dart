import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class TasteProfilerCta extends StatelessWidget {
  const TasteProfilerCta({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3B36),
        borderRadius: BorderRadius.circular(R.w(context, 20)),
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1636800637091-3d54ec4dfffb?q=80&w=600&auto=format&fit=crop'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(R.w(context, 22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: R.w(context, 8), vertical: R.h(context, 4)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(R.w(context, 4)),
              ),
              child: Text('AI-POWERED',
                  style: AppTypography.label(context).copyWith(
                      color: AppColors.primary,
                      fontSize: R.sp(context, 8),
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w900)),
            ),
            SizedBox(height: R.h(context, 10)),
            Text(
              'Not sure where\nto start?',
              style: AppTypography.h1(context).copyWith(
                  color: Colors.white,
                  fontSize: R.sp(context, 22),
                  height: 1.1),
            ),
            SizedBox(height: R.h(context, 8)),
            Text(
              'Take our 1-minute Artisanal Pulse quiz and get a curated recommendation just for you.',
              style: AppTypography.bodySM(context).copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: R.sp(context, 12),
                  height: 1.5),
            ),
            SizedBox(height: R.h(context, 20)),
            GestureDetector(
              onTap: () => context.push('/taste-profiler'),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 18), vertical: R.h(context, 12)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(R.w(context, 10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome,
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurface
                            : AppColors.deepCharcoal),
                        size: R.sp(context, 13)),
                    SizedBox(width: R.w(context, 7)),
                    Text(
                      'TAKE THE QUIZ',
                      style: AppTypography.label(context).copyWith(
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurface
                            : AppColors.deepCharcoal),
                        fontWeight: FontWeight.w900,
                        fontSize: R.sp(context, 10),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
