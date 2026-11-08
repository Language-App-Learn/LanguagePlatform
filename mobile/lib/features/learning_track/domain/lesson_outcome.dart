import 'package:flutter/foundation.dart';

import 'lesson_stage.dart';

/// Approved overall pass mark (out of 100). Per-stage minimums and equal
/// weights are NOT approved and must not be assumed.
const int overallPassMark = 60;

/// Authoritative lesson result as returned by the backend
/// (`curriculum-progress`). The client renders it; it never recomputes it.
@immutable
class ServerLessonResult {
  const ServerLessonResult({
    required this.finalScore,
    required this.passed,
    required this.stageScores,
    this.weights,
    this.passingScore = 60,
    this.nextLessonId,
  });

  /// Weighted score, possibly fractional (server shows up to 2 decimals).
  final double finalScore;

  /// Pass/fail exactly as decided by the server policy.
  final bool passed;

  /// Graded stage scores; `null` until a stage has a graded result.
  final Map<LessonStage, double?> stageScores;

  /// Server-configured weights, or `null` when not provided.
  final Map<LessonStage, double>? weights;

  /// Threshold reported by the server (60 for these lessons).
  final double passingScore;

  /// Next published lesson to open, when the server supplies one.
  final String? nextLessonId;
}

/// Score text without needless decimals, TRUNCATED (never rounded) to two
/// decimals exactly like the server's display score: 60 -> "60",
/// 59.5 -> "59.5", 66.666 -> "66.66", 59.999 -> "59.99". Rounding could show
/// "60" next to a "Not passed" verdict.
String formatScore(num score) {
  // Eight decimals absorb binary noise (59.99 is stored as 59.98999...)
  // without ever carrying a genuine 59.999 up to 60.
  final fixed = score.toDouble().toStringAsFixed(8);
  final dot = fixed.indexOf('.');
  final text = fixed.substring(0, dot + 3);
  return text.contains('.') ? text.replaceFirst(RegExp(r'\.?0+$'), '') : text;
}

enum LessonOutcomeStatus {
  notStarted,
  inProgress,

  /// All five stages were practiced but no official result exists.
  awaitingAssessment,
  passed,
  failed,
}
