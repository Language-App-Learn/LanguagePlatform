import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../vocabulary/application/vocabulary_providers.dart';
import '../../vocabulary/domain/vocabulary_item.dart';
import '../data/demo_lesson_repository.dart';
import '../domain/lesson.dart';
import '../domain/lesson_repository.dart';

final lessonRepositoryProvider = Provider<LessonRepository>(
  (ref) => const DemoLessonRepository(),
);

final lessonsForCourseProvider = FutureProvider.family<List<Lesson>, String>(
  (ref, courseId) =>
      ref.watch(lessonRepositoryProvider).getLessonsForCourse(courseId),
);

final lessonProvider = FutureProvider.family<Lesson, String>(
  (ref, lessonId) => ref.watch(lessonRepositoryProvider).getLesson(lessonId),
);

/// Dersin kelimeleri (ders içindeki sırayla). Bulunamayan kimlikler atlanır.
final lessonVocabularyProvider =
    FutureProvider.family<List<VocabularyItem>, String>((ref, lessonId) async {
      final lesson = await ref.watch(lessonProvider(lessonId).future);
      final all = await ref.watch(vocabularyProvider.future);
      final byId = {for (final item in all) item.id: item};
      return [
        for (final id in lesson.vocabularyIds)
          if (byId[id] != null) byId[id]!,
      ];
    });
