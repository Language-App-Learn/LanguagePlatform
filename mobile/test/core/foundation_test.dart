import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/l10n/l10n.dart';
import 'package:language_platform/core/theme/app_colors.dart';
import 'package:language_platform/core/theme/app_theme.dart';
import 'package:language_platform/core/utils/bidi.dart';

void main() {
  group('AppTheme', () {
    test('Material 3, doğru parlaklık ve anlamsal renkler', () {
      expect(AppTheme.light.useMaterial3, isTrue);
      expect(AppTheme.dark.useMaterial3, isTrue);
      expect(AppTheme.light.colorScheme.brightness, Brightness.light);
      expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
      expect(AppTheme.light.extension<AppSemanticColors>(), isNotNull);
      expect(AppTheme.dark.extension<AppSemanticColors>(), isNotNull);
      expect(
        AppTheme.light.colorScheme.surface,
        isNot(AppTheme.dark.colorScheme.surface),
      );
    });
  });

  group('AppLanguage', () {
    test('en, tr, ar; İngilizce ilk (yedek dil); yönler doğru', () {
      expect(AppLanguage.supportedLocales, const [
        Locale('en'),
        Locale('tr'),
        Locale('ar'),
      ]);
      expect(AppLanguage.ar.textDirection, TextDirection.rtl);
      expect(AppLanguage.tr.textDirection, TextDirection.ltr);
      expect(AppLanguage.en.textDirection, TextDirection.ltr);
    });

    test('fromCode bilinmeyen kodda null döner', () {
      expect(AppLanguage.fromCode('tr'), AppLanguage.tr);
      expect(AppLanguage.fromCode('fr'), isNull);
      expect(AppLanguage.fromCode(null), isNull);
    });

    test('üretilen yerelleştirme AppLanguage ile aynı dilleri kapsar', () {
      expect(
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
        AppLanguage.values.map((l) => l.code).toSet(),
      );
    });

    test('her dilde temel metinler dolu ve dillere göre farklıdır', () async {
      final retries = <String>{};
      for (final language in AppLanguage.values) {
        final l10n = await AppLocalizations.delegate.load(language.locale);
        expect(l10n.settingsTitle, isNotEmpty);
        retries.add(l10n.retry);
      }
      expect(retries, hasLength(AppLanguage.values.length));
    });
  });

  group('LocalizedText', () {
    const text = LocalizedText({'tr': 'Merhaba', 'en': 'Hello'});

    test('istenen dili döner, yoksa İngilizceye düşer', () {
      expect(text.resolve('tr'), 'Merhaba');
      expect(text.resolve('ar'), 'Hello');
      expect(text.resolve(null), 'Hello');
    });

    test('İngilizce de yoksa ilk değere düşer, plain her dilde aynıdır', () {
      expect(const LocalizedText({'tr': 'Selam'}).resolve('ar'), 'Selam');
      expect(const LocalizedText.plain('A1').resolve('ar'), 'A1');
      expect(const LocalizedText({}).resolve('en'), isEmpty);
    });

    test('değer eşitliği', () {
      expect(
        const LocalizedText({'en': 'a'}),
        const LocalizedText({'en': 'a'}),
      );
    });
  });

  test('isolateLtr metni LRI/PDI ile sarar', () {
    expect('a@b.com'.isolateLtr, '\u{2066}a@b.com\u{2069}');
  });
}
