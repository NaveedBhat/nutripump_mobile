import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/providers.dart';
import '../../utils/ai_matcher.dart';

class TasteProfilerState {
  final int step;
  final TasteProfile profile;
  final List<Product> results;
  final bool isRevealing;

  const TasteProfilerState({
    required this.step,
    required this.profile,
    required this.results,
    required this.isRevealing,
  });

  factory TasteProfilerState.initial() {
    return const TasteProfilerState(
      step: 0,
      profile: TasteProfile(morning: '', texture: '', lifestyle: '', vibe: ''),
      results: [],
      isRevealing: false,
    );
  }

  TasteProfilerState copyWith({
    int? step,
    TasteProfile? profile,
    List<Product>? results,
    bool? isRevealing,
  }) {
    return TasteProfilerState(
      step: step ?? this.step,
      profile: profile ?? this.profile,
      results: results ?? this.results,
      isRevealing: isRevealing ?? this.isRevealing,
    );
  }
}

class TasteProfilerNotifier extends StateNotifier<TasteProfilerState> {
  final Ref _ref;

  TasteProfilerNotifier(this._ref) : super(TasteProfilerState.initial());

  void selectAnswer(String stepId, String answerId) {
    TasteProfile newProfile = state.profile;

    switch (stepId) {
      case 'morning':
        newProfile = newProfile.copyWith(morning: answerId);
        break;
      case 'texture':
        newProfile = newProfile.copyWith(texture: answerId);
        break;
      case 'lifestyle':
        newProfile = newProfile.copyWith(lifestyle: answerId);
        break;
      case 'vibe':
        newProfile = newProfile.copyWith(vibe: answerId);
        break;
    }

    if (state.step < 3) {
      state = state.copyWith(
        profile: newProfile,
        step: state.step + 1,
      );
    } else {
      // Final step
      state = state.copyWith(
        profile: newProfile,
        isRevealing: true,
      );

      _matchProducts(newProfile);
    }
  }

  Future<void> _matchProducts(TasteProfile finalProfile) async {
    // Artificial delay for the cool animation
    await Future.delayed(const Duration(milliseconds: 1500));

    // Get all products
    final asyncProducts = _ref.read(allProductsProvider);
    final products = asyncProducts.value ?? [];

    final ranked = AiMatcher.scoreProfileMatch(products, finalProfile);

    if (mounted) {
      state = state.copyWith(
        results: ranked,
        isRevealing: false,
        step: 4, // Showing results
      );
    }
  }

  void reset() {
    state = TasteProfilerState.initial();
  }
}

final tasteProfilerProvider =
    StateNotifierProvider<TasteProfilerNotifier, TasteProfilerState>((ref) {
  return TasteProfilerNotifier(ref);
});
