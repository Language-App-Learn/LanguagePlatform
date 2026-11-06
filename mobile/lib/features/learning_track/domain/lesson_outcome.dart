import 'package:flutter/foundation.dart';

import 'lesson_stage.dart';

/// Approved overall pass mark (out of 100). Per-stage minimums and equal
/// weights are NOT approved and must not be assumed.
const int overallPassMark = 60;

/// Authoritative lesson result as returned by the backend (shape pending the
/// five-stage contract). The client renders it; it never recomputes it.
@immutable
class ServerLessonResult {
  const ServerLessonResult({
    required this.finalScore,
    required this.passed,
    required this.stageScores,
    this.weights,
  });

  final int finalScore;

  /// Pass/fail exactly as decided by the server policy.
  final bool passed;
  final Map<LessonStage, int> stageScores;

  /// Server-configured weights, or `null` when not provided.
  final Map<LessonStage, double>? weights;
}

enum LessonOutcomeStatus {
  notStarted,
  inProgress,

  /// All five stages were practiced but no official result exists.
  awaitingAssessment,
  passed,
  failed,
}

/// Overall lesson status.
///
/// Without a [ServerLessonResult] the lesson can never be passed or failed:
/// a local average is not an authoritative result.
LessonOutcomeStatus lessonOutcome({
  required Map<LessonStage, StageRecord> records,
  ServerLessonResult? serverResult,
}) {
  if (serverResult != null) {
    return serverResult.passed
        ? LessonOutcomeStatus.passed
        : LessonOutcomeStatus.failed;
  }
  final completed = records.values.where((r) => r.completed).length;
  if (completed == 0 && !records.values.any((r) => r.inProgress)) {
    return LessonOutcomeStatus.notStarted;
  }
  return completed == LessonStage.values.length
      ? LessonOutcomeStatus.awaitingAssessment
      : LessonOutcomeStatus.inProgress;
}
