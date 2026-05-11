import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/skeleton_loaders.dart';
import '../../../models/models.dart';
import '../../../models/product.dart';
import '../../../providers/providers.dart';

class ProductReviewsSection extends ConsumerWidget {
  final Product product;

  const ProductReviewsSection({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));

    return Container(
      margin: EdgeInsets.only(top: R.h(context, 32)),
      padding: EdgeInsets.only(top: R.h(context, 32)),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What people are saying',
              style: AppTypography.h2(context)
                  .copyWith(fontSize: R.sp(context, 20))),
          SizedBox(height: R.h(context, 16)),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.w(context, 10)),
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(R.w(context, 12))),
                child: Icon(Icons.star,
                    color: AppColors.primary, size: R.sp(context, 20)),
              ),
              SizedBox(width: R.w(context, 12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.rating > 0
                        ? product.rating.toStringAsFixed(1)
                        : '—',
                    style: AppTypography.h2(context)
                        .copyWith(fontSize: R.sp(context, 24)),
                  ),
                  Text(
                    '${product.reviewCount} Global Ratings',
                    style: AppTypography.label(context).copyWith(
                        color: AppColors.neutralGold,
                        fontSize: R.sp(context, 10)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(context, 24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer Reviews',
                  style: AppTypography.h2(context)
                      .copyWith(fontSize: R.sp(context, 18))),
              GestureDetector(
                onTap: () => _showReviewBottomSheet(context, ref, product),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 14), vertical: R.h(context, 8)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : AppColors.deepCharcoal,
                    borderRadius: BorderRadius.circular(R.w(context, 100)),
                  ),
                  child: Text('Write a Review',
                      style: AppTypography.label(context).copyWith(
                          color: Colors.white,
                          fontSize: R.sp(context, 10),
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(context, 16)),
          reviewsAsync.when(
            loading: () => const HorizontalProductListSkeleton(height: 240),
            error: (_, __) => const SizedBox.shrink(),
            data: (reviews) {
              if (reviews.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.borderLight, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.rate_review_outlined,
                          size: 32, color: AppColors.neutralGold),
                      const SizedBox(height: 12),
                      Text('No reviews yet',
                          style: AppTypography.bodySM(context).copyWith(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Be the first to review this product!',
                          style: AppTypography.bodySM(context).copyWith(
                              color: AppColors.neutralGold, fontSize: 12)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildReviewCard(context, reviews[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    final displayName =
        review.isAnonymous ? 'Anonymous' : (review.userName ?? 'Customer');
    final ago = _timeAgo(review.createdAt);
    return Container(
      padding: EdgeInsets.all(R.w(context, 16)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(R.w(context, 12)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(
                    5,
                    (index) => Icon(
                          index < review.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.primary,
                          size: R.sp(context, 12),
                        )),
              ),
              if (review.verified) ...[
                SizedBox(width: R.w(context, 8)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 6), vertical: R.h(context, 2)),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(R.w(context, 100))),
                  child: Text('Verified',
                      style: AppTypography.label(context).copyWith(
                          color: const Color(0xFF137333),
                          fontSize: R.sp(context, 8))),
                ),
              ],
              const Spacer(),
              Text(ago,
                  style: AppTypography.label(context).copyWith(
                      color: AppColors.neutralGold,
                      fontSize: R.sp(context, 9))),
            ],
          ),
          SizedBox(height: R.h(context, 8)),
          if (review.title.isNotEmpty)
            Text(review.title,
                style: AppTypography.bodySM(context).copyWith(
                    fontWeight: FontWeight.w700, fontSize: R.sp(context, 12))),
          if (review.title.isNotEmpty) SizedBox(height: R.h(context, 4)),
          Text(review.body,
              style: AppTypography.bodySM(context).copyWith(
                  color: AppColors.neutralGold,
                  fontSize: R.sp(context, 12),
                  height: 1.4)),
          SizedBox(height: R.h(context, 8)),
          Text('— $displayName',
              style: AppTypography.label(context).copyWith(
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.deepCharcoal),
                  fontSize: R.sp(context, 10))),
          if (review.adminReply != null) ...[
            SizedBox(height: R.h(context, 12)),
            Container(
              padding: EdgeInsets.all(R.w(context, 12)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(R.w(context, 8)),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NutriPump Team',
                      style: AppTypography.label(context).copyWith(
                          color: AppColors.primary,
                          fontSize: R.sp(context, 9),
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: R.h(context, 4)),
                  Text(review.adminReply!,
                      style: AppTypography.bodySM(context)
                          .copyWith(fontSize: R.sp(context, 11), height: 1.4)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  void _showReviewBottomSheet(
      BuildContext context, WidgetRef ref, Product product) {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(milliseconds: 2000),
            content: Text('Please log in to write a review')),
      );
      context.push('/auth/login');
      return;
    }

    int rating = 5;
    bool isAnonymous = false;
    bool isSubmitting = false;
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(R.w(context, 28))),
          ),
          padding: EdgeInsets.fromLTRB(
              R.w(context, 24),
              R.h(context, 24),
              R.w(context, 24),
              MediaQuery.of(ctx).viewInsets.bottom + R.h(context, 32)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: R.w(context, 40),
                    height: R.h(context, 4),
                    decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(R.w(context, 2))),
                  ),
                ),
                SizedBox(height: R.h(context, 20)),
                Text('Write a Review',
                    style: AppTypography.h2(context)
                        .copyWith(fontSize: R.sp(context, 22))),
                SizedBox(height: R.h(context, 24)),
                Text('Your Rating',
                    style: AppTypography.label(context).copyWith(
                        color: AppColors.neutralGold,
                        fontSize: R.sp(context, 10),
                        letterSpacing: 1.5)),
                SizedBox(height: R.h(context, 10)),
                Row(
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setModalState(() => rating = i + 1),
                      child: Padding(
                        padding: EdgeInsets.only(right: R.w(context, 8)),
                        child: Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          color: AppColors.primary,
                          size: R.sp(context, 32),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: R.h(context, 20)),
                Text('Review Title',
                    style: AppTypography.label(context).copyWith(
                        color: AppColors.neutralGold,
                        fontSize: R.sp(context, 10),
                        letterSpacing: 1.5)),
                SizedBox(height: R.h(context, 8)),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'Sum up your experience',
                    hintStyle: AppTypography.bodySM(context).copyWith(
                        color: AppColors.neutralGold.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : const Color(0xFFF9F9F9),
                    contentPadding: EdgeInsets.all(R.w(context, 16)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 14)),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 14)),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 14)),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2)),
                  ),
                ),
                SizedBox(height: R.h(context, 16)),
                Text('Review Details',
                    style: AppTypography.label(context).copyWith(
                        color: AppColors.neutralGold,
                        fontSize: R.sp(context, 10),
                        letterSpacing: 1.5)),
                SizedBox(height: R.h(context, 8)),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'What did you love about it?',
                    hintStyle: AppTypography.bodySM(context).copyWith(
                        color: AppColors.neutralGold.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : const Color(0xFFF9F9F9),
                    contentPadding: EdgeInsets.all(R.w(context, 16)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 14)),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 14)),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 14)),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2)),
                  ),
                ),
                SizedBox(height: R.h(context, 16)),
                GestureDetector(
                  onTap: () => setModalState(() => isAnonymous = !isAnonymous),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: R.w(context, 44),
                        height: R.h(context, 24),
                        decoration: BoxDecoration(
                          color: isAnonymous
                              ? AppColors.primary
                              : AppColors.borderLight,
                          borderRadius:
                              BorderRadius.circular(R.w(context, 100)),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: isAnonymous
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.all(R.w(context, 3)),
                            width: R.w(context, 18),
                            height: R.h(context, 18),
                            decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.surfaceDark
                                    : Colors.white,
                                shape: BoxShape.circle),
                          ),
                        ),
                      ),
                      SizedBox(width: R.w(context, 12)),
                      Text('Post Anonymously',
                          style: AppTypography.bodySM(context).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: R.sp(context, 13))),
                    ],
                  ),
                ),
                SizedBox(height: R.h(context, 24)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.deepCharcoal,
                      padding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(R.w(context, 14))),
                      elevation: 0,
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final title = titleCtrl.text.trim();
                            final body = bodyCtrl.text.trim();
                            if (title.isEmpty || body.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                      duration: Duration(milliseconds: 2000),
                                      content:
                                          Text('Please fill in all fields')));
                              return;
                            }
                            setModalState(() => isSubmitting = true);
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await ref.read(reviewServiceProvider).addReview(
                                    productId: product.id,
                                    userId: user.uid,
                                    userName: user.displayName ?? 'Customer',
                                    rating: rating.toDouble(),
                                    title: title,
                                    body: body,
                                  );
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              ref.invalidate(
                                  productReviewsProvider(product.id));
                              messenger.showSnackBar(const SnackBar(
                                  duration: Duration(milliseconds: 2000),
                                  content:
                                      Text('Review submitted! Thank you.')));
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(milliseconds: 2000),
                                        content: Text(
                                            'Failed to submit review. Please try again.')));
                              }
                            }
                          },
                    child: isSubmitting
                        ? SizedBox(
                            height: R.h(context, 20),
                            width: R.w(context, 20),
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.deepCharcoal))
                        : Text('Submit Review',
                            style: AppTypography.bodySM(context).copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: R.sp(context, 14))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
