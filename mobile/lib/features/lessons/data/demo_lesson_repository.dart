import '../../../core/errors/app_exceptions.dart';
import '../domain/lesson.dart';
import '../domain/lesson_repository.dart';
import 'demo_lesson_data.dart';

/// Yerel DEMO verisi. Gerçek API uygulaması aynı arayüzü uygulayıp
/// provider'da bunun yerine geçecek.
class DemoLessonRepository implements LessonRepository {
  const DemoLessonRepository();

  @override
  Future<List<Lesson>> getLessonsForCourse(String courseId) async {
    final lessons = demoLessons.where((l) => l.courseId == courseId).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return lessons;
  }

  @override
  Future<Lesson> getLesson(String lessonId) async {
    for (final lesson in demoLessons) {
      if (lesson.id == lessonId) return lesson;
    }
    throw NotFoundException('lesson:$lessonId');
  }
}
