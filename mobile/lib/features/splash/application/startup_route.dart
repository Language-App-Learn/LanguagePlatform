import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_routes.dart';
import '../../language_selection/application/learning_preferences.dart';
import '../../onboarding/application/onboarding_state.dart';

/// Başlangıç yönlendirme kuralı (saf fonksiyon, kolay test edilir):
/// önce tanıtım, sonra dil kurulumu, ardından ana sayfa.
///
/// Gerçek kimlik doğrulama yok; bu yüzden burada oturum denetimi yapılmaz.
String startupRouteFor({
  required bool onboardingCompleted,
  required LearningPreferences preferences,
}) {
  if (!onboardingCompleted) return AppRoutes.onboarding;
  if (!preferences.isComplete) return AppRoutes.languageSetup;
  return AppRoutes.home;
}

/// Splash'in gideceği rota. Tercihler kalıcı hale gelince (yerel depolama)
/// burada asenkron okunacak; bu yüzden `Future`.
final startupRouteProvider = FutureProvider<String>((ref) async {
  return startupRouteFor(
    onboardingCompleted: ref.watch(onboardingCompletedProvider),
    preferences: ref.watch(learningPreferencesProvider),
  );
});
