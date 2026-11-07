import 'package:flutter/foundation.dart';

import '../../courses/domain/course.dart';

/// One learning direction offered to students. Only Turkish -> Arabic is
/// active in the first release; the model stays language-agnostic so other
/// pairs can be added without redesign.
@immutable
class LearningTrack {
  const LearningTrack({
    required this.id,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  final String id;

  /// ISO code of the language the learner already knows.
  final String sourceLanguage;

  /// ISO code of the language being learned.
  final String targetLanguage;
}

abstract final class LearningTracks {
  static const turkishToArabic = LearningTrack(
    id: 'tr-ar',
    sourceLanguage: 'tr',
    targetLanguage: 'ar',
  );

  /// The only track exposed to students for now.
  static const active = [turkishToArabic];

  static LearningTrack? byId(String id) {
    for (final track in active) {
      if (track.id == id) return track;
    }
    return null;
  }
}

/// Number of lesson positions in every CEFR level.
const int lessonsPerLevel = 20;

/// Number of stages in every lesson.
const int stagesPerLesson = 5;

/// Parses a level path segment ("a1", "A2") into a [CourseLevel].
CourseLevel? levelFromSegment(String segment) =>
    CourseLevel.values.asNameMap()[segment.toLowerCase()];
