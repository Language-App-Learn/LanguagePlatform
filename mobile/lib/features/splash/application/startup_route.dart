import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/l10n/app_language.dart';

/// First route after the splash: the one-time app-language choice, then
/// always the main menu. The choice is "made" once an interface language has
/// been saved.
String entryRouteFor({required AppLanguage? appLanguage}) =>
    appLanguage == null ? AppRoutes.appLanguage : AppRoutes.menu;

/// How long the splash stays visible so the logo can be seen. Tests override
/// it with [Duration.zero].
final splashHoldProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 1300),
);

/// The splash's destination (after the short hold).
final startupRouteProvider = FutureProvider<String>((ref) async {
  final hold = ref.read(splashHoldProvider);
  if (hold > Duration.zero) await Future<void>.delayed(hold);
  return entryRouteFor(appLanguage: ref.watch(appLanguageProvider));
});
