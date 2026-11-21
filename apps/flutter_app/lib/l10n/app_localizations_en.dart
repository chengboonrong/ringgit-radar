// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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

  @override
  String get navHighlights => 'Highlights';

  @override
  String get navSearch => 'Search';

  @override
  String get navWishList => 'Wish List';

  @override
  String get navSale => 'Sale';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navRecent => 'Recent Releases';

  @override
  String get navComingSoon => 'Coming Soon';

  @override
  String get aboutApp => 'About Ringgit Radar';

  @override
  String get sections => 'Sections';

  @override
  String get retry => 'Retry';

  @override
  String get kindBundle => 'Bundle';

  @override
  String get kindAddon => 'Add-on';

  @override
  String get kindGame => 'Game';

  @override
  String get statusPreorder => 'Pre-order';

  @override
  String get statusNew => 'NEW';

  @override
  String rankN(int rank) {
    return 'Rank $rank';
  }

  @override
  String endsOn(String date) {
    return 'Ends $date';
  }

  @override
  String wishRemove(String title) {
    return 'Remove $title from Wish List';
  }

  @override
  String wishAdd(String title) {
    return 'Add $title to Wish List';
  }

  @override
  String priceOnSaleDescription(String now, String was, int percent) {
    return 'Sale price $now, was $was, $percent percent off';
  }

  @override
  String get back => 'Back';

  @override
  String mediaPosition(int index, int count) {
    return 'Media, $index of $count';
  }

  @override
  String get nextImage => 'Next image';

  @override
  String get previousImage => 'Previous image';

  @override
  String get noPriceYet => 'No price recorded yet.';

  @override
  String trackingBeganOnlyPrice(String date) {
    return 'Tracking began $date. We\'ve only seen this price so far.';
  }

  @override
  String lowestSeenSince(String price, String date) {
    return 'Lowest we\'ve seen: $price since $date';
  }

  @override
  String trackingBegan(String date) {
    return 'Tracking began $date';
  }

  @override
  String get historyHeading => 'What our history shows';

  @override
  String priceHistorySummary(String date, String prices) {
    return 'Price history from $date: $prices.';
  }

  @override
  String get priceHistoryJoiner => ', then ';

  @override
  String get descriptionHeading => 'Description';

  @override
  String get dlcHeading => 'Downloadable Content';

  @override
  String get publisher => 'Publisher';

  @override
  String get platform => 'Platform';

  @override
  String get productTypeDetail => 'Product type';

  @override
  String get releaseDate => 'Release date';

  @override
  String get genre => 'Genre';

  @override
  String get players => 'Players';

  @override
  String get detailsHeading => 'Details';

  @override
  String get onWishList => 'On Wish List';

  @override
  String get addToWishList => 'Add to Wish List';

  @override
  String get buyOnSwitch => 'Buy on your Switch\'s Nintendo eShop.';

  @override
  String get biggestSwitch2Savings => 'Biggest Switch 2 savings';

  @override
  String get endingSoonHeading => 'Ending Soon';

  @override
  String get newSales => 'New Sales';

  @override
  String upToRm(int amount) {
    return 'Up to RM $amount';
  }

  @override
  String showResults(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $countString results',
      one: 'Show 1 result',
      zero: 'Show 0 results',
    );
    return '$_temp0';
  }

  @override
  String get showResultsNoCount => 'Show results';

  @override
  String get closeFilters => 'Close filters';

  @override
  String get backToFilters => 'Back to filters';

  @override
  String get clear => 'Clear';

  @override
  String get filterProductType => 'Product Type';

  @override
  String get filterPrice => 'On Sale / Price Cap';

  @override
  String get filter => 'Filter';

  @override
  String filterCount(int count) {
    return 'Filter ($count)';
  }

  @override
  String filterSelected(int count) {
    return 'Filter, $count selected';
  }

  @override
  String get onSaleOnly => 'On sale only';

  @override
  String get nothingHere => 'Nothing here yet.';

  @override
  String get retryLoadingMore => 'Retry loading more';

  @override
  String get sortOrder => 'Sort order';

  @override
  String sortCurrent(String label) {
    return 'Sort: $label';
  }

  @override
  String get sortSavings => 'Biggest savings';

  @override
  String get sortDiscount => 'Biggest discount';

  @override
  String get sortPrice => 'Lowest price';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortEnding => 'Ending soon';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortSoonest => 'Soonest';

  @override
  String get saleHint => 'Sale end dates are shown in Malaysia time.';

  @override
  String get comingSoonHint => 'Release dates come from the store listing.';

  @override
  String get noFilterMatch =>
      'No titles match these filters. Clear a filter to see more.';

  @override
  String get rankedBySaved => 'Ranked by ringgit saved';

  @override
  String get nothingOnSaleConsole =>
      'Nothing is on sale for this console right now.';

  @override
  String get someProductsMissing => 'Some products may not be included.';

  @override
  String get noTitlesFound =>
      'No titles found. Try another keyword, or clear a filter.';

  @override
  String get searchHint => 'Search by keyword/title';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get viewAllSoftware => 'View All Software';

  @override
  String get switch2ViewAll => 'Switch 2, View All Software';

  @override
  String genreGames(String name, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, $countString games',
      one: '$name, 1 game',
    );
    return '$_temp0';
  }

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutUnofficial =>
      'Ringgit Radar is an independent, unofficial app. Not affiliated with or endorsed by Nintendo.';

  @override
  String get aboutRecord =>
      'It keeps its own record of Malaysian eShop prices in ringgit. To buy a game, use your Switch.';

  @override
  String get privacy => 'Privacy';

  @override
  String get dataHeading => 'Data';

  @override
  String get pricesLastChecked => 'Prices last checked';

  @override
  String get notYet => 'Not yet';

  @override
  String malaysiaTime(String dateTime) {
    return '$dateTime (Malaysia time)';
  }

  @override
  String get trackingBeganLabel => 'Tracking began';

  @override
  String get productsTracked => 'Products tracked';

  @override
  String get appearanceHeading => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get listsHeading => 'Lists';

  @override
  String get showAllTitles => 'Show all titles';

  @override
  String get showAllSubtitle =>
      'Also lists titles hidden by default, such as ones flagged by keyword.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageMalay => 'Bahasa Melayu';

  @override
  String get privacyNoAccountsTitle => 'No accounts';

  @override
  String get privacyNoAccountsBody =>
      'There is no sign-in. Ringgit Radar does not ask for your name, email or phone number, and it has no ads and no analytics.';

  @override
  String get privacyDeviceTitle => 'Your Wish List stays on your device';

  @override
  String get privacyDeviceBody =>
      'Your Wish List, your theme and language choices and the \"Show all titles\" setting are saved on this device only: in the browser\'s local storage on the web, in the app\'s preferences on Android. When you open your Wish List, the app asks our server for those games by their ids, so the server receives the ids in that request to answer it. It does not keep them or link them to you.';

  @override
  String get privacyLogsTitle => 'What our server logs';

  @override
  String get privacyLogsBody =>
      'Our server writes no access log. It logs only errors, for example a database error, and those lines hold an error message, not your address. To stop one visitor from overloading it, the server counts requests per internet address, in memory only. Those addresses are never written to disk.';

  @override
  String get privacyPicturesTitle =>
      'Pictures come from Nintendo\'s image server';

  @override
  String get privacyPicturesBody =>
      'Game art and screenshots load straight from the store\'s image server (img-eshop.cdn.nintendo.net). Your browser or phone asks it for each picture, so Nintendo receives your internet address and the usual details of a request, under Nintendo\'s own privacy policy. Ringgit Radar does not keep or pass on any pictures.';

  @override
  String get privacyOthersTitle => 'Who else sees your visit';

  @override
  String get privacyOthersBody =>
      'The site and its server run on Vercel. Vercel keeps request logs under its own policy, which can include the page you asked for, the time, your internet address and your browser type. Price data is stored with Supabase; it holds game prices and nothing about visitors, and it only ever hears from our server. Apart from those pictures, the web version loads everything, fonts included, from our own address, and the Android app talks only to our server.';

  @override
  String get privacyNotNintendoTitle => 'Not Nintendo';

  @override
  String get privacyNotNintendoBody =>
      'Ringgit Radar is an independent, unofficial app. Not affiliated with or endorsed by Nintendo. Prices are collected from the Malaysian Nintendo eShop and shown with their history; to buy a game, use your Switch.';

  @override
  String get privacyEnglishPrevails => '';

  @override
  String get backToAbout => 'Back to About';

  @override
  String get onSaleChip => 'On Sale';

  @override
  String get noneOnSale =>
      'None of the games on your Wish List are on sale right now.';

  @override
  String get wishEmptyTitle =>
      'You can add software you\'re interested in to your Wish List!';

  @override
  String get wishEmptyHint =>
      'Tap the heart on any game, in a list or on its page, to add it here.';

  @override
  String get genreAction => 'Action';

  @override
  String get genreAdventure => 'Adventure';

  @override
  String get genrePuzzle => 'Puzzle';

  @override
  String get genreSimulation => 'Simulation';

  @override
  String get genreArcade => 'Arcade';

  @override
  String get genreRpg => 'RPG';

  @override
  String get genreStrategy => 'Strategy';

  @override
  String get genreOther => 'Other';

  @override
  String get genrePlatformer => 'Platformer';

  @override
  String get genreShooter => 'Shooter';

  @override
  String get genreParty => 'Party';

  @override
  String get genreMultiplayer => 'Multiplayer';

  @override
  String get genreRacing => 'Racing';

  @override
  String get genreSports => 'Sports';

  @override
  String get genreBoardGame => 'Board Game';

  @override
  String get genreFighting => 'Fighting';

  @override
  String get genreLifestyle => 'Lifestyle';

  @override
  String get genreCommunication => 'Communication';

  @override
  String get genreEducation => 'Education';

  @override
  String get genreTraining => 'Training';

  @override
  String get genreStudy => 'Study';

  @override
  String get genreUtility => 'Utility';

  @override
  String get genreFirstPersonShooter => 'First-Person Shooter';

  @override
  String get genreMusic => 'Music';

  @override
  String get genrePractical => 'Practical';

  @override
  String get genreVideo => 'Video';
}
