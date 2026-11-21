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

  /// Bottom-bar tab, sidebar item and section name for the home page of picked deals. Bottom bar is tight: about 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get navHighlights;

  /// Bottom-bar tab and sidebar item. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Bottom-bar tab, sidebar item and page title for the device-local list of games the user saved. About 10 characters in the bar.
  ///
  /// In en, this message translates to:
  /// **'Wish List'**
  String get navWishList;

  /// Bottom-bar tab, sidebar item and page title: all games on sale now. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get navSale;

  /// Bottom-bar tab, sidebar item and page title: games on sale ranked by ringgit saved. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get navRanking;

  /// Sidebar item, chip on Highlights and page title: games released in the last 30 days. About 20 characters.
  ///
  /// In en, this message translates to:
  /// **'Recent Releases'**
  String get navRecent;

  /// Sidebar item, chip on Highlights and page title: games not released yet. About 20 characters.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get navComingSoon;

  /// Screen-reader label of the round profile button that opens the About page. 'Ringgit Radar' is the app's name, never translated.
  ///
  /// In en, this message translates to:
  /// **'About Ringgit Radar'**
  String get aboutApp;

  /// Screen-reader label for the bottom navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get sections;

  /// Button after an error: try loading again. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Product type: several products sold together. Shown on cards, filters and the game page. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Bundle'**
  String get kindBundle;

  /// Product type: downloadable content for a game. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Add-on'**
  String get kindAddon;

  /// Product type: a full game. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get kindGame;

  /// Small green chip on a game card: the game can be ordered before release. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Pre-order'**
  String get statusPreorder;

  /// Small amber chip on a game card: released in the last 30 days. Capitals in English. About 6 characters.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get statusNew;

  /// Screen-reader text on a ranking card, e.g. 'Rank 3'.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}'**
  String rankN(int rank);

  /// Small note on a sale card left of the struck price: when the sale ends, e.g. 'Ends 15 Nov'. Very tight: about 12 characters including the date.
  ///
  /// In en, this message translates to:
  /// **'Ends {date}'**
  String endsOn(String date);

  /// Screen-reader label of the heart button on a card when the game is saved. title is the game title in English.
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from Wish List'**
  String wishRemove(String title);

  /// Screen-reader label of the heart button on a card when the game is not saved. title is the game title in English.
  ///
  /// In en, this message translates to:
  /// **'Add {title} to Wish List'**
  String wishAdd(String title);

  /// What a screen reader says for a price on sale. now and was are money like 'RM 64.80'.
  ///
  /// In en, this message translates to:
  /// **'Sale price {now}, was {was}, {percent} percent off'**
  String priceOnSaleDescription(String now, String was, int percent);

  /// Screen-reader label of the back arrow on a game page.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Screen-reader label of the screenshot carousel, e.g. 'Media, 2 of 5'.
  ///
  /// In en, this message translates to:
  /// **'Media, {index} of {count}'**
  String mediaPosition(int index, int count);

  /// Screen-reader label of the carousel's forward arrow.
  ///
  /// In en, this message translates to:
  /// **'Next image'**
  String get nextImage;

  /// Screen-reader label of the carousel's back arrow.
  ///
  /// In en, this message translates to:
  /// **'Previous image'**
  String get previousImage;

  /// Price history section when we have no observation yet. A full sentence.
  ///
  /// In en, this message translates to:
  /// **'No price recorded yet.'**
  String get noPriceYet;

  /// Price history section with a single observation. 'We' is Ringgit Radar: only our own record, not the store's. A full sentence, can wrap.
  ///
  /// In en, this message translates to:
  /// **'Tracking began {date}. We\'ve only seen this price so far.'**
  String trackingBeganOnlyPrice(String date);

  /// Price history headline: the lowest price in OUR OWN record and since when it has been seen. Must keep 'we've seen' (our history only, not an all-time low). price is money like 'RM 64.80'. Can wrap.
  ///
  /// In en, this message translates to:
  /// **'Lowest we\'ve seen: {price} since {date}'**
  String lowestSeenSince(String price, String date);

  /// Small line under the lowest price: the date our own record of this game starts.
  ///
  /// In en, this message translates to:
  /// **'Tracking began {date}'**
  String trackingBegan(String date);

  /// Section heading on a game page above the price history. 'Our' is Ringgit Radar's own record. About 30 characters.
  ///
  /// In en, this message translates to:
  /// **'What our history shows'**
  String get historyHeading;

  /// What a screen reader says for the price chart. prices is a list of money values joined by priceHistoryJoiner.
  ///
  /// In en, this message translates to:
  /// **'Price history from {date}: {prices}.'**
  String priceHistorySummary(String date, String prices);

  /// Joins prices in the chart's screen-reader text: 'RM 99.00, then RM 59.40'. Keep the surrounding spaces as your language needs.
  ///
  /// In en, this message translates to:
  /// **', then '**
  String get priceHistoryJoiner;

  /// Section heading on a game page above the store's description (which stays in English). About 20 characters.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionHeading;

  /// Section heading on a game page above its add-ons. About 25 characters.
  ///
  /// In en, this message translates to:
  /// **'Downloadable Content'**
  String get dlcHeading;

  /// Label in the game page's details table. About 15 characters.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisher;

  /// Label in the details table and filter section: Switch 2 or Switch. About 15 characters.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// Label in the game page's details table: game, bundle or add-on. About 15 characters.
  ///
  /// In en, this message translates to:
  /// **'Product type'**
  String get productTypeDetail;

  /// Label in the game page's details table. About 15 characters.
  ///
  /// In en, this message translates to:
  /// **'Release date'**
  String get releaseDate;

  /// Label in the details table, filter section and section heading on Search. About 15 characters.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// Label in the details table: number of players. About 15 characters.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// Section heading on a game page above the details table. About 20 characters.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsHeading;

  /// Button on a game page when the game is saved. About 16 characters, next to a heart icon.
  ///
  /// In en, this message translates to:
  /// **'On Wish List'**
  String get onWishList;

  /// Button on a game page when the game is not saved. About 16 characters, next to a heart icon.
  ///
  /// In en, this message translates to:
  /// **'Add to Wish List'**
  String get addToWishList;

  /// Small note under the price: the app sells nothing, purchases happen on the console. Must not suggest the app is Nintendo. One short line.
  ///
  /// In en, this message translates to:
  /// **'Buy on your Switch\'s Nintendo eShop.'**
  String get buyOnSwitch;

  /// Section heading on Highlights: Switch 2 games with the most ringgit saved. Keep 'Switch 2'. About 30 characters.
  ///
  /// In en, this message translates to:
  /// **'Biggest Switch 2 savings'**
  String get biggestSwitch2Savings;

  /// Section heading on Highlights: sales that end soonest. About 20 characters.
  ///
  /// In en, this message translates to:
  /// **'Ending Soon'**
  String get endingSoonHeading;

  /// Section heading on Highlights: sales that started most recently. About 20 characters.
  ///
  /// In en, this message translates to:
  /// **'New Sales'**
  String get newSales;

  /// Price-cap filter option, e.g. 'Up to RM 20'. Keep 'RM' as is, never translate it.
  ///
  /// In en, this message translates to:
  /// **'Up to RM {amount}'**
  String upToRm(int amount);

  /// Big red button at the bottom of the filter sheet: apply the filters, with how many games they give. About 22 characters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Show 0 results} =1{Show 1 result} other{Show {count} results}}'**
  String showResults(int count);

  /// The same button while the count is loading. About 22 characters.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get showResultsNoCount;

  /// Screen-reader label of the X in the filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Close filters'**
  String get closeFilters;

  /// Screen-reader label of the back arrow inside a filter section.
  ///
  /// In en, this message translates to:
  /// **'Back to filters'**
  String get backToFilters;

  /// Text button in the filter sheet's header: reset every filter. About 8 characters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Filter section name (a row in the sheet and its header). About 22 characters.
  ///
  /// In en, this message translates to:
  /// **'Product Type'**
  String get filterProductType;

  /// Filter section name: on-sale switch and price caps. About 22 characters.
  ///
  /// In en, this message translates to:
  /// **'On Sale / Price Cap'**
  String get filterPrice;

  /// Filter button on list pages and the filter sheet's header. About 10 characters, next to an icon.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Filter button when filters are set, e.g. 'Filter (2)'. About 12 characters.
  ///
  /// In en, this message translates to:
  /// **'Filter ({count})'**
  String filterCount(int count);

  /// Screen-reader label of the filter button when filters are set.
  ///
  /// In en, this message translates to:
  /// **'Filter, {count} selected'**
  String filterSelected(int count);

  /// Filter option: show only games on sale. About 20 characters.
  ///
  /// In en, this message translates to:
  /// **'On sale only'**
  String get onSaleOnly;

  /// A list with no games and no filters set.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get nothingHere;

  /// Button at the end of a list when the next page failed to load. About 22 characters.
  ///
  /// In en, this message translates to:
  /// **'Retry loading more'**
  String get retryLoadingMore;

  /// Tooltip of the sort dropdown.
  ///
  /// In en, this message translates to:
  /// **'Sort order'**
  String get sortOrder;

  /// Screen-reader label of the sort dropdown, e.g. 'Sort: Biggest savings'.
  ///
  /// In en, this message translates to:
  /// **'Sort: {label}'**
  String sortCurrent(String label);

  /// Sort option: most ringgit saved first. About 18 characters (shown in a dropdown).
  ///
  /// In en, this message translates to:
  /// **'Biggest savings'**
  String get sortSavings;

  /// Sort option: highest percentage off first. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Biggest discount'**
  String get sortDiscount;

  /// Sort option: cheapest first. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get sortPrice;

  /// Sort option: latest release first. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// Sort option: sales that end soonest first. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get sortEnding;

  /// Sort option: alphabetical by game title. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// Sort option on Coming Soon: earliest release date first. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Soonest'**
  String get sortSoonest;

  /// Small note at the top of the Sale list.
  ///
  /// In en, this message translates to:
  /// **'Sale end dates are shown in Malaysia time.'**
  String get saleHint;

  /// Small note at the top of Coming Soon: we copy the dates, we don't promise them.
  ///
  /// In en, this message translates to:
  /// **'Release dates come from the store listing.'**
  String get comingSoonHint;

  /// A filtered list with no games.
  ///
  /// In en, this message translates to:
  /// **'No titles match these filters. Clear a filter to see more.'**
  String get noFilterMatch;

  /// Small note under the Ranking tabs: the order is by ringgit saved in the sale, nothing else (not sales or popularity).
  ///
  /// In en, this message translates to:
  /// **'Ranked by ringgit saved'**
  String get rankedBySaved;

  /// Ranking tab with no games on sale.
  ///
  /// In en, this message translates to:
  /// **'Nothing is on sale for this console right now.'**
  String get nothingOnSaleConsole;

  /// Small note on Search: our catalogue may not hold every product.
  ///
  /// In en, this message translates to:
  /// **'Some products may not be included.'**
  String get someProductsMissing;

  /// Search with no results.
  ///
  /// In en, this message translates to:
  /// **'No titles found. Try another keyword, or clear a filter.'**
  String get noTitlesFound;

  /// Placeholder text and screen-reader label of the search field. About 28 characters.
  ///
  /// In en, this message translates to:
  /// **'Search by keyword/title'**
  String get searchHint;

  /// Screen-reader label of the X in the search field.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// Small white button on the red Switch 2 banner on Search. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'View All Software'**
  String get viewAllSoftware;

  /// Screen-reader label of the Switch 2 banner on Search.
  ///
  /// In en, this message translates to:
  /// **'Switch 2, View All Software'**
  String get switch2ViewAll;

  /// Screen-reader label of a genre tile on Search, e.g. 'Puzzle, 1,111 games'. name is the genre label.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{name}, 1 game} other{{name}, {count} games}}'**
  String genreGames(String name, int count);

  /// Page title of the About and settings page. About 15 characters.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// First line of About. 'Ringgit Radar' is the app's name, never translated. Must say clearly that it is not Nintendo's.
  ///
  /// In en, this message translates to:
  /// **'Ringgit Radar is an independent, unofficial app. Not affiliated with or endorsed by Nintendo.'**
  String get aboutUnofficial;

  /// Second line of About: what the app is for.
  ///
  /// In en, this message translates to:
  /// **'It keeps its own record of Malaysian eShop prices in ringgit. To buy a game, use your Switch.'**
  String get aboutRecord;

  /// Chip on About that opens the Privacy page, and that page's title. About 12 characters.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Section heading on About above facts about our price data. About 20 characters.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataHeading;

  /// Label on About: when our server last read the store's prices. About 22 characters.
  ///
  /// In en, this message translates to:
  /// **'Prices last checked'**
  String get pricesLastChecked;

  /// Value on About when something has not happened yet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// A date and time on About with its time zone, e.g. '2 Nov 2026, 12:10 am (Malaysia time)'.
  ///
  /// In en, this message translates to:
  /// **'{dateTime} (Malaysia time)'**
  String malaysiaTime(String dateTime);

  /// Label on About: the date our own price record starts. About 22 characters.
  ///
  /// In en, this message translates to:
  /// **'Tracking began'**
  String get trackingBeganLabel;

  /// Label on About: how many products we record. About 22 characters.
  ///
  /// In en, this message translates to:
  /// **'Products tracked'**
  String get productsTracked;

  /// Section heading on About above the theme chips. About 20 characters.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceHeading;

  /// Theme chip: follow the device's light or dark setting. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Theme chip. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme chip. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Section heading on About above list settings. About 20 characters.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get listsHeading;

  /// Switch on About: also list titles hidden by default. About 25 characters.
  ///
  /// In en, this message translates to:
  /// **'Show all titles'**
  String get showAllTitles;

  /// Small line under the 'Show all titles' switch. Can wrap.
  ///
  /// In en, this message translates to:
  /// **'Also lists titles hidden by default, such as ones flagged by keyword.'**
  String get showAllSubtitle;

  /// Language chip. Always written in its own language, the same in every file.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language chip. Always written in its own language, the same in every file.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// Language chip. Always written in its own language, the same in every file.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Melayu'**
  String get languageMalay;

  /// Privacy page heading.
  ///
  /// In en, this message translates to:
  /// **'No accounts'**
  String get privacyNoAccountsTitle;

  /// Privacy page paragraph. Must say exactly what is true, no more.
  ///
  /// In en, this message translates to:
  /// **'There is no sign-in. Ringgit Radar does not ask for your name, email or phone number, and it has no ads and no analytics.'**
  String get privacyNoAccountsBody;

  /// Privacy page heading.
  ///
  /// In en, this message translates to:
  /// **'Your Wish List stays on your device'**
  String get privacyDeviceTitle;

  /// Privacy page paragraph. 'Show all titles' is the name of the setting on About. Must say exactly what is true, no more.
  ///
  /// In en, this message translates to:
  /// **'Your Wish List, your theme and language choices and the \"Show all titles\" setting are saved on this device only: in the browser\'s local storage on the web, in the app\'s preferences on Android. When you open your Wish List, the app asks our server for those games by their ids, so the server receives the ids in that request to answer it. It does not keep them or link them to you.'**
  String get privacyDeviceBody;

  /// Privacy page heading.
  ///
  /// In en, this message translates to:
  /// **'What our server logs'**
  String get privacyLogsTitle;

  /// Privacy page paragraph. Must say exactly what is true, no more.
  ///
  /// In en, this message translates to:
  /// **'Our server writes no access log. It logs only errors, for example a database error, and those lines hold an error message, not your address. To stop one visitor from overloading it, the server counts requests per internet address, in memory only. Those addresses are never written to disk.'**
  String get privacyLogsBody;

  /// Privacy page heading.
  ///
  /// In en, this message translates to:
  /// **'Pictures come from Nintendo\'s image server'**
  String get privacyPicturesTitle;

  /// Privacy page paragraph. Keep the host name exactly. Must say exactly what is true, no more.
  ///
  /// In en, this message translates to:
  /// **'Game art and screenshots load straight from the store\'s image server (img-eshop.cdn.nintendo.net). Your browser or phone asks it for each picture, so Nintendo receives your internet address and the usual details of a request, under Nintendo\'s own privacy policy. Ringgit Radar does not keep or pass on any pictures.'**
  String get privacyPicturesBody;

  /// Privacy page heading.
  ///
  /// In en, this message translates to:
  /// **'Who else sees your visit'**
  String get privacyOthersTitle;

  /// Privacy page paragraph. Keep Vercel and Supabase as names. Must say exactly what is true, no more.
  ///
  /// In en, this message translates to:
  /// **'The site and its server run on Vercel. Vercel keeps request logs under its own policy, which can include the page you asked for, the time, your internet address and your browser type. Price data is stored with Supabase; it holds game prices and nothing about visitors, and it only ever hears from our server. Apart from those pictures, the web version loads everything, fonts included, from our own address, and the Android app talks only to our server.'**
  String get privacyOthersBody;

  /// Privacy page heading.
  ///
  /// In en, this message translates to:
  /// **'Not Nintendo'**
  String get privacyNotNintendoTitle;

  /// Privacy page paragraph. Must say clearly that the app is not Nintendo's.
  ///
  /// In en, this message translates to:
  /// **'Ringgit Radar is an independent, unofficial app. Not affiliated with or endorsed by Nintendo. Prices are collected from the Malaysian Nintendo eShop and shown with their history; to buy a game, use your Switch.'**
  String get privacyNotNintendoBody;

  /// One line at the end of the Privacy page, only in translations: this is a translation and the English version applies if they differ. Empty in English (not shown).
  ///
  /// In en, this message translates to:
  /// **''**
  String get privacyEnglishPrevails;

  /// Chip at the end of the Privacy page. About 15 characters.
  ///
  /// In en, this message translates to:
  /// **'Back to About'**
  String get backToAbout;

  /// Chip on Wish List: show only saved games on sale. About 10 characters.
  ///
  /// In en, this message translates to:
  /// **'On Sale'**
  String get onSaleChip;

  /// Wish List filtered to on-sale with nothing on sale.
  ///
  /// In en, this message translates to:
  /// **'None of the games on your Wish List are on sale right now.'**
  String get noneOnSale;

  /// Big line on an empty Wish List.
  ///
  /// In en, this message translates to:
  /// **'You can add software you\'re interested in to your Wish List!'**
  String get wishEmptyTitle;

  /// Smaller line under it.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any game, in a list or on its page, to add it here.'**
  String get wishEmptyHint;

  /// Genre name as the eShop groups games (API value 'Action'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get genreAction;

  /// Genre name as the eShop groups games (API value 'Adventure'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get genreAdventure;

  /// Genre name as the eShop groups games (API value 'Puzzle'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Puzzle'**
  String get genrePuzzle;

  /// Genre name as the eShop groups games (API value 'Simulation'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get genreSimulation;

  /// Genre name as the eShop groups games (API value 'Arcade'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Arcade'**
  String get genreArcade;

  /// Genre name as the eShop groups games (API value 'RPG'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'RPG'**
  String get genreRpg;

  /// Genre name as the eShop groups games (API value 'Strategy'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get genreStrategy;

  /// Genre name as the eShop groups games (API value 'Other'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genreOther;

  /// Genre name as the eShop groups games (API value 'Platformer'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Platformer'**
  String get genrePlatformer;

  /// Genre name as the eShop groups games (API value 'Shooter'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Shooter'**
  String get genreShooter;

  /// Genre name as the eShop groups games (API value 'Party'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get genreParty;

  /// Genre name as the eShop groups games (API value 'Multiplayer'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer'**
  String get genreMultiplayer;

  /// Genre name as the eShop groups games (API value 'Racing'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Racing'**
  String get genreRacing;

  /// Genre name as the eShop groups games (API value 'Sports'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get genreSports;

  /// Genre name as the eShop groups games (API value 'Board Game'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Board Game'**
  String get genreBoardGame;

  /// Genre name as the eShop groups games (API value 'Fighting'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Fighting'**
  String get genreFighting;

  /// Genre name as the eShop groups games (API value 'Lifestyle'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get genreLifestyle;

  /// Genre name as the eShop groups games (API value 'Communication'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get genreCommunication;

  /// Genre name as the eShop groups games (API value 'Education'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get genreEducation;

  /// Genre name as the eShop groups games (API value 'Training'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get genreTraining;

  /// Genre name as the eShop groups games (API value 'Study'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get genreStudy;

  /// Genre name as the eShop groups games (API value 'Utility'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Utility'**
  String get genreUtility;

  /// Genre name as the eShop groups games (API value 'First-Person Shooter'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'First-Person Shooter'**
  String get genreFirstPersonShooter;

  /// Genre name as the eShop groups games (API value 'Music'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get genreMusic;

  /// Genre name as the eShop groups games (API value 'Practical'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Practical'**
  String get genrePractical;

  /// Genre name as the eShop groups games (API value 'Video'). Shown on Search tiles, filters and the game page. About 18 characters.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get genreVideo;
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
