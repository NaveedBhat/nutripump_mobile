import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/article.dart';
import '../../providers/journal_provider.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(journalCategoryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final articles = ref.watch(filteredArticlesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Journal', style: AppTypography.h3(context)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Featured Banner ───────────────────────────────────
          if (articles.isNotEmpty && selectedCategory == 'All')
            SliverToBoxAdapter(
              child: _FeaturedArticleCard(article: articles.first),
            ),

          // ── Categories ────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category,
                          style: AppTypography.bodySM(context).copyWith(
                            color: isSelected ? Colors.white : AppColors.deepCharcoal,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          )),
                      selected: isSelected,
                      onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = category,
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Article List ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: articles.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text('No articles found.', style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold)),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Skip the first one if it's already shown as featured
                        if (selectedCategory == 'All' && index == 0) return const SizedBox.shrink();
                        return _ArticleCard(article: articles[index]);
                      },
                      childCount: articles.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  final Article article;
  const _FeaturedArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/journal/${article.id}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(article.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepCharcoal.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                child: Text(article.category.toUpperCase(), style: AppTypography.label(context).copyWith(fontSize: 10, color: AppColors.deepCharcoal)),
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: AppTypography.h2(context).copyWith(color: Colors.white, fontSize: 22, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text('${article.readTimeMinutes} min read', style: AppTypography.bodySM(context).copyWith(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/journal/${article.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: AppColors.deepCharcoal.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: Image.network(
                article.imageUrl,
                width: 100,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 100, height: 110, color: AppColors.backgroundLight,
                  child: const Icon(Icons.image_outlined, color: AppColors.neutralGold),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.category.toUpperCase(),
                        style: AppTypography.label(context).copyWith(fontSize: 10, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      style: AppTypography.bodySM(context).copyWith(fontWeight: FontWeight.w800, fontSize: 14, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: AppColors.neutralGold),
                        const SizedBox(width: 4),
                        Text('${article.readTimeMinutes} min read',
                            style: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold, fontSize: 11)),
                      ],
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
