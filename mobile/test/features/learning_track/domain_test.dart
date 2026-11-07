import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/features/courses/domain/course.dart';
import 'package:language_platform/features/learning_track/data/local_stage_store.dart';
import 'package:language_platform/features/learning_track/domain/learning_track.dart';
import 'package:language_platform/features/learning_track/domain/lesson_outcome.dart';
import 'package:language_platform/features/learning_track/domain/lesson_stage.dart';
import 'package:language_platform/features/learning_track/domain/level_overview.dart';
import 'package:language_platform/features/learning_track/domain/stage_grading.dart';
import 'package:language_platform/features/lessons/data/demo_lesson_data.dart';

Map<LessonStage, StageRecord> _done(Iterable<LessonStage> stages) => {
  for (final s in stages) s: const StageRecord(completed: true, score: 80),
};

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
    test('always 20 positions; unpublished ones have no lesson', () {
      final published = demoLessons.take(3).toList();
      final positions = buildLevelPositions(CourseLevel.a1, published);
      expect(positions, hasLength(20));
      expect(positions.map((p) => p.number), List.generate(20, (i) => i + 1));
      expect(positions.where((p) => p.isPublished), hasLength(3));
      expect(positions[3].lesson, isNull);
      expect(positions[0].lesson, same(published[0]));
    });

    test('lessons beyond capacity are ignored, empty level is all drafts', () {
      final many = List.generate(25, (_) => demoLessons.first);
      expect(
        buildLevelPositions(CourseLevel.a1, many).where((p) => p.isPublished),
        hasLength(20),
      );
      expect(
        buildLevelPositions(CourseLevel.c2, const []).any((p) => p.isPublished),
        isFalse,
      );
    });

    test('level progress uses published lessons, never invented', () {
      const none = LevelOverview(
        level: CourseLevel.a1,
        publishedLessons: 0,
        completedLessons: 0,
      );
      expect(none.progress, 0);
      const half = LevelOverview(
        level: CourseLevel.a1,
        publishedLessons: 4,
        completedLessons: 2,
      );
      expect(half.progress, 0.5);
      expect(half.capacity, 20);
    });
  });

  group('stage status (sequential, no per-stage thresholds)', () {
    StageStatus status(
      LessonStage s,
      Map<LessonStage, StageRecord> records, {
      bool content = true,
    }) => stageStatus(stage: s, records: records, hasContent: (_) => content);

    test('only the first stage is open at the start', () {
      expect(status(LessonStage.reading, {}), StageStatus.available);
      for (final s in LessonStage.values.skip(1)) {
        expect(status(s, {}), StageStatus.locked);
      }
    });

    test('completing a stage opens the next, completed stays reachable', () {
      final r = _done([LessonStage.reading]);
      expect(status(LessonStage.reading, r), StageStatus.completed);
      expect(status(LessonStage.speaking, r), StageStatus.available);
      expect(status(LessonStage.listening, r), StageStatus.locked);
    });

    test('a low practice score still completes a stage (no minimum)', () {
      final r = {
        LessonStage.reading: const StageRecord(completed: true, score: 0),
      };
      expect(status(LessonStage.reading, r), StageStatus.completed);
      expect(status(LessonStage.speaking, r), StageStatus.available);
    });

    test('in-progress and unavailable content', () {
      final started = {
        LessonStage.reading: const StageRecord(
          completed: false,
          inProgress: true,
        ),
      };
      expect(status(LessonStage.reading, started), StageStatus.inProgress);
      expect(
        status(LessonStage.reading, {}, content: false),
        StageStatus.unavailable,
      );
      // Later stages stay locked behind an unavailable one.
      expect(
        status(LessonStage.speaking, {}, content: false),
        StageStatus.locked,
      );
    });
  });

  group('lesson outcome (backend is authoritative)', () {
    test('not started / in progress', () {
      expect(lessonOutcome(records: {}), LessonOutcomeStatus.notStarted);
      expect(
        lessonOutcome(records: _done([LessonStage.reading])),
        LessonOutcomeStatus.inProgress,
      );
    });

    test('all five practiced but no server result: awaiting, never passed', () {
      final all = _done(LessonStage.values);
      expect(
        lessonOutcome(records: all),
        LessonOutcomeStatus.awaitingAssessment,
      );
    });

    test('missing stage prevents any final result', () {
      final four = _done(LessonStage.values.take(4));
      expect(lessonOutcome(records: four), LessonOutcomeStatus.inProgress);
    });

    test('server result is rendered as given: exactly 60 passes, 59 fails', () {
      const pass = ServerLessonResult(
        finalScore: 60,
        passed: true,
        stageScores: {},
      );
      const fail = ServerLessonResult(
        finalScore: 59,
        passed: false,
        stageScores: {},
      );
      expect(
        lessonOutcome(records: const {}, serverResult: pass),
        LessonOutcomeStatus.passed,
      );
      expect(
        lessonOutcome(records: const {}, serverResult: fail),
        LessonOutcomeStatus.failed,
      );
      // The client does not re-decide: the server's flag wins.
      const odd = ServerLessonResult(
        finalScore: 95,
        passed: false,
        stageScores: {},
      );
      expect(
        lessonOutcome(records: _done(LessonStage.values), serverResult: odd),
        LessonOutcomeStatus.failed,
      );
    });
  });

  group('demo grading helpers', () {
    test('percentOf', () {
      expect(percentOf(0, 0), 0);
      expect(percentOf(2, 3), 67);
      expect(percentOf(3, 3), 100);
    });

    test('blanks require the exact word per blank', () {
      expect(gradeBlanks(['a', 'b'], ['a', 'b']), 2);
      expect(gradeBlanks(['b', 'a'], ['a', 'b']), 0);
      expect(gradeBlanks(['a', null], ['a', 'b']), 1);
    });

    test('arrangement with duplicate tokens compares by position', () {
      expect(gradeArrangement(['a', 'b', 'a'], ['a', 'b', 'a']), isTrue);
      expect(gradeArrangement(['a', 'a', 'b'], ['a', 'b', 'a']), isFalse);
      expect(gradeArrangement(['a'], ['a', 'b']), isFalse);
    });

    test('text grading keeps diacritics significant', () {
      const accepted = ['شُكْرًا', 'شكرا'];
      expect(gradeText('شُكْرًا', accepted), isTrue);
      expect(gradeText('  شكرا  ', accepted), isTrue);
      expect(
        gradeText('شُكرا', accepted),
        isFalse,
      ); // partial marks: not listed
      expect(gradeText('', accepted), isFalse);
    });
  });

  group('LocalStageStore', () {
    test('roundtrip and tolerance for bad data', () async {
      final store = MemoryKeyValueStore();
      final local = LocalStageStore(store);
      await local.save({
        'l1': {
          LessonStage.reading: const StageRecord(completed: true, score: 90),
          LessonStage.speaking: const StageRecord(
            completed: false,
            inProgress: true,
          ),
        },
      });
      final loaded = local.load();
      expect(loaded['l1']![LessonStage.reading]!.score, 90);
      expect(loaded['l1']![LessonStage.speaking]!.inProgress, isTrue);

      await store.write(LocalStageStore.storageKey, '{oops');
      expect(local.load(), isEmpty);
      await store.write(
        LocalStageStore.storageKey,
        '{"v":99,"lessons":{"l1":{"reading":{"c":true}}}}',
      );
      expect(local.load(), isEmpty);
      await store.write(
        LocalStageStore.storageKey,
        '{"v":1,"lessons":{"l1":{"reading":{"c":true,"s":500},"zzz":{"c":true},"x":5},"l2":7}}',
      );
      final partly = local.load();
      expect(partly['l1']![LessonStage.reading]!.score, isNull); // out of range
      expect(partly.containsKey('l2'), isFalse);
    });
  });
}
