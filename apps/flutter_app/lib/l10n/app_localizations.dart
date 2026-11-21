import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
    Locale('zh'),
  ];

  /// Settings section heading above the language chips, about 20 characters
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageHeading;

  /// Language chip in Settings: follow the device language, about 10 characters
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appLanguageSystem;

  /// First sentence of an error message in the middle of a page, saying which request failed. Followed by a second sentence saying why. Room for a full sentence.
  ///
  /// In en, this message translates to:
  /// **'{what, select, list{Couldn\'t load the list.} highlights{Couldn\'t load Highlights.} ranking{Couldn\'t load the ranking.} genres{Couldn\'t load genres.} status{Couldn\'t load data status.} game{Couldn\'t load this game.} other{Couldn\'t load this.}}'**
  String couldNotLoad(String what);

  /// Second sentence of an error message: the server replied with an HTTP error code (the number, e.g. 503). Room for a full sentence.
  ///
  /// In en, this message translates to:
  /// **'The server answered {status}.'**
  String serverAnswered(int status);

  /// Second sentence of an error message: no connection to the app's server. 'Ringgit Radar' is the app's name, never translated. Room for a full sentence.
  ///
  /// In en, this message translates to:
  /// **'The Ringgit Radar server can\'t be reached.'**
  String get serverUnreachable;

  /// Second sentence of an error message: the server answered with data the app could not read. Room for a full sentence.
  ///
  /// In en, this message translates to:
  /// **'The answer was not in the expected shape.'**
  String get unexpectedAnswer;

  /// Error message for a failure that is not a server request. Room for a full sentence.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// Line on a game page under the price: when the sale ends. dateTime is a date and time in Malaysia time, e.g. '16 Dec 2026, 11:59 pm'. About 35 characters plus the date.
  ///
  /// In en, this message translates to:
  /// **'Sale ends {dateTime}'**
  String saleEnds(String dateTime);

  /// Red sale chip next to a price, e.g. '10% OFF'. Very tight: about 8 characters. Capitals in English as on the eShop.
  ///
  /// In en, this message translates to:
  /// **'{percent}% OFF'**
  String percentOff(int percent);

  /// Small count above a list of games, e.g. 'Items: 7,827'. About 15 characters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Items: {count}}}'**
  String itemsCount(int count);

  /// Stands where a price would be, for a game not out yet with no release date. About 14 characters, right-aligned on a card.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Stands where a price would be when the store gives none for a released game. About 18 characters, right-aligned on a card.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get priceUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
