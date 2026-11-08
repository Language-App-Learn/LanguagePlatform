import '../../../core/storage/key_value_store.dart';
import '../domain/lesson_stage.dart';

/// Persists locally recorded DEMO stage outcomes (`lp.stages`, versioned).
/// Corrupted or newer-version data reads as empty; bad entries are skipped.
class LocalStageStore {
  LocalStageStore(this._store);

  final KeyValueStore _store;

  static const storageKey = 'lp.stages';
  static const schemaVersion = 1;

  Map<String, Map<LessonStage, StageRecord>> load() {
    final json = readJsonObject(_store, storageKey);
    if (json == null) return const {};
    final version = json['v'];
    if (version is int && version > schemaVersion) return const {};
    final lessons = json['lessons'];
    if (lessons is! Map) return const {};
    final result = <String, Map<LessonStage, StageRecord>>{};
    for (final lesson in lessons.entries) {
      if (lesson.key is! String || lesson.value is! Map) continue;
      final stages = <LessonStage, StageRecord>{};
      for (final stage in (lesson.value as Map).entries) {
        final key = LessonStage.values.asNameMap()[stage.key];
        final v = stage.value;
        if (key == null || v is! Map) continue;
        final score = v['s'];
        stages[key] = StageRecord(
          completed: v['c'] == true,
          inProgress: v['p'] == true,
          score: score is int && score >= 0 && score <= 100 ? score : null,
        );
      }
      if (stages.isNotEmpty) result[lesson.key as String] = stages;
    }
    return result;
  }

  Future<void> save(Map<String, Map<LessonStage, StageRecord>> all) =>
      writeJsonObject(_store, storageKey, {
        'v': schemaVersion,
        'lessons': {
          for (final lesson in all.entries)
            lesson.key: {
              for (final stage in lesson.value.entries)
                stage.key.name: {
                  'c': stage.value.completed,
                  'p': stage.value.inProgress,
                  if (stage.value.score != null) 's': stage.value.score,
                },
            },
        },
      });
}
