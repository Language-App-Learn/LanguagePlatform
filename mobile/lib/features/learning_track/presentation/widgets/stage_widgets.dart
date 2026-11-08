import '../../../../core/l10n/l10n.dart';
import '../../domain/lesson_outcome.dart';
import '../../domain/lesson_stage.dart';

/// Localized names for stages, levels and statuses.
extension StageL10n on AppLocalizations {
  String stageName(LessonStage s) => switch (s) {
    LessonStage.reading => stageReading,
    LessonStage.speaking => stageSpeaking,
    LessonStage.listening => stageListening,
    LessonStage.writing => stageWriting,
    LessonStage.translation => stageTranslation,
  };

  String stageDescription(LessonStage s) => switch (s) {
    LessonStage.reading => stageReadingDesc,
    LessonStage.speaking => stageSpeakingDesc,
    LessonStage.listening => stageListeningDesc,
    LessonStage.writing => stageWritingDesc,
    LessonStage.translation => stageTranslationDesc,
  };

  String statusName(StageStatus s) => switch (s) {
    StageStatus.available => stageStatusAvailable,
    StageStatus.inProgress => stageStatusInProgress,
    StageStatus.completed => stageStatusCompleted,
    StageStatus.locked => stageStatusLocked,
    StageStatus.unavailable => stageStatusUnavailable,
  };

  String outcomeName(LessonOutcomeStatus s) => switch (s) {
    LessonOutcomeStatus.notStarted => lessonStatusNotStarted,
    LessonOutcomeStatus.inProgress => lessonStatusInProgress,
    LessonOutcomeStatus.awaitingAssessment => lessonStatusAwaiting,
    LessonOutcomeStatus.passed => lessonStatusPassed,
    LessonOutcomeStatus.failed => lessonStatusFailed,
  };
}
