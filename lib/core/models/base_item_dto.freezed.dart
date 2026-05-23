// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudioDto {

/// Unique identifier for the studio.
 int? get id;/// Name of the studio (e.g., "Marvel Studios").
 String? get name;/// Image tags for the studio (e.g. Primary, Logo, Backdrop).
 Map<String, String>? get imageTags;
/// Create a copy of StudioDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudioDtoCopyWith<StudioDto> get copyWith => _$StudioDtoCopyWithImpl<StudioDto>(this as StudioDto, _$identity);

  /// Serializes this StudioDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudioDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.imageTags, imageTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(imageTags));

@override
String toString() {
  return 'StudioDto(id: $id, name: $name, imageTags: $imageTags)';
}


}

/// @nodoc
abstract mixin class $StudioDtoCopyWith<$Res>  {
  factory $StudioDtoCopyWith(StudioDto value, $Res Function(StudioDto) _then) = _$StudioDtoCopyWithImpl;
@useResult
$Res call({
 int? id, String? name, Map<String, String>? imageTags
});




}
/// @nodoc
class _$StudioDtoCopyWithImpl<$Res>
    implements $StudioDtoCopyWith<$Res> {
  _$StudioDtoCopyWithImpl(this._self, this._then);

  final StudioDto _self;
  final $Res Function(StudioDto) _then;

/// Create a copy of StudioDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? imageTags = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,imageTags: freezed == imageTags ? _self.imageTags : imageTags // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudioDto].
extension StudioDtoPatterns on StudioDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudioDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudioDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudioDto value)  $default,){
final _that = this;
switch (_that) {
case _StudioDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudioDto value)?  $default,){
final _that = this;
switch (_that) {
case _StudioDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? name,  Map<String, String>? imageTags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudioDto() when $default != null:
return $default(_that.id,_that.name,_that.imageTags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? name,  Map<String, String>? imageTags)  $default,) {final _that = this;
switch (_that) {
case _StudioDto():
return $default(_that.id,_that.name,_that.imageTags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? name,  Map<String, String>? imageTags)?  $default,) {final _that = this;
switch (_that) {
case _StudioDto() when $default != null:
return $default(_that.id,_that.name,_that.imageTags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudioDto implements StudioDto {
  const _StudioDto({this.id, this.name, final  Map<String, String>? imageTags}): _imageTags = imageTags;
  factory _StudioDto.fromJson(Map<String, dynamic> json) => _$StudioDtoFromJson(json);

/// Unique identifier for the studio.
@override final  int? id;
/// Name of the studio (e.g., "Marvel Studios").
@override final  String? name;
/// Image tags for the studio (e.g. Primary, Logo, Backdrop).
 final  Map<String, String>? _imageTags;
/// Image tags for the studio (e.g. Primary, Logo, Backdrop).
@override Map<String, String>? get imageTags {
  final value = _imageTags;
  if (value == null) return null;
  if (_imageTags is EqualUnmodifiableMapView) return _imageTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of StudioDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudioDtoCopyWith<_StudioDto> get copyWith => __$StudioDtoCopyWithImpl<_StudioDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudioDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudioDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._imageTags, _imageTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_imageTags));

@override
String toString() {
  return 'StudioDto(id: $id, name: $name, imageTags: $imageTags)';
}


}

/// @nodoc
abstract mixin class _$StudioDtoCopyWith<$Res> implements $StudioDtoCopyWith<$Res> {
  factory _$StudioDtoCopyWith(_StudioDto value, $Res Function(_StudioDto) _then) = __$StudioDtoCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? name, Map<String, String>? imageTags
});




}
/// @nodoc
class __$StudioDtoCopyWithImpl<$Res>
    implements _$StudioDtoCopyWith<$Res> {
  __$StudioDtoCopyWithImpl(this._self, this._then);

  final _StudioDto _self;
  final $Res Function(_StudioDto) _then;

/// Create a copy of StudioDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? imageTags = freezed,}) {
  return _then(_StudioDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,imageTags: freezed == imageTags ? _self._imageTags : imageTags // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}


/// @nodoc
mixin _$PersonDto {

/// Unique identifier for the person.
 String? get id;/// Name of the person.
 String? get name;/// Role the person played (e.g., "Peter Parker" for actors).
 String? get role;/// Type of contribution (Actor, Director, Writer, Composer, etc.).
 String? get type;/// Primary image tag for the person's photo.
 String? get primaryImageTag;
/// Create a copy of PersonDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonDtoCopyWith<PersonDto> get copyWith => _$PersonDtoCopyWithImpl<PersonDto>(this as PersonDto, _$identity);

  /// Serializes this PersonDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.type, type) || other.type == type)&&(identical(other.primaryImageTag, primaryImageTag) || other.primaryImageTag == primaryImageTag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,role,type,primaryImageTag);

@override
String toString() {
  return 'PersonDto(id: $id, name: $name, role: $role, type: $type, primaryImageTag: $primaryImageTag)';
}


}

/// @nodoc
abstract mixin class $PersonDtoCopyWith<$Res>  {
  factory $PersonDtoCopyWith(PersonDto value, $Res Function(PersonDto) _then) = _$PersonDtoCopyWithImpl;
@useResult
$Res call({
 String? id, String? name, String? role, String? type, String? primaryImageTag
});




}
/// @nodoc
class _$PersonDtoCopyWithImpl<$Res>
    implements $PersonDtoCopyWith<$Res> {
  _$PersonDtoCopyWithImpl(this._self, this._then);

  final PersonDto _self;
  final $Res Function(PersonDto) _then;

/// Create a copy of PersonDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? role = freezed,Object? type = freezed,Object? primaryImageTag = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,primaryImageTag: freezed == primaryImageTag ? _self.primaryImageTag : primaryImageTag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonDto].
extension PersonDtoPatterns on PersonDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonDto value)  $default,){
final _that = this;
switch (_that) {
case _PersonDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonDto value)?  $default,){
final _that = this;
switch (_that) {
case _PersonDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name,  String? role,  String? type,  String? primaryImageTag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonDto() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.type,_that.primaryImageTag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name,  String? role,  String? type,  String? primaryImageTag)  $default,) {final _that = this;
switch (_that) {
case _PersonDto():
return $default(_that.id,_that.name,_that.role,_that.type,_that.primaryImageTag);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name,  String? role,  String? type,  String? primaryImageTag)?  $default,) {final _that = this;
switch (_that) {
case _PersonDto() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.type,_that.primaryImageTag);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonDto implements PersonDto {
  const _PersonDto({this.id, this.name, this.role, this.type, this.primaryImageTag});
  factory _PersonDto.fromJson(Map<String, dynamic> json) => _$PersonDtoFromJson(json);

/// Unique identifier for the person.
@override final  String? id;
/// Name of the person.
@override final  String? name;
/// Role the person played (e.g., "Peter Parker" for actors).
@override final  String? role;
/// Type of contribution (Actor, Director, Writer, Composer, etc.).
@override final  String? type;
/// Primary image tag for the person's photo.
@override final  String? primaryImageTag;

/// Create a copy of PersonDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonDtoCopyWith<_PersonDto> get copyWith => __$PersonDtoCopyWithImpl<_PersonDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.type, type) || other.type == type)&&(identical(other.primaryImageTag, primaryImageTag) || other.primaryImageTag == primaryImageTag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,role,type,primaryImageTag);

@override
String toString() {
  return 'PersonDto(id: $id, name: $name, role: $role, type: $type, primaryImageTag: $primaryImageTag)';
}


}

/// @nodoc
abstract mixin class _$PersonDtoCopyWith<$Res> implements $PersonDtoCopyWith<$Res> {
  factory _$PersonDtoCopyWith(_PersonDto value, $Res Function(_PersonDto) _then) = __$PersonDtoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name, String? role, String? type, String? primaryImageTag
});




}
/// @nodoc
class __$PersonDtoCopyWithImpl<$Res>
    implements _$PersonDtoCopyWith<$Res> {
  __$PersonDtoCopyWithImpl(this._self, this._then);

  final _PersonDto _self;
  final $Res Function(_PersonDto) _then;

/// Create a copy of PersonDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? role = freezed,Object? type = freezed,Object? primaryImageTag = freezed,}) {
  return _then(_PersonDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,primaryImageTag: freezed == primaryImageTag ? _self.primaryImageTag : primaryImageTag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BaseItemDto {

/// Unique identifier for the item.
 String? get id;/// Display name of the item.
 String? get name;/// Item type (Movie, Series, Season, Episode, BoxSet, etc.).
 String? get type;/// Premiere/release date of the item.
 DateTime? get premiereDate;/// Official content rating (e.g., PG-13, TV-MA).
 String? get officialRating;/// Community rating from external sources (e.g., IMDb, TMDB).
 double? get communityRating;/// Critic rating from aggregators (e.g., Rotten Tomatoes).
 double? get criticRating;/// Map of image type to image tag for constructing image URLs.
/// Keys: Primary, Art, Backdrop, Banner, Logo, Thumb, Disc.
 Map<String, String>? get imageTags;/// List of backdrop image tags.
 List<String>? get backdropImageTags;/// Synopsis/overview of the item.
 String? get overview;/// Genre tags (e.g., ["科幻", "动作", "冒险"]).
 List<String>? get genres;/// External provider IDs (e.g., {"Imdb": "tt123456", "Tmdb": "12345"}).
 Map<String, String>? get providerIds;/// Production studios (e.g., [{"Name": "Marvel Studios", "Id": "7025"}]).
 List<StudioDto>? get studios;/// Runtime duration in ticks (1 tick = 100 nanoseconds).
 int? get runTimeTicks;/// Year the item was produced/released.
 int? get productionYear;/// Whether this item represents a folder/container.
 bool? get isFolder;/// Parent folder/item identifier.
 String? get parentId;/// Series ID (for episodes).
 String? get seriesId;/// Series name (for episodes).
 String? get seriesName;/// Season name (for episodes).
 String? get seasonName;/// Episode number within the season.
 int? get indexNumber;/// Season number (for episodes).
 int? get parentIndexNumber;/// List of people associated with the item (cast and crew).
 List<PersonDto> get people;/// List of available media sources for playback.
 List<MediaSourceInfo> get mediaSources;/// User-specific data (playback progress, favorites, etc.).
 UserItemDataDto? get userData;/// Collection type for library views (movies, tvshows, music, etc.).
 String? get collectionType;/// Number of child items in a folder/library.
 int? get childCount;/// Status for series (e.g., "Continuing" / "Ended").
/// - "Continuing": 连载中
/// - "Ended": 已完结
 String? get status;
/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseItemDtoCopyWith<BaseItemDto> get copyWith => _$BaseItemDtoCopyWithImpl<BaseItemDto>(this as BaseItemDto, _$identity);

  /// Serializes this BaseItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.premiereDate, premiereDate) || other.premiereDate == premiereDate)&&(identical(other.officialRating, officialRating) || other.officialRating == officialRating)&&(identical(other.communityRating, communityRating) || other.communityRating == communityRating)&&(identical(other.criticRating, criticRating) || other.criticRating == criticRating)&&const DeepCollectionEquality().equals(other.imageTags, imageTags)&&const DeepCollectionEquality().equals(other.backdropImageTags, backdropImageTags)&&(identical(other.overview, overview) || other.overview == overview)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.providerIds, providerIds)&&const DeepCollectionEquality().equals(other.studios, studios)&&(identical(other.runTimeTicks, runTimeTicks) || other.runTimeTicks == runTimeTicks)&&(identical(other.productionYear, productionYear) || other.productionYear == productionYear)&&(identical(other.isFolder, isFolder) || other.isFolder == isFolder)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.seasonName, seasonName) || other.seasonName == seasonName)&&(identical(other.indexNumber, indexNumber) || other.indexNumber == indexNumber)&&(identical(other.parentIndexNumber, parentIndexNumber) || other.parentIndexNumber == parentIndexNumber)&&const DeepCollectionEquality().equals(other.people, people)&&const DeepCollectionEquality().equals(other.mediaSources, mediaSources)&&(identical(other.userData, userData) || other.userData == userData)&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.childCount, childCount) || other.childCount == childCount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,premiereDate,officialRating,communityRating,criticRating,const DeepCollectionEquality().hash(imageTags),const DeepCollectionEquality().hash(backdropImageTags),overview,const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(providerIds),const DeepCollectionEquality().hash(studios),runTimeTicks,productionYear,isFolder,parentId,seriesId,seriesName,seasonName,indexNumber,parentIndexNumber,const DeepCollectionEquality().hash(people),const DeepCollectionEquality().hash(mediaSources),userData,collectionType,childCount,status]);

@override
String toString() {
  return 'BaseItemDto(id: $id, name: $name, type: $type, premiereDate: $premiereDate, officialRating: $officialRating, communityRating: $communityRating, criticRating: $criticRating, imageTags: $imageTags, backdropImageTags: $backdropImageTags, overview: $overview, genres: $genres, providerIds: $providerIds, studios: $studios, runTimeTicks: $runTimeTicks, productionYear: $productionYear, isFolder: $isFolder, parentId: $parentId, seriesId: $seriesId, seriesName: $seriesName, seasonName: $seasonName, indexNumber: $indexNumber, parentIndexNumber: $parentIndexNumber, people: $people, mediaSources: $mediaSources, userData: $userData, collectionType: $collectionType, childCount: $childCount, status: $status)';
}


}

/// @nodoc
abstract mixin class $BaseItemDtoCopyWith<$Res>  {
  factory $BaseItemDtoCopyWith(BaseItemDto value, $Res Function(BaseItemDto) _then) = _$BaseItemDtoCopyWithImpl;
@useResult
$Res call({
 String? id, String? name, String? type, DateTime? premiereDate, String? officialRating, double? communityRating, double? criticRating, Map<String, String>? imageTags, List<String>? backdropImageTags, String? overview, List<String>? genres, Map<String, String>? providerIds, List<StudioDto>? studios, int? runTimeTicks, int? productionYear, bool? isFolder, String? parentId, String? seriesId, String? seriesName, String? seasonName, int? indexNumber, int? parentIndexNumber, List<PersonDto> people, List<MediaSourceInfo> mediaSources, UserItemDataDto? userData, String? collectionType, int? childCount, String? status
});


$UserItemDataDtoCopyWith<$Res>? get userData;

}
/// @nodoc
class _$BaseItemDtoCopyWithImpl<$Res>
    implements $BaseItemDtoCopyWith<$Res> {
  _$BaseItemDtoCopyWithImpl(this._self, this._then);

  final BaseItemDto _self;
  final $Res Function(BaseItemDto) _then;

/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? type = freezed,Object? premiereDate = freezed,Object? officialRating = freezed,Object? communityRating = freezed,Object? criticRating = freezed,Object? imageTags = freezed,Object? backdropImageTags = freezed,Object? overview = freezed,Object? genres = freezed,Object? providerIds = freezed,Object? studios = freezed,Object? runTimeTicks = freezed,Object? productionYear = freezed,Object? isFolder = freezed,Object? parentId = freezed,Object? seriesId = freezed,Object? seriesName = freezed,Object? seasonName = freezed,Object? indexNumber = freezed,Object? parentIndexNumber = freezed,Object? people = null,Object? mediaSources = null,Object? userData = freezed,Object? collectionType = freezed,Object? childCount = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,premiereDate: freezed == premiereDate ? _self.premiereDate : premiereDate // ignore: cast_nullable_to_non_nullable
as DateTime?,officialRating: freezed == officialRating ? _self.officialRating : officialRating // ignore: cast_nullable_to_non_nullable
as String?,communityRating: freezed == communityRating ? _self.communityRating : communityRating // ignore: cast_nullable_to_non_nullable
as double?,criticRating: freezed == criticRating ? _self.criticRating : criticRating // ignore: cast_nullable_to_non_nullable
as double?,imageTags: freezed == imageTags ? _self.imageTags : imageTags // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,backdropImageTags: freezed == backdropImageTags ? _self.backdropImageTags : backdropImageTags // ignore: cast_nullable_to_non_nullable
as List<String>?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,genres: freezed == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>?,providerIds: freezed == providerIds ? _self.providerIds : providerIds // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,studios: freezed == studios ? _self.studios : studios // ignore: cast_nullable_to_non_nullable
as List<StudioDto>?,runTimeTicks: freezed == runTimeTicks ? _self.runTimeTicks : runTimeTicks // ignore: cast_nullable_to_non_nullable
as int?,productionYear: freezed == productionYear ? _self.productionYear : productionYear // ignore: cast_nullable_to_non_nullable
as int?,isFolder: freezed == isFolder ? _self.isFolder : isFolder // ignore: cast_nullable_to_non_nullable
as bool?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,seriesId: freezed == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as String?,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,seasonName: freezed == seasonName ? _self.seasonName : seasonName // ignore: cast_nullable_to_non_nullable
as String?,indexNumber: freezed == indexNumber ? _self.indexNumber : indexNumber // ignore: cast_nullable_to_non_nullable
as int?,parentIndexNumber: freezed == parentIndexNumber ? _self.parentIndexNumber : parentIndexNumber // ignore: cast_nullable_to_non_nullable
as int?,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<PersonDto>,mediaSources: null == mediaSources ? _self.mediaSources : mediaSources // ignore: cast_nullable_to_non_nullable
as List<MediaSourceInfo>,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as UserItemDataDto?,collectionType: freezed == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String?,childCount: freezed == childCount ? _self.childCount : childCount // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserItemDataDtoCopyWith<$Res>? get userData {
    if (_self.userData == null) {
    return null;
  }

  return $UserItemDataDtoCopyWith<$Res>(_self.userData!, (value) {
    return _then(_self.copyWith(userData: value));
  });
}
}


/// Adds pattern-matching-related methods to [BaseItemDto].
extension BaseItemDtoPatterns on BaseItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseItemDto value)  $default,){
final _that = this;
switch (_that) {
case _BaseItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _BaseItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name,  String? type,  DateTime? premiereDate,  String? officialRating,  double? communityRating,  double? criticRating,  Map<String, String>? imageTags,  List<String>? backdropImageTags,  String? overview,  List<String>? genres,  Map<String, String>? providerIds,  List<StudioDto>? studios,  int? runTimeTicks,  int? productionYear,  bool? isFolder,  String? parentId,  String? seriesId,  String? seriesName,  String? seasonName,  int? indexNumber,  int? parentIndexNumber,  List<PersonDto> people,  List<MediaSourceInfo> mediaSources,  UserItemDataDto? userData,  String? collectionType,  int? childCount,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseItemDto() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.premiereDate,_that.officialRating,_that.communityRating,_that.criticRating,_that.imageTags,_that.backdropImageTags,_that.overview,_that.genres,_that.providerIds,_that.studios,_that.runTimeTicks,_that.productionYear,_that.isFolder,_that.parentId,_that.seriesId,_that.seriesName,_that.seasonName,_that.indexNumber,_that.parentIndexNumber,_that.people,_that.mediaSources,_that.userData,_that.collectionType,_that.childCount,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name,  String? type,  DateTime? premiereDate,  String? officialRating,  double? communityRating,  double? criticRating,  Map<String, String>? imageTags,  List<String>? backdropImageTags,  String? overview,  List<String>? genres,  Map<String, String>? providerIds,  List<StudioDto>? studios,  int? runTimeTicks,  int? productionYear,  bool? isFolder,  String? parentId,  String? seriesId,  String? seriesName,  String? seasonName,  int? indexNumber,  int? parentIndexNumber,  List<PersonDto> people,  List<MediaSourceInfo> mediaSources,  UserItemDataDto? userData,  String? collectionType,  int? childCount,  String? status)  $default,) {final _that = this;
switch (_that) {
case _BaseItemDto():
return $default(_that.id,_that.name,_that.type,_that.premiereDate,_that.officialRating,_that.communityRating,_that.criticRating,_that.imageTags,_that.backdropImageTags,_that.overview,_that.genres,_that.providerIds,_that.studios,_that.runTimeTicks,_that.productionYear,_that.isFolder,_that.parentId,_that.seriesId,_that.seriesName,_that.seasonName,_that.indexNumber,_that.parentIndexNumber,_that.people,_that.mediaSources,_that.userData,_that.collectionType,_that.childCount,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name,  String? type,  DateTime? premiereDate,  String? officialRating,  double? communityRating,  double? criticRating,  Map<String, String>? imageTags,  List<String>? backdropImageTags,  String? overview,  List<String>? genres,  Map<String, String>? providerIds,  List<StudioDto>? studios,  int? runTimeTicks,  int? productionYear,  bool? isFolder,  String? parentId,  String? seriesId,  String? seriesName,  String? seasonName,  int? indexNumber,  int? parentIndexNumber,  List<PersonDto> people,  List<MediaSourceInfo> mediaSources,  UserItemDataDto? userData,  String? collectionType,  int? childCount,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _BaseItemDto() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.premiereDate,_that.officialRating,_that.communityRating,_that.criticRating,_that.imageTags,_that.backdropImageTags,_that.overview,_that.genres,_that.providerIds,_that.studios,_that.runTimeTicks,_that.productionYear,_that.isFolder,_that.parentId,_that.seriesId,_that.seriesName,_that.seasonName,_that.indexNumber,_that.parentIndexNumber,_that.people,_that.mediaSources,_that.userData,_that.collectionType,_that.childCount,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BaseItemDto implements BaseItemDto {
  const _BaseItemDto({this.id, this.name, this.type, this.premiereDate, this.officialRating, this.communityRating, this.criticRating, final  Map<String, String>? imageTags, final  List<String>? backdropImageTags, this.overview, final  List<String>? genres, final  Map<String, String>? providerIds, final  List<StudioDto>? studios, this.runTimeTicks, this.productionYear, this.isFolder, this.parentId, this.seriesId, this.seriesName, this.seasonName, this.indexNumber, this.parentIndexNumber, final  List<PersonDto> people = const [], final  List<MediaSourceInfo> mediaSources = const [], this.userData, this.collectionType, this.childCount, this.status}): _imageTags = imageTags,_backdropImageTags = backdropImageTags,_genres = genres,_providerIds = providerIds,_studios = studios,_people = people,_mediaSources = mediaSources;
  factory _BaseItemDto.fromJson(Map<String, dynamic> json) => _$BaseItemDtoFromJson(json);

/// Unique identifier for the item.
@override final  String? id;
/// Display name of the item.
@override final  String? name;
/// Item type (Movie, Series, Season, Episode, BoxSet, etc.).
@override final  String? type;
/// Premiere/release date of the item.
@override final  DateTime? premiereDate;
/// Official content rating (e.g., PG-13, TV-MA).
@override final  String? officialRating;
/// Community rating from external sources (e.g., IMDb, TMDB).
@override final  double? communityRating;
/// Critic rating from aggregators (e.g., Rotten Tomatoes).
@override final  double? criticRating;
/// Map of image type to image tag for constructing image URLs.
/// Keys: Primary, Art, Backdrop, Banner, Logo, Thumb, Disc.
 final  Map<String, String>? _imageTags;
/// Map of image type to image tag for constructing image URLs.
/// Keys: Primary, Art, Backdrop, Banner, Logo, Thumb, Disc.
@override Map<String, String>? get imageTags {
  final value = _imageTags;
  if (value == null) return null;
  if (_imageTags is EqualUnmodifiableMapView) return _imageTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// List of backdrop image tags.
 final  List<String>? _backdropImageTags;
/// List of backdrop image tags.
@override List<String>? get backdropImageTags {
  final value = _backdropImageTags;
  if (value == null) return null;
  if (_backdropImageTags is EqualUnmodifiableListView) return _backdropImageTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Synopsis/overview of the item.
@override final  String? overview;
/// Genre tags (e.g., ["科幻", "动作", "冒险"]).
 final  List<String>? _genres;
/// Genre tags (e.g., ["科幻", "动作", "冒险"]).
@override List<String>? get genres {
  final value = _genres;
  if (value == null) return null;
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// External provider IDs (e.g., {"Imdb": "tt123456", "Tmdb": "12345"}).
 final  Map<String, String>? _providerIds;
/// External provider IDs (e.g., {"Imdb": "tt123456", "Tmdb": "12345"}).
@override Map<String, String>? get providerIds {
  final value = _providerIds;
  if (value == null) return null;
  if (_providerIds is EqualUnmodifiableMapView) return _providerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Production studios (e.g., [{"Name": "Marvel Studios", "Id": "7025"}]).
 final  List<StudioDto>? _studios;
/// Production studios (e.g., [{"Name": "Marvel Studios", "Id": "7025"}]).
@override List<StudioDto>? get studios {
  final value = _studios;
  if (value == null) return null;
  if (_studios is EqualUnmodifiableListView) return _studios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Runtime duration in ticks (1 tick = 100 nanoseconds).
@override final  int? runTimeTicks;
/// Year the item was produced/released.
@override final  int? productionYear;
/// Whether this item represents a folder/container.
@override final  bool? isFolder;
/// Parent folder/item identifier.
@override final  String? parentId;
/// Series ID (for episodes).
@override final  String? seriesId;
/// Series name (for episodes).
@override final  String? seriesName;
/// Season name (for episodes).
@override final  String? seasonName;
/// Episode number within the season.
@override final  int? indexNumber;
/// Season number (for episodes).
@override final  int? parentIndexNumber;
/// List of people associated with the item (cast and crew).
 final  List<PersonDto> _people;
/// List of people associated with the item (cast and crew).
@override@JsonKey() List<PersonDto> get people {
  if (_people is EqualUnmodifiableListView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_people);
}

/// List of available media sources for playback.
 final  List<MediaSourceInfo> _mediaSources;
/// List of available media sources for playback.
@override@JsonKey() List<MediaSourceInfo> get mediaSources {
  if (_mediaSources is EqualUnmodifiableListView) return _mediaSources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaSources);
}

/// User-specific data (playback progress, favorites, etc.).
@override final  UserItemDataDto? userData;
/// Collection type for library views (movies, tvshows, music, etc.).
@override final  String? collectionType;
/// Number of child items in a folder/library.
@override final  int? childCount;
/// Status for series (e.g., "Continuing" / "Ended").
/// - "Continuing": 连载中
/// - "Ended": 已完结
@override final  String? status;

/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseItemDtoCopyWith<_BaseItemDto> get copyWith => __$BaseItemDtoCopyWithImpl<_BaseItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BaseItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.premiereDate, premiereDate) || other.premiereDate == premiereDate)&&(identical(other.officialRating, officialRating) || other.officialRating == officialRating)&&(identical(other.communityRating, communityRating) || other.communityRating == communityRating)&&(identical(other.criticRating, criticRating) || other.criticRating == criticRating)&&const DeepCollectionEquality().equals(other._imageTags, _imageTags)&&const DeepCollectionEquality().equals(other._backdropImageTags, _backdropImageTags)&&(identical(other.overview, overview) || other.overview == overview)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._providerIds, _providerIds)&&const DeepCollectionEquality().equals(other._studios, _studios)&&(identical(other.runTimeTicks, runTimeTicks) || other.runTimeTicks == runTimeTicks)&&(identical(other.productionYear, productionYear) || other.productionYear == productionYear)&&(identical(other.isFolder, isFolder) || other.isFolder == isFolder)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.seasonName, seasonName) || other.seasonName == seasonName)&&(identical(other.indexNumber, indexNumber) || other.indexNumber == indexNumber)&&(identical(other.parentIndexNumber, parentIndexNumber) || other.parentIndexNumber == parentIndexNumber)&&const DeepCollectionEquality().equals(other._people, _people)&&const DeepCollectionEquality().equals(other._mediaSources, _mediaSources)&&(identical(other.userData, userData) || other.userData == userData)&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.childCount, childCount) || other.childCount == childCount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,premiereDate,officialRating,communityRating,criticRating,const DeepCollectionEquality().hash(_imageTags),const DeepCollectionEquality().hash(_backdropImageTags),overview,const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_providerIds),const DeepCollectionEquality().hash(_studios),runTimeTicks,productionYear,isFolder,parentId,seriesId,seriesName,seasonName,indexNumber,parentIndexNumber,const DeepCollectionEquality().hash(_people),const DeepCollectionEquality().hash(_mediaSources),userData,collectionType,childCount,status]);

@override
String toString() {
  return 'BaseItemDto(id: $id, name: $name, type: $type, premiereDate: $premiereDate, officialRating: $officialRating, communityRating: $communityRating, criticRating: $criticRating, imageTags: $imageTags, backdropImageTags: $backdropImageTags, overview: $overview, genres: $genres, providerIds: $providerIds, studios: $studios, runTimeTicks: $runTimeTicks, productionYear: $productionYear, isFolder: $isFolder, parentId: $parentId, seriesId: $seriesId, seriesName: $seriesName, seasonName: $seasonName, indexNumber: $indexNumber, parentIndexNumber: $parentIndexNumber, people: $people, mediaSources: $mediaSources, userData: $userData, collectionType: $collectionType, childCount: $childCount, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BaseItemDtoCopyWith<$Res> implements $BaseItemDtoCopyWith<$Res> {
  factory _$BaseItemDtoCopyWith(_BaseItemDto value, $Res Function(_BaseItemDto) _then) = __$BaseItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name, String? type, DateTime? premiereDate, String? officialRating, double? communityRating, double? criticRating, Map<String, String>? imageTags, List<String>? backdropImageTags, String? overview, List<String>? genres, Map<String, String>? providerIds, List<StudioDto>? studios, int? runTimeTicks, int? productionYear, bool? isFolder, String? parentId, String? seriesId, String? seriesName, String? seasonName, int? indexNumber, int? parentIndexNumber, List<PersonDto> people, List<MediaSourceInfo> mediaSources, UserItemDataDto? userData, String? collectionType, int? childCount, String? status
});


@override $UserItemDataDtoCopyWith<$Res>? get userData;

}
/// @nodoc
class __$BaseItemDtoCopyWithImpl<$Res>
    implements _$BaseItemDtoCopyWith<$Res> {
  __$BaseItemDtoCopyWithImpl(this._self, this._then);

  final _BaseItemDto _self;
  final $Res Function(_BaseItemDto) _then;

/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? type = freezed,Object? premiereDate = freezed,Object? officialRating = freezed,Object? communityRating = freezed,Object? criticRating = freezed,Object? imageTags = freezed,Object? backdropImageTags = freezed,Object? overview = freezed,Object? genres = freezed,Object? providerIds = freezed,Object? studios = freezed,Object? runTimeTicks = freezed,Object? productionYear = freezed,Object? isFolder = freezed,Object? parentId = freezed,Object? seriesId = freezed,Object? seriesName = freezed,Object? seasonName = freezed,Object? indexNumber = freezed,Object? parentIndexNumber = freezed,Object? people = null,Object? mediaSources = null,Object? userData = freezed,Object? collectionType = freezed,Object? childCount = freezed,Object? status = freezed,}) {
  return _then(_BaseItemDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,premiereDate: freezed == premiereDate ? _self.premiereDate : premiereDate // ignore: cast_nullable_to_non_nullable
as DateTime?,officialRating: freezed == officialRating ? _self.officialRating : officialRating // ignore: cast_nullable_to_non_nullable
as String?,communityRating: freezed == communityRating ? _self.communityRating : communityRating // ignore: cast_nullable_to_non_nullable
as double?,criticRating: freezed == criticRating ? _self.criticRating : criticRating // ignore: cast_nullable_to_non_nullable
as double?,imageTags: freezed == imageTags ? _self._imageTags : imageTags // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,backdropImageTags: freezed == backdropImageTags ? _self._backdropImageTags : backdropImageTags // ignore: cast_nullable_to_non_nullable
as List<String>?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,genres: freezed == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>?,providerIds: freezed == providerIds ? _self._providerIds : providerIds // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,studios: freezed == studios ? _self._studios : studios // ignore: cast_nullable_to_non_nullable
as List<StudioDto>?,runTimeTicks: freezed == runTimeTicks ? _self.runTimeTicks : runTimeTicks // ignore: cast_nullable_to_non_nullable
as int?,productionYear: freezed == productionYear ? _self.productionYear : productionYear // ignore: cast_nullable_to_non_nullable
as int?,isFolder: freezed == isFolder ? _self.isFolder : isFolder // ignore: cast_nullable_to_non_nullable
as bool?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,seriesId: freezed == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as String?,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,seasonName: freezed == seasonName ? _self.seasonName : seasonName // ignore: cast_nullable_to_non_nullable
as String?,indexNumber: freezed == indexNumber ? _self.indexNumber : indexNumber // ignore: cast_nullable_to_non_nullable
as int?,parentIndexNumber: freezed == parentIndexNumber ? _self.parentIndexNumber : parentIndexNumber // ignore: cast_nullable_to_non_nullable
as int?,people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as List<PersonDto>,mediaSources: null == mediaSources ? _self._mediaSources : mediaSources // ignore: cast_nullable_to_non_nullable
as List<MediaSourceInfo>,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as UserItemDataDto?,collectionType: freezed == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String?,childCount: freezed == childCount ? _self.childCount : childCount // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserItemDataDtoCopyWith<$Res>? get userData {
    if (_self.userData == null) {
    return null;
  }

  return $UserItemDataDtoCopyWith<$Res>(_self.userData!, (value) {
    return _then(_self.copyWith(userData: value));
  });
}
}

// dart format on
