import 'package:flutter/foundation.dart';

import '../../../core/l10n/localized_text.dart';
import '../../courses/domain/course.dart';
import '../../lessons/domain/lesson.dart';
import 'learning_track.dart';

/// One of the 20 lesson positions of a level. [lessonId] is `null` while the
/// position has no published lesson. Demo positions also carry the demo
/// [lesson]; server positions only carry the opaque server id and title.
@immutable
class LessonPosition {
  LessonPosition({
    required this.level,
    required this.number,
    this.lesson,
    String? lessonId,
    LocalizedText? title,
  }) : lessonId = lessonId ?? lesson?.id,
       title = title ?? lesson?.title;

  final CourseLevel level;

  /// 1..[lessonsPerLevel].
  final int number;
  final Lesson? lesson;
  final String? lessonId;
  final LocalizedText? title;

  bool get isPublished => lessonId != null;
}

/// Level card data: real counts only.
@immutable
class LevelOverview {
  const LevelOverview({
    required this.level,
    required this.publishedLessons,
    required this.completedLessons,
  });

  final CourseLevel level;
  final int publishedLessons;
  final int completedLessons;

  int get capacity => lessonsPerLevel;

  /// Progress over PUBLISHED lessons (0 when nothing is published).
  double get progress =>
      publishedLessons == 0 ? 0 : completedLessons / publishedLessons;
}

/// Builds the fixed list of positions for [level] from the lessons that are
/// actually published (in course/lesson order). Extra lessons beyond the
/// capacity are ignored.
List<LessonPosition> buildLevelPositions(
  CourseLevel level,
  List<Lesson> publishedInOrder,
) {
  return [
    for (var i = 0; i < lessonsPerLevel; i++)
      LessonPosition(
        level: level,
        number: i + 1,
        lesson: i < publishedInOrder.length ? publishedInOrder[i] : null,
      ),
  ];
}
