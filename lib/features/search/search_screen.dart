import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/product_card.dart';
import '../../providers/providers.dart';
import 'widgets/voice_search_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final bool autoStartVoice;
  const SearchScreen({super.key, this.autoStartVoice = false});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepCharcoal),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3EE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: AppTypography.bodySM.copyWith(color: AppColors.deepCharcoal),
            decoration: InputDecoration(
              hintText: 'Search honey, saffron, nuts...',
              hintStyle: AppTypography.bodySM.copyWith(color: AppColors.neutralGold.withValues(alpha: 0.7)),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.neutralGold, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.neutralGold),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.mic_none, size: 18, color: AppColors.neutralGold),
                      onPressed: _startVoiceSearch,
                    ),
            ),
            onChanged: (val) => setState(() => _query = val),
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
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search_rounded, size: 32, color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'What are you looking for?',
                      textAlign: TextAlign.center,
                      style: AppTypography.h2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Search for pure honey, premium saffron, dry fruits, or specific collections.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySM.copyWith(color: AppColors.neutralGold, height: 1.5),
                    ),
                  ],
                ),
              ),
            );
          }

          if (results.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search_off_rounded, size: 32, color: AppColors.neutralGold),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No results found',
                      textAlign: TextAlign.center,
                      style: AppTypography.h2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We couldn\'t find anything matching "$_query".\nTry checking your spelling or use more general terms.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySM.copyWith(color: AppColors.neutralGold, height: 1.5),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return ProductCard(product: results[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load products')),
      ),
    );
  }
}
