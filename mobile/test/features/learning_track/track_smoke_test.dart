import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/l10n/l10n.dart';
import 'package:language_platform/features/learning_track/application/track_providers.dart';
import 'package:language_platform/features/learning_track/domain/lesson_stage.dart';

import '../../helpers/pump_app.dart';

/// New learning-track screens on a narrow phone, in LTR and RTL UI, at
/// normal and 2x text: no layout exceptions, correct direction.
void main() {
  final routes = <String, String>{
    'track': '/track/tr-ar',
    'level-a1': '/track/tr-ar/level/a1',
    'level-c2': '/track/tr-ar/level/c2',
    'overview': '/stages/ar-a1-l1',
    'reading': '/stages/ar-a1-l1/reading',
    'speaking': '/stages/ar-a1-l1/speaking',
    'listening': '/stages/ar-a1-l1/listening',
    'writing': '/stages/ar-a1-l1/writing',
    'translation': '/stages/ar-a1-l1/translation',
    'unpublished-lesson': '/stages/ar-a1-l2',
    'invalid-level': '/track/tr-ar/level/z9',
    'invalid-stage': '/stages/ar-a1-l1/nonsense',
  };

  for (final scale in [1.0, 2.0]) {
    for (final language in [AppLanguage.en, AppLanguage.ar, AppLanguage.tr]) {
      for (final entry in routes.entries) {
        testWidgets('${entry.key} / ${language.code} / x$scale', (
          tester,
        ) async {
          useScreen(tester, width: 360, height: 640);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          // Complete every stage before the opened one so it is reachable.
          final target = LessonStage.values.asNameMap()[entry.key];
          final before = target == null
              ? <LessonStage>[]
              : LessonStage.values.take(target.index).toList();
          await pumpApp(
            tester,
            language: language,
            initialLocation: entry.value,
            overrides: [
              trToArPreferences,
              stageRecordsProvider.overrideWith(
                () => StageRecordsNotifier({
                  'ar-a1-l1': {
                    for (final s in before)
                      s: const StageRecord(completed: true, score: 100),
                  },
                }),
              ),
            ],
          );
          expect(tester.takeException(), isNull);
          expect(currentDirection(tester), language.textDirection);
        });
      }
    }
  }
}
