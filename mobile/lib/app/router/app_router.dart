import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assessment/presentation/pages/quiz_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/language_selection/presentation/pages/language_selection_page.dart';
import '../../features/lessons/presentation/pages/lesson_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/vocabulary/presentation/pages/vocabulary_page.dart';
import '../shell/main_shell.dart';
import 'app_routes.dart';

/// Açılış rotası; testlerde override edilerek doğrudan bir ekranla başlanır.
final initialLocationProvider = Provider<String>((ref) => AppRoutes.splash);

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Merkezi gezinme. Gerçek kimlik doğrulama olmadığından burada AUTH GUARD
/// yoktur; demo ile gerçek oturum arasındaki sınır `sessionProvider`'dadır.
/// Backend bağlanınca `redirect` bu noktaya eklenecek.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: ref.read(initialLocationProvider),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.languageSetup,
        builder: (context, state) => const LanguageSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.courses,
                builder: (context, state) => const CatalogPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.vocabulary,
                builder: (context, state) => const VocabularyPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) => const ProgressPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      // Sekme çubuğunun üstünde, tam ekran sayfalar.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.course,
        builder: (context, state) =>
            CourseDetailPage(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.lesson,
        builder: (context, state) =>
            LessonPage(lessonId: state.pathParameters['lessonId']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.quiz,
        builder: (context, state) =>
            QuizPage(lessonId: state.pathParameters['lessonId']!),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
