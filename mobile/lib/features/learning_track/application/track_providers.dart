import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/l10n/app_language.dart';
import '../../../core/l10n/localized_text.dart';
import '../../../core/storage/key_value_store.dart';
import '../../authentication/application/auth_providers.dart';
import '../../courses/application/course_providers.dart';
import '../../courses/domain/course.dart';
import '../../lessons/application/lesson_providers.dart';
import '../../lessons/domain/lesson.dart';
import '../data/api_five_stage_repository.dart';
import '../data/demo_stage_content.dart';
import '../data/local_stage_store.dart';
import '../domain/five_stage_repository.dart';
import '../domain/learning_track.dart';
import '../domain/pdf_delivery.dart';
import '../domain/lesson_outcome.dart';
import '../domain/lesson_stage.dart';
import '../domain/level_overview.dart';
import '../domain/remote_models.dart';
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

/// Where lesson content comes from. `remote` = the real backend (only when
/// a backend is configured and the learner is NOT in the explicit local
/// demo); `demo` = local sandbox content. The two never mix: ids, scores and
/// progress of one mode are not used in the other.
enum ContentMode { demo, remote }

final contentModeProvider = Provider<ContentMode>((ref) {
  final configured = ref.watch(apiBaseUriProvider) != null;
  final session = ref.watch(sessionProvider);
  return configured && session != SessionStatus.demo
      ? ContentMode.remote
      : ContentMode.demo;
});

final fiveStageRepositoryProvider = Provider<FiveStageRepository>(
  (ref) => ApiFiveStageRepository(ref.watch(apiClientProvider)),
);

bool _isAuthenticated(Ref ref) {
  // Watching the epoch drops cached learner data on every identity change.
  ref.watch(accountEpochProvider);
  return ref.watch(sessionProvider) == SessionStatus.authenticated;
}

/// The published Turkish -> Arabic course (one server course spans all six
/// CEFR levels), or `null`.
final remoteCourseProvider = FutureProvider<RemoteCourse?>(
  (ref) => ref
      .watch(fiveStageRepositoryProvider)
      .findTrackCourse(locale: ref.watch(appLanguageProvider)?.code),
);

final remoteLevelsProvider = FutureProvider<List<RemoteLevel>>((ref) async {
  final course = await ref.watch(remoteCourseProvider.future);
  if (course == null) return const [];
  return ref.watch(fiveStageRepositoryProvider).getLevels(course.id);
});

final remoteSlotsProvider =
    FutureProvider.family<List<RemoteSlot>, CourseLevel>((ref, level) async {
      final course = await ref.watch(remoteCourseProvider.future);
      final levels = await ref.watch(remoteLevelsProvider.future);
      if (course == null) return const [];
      for (final l in levels) {
        if (l.level == level) {
          return ref
              .watch(fiveStageRepositoryProvider)
              .getSlots(course.id, l.id);
        }
      }
      return const [];
    });

/// Lessons the signed-in learner passed (empty when signed out).
final passedLessonIdsProvider = FutureProvider<Set<String>>((ref) async {
  if (!_isAuthenticated(ref)) return const {};
  final course = await ref.watch(remoteCourseProvider.future);
  if (course == null) return const {};
  try {
    return await ref
        .watch(fiveStageRepositoryProvider)
        .getPassedLessonIds(course.id);
  } on NotFoundFailure {
    return const {}; // not enrolled yet
  }
});

final remoteLessonProvider = FutureProvider.family<RemoteLesson, String>((
  ref,
  lessonId,
) async {
  final course = await ref.watch(remoteCourseProvider.future);
  if (course == null) throw const NotFoundFailure();
  return ref.watch(fiveStageRepositoryProvider).getLesson(course.id, lessonId);
});

/// Teacher-approved reading text (`null` when none is available to this
/// learner). Learner-scoped: dropped on every identity change.
final readingMaterialProvider = FutureProvider.family<ReadingMaterial?, String>(
  (ref, lessonId) async {
    if (!_isAuthenticated(ref)) return null;
    final course = await ref.watch(remoteCourseProvider.future);
    if (course == null) return null;
    return ref
        .watch(fiveStageRepositoryProvider)
        .getReadingMaterial(course.id, lessonId);
  },
);

/// Audio / teacher-video metadata of one stage (`null` when unavailable).
final stageMediaProvider =
    FutureProvider.family<StageMedia?, ({String lessonId, String stageId})>((
      ref,
      key,
    ) async {
      if (!_isAuthenticated(ref)) return null;
      final course = await ref.watch(remoteCourseProvider.future);
      if (course == null) return null;
      return ref
          .watch(fiveStageRepositoryProvider)
          .getStageMedia(course.id, key.lessonId, key.stageId);
    });

/// How a downloaded PDF reaches the user (see `PdfDelivery`).
final pdfDeliveryProvider = Provider<PdfDelivery>(
  (ref) => const UnavailablePdfDelivery(),
);

/// Server-side stage state of the signed-in learner for a lesson; `null`
/// when signed out or not enrolled/started.
final remoteProgressProvider =
    FutureProvider.family<CurriculumProgress?, String>((ref, lessonId) async {
      if (!_isAuthenticated(ref)) return null;
      final course = await ref.watch(remoteCourseProvider.future);
      if (course == null) return null;
      try {
        return await ref
            .watch(fiveStageRepositoryProvider)
            .getProgress(course.id, lessonId);
      } on NotFoundFailure {
        return null;
      }
    });

/// Official (server-authoritative) lesson result. `null` unless the server
/// reports a final score (all five stages graded). The UI renders the
/// server's `passed` flag and never recomputes it.
final serverLessonResultProvider = Provider.family<ServerLessonResult?, String>(
  (ref, lessonId) {
    if (ref.watch(contentModeProvider) != ContentMode.remote) return null;
    final progress = ref.watch(remoteProgressProvider(lessonId)).value;
    final score = progress?.finalScore;
    if (progress == null || score == null) return null;
    final lesson = ref.watch(remoteLessonProvider(lessonId)).value;
    final weights = <LessonStage, double>{};
    for (final stage in lesson?.stages ?? const <RemoteStage>[]) {
      if (stage.kind != null && stage.weight != null) {
        weights[stage.kind!] = stage.weight!;
      }
    }
    return ServerLessonResult(
      finalScore: score,
      passed: progress.passed,
      passingScore: progress.passingScore,
      nextLessonId: progress.nextLessonId,
      stageScores: {for (final s in progress.stages) s.kind: s.score},
      // Only when the server published all five weights.
      weights: weights.length == LessonStage.values.length ? weights : null,
    );
  },
);

/// The 20 positions of [level] of the active track.
final levelPositionsProvider =
    FutureProvider.family<List<LessonPosition>, CourseLevel>((
      ref,
      level,
    ) async {
      if (ref.watch(contentModeProvider) == ContentMode.remote) {
        final slots = await ref.watch(remoteSlotsProvider(level).future);
        final byPosition = {for (final s in slots) s.position: s};
        return [
          for (var n = 1; n <= lessonsPerLevel; n++)
            LessonPosition(
              level: level,
              number: n,
              lessonId: byPosition[n]?.lessonId,
              title: byPosition[n]?.title == null
                  ? null
                  : LocalizedText.plain(byPosition[n]!.title!),
            ),
        ];
      }
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

/// Retry for the catalog screens: also drops the cached server failure of the
/// providers upstream (invalidating only the derived one would re-read it).
void reloadTrackCatalog(WidgetRef ref) {
  ref
    ..invalidate(remoteCourseProvider)
    ..invalidate(remoteLevelsProvider)
    ..invalidate(remoteSlotsProvider)
    ..invalidate(passedLessonIdsProvider)
    ..invalidate(levelPositionsProvider)
    ..invalidate(levelOverviewsProvider);
}

bool _allStagesDone(Map<LessonStage, StageRecord>? records) =>
    records != null &&
    LessonStage.values.every((s) => records[s]?.completed ?? false);

/// Six level cards with REAL counts (published / completed lessons).
/// Completed = passed on the server (remote) or fully practiced (demo).
final levelOverviewsProvider = FutureProvider<List<LevelOverview>>((ref) async {
  final remote = ref.watch(contentModeProvider) == ContentMode.remote;
  final records = ref.watch(stageRecordsProvider);
  final passed = remote
      ? await ref.watch(passedLessonIdsProvider.future)
      : const <String>{};
  final result = <LevelOverview>[];
  for (final level in CourseLevel.values) {
    final positions = await ref.watch(levelPositionsProvider(level).future);
    final published = positions.where((p) => p.isPublished).toList();
    result.add(
      LevelOverview(
        level: level,
        publishedLessons: published.length,
        completedLessons: published
            .where(
              (p) => remote
                  ? passed.contains(p.lessonId)
                  : _allStagesDone(records[p.lessonId]),
            )
            .length,
      ),
    );
  }
  return result;
});
