import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../language_selection/application/content_language.dart';
import '../data/demo_course_repository.dart';
import '../domain/course.dart';
import '../domain/course_repository.dart';

/// Şimdilik DEMO repository. Backend hazır olunca burada API uygulamasına
/// geçilir; UI ve diğer provider'lar değişmez.
final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => const DemoCourseRepository(),
);

final coursesProvider = FutureProvider<List<Course>>(
  (ref) => ref.watch(courseRepositoryProvider).getCourses(),
);

final courseProvider = FutureProvider.family<Course, String>(
  (ref, courseId) => ref.watch(courseRepositoryProvider).getCourse(courseId),
);

/// Öğrenilen dildeki kurslar (dil seçilmediyse hepsi), seviyeye göre sıralı.
final targetCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final target = ref.watch(targetLanguageCodeProvider);
  return ref.watch(coursesProvider).whenData((courses) {
    final list = [
      for (final course in courses)
        if (target == null || course.languageCode == target) course,
    ]..sort((a, b) => a.level.index.compareTo(b.level.index));
    return list;
  });
});
