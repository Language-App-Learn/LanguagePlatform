import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../courses/application/course_providers.dart';
import '../../courses/domain/course.dart';

/// Katalog arama + dil + seviye filtresi.
@immutable
class CatalogFilter {
  const CatalogFilter({this.query = '', this.languageCode, this.level});

  final String query;

  /// Öğrenilen dil; `null`: tümü.
  final String? languageCode;

  /// `null`: tüm seviyeler.
  final CourseLevel? level;

  bool get isActive =>
      query.trim().isNotEmpty || languageCode != null || level != null;

  CatalogFilter withQuery(String value) =>
      CatalogFilter(query: value, languageCode: languageCode, level: level);

  CatalogFilter withLanguage(String? value) =>
      CatalogFilter(query: query, languageCode: value, level: level);

  CatalogFilter withLevel(CourseLevel? value) =>
      CatalogFilter(query: query, languageCode: languageCode, level: value);

  bool accepts(Course course) {
    if (languageCode != null && course.languageCode != languageCode) {
      return false;
    }
    if (level != null && course.level != level) return false;
    return course.title.matches(query) ||
        course.description.matches(query) ||
        course.level.code.toLowerCase() == query.trim().toLowerCase();
  }
}

class CatalogFilterNotifier extends Notifier<CatalogFilter> {
  @override
  CatalogFilter build() => const CatalogFilter();

  void setQuery(String value) => state = state.withQuery(value);
  void setLanguage(String? code) => state = state.withLanguage(code);
  void setLevel(CourseLevel? level) => state = state.withLevel(level);
  void clear() => state = const CatalogFilter();
}

final catalogFilterProvider =
    NotifierProvider<CatalogFilterNotifier, CatalogFilter>(
      CatalogFilterNotifier.new,
    );

final filteredCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final filter = ref.watch(catalogFilterProvider);
  return ref
      .watch(coursesProvider)
      .whenData(
        (courses) => [
          for (final course in courses)
            if (filter.accepts(course)) course,
        ],
      );
});
