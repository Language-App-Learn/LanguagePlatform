import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding tamamlandı mı? Henüz kalıcı değil: uygulama yeniden
/// başlayınca tanıtım tekrar gösterilir (yerel depolama kararı bekliyor).
class OnboardingCompletedNotifier extends Notifier<bool> {
  OnboardingCompletedNotifier([this._initial = false]);

  final bool _initial;

  @override
  bool build() => _initial;

  void complete() => state = true;
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
      OnboardingCompletedNotifier.new,
    );
