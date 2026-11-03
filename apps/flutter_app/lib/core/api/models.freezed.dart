// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Price {

 String get currency; int get regularMinor; int get currentMinor; bool get onSale; int? get discountMinor; int get percentOff; int get savedMinor; DateTime? get discountStart; DateTime? get discountEnd; DateTime? get checkedAt;
/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceCopyWith<Price> get copyWith => _$PriceCopyWithImpl<Price>(this as Price, _$identity);

  /// Serializes this Price to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Price&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.regularMinor, regularMinor) || other.regularMinor == regularMinor)&&(identical(other.currentMinor, currentMinor) || other.currentMinor == currentMinor)&&(identical(other.onSale, onSale) || other.onSale == onSale)&&(identical(other.discountMinor, discountMinor) || other.discountMinor == discountMinor)&&(identical(other.percentOff, percentOff) || other.percentOff == percentOff)&&(identical(other.savedMinor, savedMinor) || other.savedMinor == savedMinor)&&(identical(other.discountStart, discountStart) || other.discountStart == discountStart)&&(identical(other.discountEnd, discountEnd) || other.discountEnd == discountEnd)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currency,regularMinor,currentMinor,onSale,discountMinor,percentOff,savedMinor,discountStart,discountEnd,checkedAt);

@override
String toString() {
  return 'Price(currency: $currency, regularMinor: $regularMinor, currentMinor: $currentMinor, onSale: $onSale, discountMinor: $discountMinor, percentOff: $percentOff, savedMinor: $savedMinor, discountStart: $discountStart, discountEnd: $discountEnd, checkedAt: $checkedAt)';
}


}

/// @nodoc
abstract mixin class $PriceCopyWith<$Res>  {
  factory $PriceCopyWith(Price value, $Res Function(Price) _then) = _$PriceCopyWithImpl;
@useResult
$Res call({
 String currency, int regularMinor, int currentMinor, bool onSale, int? discountMinor, int percentOff, int savedMinor, DateTime? discountStart, DateTime? discountEnd, DateTime? checkedAt
});




}
/// @nodoc
class _$PriceCopyWithImpl<$Res>
    implements $PriceCopyWith<$Res> {
  _$PriceCopyWithImpl(this._self, this._then);

  final Price _self;
  final $Res Function(Price) _then;

/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currency = null,Object? regularMinor = null,Object? currentMinor = null,Object? onSale = null,Object? discountMinor = freezed,Object? percentOff = null,Object? savedMinor = null,Object? discountStart = freezed,Object? discountEnd = freezed,Object? checkedAt = freezed,}) {
  return _then(_self.copyWith(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,regularMinor: null == regularMinor ? _self.regularMinor : regularMinor // ignore: cast_nullable_to_non_nullable
as int,currentMinor: null == currentMinor ? _self.currentMinor : currentMinor // ignore: cast_nullable_to_non_nullable
as int,onSale: null == onSale ? _self.onSale : onSale // ignore: cast_nullable_to_non_nullable
as bool,discountMinor: freezed == discountMinor ? _self.discountMinor : discountMinor // ignore: cast_nullable_to_non_nullable
as int?,percentOff: null == percentOff ? _self.percentOff : percentOff // ignore: cast_nullable_to_non_nullable
as int,savedMinor: null == savedMinor ? _self.savedMinor : savedMinor // ignore: cast_nullable_to_non_nullable
as int,discountStart: freezed == discountStart ? _self.discountStart : discountStart // ignore: cast_nullable_to_non_nullable
as DateTime?,discountEnd: freezed == discountEnd ? _self.discountEnd : discountEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Price].
extension PricePatterns on Price {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Price value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Price() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Price value)  $default,){
final _that = this;
switch (_that) {
case _Price():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Price value)?  $default,){
final _that = this;
switch (_that) {
case _Price() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currency,  int regularMinor,  int currentMinor,  bool onSale,  int? discountMinor,  int percentOff,  int savedMinor,  DateTime? discountStart,  DateTime? discountEnd,  DateTime? checkedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Price() when $default != null:
return $default(_that.currency,_that.regularMinor,_that.currentMinor,_that.onSale,_that.discountMinor,_that.percentOff,_that.savedMinor,_that.discountStart,_that.discountEnd,_that.checkedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currency,  int regularMinor,  int currentMinor,  bool onSale,  int? discountMinor,  int percentOff,  int savedMinor,  DateTime? discountStart,  DateTime? discountEnd,  DateTime? checkedAt)  $default,) {final _that = this;
switch (_that) {
case _Price():
return $default(_that.currency,_that.regularMinor,_that.currentMinor,_that.onSale,_that.discountMinor,_that.percentOff,_that.savedMinor,_that.discountStart,_that.discountEnd,_that.checkedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currency,  int regularMinor,  int currentMinor,  bool onSale,  int? discountMinor,  int percentOff,  int savedMinor,  DateTime? discountStart,  DateTime? discountEnd,  DateTime? checkedAt)?  $default,) {final _that = this;
switch (_that) {
case _Price() when $default != null:
return $default(_that.currency,_that.regularMinor,_that.currentMinor,_that.onSale,_that.discountMinor,_that.percentOff,_that.savedMinor,_that.discountStart,_that.discountEnd,_that.checkedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Price implements Price {
  const _Price({required this.currency, required this.regularMinor, required this.currentMinor, required this.onSale, this.discountMinor, this.percentOff = 0, this.savedMinor = 0, this.discountStart, this.discountEnd, this.checkedAt});
  factory _Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);

@override final  String currency;
@override final  int regularMinor;
@override final  int currentMinor;
@override final  bool onSale;
@override final  int? discountMinor;
@override@JsonKey() final  int percentOff;
@override@JsonKey() final  int savedMinor;
@override final  DateTime? discountStart;
@override final  DateTime? discountEnd;
@override final  DateTime? checkedAt;

/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceCopyWith<_Price> get copyWith => __$PriceCopyWithImpl<_Price>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Price&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.regularMinor, regularMinor) || other.regularMinor == regularMinor)&&(identical(other.currentMinor, currentMinor) || other.currentMinor == currentMinor)&&(identical(other.onSale, onSale) || other.onSale == onSale)&&(identical(other.discountMinor, discountMinor) || other.discountMinor == discountMinor)&&(identical(other.percentOff, percentOff) || other.percentOff == percentOff)&&(identical(other.savedMinor, savedMinor) || other.savedMinor == savedMinor)&&(identical(other.discountStart, discountStart) || other.discountStart == discountStart)&&(identical(other.discountEnd, discountEnd) || other.discountEnd == discountEnd)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currency,regularMinor,currentMinor,onSale,discountMinor,percentOff,savedMinor,discountStart,discountEnd,checkedAt);

@override
String toString() {
  return 'Price(currency: $currency, regularMinor: $regularMinor, currentMinor: $currentMinor, onSale: $onSale, discountMinor: $discountMinor, percentOff: $percentOff, savedMinor: $savedMinor, discountStart: $discountStart, discountEnd: $discountEnd, checkedAt: $checkedAt)';
}


}

/// @nodoc
abstract mixin class _$PriceCopyWith<$Res> implements $PriceCopyWith<$Res> {
  factory _$PriceCopyWith(_Price value, $Res Function(_Price) _then) = __$PriceCopyWithImpl;
@override @useResult
$Res call({
 String currency, int regularMinor, int currentMinor, bool onSale, int? discountMinor, int percentOff, int savedMinor, DateTime? discountStart, DateTime? discountEnd, DateTime? checkedAt
});




}
/// @nodoc
class __$PriceCopyWithImpl<$Res>
    implements _$PriceCopyWith<$Res> {
  __$PriceCopyWithImpl(this._self, this._then);

  final _Price _self;
  final $Res Function(_Price) _then;

/// Create a copy of Price
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currency = null,Object? regularMinor = null,Object? currentMinor = null,Object? onSale = null,Object? discountMinor = freezed,Object? percentOff = null,Object? savedMinor = null,Object? discountStart = freezed,Object? discountEnd = freezed,Object? checkedAt = freezed,}) {
  return _then(_Price(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,regularMinor: null == regularMinor ? _self.regularMinor : regularMinor // ignore: cast_nullable_to_non_nullable
as int,currentMinor: null == currentMinor ? _self.currentMinor : currentMinor // ignore: cast_nullable_to_non_nullable
as int,onSale: null == onSale ? _self.onSale : onSale // ignore: cast_nullable_to_non_nullable
as bool,discountMinor: freezed == discountMinor ? _self.discountMinor : discountMinor // ignore: cast_nullable_to_non_nullable
as int?,percentOff: null == percentOff ? _self.percentOff : percentOff // ignore: cast_nullable_to_non_nullable
as int,savedMinor: null == savedMinor ? _self.savedMinor : savedMinor // ignore: cast_nullable_to_non_nullable
as int,discountStart: freezed == discountStart ? _self.discountStart : discountStart // ignore: cast_nullable_to_non_nullable
as DateTime?,discountEnd: freezed == discountEnd ? _self.discountEnd : discountEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Game {

 String get nsuid; String get title; String get publisher; String get platform; String get category; String? get releaseDate; String get releaseText; String get image; String get sourceStatus; String get salesStatus; Price? get price; int? get rank;// UK PEGI from a title match; null means no rating was found, not that the game is unrated-safe
 int? get age; List<String>? get ageDescriptors;
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Game&&(identical(other.nsuid, nsuid) || other.nsuid == nsuid)&&(identical(other.title, title) || other.title == title)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.category, category) || other.category == category)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.releaseText, releaseText) || other.releaseText == releaseText)&&(identical(other.image, image) || other.image == image)&&(identical(other.sourceStatus, sourceStatus) || other.sourceStatus == sourceStatus)&&(identical(other.salesStatus, salesStatus) || other.salesStatus == salesStatus)&&(identical(other.price, price) || other.price == price)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.age, age) || other.age == age)&&const DeepCollectionEquality().equals(other.ageDescriptors, ageDescriptors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nsuid,title,publisher,platform,category,releaseDate,releaseText,image,sourceStatus,salesStatus,price,rank,age,const DeepCollectionEquality().hash(ageDescriptors));

@override
String toString() {
  return 'Game(nsuid: $nsuid, title: $title, publisher: $publisher, platform: $platform, category: $category, releaseDate: $releaseDate, releaseText: $releaseText, image: $image, sourceStatus: $sourceStatus, salesStatus: $salesStatus, price: $price, rank: $rank, age: $age, ageDescriptors: $ageDescriptors)';
}


}

/// @nodoc
abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
 String nsuid, String title, String publisher, String platform, String category, String? releaseDate, String releaseText, String image, String sourceStatus, String salesStatus, Price? price, int? rank, int? age, List<String>? ageDescriptors
});


$PriceCopyWith<$Res>? get price;

}
/// @nodoc
class _$GameCopyWithImpl<$Res>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nsuid = null,Object? title = null,Object? publisher = null,Object? platform = null,Object? category = null,Object? releaseDate = freezed,Object? releaseText = null,Object? image = null,Object? sourceStatus = null,Object? salesStatus = null,Object? price = freezed,Object? rank = freezed,Object? age = freezed,Object? ageDescriptors = freezed,}) {
  return _then(_self.copyWith(
nsuid: null == nsuid ? _self.nsuid : nsuid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,releaseText: null == releaseText ? _self.releaseText : releaseText // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,sourceStatus: null == sourceStatus ? _self.sourceStatus : sourceStatus // ignore: cast_nullable_to_non_nullable
as String,salesStatus: null == salesStatus ? _self.salesStatus : salesStatus // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price?,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,ageDescriptors: freezed == ageDescriptors ? _self.ageDescriptors : ageDescriptors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $PriceCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// Adds pattern-matching-related methods to [Game].
extension GamePatterns on Game {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Game value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Game value)  $default,){
final _that = this;
switch (_that) {
case _Game():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Game value)?  $default,){
final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nsuid,  String title,  String publisher,  String platform,  String category,  String? releaseDate,  String releaseText,  String image,  String sourceStatus,  String salesStatus,  Price? price,  int? rank,  int? age,  List<String>? ageDescriptors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.nsuid,_that.title,_that.publisher,_that.platform,_that.category,_that.releaseDate,_that.releaseText,_that.image,_that.sourceStatus,_that.salesStatus,_that.price,_that.rank,_that.age,_that.ageDescriptors);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nsuid,  String title,  String publisher,  String platform,  String category,  String? releaseDate,  String releaseText,  String image,  String sourceStatus,  String salesStatus,  Price? price,  int? rank,  int? age,  List<String>? ageDescriptors)  $default,) {final _that = this;
switch (_that) {
case _Game():
return $default(_that.nsuid,_that.title,_that.publisher,_that.platform,_that.category,_that.releaseDate,_that.releaseText,_that.image,_that.sourceStatus,_that.salesStatus,_that.price,_that.rank,_that.age,_that.ageDescriptors);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nsuid,  String title,  String publisher,  String platform,  String category,  String? releaseDate,  String releaseText,  String image,  String sourceStatus,  String salesStatus,  Price? price,  int? rank,  int? age,  List<String>? ageDescriptors)?  $default,) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.nsuid,_that.title,_that.publisher,_that.platform,_that.category,_that.releaseDate,_that.releaseText,_that.image,_that.sourceStatus,_that.salesStatus,_that.price,_that.rank,_that.age,_that.ageDescriptors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Game implements Game {
  const _Game({required this.nsuid, required this.title, required this.publisher, required this.platform, required this.category, this.releaseDate, this.releaseText = '', this.image = '', this.sourceStatus = '', this.salesStatus = '', this.price, this.rank, this.age, final  List<String>? ageDescriptors}): _ageDescriptors = ageDescriptors;
  factory _Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

@override final  String nsuid;
@override final  String title;
@override final  String publisher;
@override final  String platform;
@override final  String category;
@override final  String? releaseDate;
@override@JsonKey() final  String releaseText;
@override@JsonKey() final  String image;
@override@JsonKey() final  String sourceStatus;
@override@JsonKey() final  String salesStatus;
@override final  Price? price;
@override final  int? rank;
// UK PEGI from a title match; null means no rating was found, not that the game is unrated-safe
@override final  int? age;
 final  List<String>? _ageDescriptors;
@override List<String>? get ageDescriptors {
  final value = _ageDescriptors;
  if (value == null) return null;
  if (_ageDescriptors is EqualUnmodifiableListView) return _ageDescriptors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameCopyWith<_Game> get copyWith => __$GameCopyWithImpl<_Game>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Game&&(identical(other.nsuid, nsuid) || other.nsuid == nsuid)&&(identical(other.title, title) || other.title == title)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.category, category) || other.category == category)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.releaseText, releaseText) || other.releaseText == releaseText)&&(identical(other.image, image) || other.image == image)&&(identical(other.sourceStatus, sourceStatus) || other.sourceStatus == sourceStatus)&&(identical(other.salesStatus, salesStatus) || other.salesStatus == salesStatus)&&(identical(other.price, price) || other.price == price)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.age, age) || other.age == age)&&const DeepCollectionEquality().equals(other._ageDescriptors, _ageDescriptors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nsuid,title,publisher,platform,category,releaseDate,releaseText,image,sourceStatus,salesStatus,price,rank,age,const DeepCollectionEquality().hash(_ageDescriptors));

@override
String toString() {
  return 'Game(nsuid: $nsuid, title: $title, publisher: $publisher, platform: $platform, category: $category, releaseDate: $releaseDate, releaseText: $releaseText, image: $image, sourceStatus: $sourceStatus, salesStatus: $salesStatus, price: $price, rank: $rank, age: $age, ageDescriptors: $ageDescriptors)';
}


}

/// @nodoc
abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) = __$GameCopyWithImpl;
@override @useResult
$Res call({
 String nsuid, String title, String publisher, String platform, String category, String? releaseDate, String releaseText, String image, String sourceStatus, String salesStatus, Price? price, int? rank, int? age, List<String>? ageDescriptors
});


@override $PriceCopyWith<$Res>? get price;

}
/// @nodoc
class __$GameCopyWithImpl<$Res>
    implements _$GameCopyWith<$Res> {
  __$GameCopyWithImpl(this._self, this._then);

  final _Game _self;
  final $Res Function(_Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nsuid = null,Object? title = null,Object? publisher = null,Object? platform = null,Object? category = null,Object? releaseDate = freezed,Object? releaseText = null,Object? image = null,Object? sourceStatus = null,Object? salesStatus = null,Object? price = freezed,Object? rank = freezed,Object? age = freezed,Object? ageDescriptors = freezed,}) {
  return _then(_Game(
nsuid: null == nsuid ? _self.nsuid : nsuid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,releaseText: null == releaseText ? _self.releaseText : releaseText // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,sourceStatus: null == sourceStatus ? _self.sourceStatus : sourceStatus // ignore: cast_nullable_to_non_nullable
as String,salesStatus: null == salesStatus ? _self.salesStatus : salesStatus // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price?,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,ageDescriptors: freezed == ageDescriptors ? _self._ageDescriptors : ageDescriptors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $PriceCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// @nodoc
mixin _$GamePage {

 List<Game> get items; int get total; int get page;
/// Create a copy of GamePage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePageCopyWith<GamePage> get copyWith => _$GamePageCopyWithImpl<GamePage>(this as GamePage, _$identity);

  /// Serializes this GamePage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page);

@override
String toString() {
  return 'GamePage(items: $items, total: $total, page: $page)';
}


}

/// @nodoc
abstract mixin class $GamePageCopyWith<$Res>  {
  factory $GamePageCopyWith(GamePage value, $Res Function(GamePage) _then) = _$GamePageCopyWithImpl;
@useResult
$Res call({
 List<Game> items, int total, int page
});




}
/// @nodoc
class _$GamePageCopyWithImpl<$Res>
    implements $GamePageCopyWith<$Res> {
  _$GamePageCopyWithImpl(this._self, this._then);

  final GamePage _self;
  final $Res Function(GamePage) _then;

/// Create a copy of GamePage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Game>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GamePage].
extension GamePagePatterns on GamePage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GamePage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GamePage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GamePage value)  $default,){
final _that = this;
switch (_that) {
case _GamePage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GamePage value)?  $default,){
final _that = this;
switch (_that) {
case _GamePage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Game> items,  int total,  int page)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GamePage() when $default != null:
return $default(_that.items,_that.total,_that.page);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Game> items,  int total,  int page)  $default,) {final _that = this;
switch (_that) {
case _GamePage():
return $default(_that.items,_that.total,_that.page);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Game> items,  int total,  int page)?  $default,) {final _that = this;
switch (_that) {
case _GamePage() when $default != null:
return $default(_that.items,_that.total,_that.page);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GamePage implements GamePage {
  const _GamePage({required final  List<Game> items, required this.total, this.page = 1}): _items = items;
  factory _GamePage.fromJson(Map<String, dynamic> json) => _$GamePageFromJson(json);

 final  List<Game> _items;
@override List<Game> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override@JsonKey() final  int page;

/// Create a copy of GamePage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GamePageCopyWith<_GamePage> get copyWith => __$GamePageCopyWithImpl<_GamePage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GamePageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GamePage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page);

@override
String toString() {
  return 'GamePage(items: $items, total: $total, page: $page)';
}


}

/// @nodoc
abstract mixin class _$GamePageCopyWith<$Res> implements $GamePageCopyWith<$Res> {
  factory _$GamePageCopyWith(_GamePage value, $Res Function(_GamePage) _then) = __$GamePageCopyWithImpl;
@override @useResult
$Res call({
 List<Game> items, int total, int page
});




}
/// @nodoc
class __$GamePageCopyWithImpl<$Res>
    implements _$GamePageCopyWith<$Res> {
  __$GamePageCopyWithImpl(this._self, this._then);

  final _GamePage _self;
  final $Res Function(_GamePage) _then;

/// Create a copy of GamePage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,}) {
  return _then(_GamePage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Game>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Highlights {

 List<Game> get topSavings; List<Game> get endingSoon; List<Game> get newSales; List<Game> get recent;
/// Create a copy of Highlights
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HighlightsCopyWith<Highlights> get copyWith => _$HighlightsCopyWithImpl<Highlights>(this as Highlights, _$identity);

  /// Serializes this Highlights to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Highlights&&const DeepCollectionEquality().equals(other.topSavings, topSavings)&&const DeepCollectionEquality().equals(other.endingSoon, endingSoon)&&const DeepCollectionEquality().equals(other.newSales, newSales)&&const DeepCollectionEquality().equals(other.recent, recent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(topSavings),const DeepCollectionEquality().hash(endingSoon),const DeepCollectionEquality().hash(newSales),const DeepCollectionEquality().hash(recent));

@override
String toString() {
  return 'Highlights(topSavings: $topSavings, endingSoon: $endingSoon, newSales: $newSales, recent: $recent)';
}


}

/// @nodoc
abstract mixin class $HighlightsCopyWith<$Res>  {
  factory $HighlightsCopyWith(Highlights value, $Res Function(Highlights) _then) = _$HighlightsCopyWithImpl;
@useResult
$Res call({
 List<Game> topSavings, List<Game> endingSoon, List<Game> newSales, List<Game> recent
});




}
/// @nodoc
class _$HighlightsCopyWithImpl<$Res>
    implements $HighlightsCopyWith<$Res> {
  _$HighlightsCopyWithImpl(this._self, this._then);

  final Highlights _self;
  final $Res Function(Highlights) _then;

/// Create a copy of Highlights
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topSavings = null,Object? endingSoon = null,Object? newSales = null,Object? recent = null,}) {
  return _then(_self.copyWith(
topSavings: null == topSavings ? _self.topSavings : topSavings // ignore: cast_nullable_to_non_nullable
as List<Game>,endingSoon: null == endingSoon ? _self.endingSoon : endingSoon // ignore: cast_nullable_to_non_nullable
as List<Game>,newSales: null == newSales ? _self.newSales : newSales // ignore: cast_nullable_to_non_nullable
as List<Game>,recent: null == recent ? _self.recent : recent // ignore: cast_nullable_to_non_nullable
as List<Game>,
  ));
}

}


/// Adds pattern-matching-related methods to [Highlights].
extension HighlightsPatterns on Highlights {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Highlights value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Highlights() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Highlights value)  $default,){
final _that = this;
switch (_that) {
case _Highlights():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Highlights value)?  $default,){
final _that = this;
switch (_that) {
case _Highlights() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Game> topSavings,  List<Game> endingSoon,  List<Game> newSales,  List<Game> recent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Highlights() when $default != null:
return $default(_that.topSavings,_that.endingSoon,_that.newSales,_that.recent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Game> topSavings,  List<Game> endingSoon,  List<Game> newSales,  List<Game> recent)  $default,) {final _that = this;
switch (_that) {
case _Highlights():
return $default(_that.topSavings,_that.endingSoon,_that.newSales,_that.recent);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Game> topSavings,  List<Game> endingSoon,  List<Game> newSales,  List<Game> recent)?  $default,) {final _that = this;
switch (_that) {
case _Highlights() when $default != null:
return $default(_that.topSavings,_that.endingSoon,_that.newSales,_that.recent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Highlights implements Highlights {
  const _Highlights({final  List<Game> topSavings = const [], final  List<Game> endingSoon = const [], final  List<Game> newSales = const [], final  List<Game> recent = const []}): _topSavings = topSavings,_endingSoon = endingSoon,_newSales = newSales,_recent = recent;
  factory _Highlights.fromJson(Map<String, dynamic> json) => _$HighlightsFromJson(json);

 final  List<Game> _topSavings;
@override@JsonKey() List<Game> get topSavings {
  if (_topSavings is EqualUnmodifiableListView) return _topSavings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topSavings);
}

 final  List<Game> _endingSoon;
@override@JsonKey() List<Game> get endingSoon {
  if (_endingSoon is EqualUnmodifiableListView) return _endingSoon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_endingSoon);
}

 final  List<Game> _newSales;
@override@JsonKey() List<Game> get newSales {
  if (_newSales is EqualUnmodifiableListView) return _newSales;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_newSales);
}

 final  List<Game> _recent;
@override@JsonKey() List<Game> get recent {
  if (_recent is EqualUnmodifiableListView) return _recent;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recent);
}


/// Create a copy of Highlights
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HighlightsCopyWith<_Highlights> get copyWith => __$HighlightsCopyWithImpl<_Highlights>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HighlightsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Highlights&&const DeepCollectionEquality().equals(other._topSavings, _topSavings)&&const DeepCollectionEquality().equals(other._endingSoon, _endingSoon)&&const DeepCollectionEquality().equals(other._newSales, _newSales)&&const DeepCollectionEquality().equals(other._recent, _recent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_topSavings),const DeepCollectionEquality().hash(_endingSoon),const DeepCollectionEquality().hash(_newSales),const DeepCollectionEquality().hash(_recent));

@override
String toString() {
  return 'Highlights(topSavings: $topSavings, endingSoon: $endingSoon, newSales: $newSales, recent: $recent)';
}


}

/// @nodoc
abstract mixin class _$HighlightsCopyWith<$Res> implements $HighlightsCopyWith<$Res> {
  factory _$HighlightsCopyWith(_Highlights value, $Res Function(_Highlights) _then) = __$HighlightsCopyWithImpl;
@override @useResult
$Res call({
 List<Game> topSavings, List<Game> endingSoon, List<Game> newSales, List<Game> recent
});




}
/// @nodoc
class __$HighlightsCopyWithImpl<$Res>
    implements _$HighlightsCopyWith<$Res> {
  __$HighlightsCopyWithImpl(this._self, this._then);

  final _Highlights _self;
  final $Res Function(_Highlights) _then;

/// Create a copy of Highlights
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topSavings = null,Object? endingSoon = null,Object? newSales = null,Object? recent = null,}) {
  return _then(_Highlights(
topSavings: null == topSavings ? _self._topSavings : topSavings // ignore: cast_nullable_to_non_nullable
as List<Game>,endingSoon: null == endingSoon ? _self._endingSoon : endingSoon // ignore: cast_nullable_to_non_nullable
as List<Game>,newSales: null == newSales ? _self._newSales : newSales // ignore: cast_nullable_to_non_nullable
as List<Game>,recent: null == recent ? _self._recent : recent // ignore: cast_nullable_to_non_nullable
as List<Game>,
  ));
}


}


/// @nodoc
mixin _$HistoryPoint {

 DateTime get observedAt; int get regularMinor; int get priceMinor; int? get discountMinor; DateTime? get discountStart; DateTime? get discountEnd;
/// Create a copy of HistoryPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryPointCopyWith<HistoryPoint> get copyWith => _$HistoryPointCopyWithImpl<HistoryPoint>(this as HistoryPoint, _$identity);

  /// Serializes this HistoryPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryPoint&&(identical(other.observedAt, observedAt) || other.observedAt == observedAt)&&(identical(other.regularMinor, regularMinor) || other.regularMinor == regularMinor)&&(identical(other.priceMinor, priceMinor) || other.priceMinor == priceMinor)&&(identical(other.discountMinor, discountMinor) || other.discountMinor == discountMinor)&&(identical(other.discountStart, discountStart) || other.discountStart == discountStart)&&(identical(other.discountEnd, discountEnd) || other.discountEnd == discountEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,observedAt,regularMinor,priceMinor,discountMinor,discountStart,discountEnd);

@override
String toString() {
  return 'HistoryPoint(observedAt: $observedAt, regularMinor: $regularMinor, priceMinor: $priceMinor, discountMinor: $discountMinor, discountStart: $discountStart, discountEnd: $discountEnd)';
}


}

/// @nodoc
abstract mixin class $HistoryPointCopyWith<$Res>  {
  factory $HistoryPointCopyWith(HistoryPoint value, $Res Function(HistoryPoint) _then) = _$HistoryPointCopyWithImpl;
@useResult
$Res call({
 DateTime observedAt, int regularMinor, int priceMinor, int? discountMinor, DateTime? discountStart, DateTime? discountEnd
});




}
/// @nodoc
class _$HistoryPointCopyWithImpl<$Res>
    implements $HistoryPointCopyWith<$Res> {
  _$HistoryPointCopyWithImpl(this._self, this._then);

  final HistoryPoint _self;
  final $Res Function(HistoryPoint) _then;

/// Create a copy of HistoryPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? observedAt = null,Object? regularMinor = null,Object? priceMinor = null,Object? discountMinor = freezed,Object? discountStart = freezed,Object? discountEnd = freezed,}) {
  return _then(_self.copyWith(
observedAt: null == observedAt ? _self.observedAt : observedAt // ignore: cast_nullable_to_non_nullable
as DateTime,regularMinor: null == regularMinor ? _self.regularMinor : regularMinor // ignore: cast_nullable_to_non_nullable
as int,priceMinor: null == priceMinor ? _self.priceMinor : priceMinor // ignore: cast_nullable_to_non_nullable
as int,discountMinor: freezed == discountMinor ? _self.discountMinor : discountMinor // ignore: cast_nullable_to_non_nullable
as int?,discountStart: freezed == discountStart ? _self.discountStart : discountStart // ignore: cast_nullable_to_non_nullable
as DateTime?,discountEnd: freezed == discountEnd ? _self.discountEnd : discountEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryPoint].
extension HistoryPointPatterns on HistoryPoint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryPoint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryPoint value)  $default,){
final _that = this;
switch (_that) {
case _HistoryPoint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryPoint value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryPoint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime observedAt,  int regularMinor,  int priceMinor,  int? discountMinor,  DateTime? discountStart,  DateTime? discountEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryPoint() when $default != null:
return $default(_that.observedAt,_that.regularMinor,_that.priceMinor,_that.discountMinor,_that.discountStart,_that.discountEnd);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime observedAt,  int regularMinor,  int priceMinor,  int? discountMinor,  DateTime? discountStart,  DateTime? discountEnd)  $default,) {final _that = this;
switch (_that) {
case _HistoryPoint():
return $default(_that.observedAt,_that.regularMinor,_that.priceMinor,_that.discountMinor,_that.discountStart,_that.discountEnd);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime observedAt,  int regularMinor,  int priceMinor,  int? discountMinor,  DateTime? discountStart,  DateTime? discountEnd)?  $default,) {final _that = this;
switch (_that) {
case _HistoryPoint() when $default != null:
return $default(_that.observedAt,_that.regularMinor,_that.priceMinor,_that.discountMinor,_that.discountStart,_that.discountEnd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoryPoint implements HistoryPoint {
  const _HistoryPoint({required this.observedAt, required this.regularMinor, required this.priceMinor, this.discountMinor, this.discountStart, this.discountEnd});
  factory _HistoryPoint.fromJson(Map<String, dynamic> json) => _$HistoryPointFromJson(json);

@override final  DateTime observedAt;
@override final  int regularMinor;
@override final  int priceMinor;
@override final  int? discountMinor;
@override final  DateTime? discountStart;
@override final  DateTime? discountEnd;

/// Create a copy of HistoryPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryPointCopyWith<_HistoryPoint> get copyWith => __$HistoryPointCopyWithImpl<_HistoryPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryPoint&&(identical(other.observedAt, observedAt) || other.observedAt == observedAt)&&(identical(other.regularMinor, regularMinor) || other.regularMinor == regularMinor)&&(identical(other.priceMinor, priceMinor) || other.priceMinor == priceMinor)&&(identical(other.discountMinor, discountMinor) || other.discountMinor == discountMinor)&&(identical(other.discountStart, discountStart) || other.discountStart == discountStart)&&(identical(other.discountEnd, discountEnd) || other.discountEnd == discountEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,observedAt,regularMinor,priceMinor,discountMinor,discountStart,discountEnd);

@override
String toString() {
  return 'HistoryPoint(observedAt: $observedAt, regularMinor: $regularMinor, priceMinor: $priceMinor, discountMinor: $discountMinor, discountStart: $discountStart, discountEnd: $discountEnd)';
}


}

/// @nodoc
abstract mixin class _$HistoryPointCopyWith<$Res> implements $HistoryPointCopyWith<$Res> {
  factory _$HistoryPointCopyWith(_HistoryPoint value, $Res Function(_HistoryPoint) _then) = __$HistoryPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime observedAt, int regularMinor, int priceMinor, int? discountMinor, DateTime? discountStart, DateTime? discountEnd
});




}
/// @nodoc
class __$HistoryPointCopyWithImpl<$Res>
    implements _$HistoryPointCopyWith<$Res> {
  __$HistoryPointCopyWithImpl(this._self, this._then);

  final _HistoryPoint _self;
  final $Res Function(_HistoryPoint) _then;

/// Create a copy of HistoryPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? observedAt = null,Object? regularMinor = null,Object? priceMinor = null,Object? discountMinor = freezed,Object? discountStart = freezed,Object? discountEnd = freezed,}) {
  return _then(_HistoryPoint(
observedAt: null == observedAt ? _self.observedAt : observedAt // ignore: cast_nullable_to_non_nullable
as DateTime,regularMinor: null == regularMinor ? _self.regularMinor : regularMinor // ignore: cast_nullable_to_non_nullable
as int,priceMinor: null == priceMinor ? _self.priceMinor : priceMinor // ignore: cast_nullable_to_non_nullable
as int,discountMinor: freezed == discountMinor ? _self.discountMinor : discountMinor // ignore: cast_nullable_to_non_nullable
as int?,discountStart: freezed == discountStart ? _self.discountStart : discountStart // ignore: cast_nullable_to_non_nullable
as DateTime?,discountEnd: freezed == discountEnd ? _self.discountEnd : discountEnd // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Lowest {

 int get priceMinor; DateTime get since; bool get isSale;
/// Create a copy of Lowest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LowestCopyWith<Lowest> get copyWith => _$LowestCopyWithImpl<Lowest>(this as Lowest, _$identity);

  /// Serializes this Lowest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lowest&&(identical(other.priceMinor, priceMinor) || other.priceMinor == priceMinor)&&(identical(other.since, since) || other.since == since)&&(identical(other.isSale, isSale) || other.isSale == isSale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,priceMinor,since,isSale);

@override
String toString() {
  return 'Lowest(priceMinor: $priceMinor, since: $since, isSale: $isSale)';
}


}

/// @nodoc
abstract mixin class $LowestCopyWith<$Res>  {
  factory $LowestCopyWith(Lowest value, $Res Function(Lowest) _then) = _$LowestCopyWithImpl;
@useResult
$Res call({
 int priceMinor, DateTime since, bool isSale
});




}
/// @nodoc
class _$LowestCopyWithImpl<$Res>
    implements $LowestCopyWith<$Res> {
  _$LowestCopyWithImpl(this._self, this._then);

  final Lowest _self;
  final $Res Function(Lowest) _then;

/// Create a copy of Lowest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? priceMinor = null,Object? since = null,Object? isSale = null,}) {
  return _then(_self.copyWith(
priceMinor: null == priceMinor ? _self.priceMinor : priceMinor // ignore: cast_nullable_to_non_nullable
as int,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime,isSale: null == isSale ? _self.isSale : isSale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Lowest].
extension LowestPatterns on Lowest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lowest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lowest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lowest value)  $default,){
final _that = this;
switch (_that) {
case _Lowest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lowest value)?  $default,){
final _that = this;
switch (_that) {
case _Lowest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int priceMinor,  DateTime since,  bool isSale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lowest() when $default != null:
return $default(_that.priceMinor,_that.since,_that.isSale);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int priceMinor,  DateTime since,  bool isSale)  $default,) {final _that = this;
switch (_that) {
case _Lowest():
return $default(_that.priceMinor,_that.since,_that.isSale);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int priceMinor,  DateTime since,  bool isSale)?  $default,) {final _that = this;
switch (_that) {
case _Lowest() when $default != null:
return $default(_that.priceMinor,_that.since,_that.isSale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Lowest implements Lowest {
  const _Lowest({required this.priceMinor, required this.since, required this.isSale});
  factory _Lowest.fromJson(Map<String, dynamic> json) => _$LowestFromJson(json);

@override final  int priceMinor;
@override final  DateTime since;
@override final  bool isSale;

/// Create a copy of Lowest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LowestCopyWith<_Lowest> get copyWith => __$LowestCopyWithImpl<_Lowest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LowestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lowest&&(identical(other.priceMinor, priceMinor) || other.priceMinor == priceMinor)&&(identical(other.since, since) || other.since == since)&&(identical(other.isSale, isSale) || other.isSale == isSale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,priceMinor,since,isSale);

@override
String toString() {
  return 'Lowest(priceMinor: $priceMinor, since: $since, isSale: $isSale)';
}


}

/// @nodoc
abstract mixin class _$LowestCopyWith<$Res> implements $LowestCopyWith<$Res> {
  factory _$LowestCopyWith(_Lowest value, $Res Function(_Lowest) _then) = __$LowestCopyWithImpl;
@override @useResult
$Res call({
 int priceMinor, DateTime since, bool isSale
});




}
/// @nodoc
class __$LowestCopyWithImpl<$Res>
    implements _$LowestCopyWith<$Res> {
  __$LowestCopyWithImpl(this._self, this._then);

  final _Lowest _self;
  final $Res Function(_Lowest) _then;

/// Create a copy of Lowest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? priceMinor = null,Object? since = null,Object? isSale = null,}) {
  return _then(_Lowest(
priceMinor: null == priceMinor ? _self.priceMinor : priceMinor // ignore: cast_nullable_to_non_nullable
as int,since: null == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime,isSale: null == isSale ? _self.isSale : isSale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$GameDetail {

 String get nsuid; String get title; String get publisher; String get platform; String get category; String? get releaseDate; String get releaseText; String get image; String get sourceStatus; String get salesStatus; Price? get price; List<String> get screenshots; List<String> get dcolors; List<String> get genres; String get description; String get tagline; String get players; List<HistoryPoint> get history; DateTime? get firstObservedAt; Lowest? get lowest; List<Game> get addons; int? get age; List<String>? get ageDescriptors;
/// Create a copy of GameDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameDetailCopyWith<GameDetail> get copyWith => _$GameDetailCopyWithImpl<GameDetail>(this as GameDetail, _$identity);

  /// Serializes this GameDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameDetail&&(identical(other.nsuid, nsuid) || other.nsuid == nsuid)&&(identical(other.title, title) || other.title == title)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.category, category) || other.category == category)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.releaseText, releaseText) || other.releaseText == releaseText)&&(identical(other.image, image) || other.image == image)&&(identical(other.sourceStatus, sourceStatus) || other.sourceStatus == sourceStatus)&&(identical(other.salesStatus, salesStatus) || other.salesStatus == salesStatus)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.screenshots, screenshots)&&const DeepCollectionEquality().equals(other.dcolors, dcolors)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.description, description) || other.description == description)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.players, players) || other.players == players)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.firstObservedAt, firstObservedAt) || other.firstObservedAt == firstObservedAt)&&(identical(other.lowest, lowest) || other.lowest == lowest)&&const DeepCollectionEquality().equals(other.addons, addons)&&(identical(other.age, age) || other.age == age)&&const DeepCollectionEquality().equals(other.ageDescriptors, ageDescriptors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,nsuid,title,publisher,platform,category,releaseDate,releaseText,image,sourceStatus,salesStatus,price,const DeepCollectionEquality().hash(screenshots),const DeepCollectionEquality().hash(dcolors),const DeepCollectionEquality().hash(genres),description,tagline,players,const DeepCollectionEquality().hash(history),firstObservedAt,lowest,const DeepCollectionEquality().hash(addons),age,const DeepCollectionEquality().hash(ageDescriptors)]);

@override
String toString() {
  return 'GameDetail(nsuid: $nsuid, title: $title, publisher: $publisher, platform: $platform, category: $category, releaseDate: $releaseDate, releaseText: $releaseText, image: $image, sourceStatus: $sourceStatus, salesStatus: $salesStatus, price: $price, screenshots: $screenshots, dcolors: $dcolors, genres: $genres, description: $description, tagline: $tagline, players: $players, history: $history, firstObservedAt: $firstObservedAt, lowest: $lowest, addons: $addons, age: $age, ageDescriptors: $ageDescriptors)';
}


}

/// @nodoc
abstract mixin class $GameDetailCopyWith<$Res>  {
  factory $GameDetailCopyWith(GameDetail value, $Res Function(GameDetail) _then) = _$GameDetailCopyWithImpl;
@useResult
$Res call({
 String nsuid, String title, String publisher, String platform, String category, String? releaseDate, String releaseText, String image, String sourceStatus, String salesStatus, Price? price, List<String> screenshots, List<String> dcolors, List<String> genres, String description, String tagline, String players, List<HistoryPoint> history, DateTime? firstObservedAt, Lowest? lowest, List<Game> addons, int? age, List<String>? ageDescriptors
});


$PriceCopyWith<$Res>? get price;$LowestCopyWith<$Res>? get lowest;

}
/// @nodoc
class _$GameDetailCopyWithImpl<$Res>
    implements $GameDetailCopyWith<$Res> {
  _$GameDetailCopyWithImpl(this._self, this._then);

  final GameDetail _self;
  final $Res Function(GameDetail) _then;

/// Create a copy of GameDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nsuid = null,Object? title = null,Object? publisher = null,Object? platform = null,Object? category = null,Object? releaseDate = freezed,Object? releaseText = null,Object? image = null,Object? sourceStatus = null,Object? salesStatus = null,Object? price = freezed,Object? screenshots = null,Object? dcolors = null,Object? genres = null,Object? description = null,Object? tagline = null,Object? players = null,Object? history = null,Object? firstObservedAt = freezed,Object? lowest = freezed,Object? addons = null,Object? age = freezed,Object? ageDescriptors = freezed,}) {
  return _then(_self.copyWith(
nsuid: null == nsuid ? _self.nsuid : nsuid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,releaseText: null == releaseText ? _self.releaseText : releaseText // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,sourceStatus: null == sourceStatus ? _self.sourceStatus : sourceStatus // ignore: cast_nullable_to_non_nullable
as String,salesStatus: null == salesStatus ? _self.salesStatus : salesStatus // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price?,screenshots: null == screenshots ? _self.screenshots : screenshots // ignore: cast_nullable_to_non_nullable
as List<String>,dcolors: null == dcolors ? _self.dcolors : dcolors // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,tagline: null == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as String,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<HistoryPoint>,firstObservedAt: freezed == firstObservedAt ? _self.firstObservedAt : firstObservedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lowest: freezed == lowest ? _self.lowest : lowest // ignore: cast_nullable_to_non_nullable
as Lowest?,addons: null == addons ? _self.addons : addons // ignore: cast_nullable_to_non_nullable
as List<Game>,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,ageDescriptors: freezed == ageDescriptors ? _self.ageDescriptors : ageDescriptors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}
/// Create a copy of GameDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $PriceCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of GameDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LowestCopyWith<$Res>? get lowest {
    if (_self.lowest == null) {
    return null;
  }

  return $LowestCopyWith<$Res>(_self.lowest!, (value) {
    return _then(_self.copyWith(lowest: value));
  });
}
}


/// Adds pattern-matching-related methods to [GameDetail].
extension GameDetailPatterns on GameDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameDetail value)  $default,){
final _that = this;
switch (_that) {
case _GameDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameDetail value)?  $default,){
final _that = this;
switch (_that) {
case _GameDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nsuid,  String title,  String publisher,  String platform,  String category,  String? releaseDate,  String releaseText,  String image,  String sourceStatus,  String salesStatus,  Price? price,  List<String> screenshots,  List<String> dcolors,  List<String> genres,  String description,  String tagline,  String players,  List<HistoryPoint> history,  DateTime? firstObservedAt,  Lowest? lowest,  List<Game> addons,  int? age,  List<String>? ageDescriptors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameDetail() when $default != null:
return $default(_that.nsuid,_that.title,_that.publisher,_that.platform,_that.category,_that.releaseDate,_that.releaseText,_that.image,_that.sourceStatus,_that.salesStatus,_that.price,_that.screenshots,_that.dcolors,_that.genres,_that.description,_that.tagline,_that.players,_that.history,_that.firstObservedAt,_that.lowest,_that.addons,_that.age,_that.ageDescriptors);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nsuid,  String title,  String publisher,  String platform,  String category,  String? releaseDate,  String releaseText,  String image,  String sourceStatus,  String salesStatus,  Price? price,  List<String> screenshots,  List<String> dcolors,  List<String> genres,  String description,  String tagline,  String players,  List<HistoryPoint> history,  DateTime? firstObservedAt,  Lowest? lowest,  List<Game> addons,  int? age,  List<String>? ageDescriptors)  $default,) {final _that = this;
switch (_that) {
case _GameDetail():
return $default(_that.nsuid,_that.title,_that.publisher,_that.platform,_that.category,_that.releaseDate,_that.releaseText,_that.image,_that.sourceStatus,_that.salesStatus,_that.price,_that.screenshots,_that.dcolors,_that.genres,_that.description,_that.tagline,_that.players,_that.history,_that.firstObservedAt,_that.lowest,_that.addons,_that.age,_that.ageDescriptors);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nsuid,  String title,  String publisher,  String platform,  String category,  String? releaseDate,  String releaseText,  String image,  String sourceStatus,  String salesStatus,  Price? price,  List<String> screenshots,  List<String> dcolors,  List<String> genres,  String description,  String tagline,  String players,  List<HistoryPoint> history,  DateTime? firstObservedAt,  Lowest? lowest,  List<Game> addons,  int? age,  List<String>? ageDescriptors)?  $default,) {final _that = this;
switch (_that) {
case _GameDetail() when $default != null:
return $default(_that.nsuid,_that.title,_that.publisher,_that.platform,_that.category,_that.releaseDate,_that.releaseText,_that.image,_that.sourceStatus,_that.salesStatus,_that.price,_that.screenshots,_that.dcolors,_that.genres,_that.description,_that.tagline,_that.players,_that.history,_that.firstObservedAt,_that.lowest,_that.addons,_that.age,_that.ageDescriptors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameDetail implements GameDetail {
  const _GameDetail({required this.nsuid, required this.title, required this.publisher, required this.platform, required this.category, this.releaseDate, this.releaseText = '', this.image = '', this.sourceStatus = '', this.salesStatus = '', this.price, final  List<String> screenshots = const [], final  List<String> dcolors = const [], final  List<String> genres = const [], this.description = '', this.tagline = '', this.players = '', final  List<HistoryPoint> history = const [], this.firstObservedAt, this.lowest, final  List<Game> addons = const [], this.age, final  List<String>? ageDescriptors}): _screenshots = screenshots,_dcolors = dcolors,_genres = genres,_history = history,_addons = addons,_ageDescriptors = ageDescriptors;
  factory _GameDetail.fromJson(Map<String, dynamic> json) => _$GameDetailFromJson(json);

@override final  String nsuid;
@override final  String title;
@override final  String publisher;
@override final  String platform;
@override final  String category;
@override final  String? releaseDate;
@override@JsonKey() final  String releaseText;
@override@JsonKey() final  String image;
@override@JsonKey() final  String sourceStatus;
@override@JsonKey() final  String salesStatus;
@override final  Price? price;
 final  List<String> _screenshots;
@override@JsonKey() List<String> get screenshots {
  if (_screenshots is EqualUnmodifiableListView) return _screenshots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_screenshots);
}

 final  List<String> _dcolors;
@override@JsonKey() List<String> get dcolors {
  if (_dcolors is EqualUnmodifiableListView) return _dcolors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dcolors);
}

 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override@JsonKey() final  String description;
@override@JsonKey() final  String tagline;
@override@JsonKey() final  String players;
 final  List<HistoryPoint> _history;
@override@JsonKey() List<HistoryPoint> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override final  DateTime? firstObservedAt;
@override final  Lowest? lowest;
 final  List<Game> _addons;
@override@JsonKey() List<Game> get addons {
  if (_addons is EqualUnmodifiableListView) return _addons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addons);
}

@override final  int? age;
 final  List<String>? _ageDescriptors;
@override List<String>? get ageDescriptors {
  final value = _ageDescriptors;
  if (value == null) return null;
  if (_ageDescriptors is EqualUnmodifiableListView) return _ageDescriptors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of GameDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameDetailCopyWith<_GameDetail> get copyWith => __$GameDetailCopyWithImpl<_GameDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameDetail&&(identical(other.nsuid, nsuid) || other.nsuid == nsuid)&&(identical(other.title, title) || other.title == title)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.category, category) || other.category == category)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.releaseText, releaseText) || other.releaseText == releaseText)&&(identical(other.image, image) || other.image == image)&&(identical(other.sourceStatus, sourceStatus) || other.sourceStatus == sourceStatus)&&(identical(other.salesStatus, salesStatus) || other.salesStatus == salesStatus)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._screenshots, _screenshots)&&const DeepCollectionEquality().equals(other._dcolors, _dcolors)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.description, description) || other.description == description)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.players, players) || other.players == players)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.firstObservedAt, firstObservedAt) || other.firstObservedAt == firstObservedAt)&&(identical(other.lowest, lowest) || other.lowest == lowest)&&const DeepCollectionEquality().equals(other._addons, _addons)&&(identical(other.age, age) || other.age == age)&&const DeepCollectionEquality().equals(other._ageDescriptors, _ageDescriptors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,nsuid,title,publisher,platform,category,releaseDate,releaseText,image,sourceStatus,salesStatus,price,const DeepCollectionEquality().hash(_screenshots),const DeepCollectionEquality().hash(_dcolors),const DeepCollectionEquality().hash(_genres),description,tagline,players,const DeepCollectionEquality().hash(_history),firstObservedAt,lowest,const DeepCollectionEquality().hash(_addons),age,const DeepCollectionEquality().hash(_ageDescriptors)]);

@override
String toString() {
  return 'GameDetail(nsuid: $nsuid, title: $title, publisher: $publisher, platform: $platform, category: $category, releaseDate: $releaseDate, releaseText: $releaseText, image: $image, sourceStatus: $sourceStatus, salesStatus: $salesStatus, price: $price, screenshots: $screenshots, dcolors: $dcolors, genres: $genres, description: $description, tagline: $tagline, players: $players, history: $history, firstObservedAt: $firstObservedAt, lowest: $lowest, addons: $addons, age: $age, ageDescriptors: $ageDescriptors)';
}


}

/// @nodoc
abstract mixin class _$GameDetailCopyWith<$Res> implements $GameDetailCopyWith<$Res> {
  factory _$GameDetailCopyWith(_GameDetail value, $Res Function(_GameDetail) _then) = __$GameDetailCopyWithImpl;
@override @useResult
$Res call({
 String nsuid, String title, String publisher, String platform, String category, String? releaseDate, String releaseText, String image, String sourceStatus, String salesStatus, Price? price, List<String> screenshots, List<String> dcolors, List<String> genres, String description, String tagline, String players, List<HistoryPoint> history, DateTime? firstObservedAt, Lowest? lowest, List<Game> addons, int? age, List<String>? ageDescriptors
});


@override $PriceCopyWith<$Res>? get price;@override $LowestCopyWith<$Res>? get lowest;

}
/// @nodoc
class __$GameDetailCopyWithImpl<$Res>
    implements _$GameDetailCopyWith<$Res> {
  __$GameDetailCopyWithImpl(this._self, this._then);

  final _GameDetail _self;
  final $Res Function(_GameDetail) _then;

/// Create a copy of GameDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nsuid = null,Object? title = null,Object? publisher = null,Object? platform = null,Object? category = null,Object? releaseDate = freezed,Object? releaseText = null,Object? image = null,Object? sourceStatus = null,Object? salesStatus = null,Object? price = freezed,Object? screenshots = null,Object? dcolors = null,Object? genres = null,Object? description = null,Object? tagline = null,Object? players = null,Object? history = null,Object? firstObservedAt = freezed,Object? lowest = freezed,Object? addons = null,Object? age = freezed,Object? ageDescriptors = freezed,}) {
  return _then(_GameDetail(
nsuid: null == nsuid ? _self.nsuid : nsuid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,releaseText: null == releaseText ? _self.releaseText : releaseText // ignore: cast_nullable_to_non_nullable
as String,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String,sourceStatus: null == sourceStatus ? _self.sourceStatus : sourceStatus // ignore: cast_nullable_to_non_nullable
as String,salesStatus: null == salesStatus ? _self.salesStatus : salesStatus // ignore: cast_nullable_to_non_nullable
as String,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as Price?,screenshots: null == screenshots ? _self._screenshots : screenshots // ignore: cast_nullable_to_non_nullable
as List<String>,dcolors: null == dcolors ? _self._dcolors : dcolors // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,tagline: null == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as String,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<HistoryPoint>,firstObservedAt: freezed == firstObservedAt ? _self.firstObservedAt : firstObservedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lowest: freezed == lowest ? _self.lowest : lowest // ignore: cast_nullable_to_non_nullable
as Lowest?,addons: null == addons ? _self._addons : addons // ignore: cast_nullable_to_non_nullable
as List<Game>,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,ageDescriptors: freezed == ageDescriptors ? _self._ageDescriptors : ageDescriptors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

/// Create a copy of GameDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $PriceCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of GameDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LowestCopyWith<$Res>? get lowest {
    if (_self.lowest == null) {
    return null;
  }

  return $LowestCopyWith<$Res>(_self.lowest!, (value) {
    return _then(_self.copyWith(lowest: value));
  });
}
}


/// @nodoc
mixin _$GenreCount {

 String get name; int get count; String get cover;
/// Create a copy of GenreCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenreCountCopyWith<GenreCount> get copyWith => _$GenreCountCopyWithImpl<GenreCount>(this as GenreCount, _$identity);

  /// Serializes this GenreCount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenreCount&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count)&&(identical(other.cover, cover) || other.cover == cover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,count,cover);

@override
String toString() {
  return 'GenreCount(name: $name, count: $count, cover: $cover)';
}


}

/// @nodoc
abstract mixin class $GenreCountCopyWith<$Res>  {
  factory $GenreCountCopyWith(GenreCount value, $Res Function(GenreCount) _then) = _$GenreCountCopyWithImpl;
@useResult
$Res call({
 String name, int count, String cover
});




}
/// @nodoc
class _$GenreCountCopyWithImpl<$Res>
    implements $GenreCountCopyWith<$Res> {
  _$GenreCountCopyWithImpl(this._self, this._then);

  final GenreCount _self;
  final $Res Function(GenreCount) _then;

/// Create a copy of GenreCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? count = null,Object? cover = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GenreCount].
extension GenreCountPatterns on GenreCount {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenreCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenreCount() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenreCount value)  $default,){
final _that = this;
switch (_that) {
case _GenreCount():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenreCount value)?  $default,){
final _that = this;
switch (_that) {
case _GenreCount() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int count,  String cover)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenreCount() when $default != null:
return $default(_that.name,_that.count,_that.cover);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int count,  String cover)  $default,) {final _that = this;
switch (_that) {
case _GenreCount():
return $default(_that.name,_that.count,_that.cover);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int count,  String cover)?  $default,) {final _that = this;
switch (_that) {
case _GenreCount() when $default != null:
return $default(_that.name,_that.count,_that.cover);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GenreCount implements GenreCount {
  const _GenreCount({required this.name, required this.count, this.cover = ''});
  factory _GenreCount.fromJson(Map<String, dynamic> json) => _$GenreCountFromJson(json);

@override final  String name;
@override final  int count;
@override@JsonKey() final  String cover;

/// Create a copy of GenreCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenreCountCopyWith<_GenreCount> get copyWith => __$GenreCountCopyWithImpl<_GenreCount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GenreCountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenreCount&&(identical(other.name, name) || other.name == name)&&(identical(other.count, count) || other.count == count)&&(identical(other.cover, cover) || other.cover == cover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,count,cover);

@override
String toString() {
  return 'GenreCount(name: $name, count: $count, cover: $cover)';
}


}

/// @nodoc
abstract mixin class _$GenreCountCopyWith<$Res> implements $GenreCountCopyWith<$Res> {
  factory _$GenreCountCopyWith(_GenreCount value, $Res Function(_GenreCount) _then) = __$GenreCountCopyWithImpl;
@override @useResult
$Res call({
 String name, int count, String cover
});




}
/// @nodoc
class __$GenreCountCopyWithImpl<$Res>
    implements _$GenreCountCopyWith<$Res> {
  __$GenreCountCopyWithImpl(this._self, this._then);

  final _GenreCount _self;
  final $Res Function(_GenreCount) _then;

/// Create a copy of GenreCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? count = null,Object? cover = null,}) {
  return _then(_GenreCount(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PriceStatus {

 DateTime? get lastRunAt; int get productCount; DateTime? get historySince;
/// Create a copy of PriceStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceStatusCopyWith<PriceStatus> get copyWith => _$PriceStatusCopyWithImpl<PriceStatus>(this as PriceStatus, _$identity);

  /// Serializes this PriceStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceStatus&&(identical(other.lastRunAt, lastRunAt) || other.lastRunAt == lastRunAt)&&(identical(other.productCount, productCount) || other.productCount == productCount)&&(identical(other.historySince, historySince) || other.historySince == historySince));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lastRunAt,productCount,historySince);

@override
String toString() {
  return 'PriceStatus(lastRunAt: $lastRunAt, productCount: $productCount, historySince: $historySince)';
}


}

/// @nodoc
abstract mixin class $PriceStatusCopyWith<$Res>  {
  factory $PriceStatusCopyWith(PriceStatus value, $Res Function(PriceStatus) _then) = _$PriceStatusCopyWithImpl;
@useResult
$Res call({
 DateTime? lastRunAt, int productCount, DateTime? historySince
});




}
/// @nodoc
class _$PriceStatusCopyWithImpl<$Res>
    implements $PriceStatusCopyWith<$Res> {
  _$PriceStatusCopyWithImpl(this._self, this._then);

  final PriceStatus _self;
  final $Res Function(PriceStatus) _then;

/// Create a copy of PriceStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lastRunAt = freezed,Object? productCount = null,Object? historySince = freezed,}) {
  return _then(_self.copyWith(
lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as int,historySince: freezed == historySince ? _self.historySince : historySince // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceStatus].
extension PriceStatusPatterns on PriceStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceStatus value)  $default,){
final _that = this;
switch (_that) {
case _PriceStatus():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceStatus value)?  $default,){
final _that = this;
switch (_that) {
case _PriceStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? lastRunAt,  int productCount,  DateTime? historySince)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceStatus() when $default != null:
return $default(_that.lastRunAt,_that.productCount,_that.historySince);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? lastRunAt,  int productCount,  DateTime? historySince)  $default,) {final _that = this;
switch (_that) {
case _PriceStatus():
return $default(_that.lastRunAt,_that.productCount,_that.historySince);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? lastRunAt,  int productCount,  DateTime? historySince)?  $default,) {final _that = this;
switch (_that) {
case _PriceStatus() when $default != null:
return $default(_that.lastRunAt,_that.productCount,_that.historySince);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceStatus implements PriceStatus {
  const _PriceStatus({this.lastRunAt, this.productCount = 0, this.historySince});
  factory _PriceStatus.fromJson(Map<String, dynamic> json) => _$PriceStatusFromJson(json);

@override final  DateTime? lastRunAt;
@override@JsonKey() final  int productCount;
@override final  DateTime? historySince;

/// Create a copy of PriceStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceStatusCopyWith<_PriceStatus> get copyWith => __$PriceStatusCopyWithImpl<_PriceStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceStatus&&(identical(other.lastRunAt, lastRunAt) || other.lastRunAt == lastRunAt)&&(identical(other.productCount, productCount) || other.productCount == productCount)&&(identical(other.historySince, historySince) || other.historySince == historySince));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lastRunAt,productCount,historySince);

@override
String toString() {
  return 'PriceStatus(lastRunAt: $lastRunAt, productCount: $productCount, historySince: $historySince)';
}


}

/// @nodoc
abstract mixin class _$PriceStatusCopyWith<$Res> implements $PriceStatusCopyWith<$Res> {
  factory _$PriceStatusCopyWith(_PriceStatus value, $Res Function(_PriceStatus) _then) = __$PriceStatusCopyWithImpl;
@override @useResult
$Res call({
 DateTime? lastRunAt, int productCount, DateTime? historySince
});




}
/// @nodoc
class __$PriceStatusCopyWithImpl<$Res>
    implements _$PriceStatusCopyWith<$Res> {
  __$PriceStatusCopyWithImpl(this._self, this._then);

  final _PriceStatus _self;
  final $Res Function(_PriceStatus) _then;

/// Create a copy of PriceStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lastRunAt = freezed,Object? productCount = null,Object? historySince = freezed,}) {
  return _then(_PriceStatus(
lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,productCount: null == productCount ? _self.productCount : productCount // ignore: cast_nullable_to_non_nullable
as int,historySince: freezed == historySince ? _self.historySince : historySince // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$ListQuery {

 String get q; List<String> get platforms; List<String> get types; List<String> get genres; List<int> get ages; bool get sale; int? get maxPrice; String get sort; String? get release; List<String> get ids;
/// Create a copy of ListQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListQueryCopyWith<ListQuery> get copyWith => _$ListQueryCopyWithImpl<ListQuery>(this as ListQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListQuery&&(identical(other.q, q) || other.q == q)&&const DeepCollectionEquality().equals(other.platforms, platforms)&&const DeepCollectionEquality().equals(other.types, types)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.ages, ages)&&(identical(other.sale, sale) || other.sale == sale)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.release, release) || other.release == release)&&const DeepCollectionEquality().equals(other.ids, ids));
}


@override
int get hashCode => Object.hash(runtimeType,q,const DeepCollectionEquality().hash(platforms),const DeepCollectionEquality().hash(types),const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(ages),sale,maxPrice,sort,release,const DeepCollectionEquality().hash(ids));

@override
String toString() {
  return 'ListQuery(q: $q, platforms: $platforms, types: $types, genres: $genres, ages: $ages, sale: $sale, maxPrice: $maxPrice, sort: $sort, release: $release, ids: $ids)';
}


}

/// @nodoc
abstract mixin class $ListQueryCopyWith<$Res>  {
  factory $ListQueryCopyWith(ListQuery value, $Res Function(ListQuery) _then) = _$ListQueryCopyWithImpl;
@useResult
$Res call({
 String q, List<String> platforms, List<String> types, List<String> genres, List<int> ages, bool sale, int? maxPrice, String sort, String? release, List<String> ids
});




}
/// @nodoc
class _$ListQueryCopyWithImpl<$Res>
    implements $ListQueryCopyWith<$Res> {
  _$ListQueryCopyWithImpl(this._self, this._then);

  final ListQuery _self;
  final $Res Function(ListQuery) _then;

/// Create a copy of ListQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? q = null,Object? platforms = null,Object? types = null,Object? genres = null,Object? ages = null,Object? sale = null,Object? maxPrice = freezed,Object? sort = null,Object? release = freezed,Object? ids = null,}) {
  return _then(_self.copyWith(
q: null == q ? _self.q : q // ignore: cast_nullable_to_non_nullable
as String,platforms: null == platforms ? _self.platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<String>,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,ages: null == ages ? _self.ages : ages // ignore: cast_nullable_to_non_nullable
as List<int>,sale: null == sale ? _self.sale : sale // ignore: cast_nullable_to_non_nullable
as bool,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as int?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as String,release: freezed == release ? _self.release : release // ignore: cast_nullable_to_non_nullable
as String?,ids: null == ids ? _self.ids : ids // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ListQuery].
extension ListQueryPatterns on ListQuery {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListQuery() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListQuery value)  $default,){
final _that = this;
switch (_that) {
case _ListQuery():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListQuery value)?  $default,){
final _that = this;
switch (_that) {
case _ListQuery() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String q,  List<String> platforms,  List<String> types,  List<String> genres,  List<int> ages,  bool sale,  int? maxPrice,  String sort,  String? release,  List<String> ids)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListQuery() when $default != null:
return $default(_that.q,_that.platforms,_that.types,_that.genres,_that.ages,_that.sale,_that.maxPrice,_that.sort,_that.release,_that.ids);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String q,  List<String> platforms,  List<String> types,  List<String> genres,  List<int> ages,  bool sale,  int? maxPrice,  String sort,  String? release,  List<String> ids)  $default,) {final _that = this;
switch (_that) {
case _ListQuery():
return $default(_that.q,_that.platforms,_that.types,_that.genres,_that.ages,_that.sale,_that.maxPrice,_that.sort,_that.release,_that.ids);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String q,  List<String> platforms,  List<String> types,  List<String> genres,  List<int> ages,  bool sale,  int? maxPrice,  String sort,  String? release,  List<String> ids)?  $default,) {final _that = this;
switch (_that) {
case _ListQuery() when $default != null:
return $default(_that.q,_that.platforms,_that.types,_that.genres,_that.ages,_that.sale,_that.maxPrice,_that.sort,_that.release,_that.ids);case _:
  return null;

}
}

}

/// @nodoc


class _ListQuery implements ListQuery {
  const _ListQuery({this.q = '', final  List<String> platforms = const <String>[], final  List<String> types = const <String>['game'], final  List<String> genres = const <String>[], final  List<int> ages = const <int>[], this.sale = false, this.maxPrice, this.sort = 'savings', this.release, final  List<String> ids = const <String>[]}): _platforms = platforms,_types = types,_genres = genres,_ages = ages,_ids = ids;
  

@override@JsonKey() final  String q;
 final  List<String> _platforms;
@override@JsonKey() List<String> get platforms {
  if (_platforms is EqualUnmodifiableListView) return _platforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_platforms);
}

 final  List<String> _types;
@override@JsonKey() List<String> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
}

 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

 final  List<int> _ages;
@override@JsonKey() List<int> get ages {
  if (_ages is EqualUnmodifiableListView) return _ages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ages);
}

@override@JsonKey() final  bool sale;
@override final  int? maxPrice;
@override@JsonKey() final  String sort;
@override final  String? release;
 final  List<String> _ids;
@override@JsonKey() List<String> get ids {
  if (_ids is EqualUnmodifiableListView) return _ids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ids);
}


/// Create a copy of ListQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListQueryCopyWith<_ListQuery> get copyWith => __$ListQueryCopyWithImpl<_ListQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListQuery&&(identical(other.q, q) || other.q == q)&&const DeepCollectionEquality().equals(other._platforms, _platforms)&&const DeepCollectionEquality().equals(other._types, _types)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._ages, _ages)&&(identical(other.sale, sale) || other.sale == sale)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.release, release) || other.release == release)&&const DeepCollectionEquality().equals(other._ids, _ids));
}


@override
int get hashCode => Object.hash(runtimeType,q,const DeepCollectionEquality().hash(_platforms),const DeepCollectionEquality().hash(_types),const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_ages),sale,maxPrice,sort,release,const DeepCollectionEquality().hash(_ids));

@override
String toString() {
  return 'ListQuery(q: $q, platforms: $platforms, types: $types, genres: $genres, ages: $ages, sale: $sale, maxPrice: $maxPrice, sort: $sort, release: $release, ids: $ids)';
}


}

/// @nodoc
abstract mixin class _$ListQueryCopyWith<$Res> implements $ListQueryCopyWith<$Res> {
  factory _$ListQueryCopyWith(_ListQuery value, $Res Function(_ListQuery) _then) = __$ListQueryCopyWithImpl;
@override @useResult
$Res call({
 String q, List<String> platforms, List<String> types, List<String> genres, List<int> ages, bool sale, int? maxPrice, String sort, String? release, List<String> ids
});




}
/// @nodoc
class __$ListQueryCopyWithImpl<$Res>
    implements _$ListQueryCopyWith<$Res> {
  __$ListQueryCopyWithImpl(this._self, this._then);

  final _ListQuery _self;
  final $Res Function(_ListQuery) _then;

/// Create a copy of ListQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? q = null,Object? platforms = null,Object? types = null,Object? genres = null,Object? ages = null,Object? sale = null,Object? maxPrice = freezed,Object? sort = null,Object? release = freezed,Object? ids = null,}) {
  return _then(_ListQuery(
q: null == q ? _self.q : q // ignore: cast_nullable_to_non_nullable
as String,platforms: null == platforms ? _self._platforms : platforms // ignore: cast_nullable_to_non_nullable
as List<String>,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,ages: null == ages ? _self._ages : ages // ignore: cast_nullable_to_non_nullable
as List<int>,sale: null == sale ? _self.sale : sale // ignore: cast_nullable_to_non_nullable
as bool,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as int?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as String,release: freezed == release ? _self.release : release // ignore: cast_nullable_to_non_nullable
as String?,ids: null == ids ? _self._ids : ids // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
