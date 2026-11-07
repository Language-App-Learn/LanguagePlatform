import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_preferences.dart';

/// Whether onboarding was completed; persisted so it is not shown again
/// after a restart (until local data is reset).
class OnboardingCompletedNotifier extends Notifier<bool> {
  OnboardingCompletedNotifier([this._initial]);

  final bool? _initial;

  @override
  bool build() =>
      _initial ??
      ref.read(appPreferencesRepositoryProvider).load().onboardingCompleted;

  void complete() {
    state = true;
    ref
        .read(appPreferencesRepositoryProvider)
        .update((p) => p.copyWith(onboardingCompleted: true));
  }
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
      OnboardingCompletedNotifier.new,
    );
