import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/app.dart';
import 'package:language_platform/app/router/app_router.dart';
import 'package:language_platform/core/l10n/l10n.dart';
import 'package:language_platform/core/theme/theme_mode_provider.dart';
import 'package:language_platform/features/language_selection/application/learning_preferences.dart';
import 'package:language_platform/features/language_selection/domain/learning_language.dart';
import 'package:language_platform/features/progress/application/progress_providers.dart';
import 'package:language_platform/features/splash/application/startup_route.dart';

/// Uygulamayı verilen dil/tema/rota ile açar ve (varsayılan olarak) ilk
/// kareler oturana kadar bekler. Dönen container ile state okunabilir.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  AppLanguage? language = AppLanguage.en,
  ThemeMode themeMode = ThemeMode.light,
  String? initialLocation,
  List<Override> overrides = const [],
  bool settle = true,
  Duration splashHold = Duration.zero,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        appLanguageProvider.overrideWith(() => AppLanguageNotifier(language)),
        themeModeProvider.overrideWith(() => ThemeModeNotifier(themeMode)),
        splashHoldProvider.overrideWithValue(splashHold),
        if (initialLocation != null)
          initialLocationProvider.overrideWithValue(initialLocation),
        ...overrides,
      ],
      child: const LanguagePlatformApp(),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return ProviderScope.containerOf(
    tester.element(find.byType(LanguagePlatformApp)),
  );
}

/// Ekran boyutunu değiştirir (test sonunda geri alınır).
void useScreen(
  WidgetTester tester, {
  double width = 800,
  double height = 3200,
}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Bildiği dil: Türkçe, öğrendiği dil: Arapça.
final Override trToArPreferences = learningPreferencesProvider.overrideWith(
  () => LearningPreferencesNotifier(
    LearningPreferences(
      knownLanguage: LearningLanguage.fromCode('tr'),
      targetLanguage: LearningLanguage.fromCode('ar'),
    ),
  ),
);

/// Sabit saat: 2026-11-06 12:00.
final Override fixedClock = clockProvider.overrideWithValue(
  () => DateTime(2026, 11, 6, 12),
);

/// Ekrandaki etkin yazı yönü.
TextDirection currentDirection(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(Scaffold).first));

/// Ekrandaki etkin yerelleştirme.
AppLocalizations currentL10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

/// Router'ın şu anki yolu (örn. `/home`).
String currentPath(ProviderContainer container) => container
    .read(routerProvider)
    .routerDelegate
    .currentConfiguration
    .last
    .matchedLocation;
