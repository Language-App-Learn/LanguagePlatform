import 'package:flutter/foundation.dart';

import '../../courses/domain/course.dart';
import 'lesson_stage.dart';

/// Domain models of REAL backend content (five-stage curriculum). They are
/// deliberately separate from the demo `Lesson`/`LessonStageContent` models:
/// server identifiers are opaque UUID strings and never mix with demo ids.

@immutable
class RemoteCourse {
  const RemoteCourse({required this.id, required this.title});

  final String id;
  final String title;
}

@immutable
class RemoteLevel {
  const RemoteLevel({
    required this.id,
    required this.level,
    required this.order,
    required this.capacity,
  });

  final String id;
  final CourseLevel level;
  final int order;
  final int capacity;
}

/// One lesson position of a level. Empty/unavailable positions have no
/// lesson id.
@immutable
class RemoteSlot {
  const RemoteSlot({
    required this.position,
    this.lessonId,
    this.versionId,
    this.title,
  });

  final int position;
  final String? lessonId;
  final String? versionId;
  final String? title;

  bool get isPublished => lessonId != null;
}

@immutable
class RemoteStage {
  const RemoteStage({
    required this.id,
    required this.kind,
    required this.order,
    required this.isRequired,
    this.weight,
    this.estimatedSeconds,
    this.assessmentId,
    this.texts = const {},
  });

  final String id;

  /// `null` for a stage kind this app version does not know.
  final LessonStage? kind;
  final int order;
  final bool isRequired;

  /// Server-configured weight (display only; never used to recompute).
  final double? weight;
  final int? estimatedSeconds;
  final String? assessmentId;

  /// Locale -> text (e.g. `ar`, `tr`).
  final Map<String, String> texts;
}

@immutable
class RemoteLesson {
  const RemoteLesson({
    required this.id,
    required this.courseId,
    required this.versionId,
    required this.title,
    required this.passingScore,
    required this.stages,
  });

  final String id;
  final String courseId;
  final String versionId;
  final String title;
  final double passingScore;
  final List<RemoteStage> stages;

  RemoteStage? stageOf(LessonStage kind) {
    for (final s in stages) {
      if (s.kind == kind) return s;
    }
    return null;
  }
}

/// Stage state as reported by the server for THIS learner.
enum RemoteStageStatus { available, inProgress, completed, locked }

@immutable
class RemoteStageProgress {
  const RemoteStageProgress({
    required this.id,
    required this.kind,
    required this.order,
    required this.status,
    required this.attempts,
    this.score,
  });

  final String id;
  final LessonStage kind;
  final int order;
  final RemoteStageStatus status;

  /// Null until a graded result exists.
  final double? score;
  final int attempts;
}

@immutable
class CurriculumProgress {
  const CurriculumProgress({
    required this.versionId,
    required this.stages,
    required this.passingScore,
    required this.passed,
    this.finalScore,
    this.nextLessonId,
  });

  final String versionId;
  final List<RemoteStageProgress> stages;

  /// Null until all five required stages have graded results.
  final double? finalScore;
  final double passingScore;

  /// Server decision; never recomputed on the client.
  final bool passed;
  final String? nextLessonId;

  RemoteStageProgress? stageOf(LessonStage kind) {
    for (final s in stages) {
      if (s.kind == kind) return s;
    }
    return null;
  }
}

/// Question kinds of the objective assessment API.
enum RemoteQuestionKind {
  multipleChoice,
  trueFalse,
  wordBank,
  fillBlank,
  wordOrder,
  exactText,

  /// A kind this app version does not know (shown as unsupported, never
  /// guessed).
  unknown,
}

RemoteQuestionKind questionKindFrom(String raw) => switch (raw) {
  'MultipleChoice' => RemoteQuestionKind.multipleChoice,
  'TrueFalse' => RemoteQuestionKind.trueFalse,
  'WordBank' => RemoteQuestionKind.wordBank,
  'FillBlank' => RemoteQuestionKind.fillBlank,
  'WordOrder' => RemoteQuestionKind.wordOrder,
  'ExactText' => RemoteQuestionKind.exactText,
  _ => RemoteQuestionKind.unknown,
};

/// A question of a server attempt: NO answer key is ever present.
@immutable
class RemoteQuestion {
  const RemoteQuestion({
    required this.id,
    required this.kind,
    required this.prompt,
    required this.maximumScore,
    this.options = const [],
  });

  final String id;

  /// Raw kind string as sent by the server.
  final String kind;
  final String prompt;
  final double maximumScore;
  final List<RemoteOption> options;

  RemoteQuestionKind get type => questionKindFrom(kind);

  bool get isTrueFalse => type == RemoteQuestionKind.trueFalse;
  bool get isMultipleChoice => type == RemoteQuestionKind.multipleChoice;

  /// Whether this app can render and answer the question.
  bool get isSupported => switch (type) {
    RemoteQuestionKind.trueFalse => true,
    RemoteQuestionKind.fillBlank || RemoteQuestionKind.exactText => true,
    RemoteQuestionKind.multipleChoice ||
    RemoteQuestionKind.wordBank => options.length >= 2,
    RemoteQuestionKind.wordOrder => options.length >= 2,
    RemoteQuestionKind.unknown => false,
  };
}

@immutable
class RemoteOption {
  const RemoteOption({required this.id, required this.text});

  final String id;
  final String text;
}

@immutable
class RemoteAttempt {
  const RemoteAttempt({
    required this.id,
    required this.assessmentId,
    required this.attemptNumber,
    required this.questions,
    this.deadlineUtc,
  });

  final String id;
  final String assessmentId;
  final int attemptNumber;
  final List<RemoteQuestion> questions;

  /// Server deadline, if the assessment is timed.
  final DateTime? deadlineUtc;
}

/// Learner answer: exactly ONE of [optionId] / [value] / [text] /
/// [orderedOptionIds], matching the question kind.
@immutable
class RemoteAnswer {
  const RemoteAnswer({
    required this.questionId,
    this.optionId,
    this.value,
    this.text,
    this.orderedOptionIds,
  });

  final String questionId;
  final String? optionId;
  final bool? value;

  /// Exact learner input (Arabic diacritics and spacing are preserved).
  final String? text;

  /// Option ids in the learner's logical order (WordOrder).
  final List<String>? orderedOptionIds;
}

@immutable
class RemoteAssessmentResult {
  const RemoteAssessmentResult({
    required this.attemptId,
    required this.score,
    required this.maximumScore,
    required this.percentage,
    required this.passingScore,
    required this.passed,
  });

  final String attemptId;
  final double score;
  final double maximumScore;
  final double percentage;
  final double passingScore;

  /// Server decision for this attempt.
  final bool passed;
}

/// One approved line of the reading text. [id] is the stable segment id.
@immutable
class ReadingLine {
  const ReadingLine({
    required this.id,
    required this.page,
    required this.order,
    required this.text,
  });

  final String id;
  final int page;
  final int order;
  final String text;
}

/// Teacher-approved reading text of a lesson.
@immutable
class ReadingMaterial {
  const ReadingMaterial({required this.lines, required this.hasOriginalPdf});

  /// Ordered by page, then order. Empty means "use the stage text".
  final List<ReadingLine> lines;
  final bool hasOriginalPdf;
}

/// Media metadata of a stage. Playback is only possible with a valid
/// permitted URL; nothing here is a player.
@immutable
class StageMedia {
  const StageMedia({
    this.audioUrl,
    this.videoUrl,
    this.videoTitle,
    this.status = 'available',
  });

  final Uri? audioUrl;
  final Uri? videoUrl;
  final String? videoTitle;

  /// Server status: `available`, `unavailable` or `unconfigured`.
  final String status;

  bool get hasAudio => audioUrl != null;
  bool get hasVideo => videoUrl != null;
  bool get isEmpty => !hasAudio && !hasVideo;
}

/// Whether [answer] is a complete, submittable answer to [question].
bool isAnswerComplete(RemoteQuestion question, RemoteAnswer? answer) {
  if (answer == null) return false;
  return switch (question.type) {
    RemoteQuestionKind.trueFalse => answer.value != null,
    RemoteQuestionKind.multipleChoice ||
    RemoteQuestionKind.wordBank => answer.optionId != null,
    RemoteQuestionKind.fillBlank ||
    RemoteQuestionKind.exactText => (answer.text ?? '').trim().isNotEmpty,
    // Every option id exactly once (repeated words have distinct ids).
    RemoteQuestionKind.wordOrder =>
      answer.orderedOptionIds?.length == question.options.length,
    RemoteQuestionKind.unknown => false,
  };
}
