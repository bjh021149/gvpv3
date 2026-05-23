// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_stream.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaStream {

/// Stream index within the container.
 int? get index;/// Stream type: Video, Audio, or Subtitle.
 String? get type;/// Codec name (e.g., h264, aac, ass).
 String? get codec;/// ISO language code (e.g., eng, jpn, chi).
 String? get language;/// Display title for the stream.
 String? get title;/// Whether this stream is selected by default.
@JsonKey(name: 'IsDefault') bool? get isDefault;/// Whether this is an external subtitle file.
@JsonKey(name: 'IsExternal') bool? get isExternal;/// File path for external streams.
 String? get path;/// Human-readable display title combining codec and language.
 String? get displayTitle;/// Video height in pixels (for video streams).
 int? get height;/// Video width in pixels (for video streams).
 int? get width;/// Audio channel layout (e.g., stereo, 5.1, 7.1).
 String? get channelLayout;
/// Create a copy of MediaStream
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaStreamCopyWith<MediaStream> get copyWith => _$MediaStreamCopyWithImpl<MediaStream>(this as MediaStream, _$identity);

  /// Serializes this MediaStream to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaStream&&(identical(other.index, index) || other.index == index)&&(identical(other.type, type) || other.type == type)&&(identical(other.codec, codec) || other.codec == codec)&&(identical(other.language, language) || other.language == language)&&(identical(other.title, title) || other.title == title)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isExternal, isExternal) || other.isExternal == isExternal)&&(identical(other.path, path) || other.path == path)&&(identical(other.displayTitle, displayTitle) || other.displayTitle == displayTitle)&&(identical(other.height, height) || other.height == height)&&(identical(other.width, width) || other.width == width)&&(identical(other.channelLayout, channelLayout) || other.channelLayout == channelLayout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,type,codec,language,title,isDefault,isExternal,path,displayTitle,height,width,channelLayout);

@override
String toString() {
  return 'MediaStream(index: $index, type: $type, codec: $codec, language: $language, title: $title, isDefault: $isDefault, isExternal: $isExternal, path: $path, displayTitle: $displayTitle, height: $height, width: $width, channelLayout: $channelLayout)';
}


}

/// @nodoc
abstract mixin class $MediaStreamCopyWith<$Res>  {
  factory $MediaStreamCopyWith(MediaStream value, $Res Function(MediaStream) _then) = _$MediaStreamCopyWithImpl;
@useResult
$Res call({
 int? index, String? type, String? codec, String? language, String? title,@JsonKey(name: 'IsDefault') bool? isDefault,@JsonKey(name: 'IsExternal') bool? isExternal, String? path, String? displayTitle, int? height, int? width, String? channelLayout
});




}
/// @nodoc
class _$MediaStreamCopyWithImpl<$Res>
    implements $MediaStreamCopyWith<$Res> {
  _$MediaStreamCopyWithImpl(this._self, this._then);

  final MediaStream _self;
  final $Res Function(MediaStream) _then;

/// Create a copy of MediaStream
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = freezed,Object? type = freezed,Object? codec = freezed,Object? language = freezed,Object? title = freezed,Object? isDefault = freezed,Object? isExternal = freezed,Object? path = freezed,Object? displayTitle = freezed,Object? height = freezed,Object? width = freezed,Object? channelLayout = freezed,}) {
  return _then(_self.copyWith(
index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,codec: freezed == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,isDefault: freezed == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool?,isExternal: freezed == isExternal ? _self.isExternal : isExternal // ignore: cast_nullable_to_non_nullable
as bool?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,displayTitle: freezed == displayTitle ? _self.displayTitle : displayTitle // ignore: cast_nullable_to_non_nullable
as String?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,channelLayout: freezed == channelLayout ? _self.channelLayout : channelLayout // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaStream].
extension MediaStreamPatterns on MediaStream {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaStream value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaStream() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaStream value)  $default,){
final _that = this;
switch (_that) {
case _MediaStream():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaStream value)?  $default,){
final _that = this;
switch (_that) {
case _MediaStream() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? index,  String? type,  String? codec,  String? language,  String? title, @JsonKey(name: 'IsDefault')  bool? isDefault, @JsonKey(name: 'IsExternal')  bool? isExternal,  String? path,  String? displayTitle,  int? height,  int? width,  String? channelLayout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaStream() when $default != null:
return $default(_that.index,_that.type,_that.codec,_that.language,_that.title,_that.isDefault,_that.isExternal,_that.path,_that.displayTitle,_that.height,_that.width,_that.channelLayout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? index,  String? type,  String? codec,  String? language,  String? title, @JsonKey(name: 'IsDefault')  bool? isDefault, @JsonKey(name: 'IsExternal')  bool? isExternal,  String? path,  String? displayTitle,  int? height,  int? width,  String? channelLayout)  $default,) {final _that = this;
switch (_that) {
case _MediaStream():
return $default(_that.index,_that.type,_that.codec,_that.language,_that.title,_that.isDefault,_that.isExternal,_that.path,_that.displayTitle,_that.height,_that.width,_that.channelLayout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? index,  String? type,  String? codec,  String? language,  String? title, @JsonKey(name: 'IsDefault')  bool? isDefault, @JsonKey(name: 'IsExternal')  bool? isExternal,  String? path,  String? displayTitle,  int? height,  int? width,  String? channelLayout)?  $default,) {final _that = this;
switch (_that) {
case _MediaStream() when $default != null:
return $default(_that.index,_that.type,_that.codec,_that.language,_that.title,_that.isDefault,_that.isExternal,_that.path,_that.displayTitle,_that.height,_that.width,_that.channelLayout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaStream implements MediaStream {
  const _MediaStream({this.index, this.type, this.codec, this.language, this.title, @JsonKey(name: 'IsDefault') this.isDefault, @JsonKey(name: 'IsExternal') this.isExternal, this.path, this.displayTitle, this.height, this.width, this.channelLayout});
  factory _MediaStream.fromJson(Map<String, dynamic> json) => _$MediaStreamFromJson(json);

/// Stream index within the container.
@override final  int? index;
/// Stream type: Video, Audio, or Subtitle.
@override final  String? type;
/// Codec name (e.g., h264, aac, ass).
@override final  String? codec;
/// ISO language code (e.g., eng, jpn, chi).
@override final  String? language;
/// Display title for the stream.
@override final  String? title;
/// Whether this stream is selected by default.
@override@JsonKey(name: 'IsDefault') final  bool? isDefault;
/// Whether this is an external subtitle file.
@override@JsonKey(name: 'IsExternal') final  bool? isExternal;
/// File path for external streams.
@override final  String? path;
/// Human-readable display title combining codec and language.
@override final  String? displayTitle;
/// Video height in pixels (for video streams).
@override final  int? height;
/// Video width in pixels (for video streams).
@override final  int? width;
/// Audio channel layout (e.g., stereo, 5.1, 7.1).
@override final  String? channelLayout;

/// Create a copy of MediaStream
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaStreamCopyWith<_MediaStream> get copyWith => __$MediaStreamCopyWithImpl<_MediaStream>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaStreamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaStream&&(identical(other.index, index) || other.index == index)&&(identical(other.type, type) || other.type == type)&&(identical(other.codec, codec) || other.codec == codec)&&(identical(other.language, language) || other.language == language)&&(identical(other.title, title) || other.title == title)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isExternal, isExternal) || other.isExternal == isExternal)&&(identical(other.path, path) || other.path == path)&&(identical(other.displayTitle, displayTitle) || other.displayTitle == displayTitle)&&(identical(other.height, height) || other.height == height)&&(identical(other.width, width) || other.width == width)&&(identical(other.channelLayout, channelLayout) || other.channelLayout == channelLayout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,type,codec,language,title,isDefault,isExternal,path,displayTitle,height,width,channelLayout);

@override
String toString() {
  return 'MediaStream(index: $index, type: $type, codec: $codec, language: $language, title: $title, isDefault: $isDefault, isExternal: $isExternal, path: $path, displayTitle: $displayTitle, height: $height, width: $width, channelLayout: $channelLayout)';
}


}

/// @nodoc
abstract mixin class _$MediaStreamCopyWith<$Res> implements $MediaStreamCopyWith<$Res> {
  factory _$MediaStreamCopyWith(_MediaStream value, $Res Function(_MediaStream) _then) = __$MediaStreamCopyWithImpl;
@override @useResult
$Res call({
 int? index, String? type, String? codec, String? language, String? title,@JsonKey(name: 'IsDefault') bool? isDefault,@JsonKey(name: 'IsExternal') bool? isExternal, String? path, String? displayTitle, int? height, int? width, String? channelLayout
});




}
/// @nodoc
class __$MediaStreamCopyWithImpl<$Res>
    implements _$MediaStreamCopyWith<$Res> {
  __$MediaStreamCopyWithImpl(this._self, this._then);

  final _MediaStream _self;
  final $Res Function(_MediaStream) _then;

/// Create a copy of MediaStream
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = freezed,Object? type = freezed,Object? codec = freezed,Object? language = freezed,Object? title = freezed,Object? isDefault = freezed,Object? isExternal = freezed,Object? path = freezed,Object? displayTitle = freezed,Object? height = freezed,Object? width = freezed,Object? channelLayout = freezed,}) {
  return _then(_MediaStream(
index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,codec: freezed == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,isDefault: freezed == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool?,isExternal: freezed == isExternal ? _self.isExternal : isExternal // ignore: cast_nullable_to_non_nullable
as bool?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,displayTitle: freezed == displayTitle ? _self.displayTitle : displayTitle // ignore: cast_nullable_to_non_nullable
as String?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,channelLayout: freezed == channelLayout ? _self.channelLayout : channelLayout // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
