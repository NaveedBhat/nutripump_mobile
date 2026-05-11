import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
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
        title: Text('Journal',
            style: AppTypography.h3(context)
                .copyWith(fontSize: R.sp(context, 16))),
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
              height: R.h(context, 60),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 16), vertical: R.h(context, 12)),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;
                  return Padding(
                    padding: EdgeInsets.only(right: R.w(context, 8)),
                    child: ChoiceChip(
                      label: Text(category,
                          style: AppTypography.bodySM(context).copyWith(
                            color: isSelected
                                ? Colors.white
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Theme.of(context).colorScheme.onSurface
                                    : AppColors.deepCharcoal),
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                          )),
                      selected: isSelected,
                      onSelected: (_) => ref
                          .read(selectedCategoryProvider.notifier)
                          .state = category,
                      backgroundColor:
                          (Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).scaffoldBackgroundColor
                              : Colors.white),
                      selectedColor: AppColors.primary,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(R.w(context, 20))),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Article List ──────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 8),
                R.w(context, 16), R.h(context, 24)),
            sliver: articles.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(R.w(context, 40)),
                        child: Text('No articles found.',
                            style: AppTypography.bodySM(context)
                                .copyWith(color: AppColors.neutralGold)),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Skip the first one if it's already shown as featured
                        if (selectedCategory == 'All' && index == 0) {
                          return const SizedBox.shrink();
                        }
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
        margin: EdgeInsets.fromLTRB(R.w(context, 16), R.h(context, 16),
            R.w(context, 16), R.h(context, 8)),
        height: R.h(context, 240),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(R.w(context, 16)),
          image: DecorationImage(
            image: NetworkImage(article.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.4), BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(
              color: (Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.deepCharcoal)
                  .withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(R.w(context, 20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(context, 10), vertical: R.h(context, 4)),
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(R.w(context, 20))),
                child: Text(article.category.toUpperCase(),
                    style: AppTypography.label(context).copyWith(
                        fontSize: R.sp(context, 10),
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurface
                            : AppColors.deepCharcoal))),
              ),
              SizedBox(height: R.h(context, 12)),
              Text(
                article.title,
                style: AppTypography.h2(context).copyWith(
                    color: Colors.white,
                    fontSize: R.sp(context, 22),
                    height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: R.h(context, 8)),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: R.sp(context, 14), color: Colors.white70),
                  SizedBox(width: R.w(context, 4)),
                  Text('${article.readTimeMinutes} min read',
                      style: AppTypography.bodySM(context).copyWith(
                          color: Colors.white70, fontSize: R.sp(context, 12))),
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
        margin: EdgeInsets.only(bottom: R.h(context, 16)),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onSurface
                        : AppColors.deepCharcoal)
                    .withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(R.w(context, 12)),
                  bottomLeft: Radius.circular(R.w(context, 12))),
              child: Image.network(
                article.imageUrl,
                width: R.w(context, 100),
                height: R.w(context, 110),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: R.w(context, 100),
                  height: R.w(context, 110),
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).scaffoldBackgroundColor
                      : AppColors.backgroundLight),
                  child: const Icon(Icons.image_outlined,
                      color: AppColors.neutralGold),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(R.w(context, 12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.category.toUpperCase(),
                        style: AppTypography.label(context).copyWith(
                            fontSize: R.sp(context, 10),
                            color: AppColors.primary)),
                    SizedBox(height: R.h(context, 4)),
                    Text(
                      article.title,
                      style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: R.sp(context, 14),
                          height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: R.h(context, 8)),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: R.sp(context, 12),
                            color: AppColors.neutralGold),
                        SizedBox(width: R.w(context, 4)),
                        Text('${article.readTimeMinutes} min read',
                            style: AppTypography.bodySM(context).copyWith(
                                color: AppColors.neutralGold,
                                fontSize: R.sp(context, 11))),
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
