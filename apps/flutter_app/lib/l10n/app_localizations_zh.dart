// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get languageHeading => 'Language';

  @override
  String get appLanguageSystem => 'System';

  @override
  String couldNotLoad(String what) {
    String _temp0 = intl.Intl.selectLogic(what, {
      'list': 'Couldn\'t load the list.',
      'highlights': 'Couldn\'t load Highlights.',
      'ranking': 'Couldn\'t load the ranking.',
      'genres': 'Couldn\'t load genres.',
      'status': 'Couldn\'t load data status.',
      'game': 'Couldn\'t load this game.',
      'other': 'Couldn\'t load this.',
    });
    return '$_temp0';
  }

  @override
  String serverAnswered(int status) {
    return 'The server answered $status.';
  }

  @override
  String get serverUnreachable => 'The Ringgit Radar server can\'t be reached.';

  @override
  String get unexpectedAnswer => 'The answer was not in the expected shape.';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String saleEnds(String dateTime) {
    return 'Sale ends $dateTime';
  }

  @override
  String percentOff(int percent) {
    return '$percent% OFF';
  }

  @override
  String itemsCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Items: $countString',
    );
    return '$_temp0';
  }

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get priceUnavailable => 'Price unavailable';
}
