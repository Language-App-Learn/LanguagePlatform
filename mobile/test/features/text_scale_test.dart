import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/l10n/l10n.dart';

import '../helpers/pump_app.dart';

/// Large system font on a narrow phone (360x640): no render overflow on any
/// screen, in a LTR and the RTL language.
void main() {
  final screens = <String, String>{
    'onboarding': AppRoutes.onboarding,
    'language-setup': AppRoutes.languageSetup,
    'login': AppRoutes.login,
    'register': AppRoutes.register,
    'home': AppRoutes.home,
    'courses': AppRoutes.courses,
    'vocabulary': AppRoutes.vocabulary,
    'review': AppRoutes.review,
    'review-history': AppRoutes.reviewHistory,
    'progress': AppRoutes.progress,
    'profile': AppRoutes.profile,
    'settings': AppRoutes.settings,
    'course': '/course/ar-a1-basics',
    'lesson': '/lesson/ar-a1-l1',
    'quiz': '/quiz/ar-a1-l1',
  };

  for (final scale in [1.5, 2.0]) {
    for (final language in [AppLanguage.en, AppLanguage.ar]) {
      for (final entry in screens.entries) {
        testWidgets('${entry.key} / ${language.code} / x$scale', (
          tester,
        ) async {
          useScreen(tester, width: 360, height: 640);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await pumpApp(
            tester,
            language: language,
            initialLocation: entry.value,
            overrides: [trToArPreferences, fixedClock],
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
