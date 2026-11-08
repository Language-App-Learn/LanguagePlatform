import 'lesson.dart';

/// Structural checks for lesson content, independent of any UI.
///
/// Returns human-readable issues (empty = valid). Repositories can use this
/// to reject or log malformed lessons; tests run it over all demo content.
abstract final class LessonValidator {
  static List<String> validate(Lesson lesson) {
    final issues = <String>[];
    if (lesson.id.isEmpty) issues.add('empty lesson id');
    if (lesson.courseId.isEmpty) issues.add('empty course id');
    if (lesson.order < 1) issues.add('order must be >= 1');
    if (lesson.estimatedMinutes < 1) {
      issues.add('estimatedMinutes must be >= 1');
    }
    if (lesson.contents.isEmpty) issues.add('no content blocks');

    for (final (i, block) in lesson.contents.indexed) {
      final where = 'block $i';
      switch (block) {
        case DialogueContent(:final lines):
          if (lines.isEmpty) issues.add('$where: dialogue has no lines');
          if (lines.any((l) => l.text.trim().isEmpty)) {
            issues.add('$where: dialogue line without text');
          }
        case VocabularyContent(:final itemIds):
          if (itemIds.isEmpty) issues.add('$where: no vocabulary ids');
          if (itemIds.toSet().length != itemIds.length) {
            issues.add('$where: duplicate vocabulary ids');
          }
        case ExerciseContent(:final question):
          for (final issue in question.validationIssues) {
            issues.add('$where: exercise $issue');
          }
        case UnknownContent(:final type):
          issues.add('$where: unknown block type "$type"');
        case HeadingContent() ||
            TextContent() ||
            GrammarContent() ||
            ExampleContent():
          break;
      }
    }
    return issues;
  }
}
