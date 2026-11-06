import 'course.dart';

abstract interface class CourseRepository {
  Future<List<Course>> getCourses();

  /// Kurs yoksa `NotFoundException` fırlatır.
  Future<Course> getCourse(String courseId);
}
