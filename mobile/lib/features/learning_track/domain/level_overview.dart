import 'package:flutter/foundation.dart';

import '../../../core/l10n/localized_text.dart';
import '../../courses/domain/course.dart';

/// One of the 20 lesson positions of a level. [lessonId] is `null` while the
/// position has no published lesson; published positions carry only the
/// opaque server id and title.
@immutable
class LessonPosition {
  const LessonPosition({
    required this.level,
    required this.number,
    this.lessonId,
    this.title,
  });

  final CourseLevel level;

  /// 1..`lessonsPerLevel`.
  final int number;
  final String? lessonId;
  final LocalizedText? title;

  bool get isPublished => lessonId != null;
}
