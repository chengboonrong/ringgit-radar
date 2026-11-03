import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
abstract class Price with _$Price {
  const factory Price({
    required String currency,
    required int regularMinor,
    required int currentMinor,
    required bool onSale,
    int? discountMinor,
    @Default(0) int percentOff,
    @Default(0) int savedMinor,
    DateTime? discountStart,
    DateTime? discountEnd,
    DateTime? checkedAt,
  }) = _Price;

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
}

@freezed
abstract class Game with _$Game {
  const factory Game({
    required String nsuid,
    required String title,
    required String publisher,
    required String platform,
    required String category,
    String? releaseDate,
    @Default('') String releaseText,
    @Default('') String image,
    @Default('') String sourceStatus,
    @Default('') String salesStatus,
    Price? price,
    int? rank,
    // UK PEGI from a title match; null means no rating was found, not that the game is unrated-safe
    int? age,
    List<String>? ageDescriptors,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

@freezed
abstract class GamePage with _$GamePage {
  const factory GamePage({
    required List<Game> items,
    required int total,
    @Default(1) int page,
  }) = _GamePage;

  factory GamePage.fromJson(Map<String, dynamic> json) => _$GamePageFromJson(json);
}

@freezed
abstract class Highlights with _$Highlights {
  const factory Highlights({
    @Default([]) List<Game> topSavings,
    @Default([]) List<Game> endingSoon,
    @Default([]) List<Game> newSales,
    @Default([]) List<Game> recent,
  }) = _Highlights;

  factory Highlights.fromJson(Map<String, dynamic> json) => _$HighlightsFromJson(json);
}

@freezed
abstract class HistoryPoint with _$HistoryPoint {
  const factory HistoryPoint({
    required DateTime observedAt,
    required int regularMinor,
    required int priceMinor,
    int? discountMinor,
    DateTime? discountStart,
    DateTime? discountEnd,
  }) = _HistoryPoint;

  factory HistoryPoint.fromJson(Map<String, dynamic> json) => _$HistoryPointFromJson(json);
}

@freezed
abstract class Lowest with _$Lowest {
  const factory Lowest({
    required int priceMinor,
    required DateTime since,
    required bool isSale,
  }) = _Lowest;

  factory Lowest.fromJson(Map<String, dynamic> json) => _$LowestFromJson(json);
}

@freezed
abstract class GameDetail with _$GameDetail {
  const factory GameDetail({
    required String nsuid,
    required String title,
    required String publisher,
    required String platform,
    required String category,
    String? releaseDate,
    @Default('') String releaseText,
    @Default('') String image,
    @Default('') String sourceStatus,
    @Default('') String salesStatus,
    Price? price,
    @Default([]) List<String> screenshots,
    @Default([]) List<String> dcolors,
    @Default([]) List<String> genres,
    @Default('') String description,
    @Default('') String tagline,
    @Default('') String players,
    @Default([]) List<HistoryPoint> history,
    DateTime? firstObservedAt,
    Lowest? lowest,
    @Default([]) List<Game> addons,
    int? age,
    List<String>? ageDescriptors,
  }) = _GameDetail;

  factory GameDetail.fromJson(Map<String, dynamic> json) => _$GameDetailFromJson(json);
}

@freezed
abstract class GenreCount with _$GenreCount {
  const factory GenreCount({required String name, required int count, @Default('') String cover}) = _GenreCount;

  factory GenreCount.fromJson(Map<String, dynamic> json) => _$GenreCountFromJson(json);
}

@freezed
abstract class PriceStatus with _$PriceStatus {
  const factory PriceStatus({
    DateTime? lastRunAt,
    @Default(0) int productCount,
    DateTime? historySince,
  }) = _PriceStatus;

  factory PriceStatus.fromJson(Map<String, dynamic> json) => _$PriceStatusFromJson(json);
}

/// What a list asks the API for. Value equality makes it the key of the list providers.
@freezed
abstract class ListQuery with _$ListQuery {
  const factory ListQuery({
    @Default('') String q,
    @Default(<String>[]) List<String> platforms,
    @Default(<String>['game']) List<String> types,
    @Default(<String>[]) List<String> genres,
    @Default(<int>[]) List<int> ages,
    @Default(false) bool sale,
    int? maxPrice,
    @Default('savings') String sort,
    String? release,
    @Default(<String>[]) List<String> ids,
  }) = _ListQuery;
}

extension GameX on Game {
  bool get isSwitch2 => platform == 'switch2';
  bool get isPreorder => sourceStatus == 'preorder';
  bool get isUnreleased => sourceStatus == 'unreleased';
  bool get onSale => price?.onSale ?? false;
}

extension GameDetailX on GameDetail {
  Game get asGame => Game(
        nsuid: nsuid,
        title: title,
        publisher: publisher,
        platform: platform,
        category: category,
        releaseDate: releaseDate,
        releaseText: releaseText,
        image: image,
        sourceStatus: sourceStatus,
        salesStatus: salesStatus,
        price: price,
        age: age,
        ageDescriptors: ageDescriptors,
      );
}
