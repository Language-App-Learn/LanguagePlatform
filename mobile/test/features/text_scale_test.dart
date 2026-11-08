import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/l10n/app_language.dart';

import '../helpers/pump_app.dart';

/// The account screens (kept infrastructure) must stay usable at large text
/// sizes on a small phone, in an LTR and the RTL language. The seven approved
/// screens have the same check in `first_screens_test.dart`.
void main() {
  const screens = <String, String>{
    'login': AppRoutes.login,
    'register': AppRoutes.register,
    'forgot-password': AppRoutes.forgotPassword,
    'confirm-email': AppRoutes.confirmEmail,
    'delete-account': AppRoutes.deleteAccount,
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
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
