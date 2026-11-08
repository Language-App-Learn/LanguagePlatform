/// Route paths in one place, with helpers for the parameterised ones.
///
/// The approved flow is splash -> app language (first use only) -> menu ->
/// language pair -> Arabic sections -> levels -> lesson menu. The auth and
/// delete-account routes are infrastructure, not part of that flow.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const appLanguage = '/app-language';
  static const menu = '/menu';
  static const languagePair = '/language-pair';
  static const arabicSections = '/arabic-sections';

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const confirmEmail = '/auth/confirm-email';
  static const deleteAccount = '/delete-account';

  /// Screen 6 (levels) and screen 7 (lesson menu of one level).
  static const track = '/track/:trackId';
  static const level = '/track/:trackId/level/:level';

  /// Screen 7 bound to one REAL (server) lesson, and its stage pages.
  static const stages = '/stages/:lessonId';
  static const stage = '/stages/:lessonId/:stage';

  /// Paths of the former app (onboarding, language setup, dashboard, tabs,
  /// old lesson/quiz/review screens). They no longer exist; the router sends
  /// them to the splash so old bookmarks and browser history never reopen an
  /// obsolete screen.
  static const legacyPrefixes = [
    '/onboarding',
    '/language-setup',
    '/home',
    '/courses',
    '/course',
    '/vocabulary',
    '/progress',
    '/profile',
    '/settings',
    '/lesson',
    '/quiz',
    '/review',
    '/review-history',
  ];

  static String trackOf(String id) => '/track/$id';
  static String levelOf(String trackId, String level) =>
      '/track/$trackId/level/$level';
  static String stagesOf(String lessonId) => '/stages/$lessonId';
  static String stageOf(String lessonId, String stage) =>
      '/stages/$lessonId/$stage';

  /// Whether [path] belongs to the removed former app.
  static bool isLegacy(String path) => legacyPrefixes.any(
    (prefix) => path == prefix || path.startsWith('$prefix/'),
  );
}
