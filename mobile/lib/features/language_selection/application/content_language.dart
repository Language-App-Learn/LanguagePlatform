import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_language.dart';
import 'learning_preferences.dart';

/// Ders/kelime İÇERİĞİNİN çevirileri hangi dilde gösterilir?
/// Öğrencinin bildiği dil; seçilmemişse arayüz dili; o da yoksa İngilizce.
/// (Arayüz metinleri bundan bağımsız olarak ARB ile arayüz dilinde gelir.)
final contentLanguageProvider = Provider<String>((ref) {
  final known = ref.watch(
    learningPreferencesProvider.select((p) => p.knownLanguage?.code),
  );
  return known ?? ref.watch(appLanguageProvider)?.code ?? 'en';
});

/// Öğrenilen dil kodu; seçilmediyse `null`.
final targetLanguageCodeProvider = Provider<String?>((ref) {
  return ref.watch(
    learningPreferencesProvider.select((p) => p.targetLanguage?.code),
  );
});
