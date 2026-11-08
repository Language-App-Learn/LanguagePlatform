import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/l10n/app_language.dart';
import 'package:language_platform/core/storage/app_preferences.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/features/language_selection/application/learning_preferences.dart';
import 'package:language_platform/features/language_selection/domain/learning_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A new container over the same store = an app restart.
ProviderContainer _launch(KeyValueStore store) => ProviderContainer.test(
  overrides: [keyValueStoreProvider.overrideWithValue(store)],
);

void main() {
  group('KeyValueStore', () {
    test(
      'SharedPreferences store: roundtrip and clearAll only own keys',
      () async {
        SharedPreferences.setMockInitialValues({'other.key': 'keep'});
        final prefs = await SharedPreferences.getInstance();
        final store = SharedPreferencesKeyValueStore(prefs);
        await store.write('lp.a', '1');
        expect(store.read('lp.a'), '1');
        await store.clearAll();
        expect(store.read('lp.a'), isNull);
        expect(prefs.getString('other.key'), 'keep');
      },
    );

    test('corrupted JSON reads as missing', () {
      final store = MemoryKeyValueStore({'k': '{not json', 'l': '[1,2]'});
      expect(readJsonObject(store, 'k'), isNull);
      expect(readJsonObject(store, 'l'), isNull);
      expect(readJsonObject(store, 'none'), isNull);
    });
  });

  group('AppPreferencesRepository', () {
    test('roundtrip', () async {
      final repo = AppPreferencesRepository(MemoryKeyValueStore());
      await repo.save(
        const AppPreferences(
          interfaceLanguage: 'ar',
          knownLanguage: 'tr',
          targetLanguage: 'en',
          themeMode: 'dark',
          onboardingCompleted: true,
        ),
      );
      final p = repo.load();
      expect(p.interfaceLanguage, 'ar');
      expect(p.knownLanguage, 'tr');
      expect(p.targetLanguage, 'en');
      expect(p.themeMode, 'dark');
      expect(p.onboardingCompleted, isTrue);
    });

    test('corrupted or newer-version data falls back to defaults', () {
      final bad = AppPreferencesRepository(
        MemoryKeyValueStore({AppPreferencesRepository.storageKey: 'oops'}),
      );
      expect(bad.load().onboardingCompleted, isFalse);
      final future = AppPreferencesRepository(
        MemoryKeyValueStore({
          AppPreferencesRepository.storageKey:
              '{"v":99,"onboardingCompleted":true}',
        }),
      );
      expect(future.load().onboardingCompleted, isFalse);
    });

    test('wrong value types are ignored', () {
      final repo = AppPreferencesRepository(
        MemoryKeyValueStore({
          AppPreferencesRepository.storageKey: '{"v":1,"interfaceLanguage":5,"themeMode":"","onboardingCompleted":"yes"}',
        }),
      );
      final p = repo.load();
      expect(p.interfaceLanguage, isNull);
      expect(p.themeMode, isNull);
      expect(p.onboardingCompleted, isFalse);
    });
  });

  group('restart restores state', () {
    test('preferences: app language and the language pair', () {
      final store = MemoryKeyValueStore();
      final a = _launch(store);
      a.read(appLanguageProvider.notifier).select(AppLanguage.ar);
      a
          .read(learningPreferencesProvider.notifier)
          .setPair(
            LearningLanguage.fromCode('tr')!,
            LearningLanguage.fromCode('ar')!,
          );

      final b = _launch(store); // restart
      expect(b.read(appLanguageProvider), AppLanguage.ar);
      final prefs = b.read(learningPreferencesProvider);
      expect(prefs.knownLanguage?.code, 'tr');
      expect(prefs.targetLanguage?.code, 'ar');
      expect(prefs.isComplete, isTrue);
    });

    test('a pair with the same language twice is rejected', () {
      final c = _launch(MemoryKeyValueStore());
      final tr = LearningLanguage.fromCode('tr')!;
      c.read(learningPreferencesProvider.notifier).setPair(tr, tr);
      expect(c.read(learningPreferencesProvider).isComplete, isFalse);
    });

    test('a corrupted saved pair (same language) is dropped', () async {
      final store = MemoryKeyValueStore();
      await AppPreferencesRepository(
        store,
      ).save(const AppPreferences(knownLanguage: 'tr', targetLanguage: 'tr'));
      final prefs = _launch(store).read(learningPreferencesProvider);
      expect(prefs.isComplete, isFalse);
    });
  });
}
