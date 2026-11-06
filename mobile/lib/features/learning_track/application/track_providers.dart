import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../courses/application/course_providers.dart';
import '../../courses/domain/course.dart';
import '../../lessons/application/lesson_providers.dart';
import '../../lessons/domain/lesson.dart';
import '../data/demo_stage_content.dart';
import '../data/local_stage_store.dart';
import '../domain/learning_track.dart';
import '../domain/lesson_outcome.dart';
import '../domain/lesson_stage.dart';
import '../domain/level_overview.dart';
import '../domain/stage_content.dart';

final stageStoreProvider = Provider<LocalStageStore>(
  (ref) => LocalStageStore(ref.watch(keyValueStoreProvider)),
);

/// Locally recorded DEMO stage outcomes per lesson (persisted, `lp.stages`).
/// These are practice records, never official results.
class StageRecordsNotifier
    extends Notifier<Map<String, Map<LessonStage, StageRecord>>> {
  StageRecordsNotifier([this._initial]);

  final Map<String, Map<LessonStage, StageRecord>>? _initial;

  @override
  Map<String, Map<LessonStage, StageRecord>> build() =>
      _initial ?? ref.read(stageStoreProvider).load();

  void _set(Map<String, Map<LessonStage, StageRecord>> next) {
    state = next;
    ref.read(stageStoreProvider).save(next);
  }

  Map<LessonStage, StageRecord> recordsOf(String lessonId) =>
      state[lessonId] ?? const {};

  /// Records a finished practice (retries overwrite the previous score).
  void complete(String lessonId, LessonStage stage, int? score) {
    _set({
      ...state,
      lessonId: {
        ...recordsOf(lessonId),
        stage: StageRecord(completed: true, score: score?.clamp(0, 100)),
      },
    });
  }

  /// Marks a stage as started (no effect on a completed stage).
  void start(String lessonId, LessonStage stage) {
    final current = recordsOf(lessonId)[stage];
    if (current?.completed ?? false) return;
    _set({
      ...state,
      lessonId: {
        ...recordsOf(lessonId),
        stage: const StageRecord(completed: false, inProgress: true),
      },
    });
  }
}

final stageRecordsProvider =
    NotifierProvider<
      StageRecordsNotifier,
      Map<String, Map<LessonStage, StageRecord>>
    >(StageRecordsNotifier.new);

/// Source of stage content (DEMO fixture today; published server content
/// once the five-stage contract exists).
final stageContentProvider = Provider.family<LessonStageContent?, String>(
  (ref, lessonId) => demoStageContent[lessonId],
);

/// Whether a stage of [lesson] can be opened (published content present).
bool stageHasContent(
  Lesson lesson,
  LessonStageContent? content,
  LessonStage stage,
) {
  return switch (stage) {
    LessonStage.reading => content?.reading != null,
    LessonStage.speaking => lesson.contents.any((c) => c is DialogueContent),
    LessonStage.listening => content?.listening != null,
    LessonStage.writing => content?.writing != null,
    LessonStage.translation => content?.translation != null,
  };
}

/// Official (server-authoritative) lesson result. Always `null` until the
/// five-stage backend contract is available and integrated.
final serverLessonResultProvider = Provider.family<ServerLessonResult?, String>(
  (ref, lessonId) => null,
);

/// Published target-language lessons for [level] of the active track, in
/// course then lesson order.
final levelPositionsProvider =
    FutureProvider.family<List<LessonPosition>, CourseLevel>((
      ref,
      level,
    ) async {
      final courses = await ref.watch(coursesProvider.future);
      final lessons = <Lesson>[];
      for (final course in courses) {
        if (course.level != level ||
            course.languageCode !=
                LearningTracks.turkishToArabic.targetLanguage) {
          continue;
        }
        lessons.addAll(
          await ref.watch(lessonsForCourseProvider(course.id).future),
        );
      }
      return buildLevelPositions(level, lessons);
    });

bool _allStagesDone(Map<LessonStage, StageRecord>? records) =>
    records != null &&
    LessonStage.values.every((s) => records[s]?.completed ?? false);

/// Six level cards with REAL counts (published / fully practiced lessons).
final levelOverviewsProvider = FutureProvider<List<LevelOverview>>((ref) async {
  final records = ref.watch(stageRecordsProvider);
  final result = <LevelOverview>[];
  for (final level in CourseLevel.values) {
    final positions = await ref.watch(levelPositionsProvider(level).future);
    final published = positions.where((p) => p.isPublished).toList();
    result.add(
      LevelOverview(
        level: level,
        publishedLessons: published.length,
        completedLessons: published
            .where((p) => _allStagesDone(records[p.lesson!.id]))
            .length,
      ),
    );
  }
  return result;
});
