import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/legal_service.dart';

final legalServiceProvider = Provider<LegalService>((ref) {
  return LegalService();
});

final privacyPageProvider = FutureProvider.autoDispose<LegalPage?>((ref) async {
  final service = ref.watch(legalServiceProvider);
  return await service.getLegalPage('privacy_policy');
});

final termsPageProvider = FutureProvider.autoDispose<LegalPage?>((ref) async {
  final service = ref.watch(legalServiceProvider);
  return await service.getLegalPage('terms_of_service');
});
