import 'dart:typed_data';

import '../../../core/network/api_client.dart' show CancelToken;
import 'remote_models.dart';

/// Access to the real five-stage curriculum. Public reads need no session;
/// everything about the learner (`enroll`, `start`, progress, attempts)
/// requires a signed-in account and throws `UnauthorizedFailure` otherwise.
abstract interface class FiveStageRepository {
  /// The Turkish -> Arabic course visible to students, or `null` when none
  /// is published.
  Future<RemoteCourse?> findTrackCourse({String? locale});

  Future<List<RemoteLevel>> getLevels(String courseId);

  /// The 20 ordered positions of a level (empty ones included).
  Future<List<RemoteSlot>> getSlots(String courseId, String levelId);

  Future<RemoteLesson> getLesson(String courseId, String lessonId);

  /// Lesson ids the learner has passed (requires a session).
  Future<Set<String>> getPassedLessonIds(String courseId);

  Future<void> enroll(String courseId);

  Future<void> startLesson(String courseId, String lessonId);

  Future<CurriculumProgress> getProgress(String courseId, String lessonId);

  Future<RemoteAttempt> startAttempt({
    required String courseId,
    required String lessonId,
    required String assessmentId,
    required String idempotencyKey,
  });

  Future<RemoteAssessmentResult> submitAttempt({
    required String courseId,
    required String lessonId,
    required String assessmentId,
    required String attemptId,
    required List<RemoteAnswer> answers,
  });

  /// Teacher-approved reading text. `null` when the server has none for this
  /// learner (404: not enrolled, stage not accessible, nothing published).
  Future<ReadingMaterial?> getReadingMaterial(String courseId, String lessonId);

  /// The unchanged original PDF as bytes (authenticated download). Throws a
  /// typed failure when the session expired, the file is missing or the
  /// response is not a PDF.
  Future<Uint8List> downloadReadingPdf(
    String courseId,
    String lessonId, {
    CancelToken? cancelToken,
  });

  /// Audio/video metadata of an eligible stage; `null` on 404.
  Future<StageMedia?> getStageMedia(
    String courseId,
    String lessonId,
    String stageId,
  );

  /// Completed result of an attempt; `null` while evaluation is pending (the
  /// server answers 404 until a score exists).
  Future<RemoteAssessmentResult?> getAttemptResult(String attemptId);
}
