import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../providers/journal_provider.dart';

class ArticleScreen extends ConsumerWidget {
  final String id;
  const ArticleScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(journalProvider);
    final article = articles.firstWhere(
      (a) => a.id == id,
      orElse: () => articles.first, // Fallback just in case
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── App Bar / Header Image ────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.deepCharcoal),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(article.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Article Content ───────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(article.category.toUpperCase(),
                            style: AppTypography.label(context).copyWith(fontSize: 10, color: AppColors.primary)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.neutralGold),
                          const SizedBox(width: 4),
                          Text('${article.readTimeMinutes} min read',
                              style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(article.title, style: AppTypography.h2(context).copyWith(fontSize: 26, height: 1.2)),
                  const SizedBox(height: 16),

                  // Author & Date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.backgroundLight,
                        child: Text(article.author[0], style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article.author, style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(_formatDate(article.publishedAt), style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.borderLight),
                  const SizedBox(height: 24),

                  // Summary
                  Text(
                    article.summary,
                    style: AppTypography.bodySM(context).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: AppColors.deepCharcoal.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Content
                  Text(
                    article.content,
                    style: AppTypography.bodySM(context).copyWith(
                      fontSize: 15,
                      height: 1.8,
                      color: AppColors.deepCharcoal,
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

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
