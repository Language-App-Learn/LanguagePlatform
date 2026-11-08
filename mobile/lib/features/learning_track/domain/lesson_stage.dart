/// The five required stages of every lesson, in study order. The study
/// sequence, unlocking and grading belong to the server; this order is only
/// the identity of the stages.
enum LessonStage { reading, speaking, listening, writing, translation }

/// Where a stage stands for the learner (as reported by the server).
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
