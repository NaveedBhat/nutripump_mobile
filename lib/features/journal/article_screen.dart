import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
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
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white),
      body: CustomScrollView(
        slivers: [
          // ── App Bar / Header Image ────────────────────────────
          SliverAppBar(
            expandedHeight: R.h(context, 300),
            pinned: true,
            backgroundColor: (Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).scaffoldBackgroundColor
                : Colors.white),
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.all(R.w(context, 8)),
              child: CircleAvatar(
                backgroundColor:
                    (Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).scaffoldBackgroundColor
                            : Colors.white)
                        .withValues(alpha: 0.8),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.deepCharcoal),
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
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : Colors.white,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(R.w(context, 24))),
              ),
              transform: Matrix4.translationValues(0, -R.h(context, 24), 0),
              padding: EdgeInsets.all(R.w(context, 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: R.w(context, 10),
                            vertical: R.h(context, 4)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(R.w(context, 20)),
                        ),
                        child: Text(article.category.toUpperCase(),
                            style: AppTypography.label(context).copyWith(
                                fontSize: R.sp(context, 10),
                                color: AppColors.primary)),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: R.sp(context, 14),
                              color: AppColors.neutralGold),
                          SizedBox(width: R.w(context, 4)),
                          Text('${article.readTimeMinutes} min read',
                              style: AppTypography.bodySM(context).copyWith(
                                  color: AppColors.neutralGold,
                                  fontSize: R.sp(context, 12))),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(context, 16)),

                  // Title
                  Text(article.title,
                      style: AppTypography.h2(context)
                          .copyWith(fontSize: R.sp(context, 26), height: 1.2)),
                  SizedBox(height: R.h(context, 16)),

                  // Author & Date
                  Row(
                    children: [
                      CircleAvatar(
                        radius: R.w(context, 16),
                        backgroundColor:
                            (Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).scaffoldBackgroundColor
                                : AppColors.backgroundLight),
                        child: Text(article.author[0],
                            style: AppTypography.bodySM(context)
                                .copyWith(fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(width: R.w(context, 10)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(article.author,
                              style: AppTypography.bodySM(context).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: R.sp(context, 13))),
                          Text(_formatDate(article.publishedAt),
                              style: AppTypography.bodySM(context).copyWith(
                                  color: AppColors.neutralGold,
                                  fontSize: R.sp(context, 11))),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(context, 24)),
                  const Divider(color: AppColors.borderLight),
                  SizedBox(height: R.h(context, 24)),

                  // Summary
                  Text(
                    article.summary,
                    style: AppTypography.bodySM(context).copyWith(
                      fontSize: R.sp(context, 16),
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.onSurface
                              : AppColors.deepCharcoal)
                          .withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: R.h(context, 24)),

                  // Main Content
                  Text(
                    article.content,
                    style: AppTypography.bodySM(context).copyWith(
                      fontSize: R.sp(context, 15),
                      height: 1.8,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.deepCharcoal),
                    ),
                  ),
                  SizedBox(height: R.h(context, 40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
