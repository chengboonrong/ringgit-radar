// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Price _$PriceFromJson(Map<String, dynamic> json) => _Price(
  currency: json['currency'] as String,
  regularMinor: (json['regular_minor'] as num).toInt(),
  currentMinor: (json['current_minor'] as num).toInt(),
  onSale: json['on_sale'] as bool,
  discountMinor: (json['discount_minor'] as num?)?.toInt(),
  percentOff: (json['percent_off'] as num?)?.toInt() ?? 0,
  savedMinor: (json['saved_minor'] as num?)?.toInt() ?? 0,
  discountStart: json['discount_start'] == null
      ? null
      : DateTime.parse(json['discount_start'] as String),
  discountEnd: json['discount_end'] == null
      ? null
      : DateTime.parse(json['discount_end'] as String),
  checkedAt: json['checked_at'] == null
      ? null
      : DateTime.parse(json['checked_at'] as String),
);

Map<String, dynamic> _$PriceToJson(_Price instance) => <String, dynamic>{
  'currency': instance.currency,
  'regular_minor': instance.regularMinor,
  'current_minor': instance.currentMinor,
  'on_sale': instance.onSale,
  'discount_minor': instance.discountMinor,
  'percent_off': instance.percentOff,
  'saved_minor': instance.savedMinor,
  'discount_start': instance.discountStart?.toIso8601String(),
  'discount_end': instance.discountEnd?.toIso8601String(),
  'checked_at': instance.checkedAt?.toIso8601String(),
};

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
  nsuid: json['nsuid'] as String,
  title: json['title'] as String,
  publisher: json['publisher'] as String,
  platform: json['platform'] as String,
  category: json['category'] as String,
  releaseDate: json['release_date'] as String?,
  releaseText: json['release_text'] as String? ?? '',
  image: json['image'] as String? ?? '',
  sourceStatus: json['source_status'] as String? ?? '',
  salesStatus: json['sales_status'] as String? ?? '',
  price: json['price'] == null
      ? null
      : Price.fromJson(json['price'] as Map<String, dynamic>),
  rank: (json['rank'] as num?)?.toInt(),
  age: (json['age'] as num?)?.toInt(),
  ageDescriptors: (json['age_descriptors'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
  'nsuid': instance.nsuid,
  'title': instance.title,
  'publisher': instance.publisher,
  'platform': instance.platform,
  'category': instance.category,
  'release_date': instance.releaseDate,
  'release_text': instance.releaseText,
  'image': instance.image,
  'source_status': instance.sourceStatus,
  'sales_status': instance.salesStatus,
  'price': instance.price?.toJson(),
  'rank': instance.rank,
  'age': instance.age,
  'age_descriptors': instance.ageDescriptors,
};

_GamePage _$GamePageFromJson(Map<String, dynamic> json) => _GamePage(
  items: (json['items'] as List<dynamic>)
      .map((e) => Game.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$GamePageToJson(_GamePage instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'page': instance.page,
};

_Highlights _$HighlightsFromJson(Map<String, dynamic> json) => _Highlights(
  topSavings:
      (json['top_savings'] as List<dynamic>?)
          ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  endingSoon:
      (json['ending_soon'] as List<dynamic>?)
          ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  newSales:
      (json['new_sales'] as List<dynamic>?)
          ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  recent:
      (json['recent'] as List<dynamic>?)
          ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$HighlightsToJson(_Highlights instance) =>
    <String, dynamic>{
      'top_savings': instance.topSavings.map((e) => e.toJson()).toList(),
      'ending_soon': instance.endingSoon.map((e) => e.toJson()).toList(),
      'new_sales': instance.newSales.map((e) => e.toJson()).toList(),
      'recent': instance.recent.map((e) => e.toJson()).toList(),
    };

_HistoryPoint _$HistoryPointFromJson(Map<String, dynamic> json) =>
    _HistoryPoint(
      observedAt: DateTime.parse(json['observed_at'] as String),
      regularMinor: (json['regular_minor'] as num).toInt(),
      priceMinor: (json['price_minor'] as num).toInt(),
      discountMinor: (json['discount_minor'] as num?)?.toInt(),
      discountStart: json['discount_start'] == null
          ? null
          : DateTime.parse(json['discount_start'] as String),
      discountEnd: json['discount_end'] == null
          ? null
          : DateTime.parse(json['discount_end'] as String),
    );

Map<String, dynamic> _$HistoryPointToJson(_HistoryPoint instance) =>
    <String, dynamic>{
      'observed_at': instance.observedAt.toIso8601String(),
      'regular_minor': instance.regularMinor,
      'price_minor': instance.priceMinor,
      'discount_minor': instance.discountMinor,
      'discount_start': instance.discountStart?.toIso8601String(),
      'discount_end': instance.discountEnd?.toIso8601String(),
    };

_Lowest _$LowestFromJson(Map<String, dynamic> json) => _Lowest(
  priceMinor: (json['price_minor'] as num).toInt(),
  since: DateTime.parse(json['since'] as String),
  isSale: json['is_sale'] as bool,
);

Map<String, dynamic> _$LowestToJson(_Lowest instance) => <String, dynamic>{
  'price_minor': instance.priceMinor,
  'since': instance.since.toIso8601String(),
  'is_sale': instance.isSale,
};

_GameDetail _$GameDetailFromJson(Map<String, dynamic> json) => _GameDetail(
  nsuid: json['nsuid'] as String,
  title: json['title'] as String,
  publisher: json['publisher'] as String,
  platform: json['platform'] as String,
  category: json['category'] as String,
  releaseDate: json['release_date'] as String?,
  releaseText: json['release_text'] as String? ?? '',
  image: json['image'] as String? ?? '',
  sourceStatus: json['source_status'] as String? ?? '',
  salesStatus: json['sales_status'] as String? ?? '',
  price: json['price'] == null
      ? null
      : Price.fromJson(json['price'] as Map<String, dynamic>),
  screenshots:
      (json['screenshots'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  dcolors:
      (json['dcolors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  description: json['description'] as String? ?? '',
  tagline: json['tagline'] as String? ?? '',
  players: json['players'] as String? ?? '',
  history:
      (json['history'] as List<dynamic>?)
          ?.map((e) => HistoryPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  firstObservedAt: json['first_observed_at'] == null
      ? null
      : DateTime.parse(json['first_observed_at'] as String),
  lowest: json['lowest'] == null
      ? null
      : Lowest.fromJson(json['lowest'] as Map<String, dynamic>),
  addons:
      (json['addons'] as List<dynamic>?)
          ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  age: (json['age'] as num?)?.toInt(),
  ageDescriptors: (json['age_descriptors'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GameDetailToJson(_GameDetail instance) =>
    <String, dynamic>{
      'nsuid': instance.nsuid,
      'title': instance.title,
      'publisher': instance.publisher,
      'platform': instance.platform,
      'category': instance.category,
      'release_date': instance.releaseDate,
      'release_text': instance.releaseText,
      'image': instance.image,
      'source_status': instance.sourceStatus,
      'sales_status': instance.salesStatus,
      'price': instance.price?.toJson(),
      'screenshots': instance.screenshots,
      'dcolors': instance.dcolors,
      'genres': instance.genres,
      'description': instance.description,
      'tagline': instance.tagline,
      'players': instance.players,
      'history': instance.history.map((e) => e.toJson()).toList(),
      'first_observed_at': instance.firstObservedAt?.toIso8601String(),
      'lowest': instance.lowest?.toJson(),
      'addons': instance.addons.map((e) => e.toJson()).toList(),
      'age': instance.age,
      'age_descriptors': instance.ageDescriptors,
    };

_GenreCount _$GenreCountFromJson(Map<String, dynamic> json) => _GenreCount(
  name: json['name'] as String,
  count: (json['count'] as num).toInt(),
  cover: json['cover'] as String? ?? '',
);

Map<String, dynamic> _$GenreCountToJson(_GenreCount instance) =>
    <String, dynamic>{
      'name': instance.name,
      'count': instance.count,
      'cover': instance.cover,
    };

_PriceStatus _$PriceStatusFromJson(Map<String, dynamic> json) => _PriceStatus(
  lastRunAt: json['last_run_at'] == null
      ? null
      : DateTime.parse(json['last_run_at'] as String),
  productCount: (json['product_count'] as num?)?.toInt() ?? 0,
  historySince: json['history_since'] == null
      ? null
      : DateTime.parse(json['history_since'] as String),
);

Map<String, dynamic> _$PriceStatusToJson(_PriceStatus instance) =>
    <String, dynamic>{
      'last_run_at': instance.lastRunAt?.toIso8601String(),
      'product_count': instance.productCount,
      'history_since': instance.historySince?.toIso8601String(),
    };
