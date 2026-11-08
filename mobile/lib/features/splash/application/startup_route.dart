import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/l10n/app_language.dart';
import '../../language_selection/application/learning_preferences.dart';
import '../../onboarding/application/onboarding_state.dart';

/// First route after the splash: the one-time app-language choice, then
/// always the main menu. The choice is "made" once an interface language has
/// been saved; it can be changed later from Settings, never by this screen.
String entryRouteFor({required AppLanguage? appLanguage}) =>
    appLanguage == null ? AppRoutes.appLanguage : AppRoutes.menu;

/// Where "Dil Öğren" leads: the existing learning flow (onboarding, then
/// the learning-language setup, then home). Pure function, easy to test.
///
/// There is no real session check here; the account flow starts inside the
/// learning flow.
String startupRouteFor({
  required bool onboardingCompleted,
  required LearningPreferences preferences,
}) {
  if (!onboardingCompleted) return AppRoutes.onboarding;
  if (!preferences.isComplete) return AppRoutes.languageSetup;
  return AppRoutes.home;
}

/// How long the splash stays visible so the logo can be seen. Tests override
/// it with [Duration.zero].
final splashHoldProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 1300),
);

/// The splash's destination (after the short hold).
final startupRouteProvider = FutureProvider<String>((ref) async {
  final hold = ref.read(splashHoldProvider);
  if (hold > Duration.zero) await Future<void>.delayed(hold);
  return entryRouteFor(appLanguage: ref.watch(appLanguageProvider));
});

/// Destination of the "Dil Öğren" menu entry.
final learningEntryRouteProvider = Provider<String>(
  (ref) => startupRouteFor(
    onboardingCompleted: ref.watch(onboardingCompletedProvider),
    preferences: ref.watch(learningPreferencesProvider),
  ),
);
