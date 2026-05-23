// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_source_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaSourceInfo {

/// Unique identifier for the media source.
 String? get id;/// Human-readable name of the media source.
 String? get name;/// File system path to the media file.
 String? get path;/// Transfer protocol (File, Http, Rtmp, Rtsp, etc.).
 String? get protocol;/// Source type (Default, Grouping, Placeholder).
 String? get type;/// File size in bytes.
 int? get size;/// Container format (e.g., mp4, mkv, avi).
 String? get container;/// URL for direct streaming without transcoding.
 String? get directStreamUrl;/// URL for transcoded streaming.
 String? get transcodingUrl;/// Whether the source supports direct stream.
 bool? get supportsDirectStream;/// Whether the source supports transcoding.
 bool? get supportsTranscoding;/// List of media streams (video, audio, subtitle).
 List<MediaStream> get mediaStreams;/// Video type (VideoFile, Iso, Dvd, BluRay).
 String? get videoType;
/// Create a copy of MediaSourceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaSourceInfoCopyWith<MediaSourceInfo> get copyWith => _$MediaSourceInfoCopyWithImpl<MediaSourceInfo>(this as MediaSourceInfo, _$identity);

  /// Serializes this MediaSourceInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaSourceInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.type, type) || other.type == type)&&(identical(other.size, size) || other.size == size)&&(identical(other.container, container) || other.container == container)&&(identical(other.directStreamUrl, directStreamUrl) || other.directStreamUrl == directStreamUrl)&&(identical(other.transcodingUrl, transcodingUrl) || other.transcodingUrl == transcodingUrl)&&(identical(other.supportsDirectStream, supportsDirectStream) || other.supportsDirectStream == supportsDirectStream)&&(identical(other.supportsTranscoding, supportsTranscoding) || other.supportsTranscoding == supportsTranscoding)&&const DeepCollectionEquality().equals(other.mediaStreams, mediaStreams)&&(identical(other.videoType, videoType) || other.videoType == videoType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,path,protocol,type,size,container,directStreamUrl,transcodingUrl,supportsDirectStream,supportsTranscoding,const DeepCollectionEquality().hash(mediaStreams),videoType);

@override
String toString() {
  return 'MediaSourceInfo(id: $id, name: $name, path: $path, protocol: $protocol, type: $type, size: $size, container: $container, directStreamUrl: $directStreamUrl, transcodingUrl: $transcodingUrl, supportsDirectStream: $supportsDirectStream, supportsTranscoding: $supportsTranscoding, mediaStreams: $mediaStreams, videoType: $videoType)';
}


}

/// @nodoc
abstract mixin class $MediaSourceInfoCopyWith<$Res>  {
  factory $MediaSourceInfoCopyWith(MediaSourceInfo value, $Res Function(MediaSourceInfo) _then) = _$MediaSourceInfoCopyWithImpl;
@useResult
$Res call({
 String? id, String? name, String? path, String? protocol, String? type, int? size, String? container, String? directStreamUrl, String? transcodingUrl, bool? supportsDirectStream, bool? supportsTranscoding, List<MediaStream> mediaStreams, String? videoType
});




}
/// @nodoc
class _$MediaSourceInfoCopyWithImpl<$Res>
    implements $MediaSourceInfoCopyWith<$Res> {
  _$MediaSourceInfoCopyWithImpl(this._self, this._then);

  final MediaSourceInfo _self;
  final $Res Function(MediaSourceInfo) _then;

/// Create a copy of MediaSourceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? path = freezed,Object? protocol = freezed,Object? type = freezed,Object? size = freezed,Object? container = freezed,Object? directStreamUrl = freezed,Object? transcodingUrl = freezed,Object? supportsDirectStream = freezed,Object? supportsTranscoding = freezed,Object? mediaStreams = null,Object? videoType = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,protocol: freezed == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as String?,directStreamUrl: freezed == directStreamUrl ? _self.directStreamUrl : directStreamUrl // ignore: cast_nullable_to_non_nullable
as String?,transcodingUrl: freezed == transcodingUrl ? _self.transcodingUrl : transcodingUrl // ignore: cast_nullable_to_non_nullable
as String?,supportsDirectStream: freezed == supportsDirectStream ? _self.supportsDirectStream : supportsDirectStream // ignore: cast_nullable_to_non_nullable
as bool?,supportsTranscoding: freezed == supportsTranscoding ? _self.supportsTranscoding : supportsTranscoding // ignore: cast_nullable_to_non_nullable
as bool?,mediaStreams: null == mediaStreams ? _self.mediaStreams : mediaStreams // ignore: cast_nullable_to_non_nullable
as List<MediaStream>,videoType: freezed == videoType ? _self.videoType : videoType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaSourceInfo].
extension MediaSourceInfoPatterns on MediaSourceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaSourceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaSourceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaSourceInfo value)  $default,){
final _that = this;
switch (_that) {
case _MediaSourceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaSourceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _MediaSourceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name,  String? path,  String? protocol,  String? type,  int? size,  String? container,  String? directStreamUrl,  String? transcodingUrl,  bool? supportsDirectStream,  bool? supportsTranscoding,  List<MediaStream> mediaStreams,  String? videoType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaSourceInfo() when $default != null:
return $default(_that.id,_that.name,_that.path,_that.protocol,_that.type,_that.size,_that.container,_that.directStreamUrl,_that.transcodingUrl,_that.supportsDirectStream,_that.supportsTranscoding,_that.mediaStreams,_that.videoType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name,  String? path,  String? protocol,  String? type,  int? size,  String? container,  String? directStreamUrl,  String? transcodingUrl,  bool? supportsDirectStream,  bool? supportsTranscoding,  List<MediaStream> mediaStreams,  String? videoType)  $default,) {final _that = this;
switch (_that) {
case _MediaSourceInfo():
return $default(_that.id,_that.name,_that.path,_that.protocol,_that.type,_that.size,_that.container,_that.directStreamUrl,_that.transcodingUrl,_that.supportsDirectStream,_that.supportsTranscoding,_that.mediaStreams,_that.videoType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name,  String? path,  String? protocol,  String? type,  int? size,  String? container,  String? directStreamUrl,  String? transcodingUrl,  bool? supportsDirectStream,  bool? supportsTranscoding,  List<MediaStream> mediaStreams,  String? videoType)?  $default,) {final _that = this;
switch (_that) {
case _MediaSourceInfo() when $default != null:
return $default(_that.id,_that.name,_that.path,_that.protocol,_that.type,_that.size,_that.container,_that.directStreamUrl,_that.transcodingUrl,_that.supportsDirectStream,_that.supportsTranscoding,_that.mediaStreams,_that.videoType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaSourceInfo implements MediaSourceInfo {
  const _MediaSourceInfo({this.id, this.name, this.path, this.protocol, this.type, this.size, this.container, this.directStreamUrl, this.transcodingUrl, this.supportsDirectStream, this.supportsTranscoding, final  List<MediaStream> mediaStreams = const [], this.videoType}): _mediaStreams = mediaStreams;
  factory _MediaSourceInfo.fromJson(Map<String, dynamic> json) => _$MediaSourceInfoFromJson(json);

/// Unique identifier for the media source.
@override final  String? id;
/// Human-readable name of the media source.
@override final  String? name;
/// File system path to the media file.
@override final  String? path;
/// Transfer protocol (File, Http, Rtmp, Rtsp, etc.).
@override final  String? protocol;
/// Source type (Default, Grouping, Placeholder).
@override final  String? type;
/// File size in bytes.
@override final  int? size;
/// Container format (e.g., mp4, mkv, avi).
@override final  String? container;
/// URL for direct streaming without transcoding.
@override final  String? directStreamUrl;
/// URL for transcoded streaming.
@override final  String? transcodingUrl;
/// Whether the source supports direct stream.
@override final  bool? supportsDirectStream;
/// Whether the source supports transcoding.
@override final  bool? supportsTranscoding;
/// List of media streams (video, audio, subtitle).
 final  List<MediaStream> _mediaStreams;
/// List of media streams (video, audio, subtitle).
@override@JsonKey() List<MediaStream> get mediaStreams {
  if (_mediaStreams is EqualUnmodifiableListView) return _mediaStreams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mediaStreams);
}

/// Video type (VideoFile, Iso, Dvd, BluRay).
@override final  String? videoType;

/// Create a copy of MediaSourceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaSourceInfoCopyWith<_MediaSourceInfo> get copyWith => __$MediaSourceInfoCopyWithImpl<_MediaSourceInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaSourceInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaSourceInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.type, type) || other.type == type)&&(identical(other.size, size) || other.size == size)&&(identical(other.container, container) || other.container == container)&&(identical(other.directStreamUrl, directStreamUrl) || other.directStreamUrl == directStreamUrl)&&(identical(other.transcodingUrl, transcodingUrl) || other.transcodingUrl == transcodingUrl)&&(identical(other.supportsDirectStream, supportsDirectStream) || other.supportsDirectStream == supportsDirectStream)&&(identical(other.supportsTranscoding, supportsTranscoding) || other.supportsTranscoding == supportsTranscoding)&&const DeepCollectionEquality().equals(other._mediaStreams, _mediaStreams)&&(identical(other.videoType, videoType) || other.videoType == videoType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,path,protocol,type,size,container,directStreamUrl,transcodingUrl,supportsDirectStream,supportsTranscoding,const DeepCollectionEquality().hash(_mediaStreams),videoType);

@override
String toString() {
  return 'MediaSourceInfo(id: $id, name: $name, path: $path, protocol: $protocol, type: $type, size: $size, container: $container, directStreamUrl: $directStreamUrl, transcodingUrl: $transcodingUrl, supportsDirectStream: $supportsDirectStream, supportsTranscoding: $supportsTranscoding, mediaStreams: $mediaStreams, videoType: $videoType)';
}


}

/// @nodoc
abstract mixin class _$MediaSourceInfoCopyWith<$Res> implements $MediaSourceInfoCopyWith<$Res> {
  factory _$MediaSourceInfoCopyWith(_MediaSourceInfo value, $Res Function(_MediaSourceInfo) _then) = __$MediaSourceInfoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name, String? path, String? protocol, String? type, int? size, String? container, String? directStreamUrl, String? transcodingUrl, bool? supportsDirectStream, bool? supportsTranscoding, List<MediaStream> mediaStreams, String? videoType
});




}
/// @nodoc
class __$MediaSourceInfoCopyWithImpl<$Res>
    implements _$MediaSourceInfoCopyWith<$Res> {
  __$MediaSourceInfoCopyWithImpl(this._self, this._then);

  final _MediaSourceInfo _self;
  final $Res Function(_MediaSourceInfo) _then;

/// Create a copy of MediaSourceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? path = freezed,Object? protocol = freezed,Object? type = freezed,Object? size = freezed,Object? container = freezed,Object? directStreamUrl = freezed,Object? transcodingUrl = freezed,Object? supportsDirectStream = freezed,Object? supportsTranscoding = freezed,Object? mediaStreams = null,Object? videoType = freezed,}) {
  return _then(_MediaSourceInfo(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,protocol: freezed == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int?,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as String?,directStreamUrl: freezed == directStreamUrl ? _self.directStreamUrl : directStreamUrl // ignore: cast_nullable_to_non_nullable
as String?,transcodingUrl: freezed == transcodingUrl ? _self.transcodingUrl : transcodingUrl // ignore: cast_nullable_to_non_nullable
as String?,supportsDirectStream: freezed == supportsDirectStream ? _self.supportsDirectStream : supportsDirectStream // ignore: cast_nullable_to_non_nullable
as bool?,supportsTranscoding: freezed == supportsTranscoding ? _self.supportsTranscoding : supportsTranscoding // ignore: cast_nullable_to_non_nullable
as bool?,mediaStreams: null == mediaStreams ? _self._mediaStreams : mediaStreams // ignore: cast_nullable_to_non_nullable
as List<MediaStream>,videoType: freezed == videoType ? _self.videoType : videoType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
