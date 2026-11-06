import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_language.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../authentication/application/auth_providers.dart';
import '../../language_selection/application/learning_preferences.dart';
import '../../onboarding/application/onboarding_state.dart';
import '../../progress/application/progress_providers.dart';
import '../../vocabulary/application/vocabulary_providers.dart';

/// Deletes ALL locally stored data of this app (preferences, onboarding,
/// demo progress, vocabulary state) and rebuilds the in-memory state from
/// the now-empty storage. Server-side data is not affected (none exists yet).
Future<void> resetLocalData(WidgetRef ref) async {
  await ref.read(keyValueStoreProvider).clearAll();
  ref
    ..invalidate(appLanguageProvider)
    ..invalidate(themeModeProvider)
    ..invalidate(learningPreferencesProvider)
    ..invalidate(onboardingCompletedProvider)
    ..invalidate(progressProvider)
    ..invalidate(vocabularyRecordsProvider)
    ..invalidate(sessionProvider);
}
