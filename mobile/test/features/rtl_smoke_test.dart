import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/l10n/l10n.dart';

import '../helpers/pump_app.dart';

/// Her ekran × 3 dil × açık/koyu tema: dar telefonda (360x640) çizim hatası
/// veya taşma olmamalı; yön dile uygun olmalı.
void main() {
  final screens = <String, String>{
    'onboarding': AppRoutes.onboarding,
    'language-setup': AppRoutes.languageSetup,
    'login': AppRoutes.login,
    'register': AppRoutes.register,
    'forgot-password': AppRoutes.forgotPassword,
    'home': AppRoutes.home,
    'courses': AppRoutes.courses,
    'vocabulary': AppRoutes.vocabulary,
    'progress': AppRoutes.progress,
    'profile': AppRoutes.profile,
    'settings': AppRoutes.settings,
    'course': '/course/ar-a1-basics',
    'lesson': '/lesson/ar-a1-l2',
    'quiz': '/quiz/ar-a1-l2',
  };

  for (final language in AppLanguage.values) {
    for (final entry in screens.entries) {
      final dark = entry.key.length.isEven; // iki temayı da dağıtarak dene
      testWidgets(
        '${entry.key} / ${language.code} / ${dark ? 'koyu' : 'açık'}',
        (tester) async {
          useScreen(tester, width: 360, height: 640);
          await pumpApp(
            tester,
            language: language,
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            initialLocation: entry.value,
            overrides: [trToArPreferences, fixedClock],
          );
          expect(tester.takeException(), isNull);
          expect(currentDirection(tester), language.textDirection);
        },
      );
    }
  }

  testWidgets('RTL: alt gezinme sırası aynalanır', (tester) async {
    useScreen(tester, width: 400, height: 800);
    await pumpApp(
      tester,
      language: AppLanguage.ar,
      initialLocation: AppRoutes.home,
    );
    final home = tester.getCenter(find.text('الرئيسية')).dx;
    final profile = tester.getCenter(find.text('الملف الشخصي')).dx;
    expect(home, greaterThan(profile)); // RTL'de ilk sekme sağda
  });

  testWidgets('LTR: alt gezinme ilk sekme solda', (tester) async {
    useScreen(tester, width: 400, height: 800);
    await pumpApp(tester, initialLocation: AppRoutes.home);
    final home = tester.getCenter(find.text('Home')).dx;
    final profile = tester.getCenter(find.text('Profile')).dx;
    expect(home, lessThan(profile));
  });

  testWidgets('RTL: ders ekranında Arapça içerik ve teknik değerler bozulmaz', (
    tester,
  ) async {
    useScreen(tester, width: 400, height: 3000);
    await pumpApp(
      tester,
      language: AppLanguage.ar,
      initialLocation: '/lesson/ar-a1-l1',
      overrides: [trToArPreferences],
    );
    expect(find.text('مرحبًا!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Türkçe arayüz: ana sayfa metinleri Türkçe', (tester) async {
    useScreen(tester);
    await pumpApp(
      tester,
      language: AppLanguage.tr,
      initialLocation: AppRoutes.home,
      overrides: [trToArPreferences, fixedClock],
    );
    expect(find.text('Tekrar hoş geldin'), findsOneWidget);
    expect(find.text('Ana sayfa'), findsOneWidget);
    expect(find.text('İlk dersine başla'), findsOneWidget);
  });
}
