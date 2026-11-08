import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/l10n/app_language.dart';
import '../../../core/l10n/localized_text.dart';
import '../../authentication/application/auth_providers.dart';
import '../../courses/domain/course.dart';
import '../data/api_five_stage_repository.dart';
import '../data/just_audio_playback.dart';
import '../data/share_pdf_delivery.dart';
import '../data/video_player_playback.dart';
import '../domain/five_stage_repository.dart';
import '../domain/learning_track.dart';
import '../domain/media_playback.dart';
import '../domain/pdf_delivery.dart';
import '../domain/lesson_outcome.dart';
import '../domain/lesson_stage.dart';
import '../domain/level_overview.dart';
import '../domain/remote_models.dart';

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
final pdfDeliveryProvider = Provider<PdfDelivery>((ref) => SharePdfDelivery());

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

/// The 20 positions of [level] of the active track, from the real server
/// slots (unpublished positions have no lesson id). Not used by the screens
/// yet: it is the foundation for the lesson selection the owner will define.
final levelPositionsProvider =
    FutureProvider.family<List<LessonPosition>, CourseLevel>((
      ref,
      level,
    ) async {
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
    });

/// Retry for catalog loads: also drops the cached server failure of the
/// providers upstream (invalidating only the derived one would re-read it).
void reloadTrackCatalog(WidgetRef ref) {
  ref
    ..invalidate(remoteCourseProvider)
    ..invalidate(remoteLevelsProvider)
    ..invalidate(remoteSlotsProvider)
    ..invalidate(passedLessonIdsProvider)
    ..invalidate(levelPositionsProvider);
}

/// Factories for the media players (replaced by fakes in tests). Each player
/// widget creates its own instance and disposes it when it leaves the screen.
final audioPlaybackFactoryProvider = Provider<AudioPlayback Function()>(
  (ref) =>
      () => JustAudioPlayback(),
);

final videoPlaybackFactoryProvider = Provider<VideoPlayback Function()>(
  (ref) =>
      () => VideoPlayerPlayback(),
);
