import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../constants/app_colors.dart';
import '../utils/responsive.dart';

// ── Shimmer effect helper ─────────────────────────────────────────────────────
// Returns the correct ShimmerEffect based on the current theme brightness.
ShimmerEffect _shimmerEffect(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return ShimmerEffect(
    baseColor: isDark ? const Color(0xFF2A2418) : const Color(0xFFE8E5DA),
    highlightColor: isDark ? const Color(0xFF3D3426) : const Color(0xFFF6F4EE),
    duration: const Duration(milliseconds: 1200),
  );
}

// ── Product Card Skeleton ────────────────────────────────────────────────────
/// Drop-in shimmer replacement for ProductCard when loading.
class ProductCardSkeleton extends StatelessWidget {
  final bool compact;
  const ProductCardSkeleton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
      enabled: true,
      effect: _shimmerEffect(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A160F) : const Color(0xFFF5F3EC),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                  ),
                  // Mock Badge (top-left)
                  Positioned(
                    top: R.h(context, 8),
                    left: R.w(context, 8),
                    child: Bone(
                      width: R.w(context, 55),
                      height: R.h(context, 14),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Mock Discount (top-right)
                  Positioned(
                    top: R.h(context, 8),
                    right: R.w(context, 8),
                    child: Bone(
                      width: R.w(context, 30),
                      height: R.h(context, 14),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Text area
            Padding(
              padding: EdgeInsets.fromLTRB(
                R.w(context, 10), R.h(context, 9), R.w(context, 10), R.h(context, 10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Bone.text(words: 2, fontSize: 8.5),
                  SizedBox(height: R.h(context, 3)),
                  Bone.text(words: 3, fontSize: compact ? 11 : 12.5),
                  SizedBox(height: R.h(context, 4)),
                  const Bone.text(words: 1, fontSize: 8),
                  SizedBox(height: R.h(context, 7)),
                  Row(
                    children: [
                      const Bone.text(words: 1, fontSize: 14),
                      const Spacer(),
                      Bone(
                        width: R.w(context, 30),
                        height: R.w(context, 30),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Horizontal Product List Skeleton ────────────────────────────────────────
class HorizontalProductListSkeleton extends StatelessWidget {
  final int count;
  final double height;
  const HorizontalProductListSkeleton({super.key, this.count = 4, this.height = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: R.h(context, height),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(width: R.w(context, 12)),
        itemBuilder: (_, __) => SizedBox(
          width: R.w(context, 150),
          child: const ProductCardSkeleton(compact: true),
        ),
      ),
    );
  }
}

// ── Product Grid Skeleton ────────────────────────────────────────────────────
class ProductGridSkeleton extends StatelessWidget {
  final int count;
  const ProductGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(R.w(context, 16)),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: R.w(context, 10),
          mainAxisSpacing: R.h(context, 10),
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => const ProductCardSkeleton(),
          childCount: count,
        ),
      ),
    );
  }
}

// ── Category Pill Skeleton ───────────────────────────────────────────────────
class CategoryListSkeleton extends StatelessWidget {
  final int count;
  const CategoryListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    final circleSize = R.w(context, 62);
    return SizedBox(
      height: R.h(context, 95),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: R.w(context, 20)),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(width: R.w(context, 12)),
        itemBuilder: (_, __) => Skeletonizer(
          enabled: true,
          effect: _shimmerEffect(context),
          child: Column(
            children: [
              Bone.circle(size: circleSize),
              SizedBox(height: R.h(context, 6)),
              const Bone.text(words: 1, fontSize: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Banner/Carousel Skeleton ─────────────────────────────────────────────────
class BannerSkeleton extends StatelessWidget {
  const BannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
      enabled: true,
      effect: _shimmerEffect(context),
      child: Container(
        width: double.infinity,
        height: R.h(context, 220),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A160F) : const Color(0xFFF5F3EC),
        ),
        padding: EdgeInsets.all(R.w(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Bone(width: R.w(context, 70), height: R.h(context, 18), borderRadius: BorderRadius.circular(4)),
            SizedBox(height: R.h(context, 8)),
            Bone(width: R.w(context, 180), height: R.h(context, 26), borderRadius: BorderRadius.circular(4)),
            SizedBox(height: R.h(context, 6)),
            Bone(width: R.w(context, 140), height: R.h(context, 16), borderRadius: BorderRadius.circular(4)),
            SizedBox(height: R.h(context, 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Bone(width: R.w(context, 100), height: R.h(context, 36), borderRadius: BorderRadius.circular(20)),
                Row(
                  children: List.generate(4, (index) => Padding(
                    padding: EdgeInsets.only(left: R.w(context, 5)),
                    child: Bone(
                      width: index == 0 ? R.w(context, 18) : R.w(context, 5),
                      height: R.h(context, 5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order Card Skeleton ──────────────────────────────────────────────────────
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
      enabled: true,
      effect: _shimmerEffect(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Container(
              padding: EdgeInsets.symmetric(horizontal: R.w(context, 12), vertical: R.h(context, 10)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.vertical(top: Radius.circular(R.w(context, 11))),
              ),
              child: Row(children: [
                const Expanded(child: Bone.text(words: 2, fontSize: 12)),
                SizedBox(width: R.w(context, 12)),
                const Expanded(child: Bone.text(words: 1, fontSize: 12)),
                SizedBox(width: R.w(context, 12)),
                const Expanded(child: Bone.text(words: 2, fontSize: 12)),
              ]),
            ),
            Padding(
              padding: EdgeInsets.all(R.w(context, 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Bone.circle(size: R.w(context, 32)),
                    SizedBox(width: R.w(context, 12)),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Bone.text(words: 2, fontSize: 13),
                      SizedBox(height: R.h(context, 4)),
                      const Bone.text(words: 5, fontSize: 11),
                    ])),
                  ]),
                  SizedBox(height: R.h(context, 10)),
                  Row(children: [
                    Bone(width: R.w(context, 56), height: R.w(context, 56), borderRadius: BorderRadius.circular(R.w(context, 8))),
                    SizedBox(width: R.w(context, 12)),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Bone.text(words: 3, fontSize: 13),
                      SizedBox(height: R.h(context, 4)),
                      const Bone.text(words: 4, fontSize: 11),
                      SizedBox(height: R.h(context, 4)),
                      const Bone.text(words: 1, fontSize: 12),
                    ])),
                  ]),
                  SizedBox(height: R.h(context, 12)),
                  Row(children: [
                    Expanded(child: Bone(height: R.h(context, 32), borderRadius: BorderRadius.circular(R.w(context, 6)))),
                    SizedBox(width: R.w(context, 8)),
                    Expanded(child: Bone(height: R.h(context, 32), borderRadius: BorderRadius.circular(R.w(context, 6)))),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Orders List Skeleton ─────────────────────────────────────────────────────
class OrdersListSkeleton extends StatelessWidget {
  final int count;
  const OrdersListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 12)),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => SizedBox(height: R.h(context, 12)),
      itemBuilder: (_, __) => const OrderCardSkeleton(),
    );
  }
}

// ── Address Card Skeleton ────────────────────────────────────────────────────
class AddressCardSkeleton extends StatelessWidget {
  const AddressCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
      enabled: true,
      effect: _shimmerEffect(context),
      child: Container(
        padding: EdgeInsets.all(R.w(context, 16)),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 12)),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Bone.circle(size: R.w(context, 40)),
            SizedBox(width: R.w(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Bone.text(words: 2, fontSize: 13),
                  SizedBox(height: R.h(context, 4)),
                  const Bone.text(words: 5, fontSize: 11),
                  SizedBox(height: R.h(context, 2)),
                  const Bone.text(words: 4, fontSize: 11),
                ],
              ),
            ),
            SizedBox(width: R.w(context, 12)),
            Column(
              children: [
                Bone(width: R.w(context, 28), height: R.w(context, 28), borderRadius: BorderRadius.circular(6)),
                SizedBox(height: R.h(context, 6)),
                Bone(width: R.w(context, 28), height: R.w(context, 28), borderRadius: BorderRadius.circular(6)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ── Product Detail Skeleton ──────────────────────────────────────────────────
class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
      enabled: true,
      effect: _shimmerEffect(context),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: R.h(context, 340),
              color: isDark ? const Color(0xFF2A2418) : const Color(0xFFEEEBE4),
            ),
            Padding(
              padding: EdgeInsets.all(R.w(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Bone.text(words: 2, fontSize: 9),
                      Bone.text(words: 3, fontSize: 9),
                    ],
                  ),
                  SizedBox(height: R.h(context, 8)),
                  const Bone.text(words: 4, fontSize: 22),
                  SizedBox(height: R.h(context, 4)),
                  const Bone.text(words: 6, fontSize: 14),
                  SizedBox(height: R.h(context, 16)),
                  Row(children: [
                    const Bone.text(words: 1, fontSize: 28),
                    SizedBox(width: R.w(context, 10)),
                    const Bone.text(words: 1, fontSize: 18),
                  ]),
                  SizedBox(height: R.h(context, 20)),
                  Bone(
                    width: double.infinity,
                    height: R.h(context, 56),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  SizedBox(height: R.h(context, 20)),
                  const Bone.text(words: 2, fontSize: 14),
                  SizedBox(height: R.h(context, 10)),
                  ...List.generate(3, (_) => Padding(
                    padding: EdgeInsets.only(bottom: R.h(context, 8)),
                    child: Row(children: [
                      const Bone.circle(size: 18),
                      SizedBox(width: R.w(context, 8)),
                      const Bone.text(words: 5, fontSize: 13),
                    ]),
                  )),
                  SizedBox(height: R.h(context, 20)),
                  const Bone.multiText(lines: 4, fontSize: 13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search Results Skeleton ──────────────────────────────────────────────────
class SearchResultsSkeleton extends StatelessWidget {
  const SearchResultsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 8)),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: R.w(context, 10),
          mainAxisSpacing: R.h(context, 10),
        ),
        itemCount: 4,
        itemBuilder: (_, __) => const ProductCardSkeleton(),
      ),
    );
  }
}

// ── Account Screen Skeleton ──────────────────────────────────────────────────
class AccountScreenSkeleton extends StatelessWidget {
  const AccountScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Skeletonizer(
      enabled: true,
      effect: _shimmerEffect(context),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(context, 20)),
        child: Column(
          children: [
            Column(
              children: [
                Bone.circle(size: R.w(context, 72)),
                SizedBox(height: R.h(context, 12)),
                const Bone.text(words: 2, fontSize: 18),
                SizedBox(height: R.h(context, 4)),
                const Bone.text(words: 3, fontSize: 13),
              ],
            ),
            SizedBox(height: R.h(context, 24)),
            ...List.generate(5, (_) => Padding(
              padding: EdgeInsets.only(bottom: R.h(context, 12)),
              child: Container(
                padding: EdgeInsets.all(R.w(context, 16)),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(R.w(context, 12)),
                ),
                child: Row(
                  children: [
                    Bone.circle(size: R.w(context, 36)),
                    SizedBox(width: R.w(context, 12)),
                    const Expanded(child: Bone.text(words: 2, fontSize: 14)),
                    Bone(width: R.w(context, 16), height: R.h(context, 16), borderRadius: BorderRadius.circular(4)),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
