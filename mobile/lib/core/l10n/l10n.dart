import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'app_language.dart';
export 'generated/app_localizations.dart';
export 'localized_text.dart';

extension AppLocalizationsContext on BuildContext {
  /// `context.l10n.retry` biçiminde kısa erişim.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Ekrandaki etkin arayüz dili kodu ('tr', 'ar', 'en').
  String get languageCode => Localizations.localeOf(this).languageCode;
}
