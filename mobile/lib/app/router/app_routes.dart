/// Rota yolları tek yerde. Parametreli yollar için yardımcılar sağlanır.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const languageSetup = '/language-setup';

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const confirmEmail = '/auth/confirm-email';

  // Alt gezinme sekmeleri
  static const home = '/home';
  static const courses = '/courses';
  static const vocabulary = '/vocabulary';
  static const progress = '/progress';
  static const profile = '/profile';

  // Sekme dışı (tam ekran) sayfalar
  static const settings = '/settings';
  static const course = '/course/:courseId';
  static const lesson = '/lesson/:lessonId';
  static const quiz = '/quiz/:lessonId';
  static const review = '/review';
  static const track = '/track/:trackId';
  static const level = '/track/:trackId/level/:level';
  static const stages = '/stages/:lessonId';
  static const stage = '/stages/:lessonId/:stage';
  static const reviewHistory = '/review-history';

  static String courseOf(String id) => '/course/$id';
  static String lessonOf(String id) => '/lesson/$id';
  static String quizOf(String lessonId) => '/quiz/$lessonId';
  static String trackOf(String id) => '/track/$id';
  static String levelOf(String trackId, String level) =>
      '/track/$trackId/level/$level';
  static String stagesOf(String lessonId) => '/stages/$lessonId';
  static String stageOf(String lessonId, String stage) =>
      '/stages/$lessonId/$stage';
}
