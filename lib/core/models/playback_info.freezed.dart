// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaybackInfo {

/// List of available media sources for playback.
 List<MediaSourceInfo> get mediaSources;/// Error code if playback information retrieval failed.
 String? get errorCode;
/// Create a copy of PlaybackInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackInfoCopyWith<PlaybackInfo> get copyWith => _$PlaybackInfoCopyWithImpl<PlaybackInfo>(this as PlaybackInfo, _$identity);

  /// Serializes this PlaybackInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackInfo&&const DeepCollectionEquality().equals(other.mediaSources, mediaSources)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mediaSources),errorCode);

@override
String toString() {
  return 'PlaybackInfo(mediaSources: $mediaSources, errorCode: $errorCode)';
}


}

/// @nodoc
abstract mixin class $PlaybackInfoCopyWith<$Res>  {
  factory $PlaybackInfoCopyWith(PlaybackInfo value, $Res Function(PlaybackInfo) _then) = _$PlaybackInfoCopyWithImpl;
@useResult
$Res call({
 List<MediaSourceInfo> mediaSources, String? errorCode
});




}
/// @nodoc
class _$PlaybackInfoCopyWithImpl<$Res>
    implements $PlaybackInfoCopyWith<$Res> {
  _$PlaybackInfoCopyWithImpl(this._self, this._then);

  final PlaybackInfo _self;
  final $Res Function(PlaybackInfo) _then;

/// Create a copy of PlaybackInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaSources = null,Object? errorCode = freezed,}) {
  return _then(_self.copyWith(
mediaSources: null == mediaSources ? _self.mediaSources : mediaSources // ignore: cast_nullable_to_non_nullable
as List<MediaSourceInfo>,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackInfo].
extension PlaybackInfoPatterns on PlaybackInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackInfo value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MediaSourceInfo> mediaSources,  String? errorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackInfo() when $default != null:
return $default(_that.mediaSources,_that.errorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MediaSourceInfo> mediaSources,  String? errorCode)  $default,) {final _that = this;
switch (_that) {
case _PlaybackInfo():
return $default(_that.mediaSources,_that.errorCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MediaSourceInfo> mediaSources,  String? errorCode)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackInfo() when $default != null:
return $default(_that.mediaSources,_that.errorCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaybackInfo implements PlaybackInfo {
  const _PlaybackInfo({final  List<MediaSourceInfo> mediaSources = const [], this.errorCode}): _mediaSources = mediaSources;
  factory _PlaybackInfo.fromJson(Map<String, dynamic> json) => _$PlaybackInfoFromJson(json);

/// List of available media sources for playback.
 final  List<MediaSourceInfo> _mediaSources;
/// List of available media sources for playback.
@override@JsonKey() List<MediaSourceInfo> get mediaSources {
  if (_mediaSources is EqualUnmodifiableListView) return _mediaSources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaSources);
}

/// Error code if playback information retrieval failed.
@override final  String? errorCode;

/// Create a copy of PlaybackInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackInfoCopyWith<_PlaybackInfo> get copyWith => __$PlaybackInfoCopyWithImpl<_PlaybackInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackInfo&&const DeepCollectionEquality().equals(other._mediaSources, _mediaSources)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mediaSources),errorCode);

@override
String toString() {
  return 'PlaybackInfo(mediaSources: $mediaSources, errorCode: $errorCode)';
}


}

/// @nodoc
abstract mixin class _$PlaybackInfoCopyWith<$Res> implements $PlaybackInfoCopyWith<$Res> {
  factory _$PlaybackInfoCopyWith(_PlaybackInfo value, $Res Function(_PlaybackInfo) _then) = __$PlaybackInfoCopyWithImpl;
@override @useResult
$Res call({
 List<MediaSourceInfo> mediaSources, String? errorCode
});




}
/// @nodoc
class __$PlaybackInfoCopyWithImpl<$Res>
    implements _$PlaybackInfoCopyWith<$Res> {
  __$PlaybackInfoCopyWithImpl(this._self, this._then);

  final _PlaybackInfo _self;
  final $Res Function(_PlaybackInfo) _then;

/// Create a copy of PlaybackInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaSources = null,Object? errorCode = freezed,}) {
  return _then(_PlaybackInfo(
mediaSources: null == mediaSources ? _self._mediaSources : mediaSources // ignore: cast_nullable_to_non_nullable
as List<MediaSourceInfo>,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
