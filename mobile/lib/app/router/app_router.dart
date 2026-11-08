import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../features/authentication/presentation/pages/confirm_email_page.dart';
import '../../features/authentication/presentation/pages/delete_account_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/language_selection/presentation/pages/app_language_page.dart';
import '../../features/language_selection/presentation/pages/language_pair_page.dart';
import '../../features/learning_track/presentation/pages/lesson_menu_page.dart';
import '../../features/learning_track/presentation/pages/level_selection_page.dart';
import '../../features/learning_track/presentation/pages/remote_lesson_pages.dart';
import '../../features/menu/presentation/pages/arabic_sections_page.dart';
import '../../features/menu/presentation/pages/main_menu_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'app_routes.dart';
import 'route_error_page.dart';

/// Opening route; tests override it to start directly on a screen.
final initialLocationProvider = Provider<String>((ref) => AppRoutes.splash);

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Paths that may be opened before the app language has been chosen.
bool _openWithoutLanguage(String path) =>
    path == AppRoutes.splash ||
    path == AppRoutes.appLanguage ||
    path.startsWith('/auth/') ||
    path == AppRoutes.deleteAccount;

/// Central navigation. Unknown routes show [RouteErrorPage].
///
/// - Paths of the removed former app (and `/`) go to the splash, which then
///   decides: first use -> app language -> menu; later -> menu.
/// - Without a saved app language only the splash and the language screen
///   (and the account routes) open, so a refresh or a pasted URL cannot skip
///   the one-time language choice.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    errorBuilder: (context, state) => const RouteErrorPage(),
    initialLocation: ref.read(initialLocationProvider),
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/' || AppRoutes.isLegacy(path)) return AppRoutes.splash;
      if (ref.read(appLanguageProvider) == null &&
          !_openWithoutLanguage(path)) {
        return AppRoutes.splash;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.appLanguage,
        builder: (context, state) => const AppLanguagePage(),
      ),
      GoRoute(
        path: AppRoutes.menu,
        builder: (context, state) => const MainMenuPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.languagePair,
        builder: (context, state) => const LanguagePairPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.arabicSections,
        builder: (context, state) => const ArabicSectionsPage(),
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
      GoRoute(
        path: AppRoutes.confirmEmail,
        builder: (context, state) => ConfirmEmailPage(
          userId: state.uri.queryParameters['userId'],
          code: state.uri.queryParameters['code'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.deleteAccount,
        builder: (context, state) => const DeleteAccountPage(),
      ),
      // Screen 6: levels.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.track,
        builder: (context, state) =>
            LevelSelectionPage(trackId: state.pathParameters['trackId']!),
      ),
      // Screen 7: the lesson menu of a level. No lesson is selected yet, so
      // its actions are unavailable until the owner defines lesson selection.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.level,
        builder: (context, state) => const LessonMenuPage(),
      ),
      // Screen 7 bound to a real server lesson, and its stage pages.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.stages,
        builder: (context, state) =>
            LessonMenuPage(lessonId: state.pathParameters['lessonId']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.stage,
        builder: (context, state) => RemoteStagePage(
          lessonId: state.pathParameters['lessonId']!,
          stage: state.pathParameters['stage']!,
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
