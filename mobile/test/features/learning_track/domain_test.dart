import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/features/courses/domain/course.dart';
import 'package:language_platform/features/learning_track/domain/learning_track.dart';
import 'package:language_platform/features/learning_track/domain/lesson_outcome.dart';
import 'package:language_platform/features/learning_track/domain/lesson_stage.dart';
import 'package:language_platform/features/learning_track/domain/level_overview.dart';

void main() {
  group('structure constants', () {
    test(
      'six levels, twenty positions per level, five stages, pass mark 60',
      () {
        expect(CourseLevel.values, hasLength(6));
        expect(lessonsPerLevel, 20);
        expect(stagesPerLesson, 5);
        expect(LessonStage.values.map((s) => s.name), [
          'reading',
          'speaking',
          'listening',
          'writing',
          'translation',
        ]);
        expect(overallPassMark, 60);
      },
    );

    test('only Turkish -> Arabic is active', () {
      expect(LearningTracks.active, hasLength(1));
      expect(LearningTracks.turkishToArabic.sourceLanguage, 'tr');
      expect(LearningTracks.turkishToArabic.targetLanguage, 'ar');
      expect(LearningTracks.byId('en-tr'), isNull);
      expect(levelFromSegment('A2'), CourseLevel.a2);
      expect(levelFromSegment('z9'), isNull);
    });
  });

  group('level positions', () {
    test('a position is published only when the server gave it a lesson', () {
      const empty = LessonPosition(level: CourseLevel.a1, number: 3);
      const filled = LessonPosition(
        level: CourseLevel.a1,
        number: 1,
        lessonId: 'server-id',
      );
      expect(empty.isPublished, isFalse);
      expect(filled.isPublished, isTrue);
    });
  });

  group('server result is the only authority', () {
    test('the model carries the server verdict untouched', () {
      const odd = ServerLessonResult(
        finalScore: 95,
        passed: false,
        stageScores: {},
      );
      // The client never re-decides: a high score with passed=false stays so.
      expect(odd.passed, isFalse);
      expect(odd.passingScore, 60);
    });
  });
}
