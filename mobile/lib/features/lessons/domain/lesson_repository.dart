import 'lesson.dart';

abstract interface class LessonRepository {
  /// Kursun dersleri, `order` sırasıyla. Boş olabilir.
  Future<List<Lesson>> getLessonsForCourse(String courseId);

  /// Ders yoksa `NotFoundException` fırlatır.
  Future<Lesson> getLesson(String lessonId);
}
