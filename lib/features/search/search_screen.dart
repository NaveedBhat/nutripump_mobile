import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/providers.dart';
import 'widgets/voice_search_bottom_sheet.dart';
import '../../core/widgets/skeleton_loaders.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final bool autoStartVoice;
  const SearchScreen({super.key, this.autoStartVoice = false});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.autoStartVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startVoiceSearch();
      });
    }
  }

  Future<void> _startVoiceSearch() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceSearchBottomSheet(),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _searchController.text = result;
        _query = result;
      });
      // Move cursor to end
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : (Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).scaffoldBackgroundColor
              : const Color(0xFFF8F6F1))),
      appBar: AppBar(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.deepCharcoal),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: R.h(context, 40),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : const Color(0xFFF5F3EE),
            borderRadius: BorderRadius.circular(R.w(context, 10)),
            border: Theme.of(context).brightness == Brightness.dark
                ? Border.all(color: AppColors.borderDark, width: 1)
                : null,
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: AppTypography.bodySM(context).copyWith(
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.deepCharcoal)),
            decoration: InputDecoration(
              hintText: 'Search honey, saffron, nuts...',
              hintStyle: AppTypography.bodySM(context).copyWith(
                  color: AppColors.neutralGold.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.search_rounded,
                  color: AppColors.neutralGold, size: R.sp(context, 20)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: R.h(context, 10)),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close,
                          size: R.sp(context, 18),
                          color: AppColors.neutralGold),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.mic_none,
                          size: R.sp(context, 18),
                          color: AppColors.neutralGold),
                      onPressed: _startVoiceSearch,
                    ),
            ),
            onChanged: (val) {
              if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                if (mounted) setState(() => _query = val);
              });
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: productsAsync.when(
        data: (products) {
          final results = products.where((p) {
            if (_query.isEmpty) return false;
            final q = _query.toLowerCase();
            return p.name.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q) ||
                p.tags.any((t) => t.toLowerCase().contains(q));
          }).toList();

          if (_query.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 40)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(R.w(context, 24)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search_rounded,
                          size: R.sp(context, 32), color: AppColors.primary),
                    ),
                    SizedBox(height: R.h(context, 24)),
                    Text(
                      'What are you looking for?',
                      textAlign: TextAlign.center,
                      style: AppTypography.h2(context)
                          .copyWith(fontSize: R.sp(context, 18)),
                    ),
                    SizedBox(height: R.h(context, 12)),
                    Text(
                      'Search for pure honey, premium saffron, dry fruits, or specific collections.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySM(context)
                          .copyWith(color: AppColors.neutralGold, height: 1.5),
                    ),
                  ],
                ),
              ),
            );
          }

          if (results.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 40)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(R.w(context, 24)),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search_off_rounded,
                          size: R.sp(context, 32),
                          color: AppColors.neutralGold),
                    ),
                    SizedBox(height: R.h(context, 24)),
                    Text(
                      'No results found',
                      textAlign: TextAlign.center,
                      style: AppTypography.h2(context)
                          .copyWith(fontSize: R.sp(context, 18)),
                    ),
                    SizedBox(height: R.h(context, 12)),
                    Text(
                      'We couldn\'t find anything matching "$_query".\nTry checking your spelling or use more general terms.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySM(context)
                          .copyWith(color: AppColors.neutralGold, height: 1.5),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(R.w(context, 20)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: R.w(context, 16),
              mainAxisSpacing: R.h(context, 24),
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return ProductCard(product: results[index]);
            },
          );
        },
        loading: () => const SearchResultsSkeleton(),
        error: (_, __) => const Center(child: Text('Failed to load products')),
      ),
    );
  }
}
