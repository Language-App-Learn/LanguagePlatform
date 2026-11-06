import '../../../core/storage/key_value_store.dart';
import '../domain/learning_progress.dart';

/// Persists [LearningProgress] as one versioned JSON document on the device.
/// Corrupted or unknown-version data yields empty progress; bad individual
/// entries are skipped instead of failing the whole load.
class LocalProgressRepository {
  LocalProgressRepository(this._store);

  final KeyValueStore _store;

  static const storageKey = 'lp.progress';
  static const schemaVersion = 1;

  LearningProgress load() {
    final json = readJsonObject(_store, storageKey);
    if (json == null) return const LearningProgress();
    final version = json['v'];
    if (version is int && version > schemaVersion) {
      return const LearningProgress(); // written by a newer app version
    }
    return LearningProgress(
      completedLessons: _dateMap(json['completedLessons']),
      quizScores: _intMap(json['quizScores']),
      dailyGoalLessons: _goal(json['dailyGoal']),
      lastOpened: _lastOpened(json['lastOpened']),
      activity: _activity(json['activity']),
    );
  }

  Future<void> save(LearningProgress p) => writeJsonObject(_store, storageKey, {
    'v': schemaVersion,
    'completedLessons': {
      for (final e in p.completedLessons.entries) e.key: _iso(e.value),
    },
    'quizScores': p.quizScores,
    'dailyGoal': p.dailyGoalLessons,
    'lastOpened': p.lastOpened == null
        ? null
        : {
            'courseId': p.lastOpened!.courseId,
            'lessonId': p.lastOpened!.lessonId,
            'at': _iso(p.lastOpened!.at),
          },
    'activity': [
      for (final e in p.activity)
        {
          't': e.type.name,
          'id': e.refId,
          'at': _iso(e.at),
          if (e.score != null) 's': e.score,
        },
    ],
  });

  static String _iso(DateTime d) => d.toUtc().toIso8601String();

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v)?.toLocal() : null;

  static Map<String, DateTime> _dateMap(Object? v) {
    if (v is! Map) return const {};
    return {
      for (final e in v.entries)
        if (e.key is String && _date(e.value) != null)
          e.key as String: _date(e.value)!,
    };
  }

  static Map<String, int> _intMap(Object? v) {
    if (v is! Map) return const {};
    return {
      for (final e in v.entries)
        if (e.key is String && e.value is int) e.key as String: e.value as int,
    };
  }

  static int _goal(Object? v) =>
      v is int && v >= 1 && v <= 50 ? v : LearningProgress.defaultDailyGoal;

  static LastOpened? _lastOpened(Object? v) {
    if (v is! Map) return null;
    final course = v['courseId'];
    final lesson = v['lessonId'];
    final at = _date(v['at']);
    if (course is! String || lesson is! String || at == null) return null;
    return LastOpened(courseId: course, lessonId: lesson, at: at);
  }

  static List<ActivityEvent> _activity(Object? v) {
    if (v is! List) return const [];
    final events = <ActivityEvent>[];
    for (final item in v) {
      if (item is! Map) continue;
      final type = ActivityType.values.asNameMap()[item['t']];
      final id = item['id'];
      final at = _date(item['at']);
      if (type == null || id is! String || at == null) continue;
      final score = item['s'];
      events.add(
        ActivityEvent(
          type: type,
          refId: id,
          at: at,
          score: score is int ? score : null,
        ),
      );
    }
    return events;
  }
}
