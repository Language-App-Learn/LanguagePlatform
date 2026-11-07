import 'package:flutter/foundation.dart';

/// The five required stages of every lesson, in study order.
enum LessonStage { reading, speaking, listening, writing, translation }

/// Where a stage stands for the learner.
enum StageStatus {
  /// Next stage to work on.
  available,
  inProgress,
  completed,

  /// An earlier stage is not completed yet.
  locked,

  /// No published content (or required provider) for this stage.
  unavailable,
}

/// Locally recorded outcome of a stage.
///
/// [isDemo] results come from on-device demo practice and are never an
/// official score. Official (server-authoritative) results will be modelled
/// by [ServerLessonResult] once the five-stage contract exists.
@immutable
class StageRecord {
  const StageRecord({
    required this.completed,
    this.score,
    this.isDemo = true,
    this.inProgress = false,
  });

  final bool completed;

  /// 0..100 practice score, when one was produced.
  final int? score;
  final bool isDemo;
  final bool inProgress;
}

/// Sequential stage status. Stages unlock in order; completed stages stay
/// reachable for review. [hasContent] says whether a stage can be opened at
/// all (published content present).
StageStatus stageStatus({
  required LessonStage stage,
  required Map<LessonStage, StageRecord> records,
  required bool Function(LessonStage) hasContent,
}) {
  final record = records[stage];
  if (record?.completed ?? false) return StageStatus.completed;
  final previousDone = LessonStage.values
      .take(stage.index)
      .every((s) => records[s]?.completed ?? false);
  if (!previousDone) return StageStatus.locked;
  if (!hasContent(stage)) return StageStatus.unavailable;
  return (record?.inProgress ?? false)
      ? StageStatus.inProgress
      : StageStatus.available;
}
