import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

const appLocales = [Locale('en'), Locale('zh'), Locale('ms')];

/// The first device language the app speaks, otherwise English. Any Chinese, Traditional included, gets
/// Simplified, which those readers follow more easily than English.
Locale resolveAppLocale(List<Locale>? device) {
  for (final l in device ?? const <Locale>[]) {
    for (final a in appLocales) {
      if (l.languageCode == a.languageCode) return a;
    }
  }
  return const Locale('en');
}
