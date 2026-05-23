// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserConfiguration {

/// Audio language preference (ISO code).
 String? get audioLanguagePreference;/// Whether to play the default audio track regardless of language.
 bool? get playDefaultAudioTrack;/// Subtitle language preference (ISO code).
 String? get subtitleLanguagePreference;/// Whether to display subtitles by default.
 bool? get displayMissingEpisodes;/// Grouped folders configuration.
 List<String> get groupedFolders;/// Subtitle playback mode.
 String? get subtitleMode;/// Whether to display collections within the media library.
 bool? get displayCollectionsView;/// Whether to display the "My Media" section on the home screen.
 bool? get displayMyMedia;
/// Create a copy of UserConfiguration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserConfigurationCopyWith<UserConfiguration> get copyWith => _$UserConfigurationCopyWithImpl<UserConfiguration>(this as UserConfiguration, _$identity);

  /// Serializes this UserConfiguration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserConfiguration&&(identical(other.audioLanguagePreference, audioLanguagePreference) || other.audioLanguagePreference == audioLanguagePreference)&&(identical(other.playDefaultAudioTrack, playDefaultAudioTrack) || other.playDefaultAudioTrack == playDefaultAudioTrack)&&(identical(other.subtitleLanguagePreference, subtitleLanguagePreference) || other.subtitleLanguagePreference == subtitleLanguagePreference)&&(identical(other.displayMissingEpisodes, displayMissingEpisodes) || other.displayMissingEpisodes == displayMissingEpisodes)&&const DeepCollectionEquality().equals(other.groupedFolders, groupedFolders)&&(identical(other.subtitleMode, subtitleMode) || other.subtitleMode == subtitleMode)&&(identical(other.displayCollectionsView, displayCollectionsView) || other.displayCollectionsView == displayCollectionsView)&&(identical(other.displayMyMedia, displayMyMedia) || other.displayMyMedia == displayMyMedia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,audioLanguagePreference,playDefaultAudioTrack,subtitleLanguagePreference,displayMissingEpisodes,const DeepCollectionEquality().hash(groupedFolders),subtitleMode,displayCollectionsView,displayMyMedia);

@override
String toString() {
  return 'UserConfiguration(audioLanguagePreference: $audioLanguagePreference, playDefaultAudioTrack: $playDefaultAudioTrack, subtitleLanguagePreference: $subtitleLanguagePreference, displayMissingEpisodes: $displayMissingEpisodes, groupedFolders: $groupedFolders, subtitleMode: $subtitleMode, displayCollectionsView: $displayCollectionsView, displayMyMedia: $displayMyMedia)';
}


}

/// @nodoc
abstract mixin class $UserConfigurationCopyWith<$Res>  {
  factory $UserConfigurationCopyWith(UserConfiguration value, $Res Function(UserConfiguration) _then) = _$UserConfigurationCopyWithImpl;
@useResult
$Res call({
 String? audioLanguagePreference, bool? playDefaultAudioTrack, String? subtitleLanguagePreference, bool? displayMissingEpisodes, List<String> groupedFolders, String? subtitleMode, bool? displayCollectionsView, bool? displayMyMedia
});




}
/// @nodoc
class _$UserConfigurationCopyWithImpl<$Res>
    implements $UserConfigurationCopyWith<$Res> {
  _$UserConfigurationCopyWithImpl(this._self, this._then);

  final UserConfiguration _self;
  final $Res Function(UserConfiguration) _then;

/// Create a copy of UserConfiguration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? audioLanguagePreference = freezed,Object? playDefaultAudioTrack = freezed,Object? subtitleLanguagePreference = freezed,Object? displayMissingEpisodes = freezed,Object? groupedFolders = null,Object? subtitleMode = freezed,Object? displayCollectionsView = freezed,Object? displayMyMedia = freezed,}) {
  return _then(_self.copyWith(
audioLanguagePreference: freezed == audioLanguagePreference ? _self.audioLanguagePreference : audioLanguagePreference // ignore: cast_nullable_to_non_nullable
as String?,playDefaultAudioTrack: freezed == playDefaultAudioTrack ? _self.playDefaultAudioTrack : playDefaultAudioTrack // ignore: cast_nullable_to_non_nullable
as bool?,subtitleLanguagePreference: freezed == subtitleLanguagePreference ? _self.subtitleLanguagePreference : subtitleLanguagePreference // ignore: cast_nullable_to_non_nullable
as String?,displayMissingEpisodes: freezed == displayMissingEpisodes ? _self.displayMissingEpisodes : displayMissingEpisodes // ignore: cast_nullable_to_non_nullable
as bool?,groupedFolders: null == groupedFolders ? _self.groupedFolders : groupedFolders // ignore: cast_nullable_to_non_nullable
as List<String>,subtitleMode: freezed == subtitleMode ? _self.subtitleMode : subtitleMode // ignore: cast_nullable_to_non_nullable
as String?,displayCollectionsView: freezed == displayCollectionsView ? _self.displayCollectionsView : displayCollectionsView // ignore: cast_nullable_to_non_nullable
as bool?,displayMyMedia: freezed == displayMyMedia ? _self.displayMyMedia : displayMyMedia // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserConfiguration].
extension UserConfigurationPatterns on UserConfiguration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserConfiguration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserConfiguration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserConfiguration value)  $default,){
final _that = this;
switch (_that) {
case _UserConfiguration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserConfiguration value)?  $default,){
final _that = this;
switch (_that) {
case _UserConfiguration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? audioLanguagePreference,  bool? playDefaultAudioTrack,  String? subtitleLanguagePreference,  bool? displayMissingEpisodes,  List<String> groupedFolders,  String? subtitleMode,  bool? displayCollectionsView,  bool? displayMyMedia)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserConfiguration() when $default != null:
return $default(_that.audioLanguagePreference,_that.playDefaultAudioTrack,_that.subtitleLanguagePreference,_that.displayMissingEpisodes,_that.groupedFolders,_that.subtitleMode,_that.displayCollectionsView,_that.displayMyMedia);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? audioLanguagePreference,  bool? playDefaultAudioTrack,  String? subtitleLanguagePreference,  bool? displayMissingEpisodes,  List<String> groupedFolders,  String? subtitleMode,  bool? displayCollectionsView,  bool? displayMyMedia)  $default,) {final _that = this;
switch (_that) {
case _UserConfiguration():
return $default(_that.audioLanguagePreference,_that.playDefaultAudioTrack,_that.subtitleLanguagePreference,_that.displayMissingEpisodes,_that.groupedFolders,_that.subtitleMode,_that.displayCollectionsView,_that.displayMyMedia);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? audioLanguagePreference,  bool? playDefaultAudioTrack,  String? subtitleLanguagePreference,  bool? displayMissingEpisodes,  List<String> groupedFolders,  String? subtitleMode,  bool? displayCollectionsView,  bool? displayMyMedia)?  $default,) {final _that = this;
switch (_that) {
case _UserConfiguration() when $default != null:
return $default(_that.audioLanguagePreference,_that.playDefaultAudioTrack,_that.subtitleLanguagePreference,_that.displayMissingEpisodes,_that.groupedFolders,_that.subtitleMode,_that.displayCollectionsView,_that.displayMyMedia);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserConfiguration implements UserConfiguration {
  const _UserConfiguration({this.audioLanguagePreference, this.playDefaultAudioTrack, this.subtitleLanguagePreference, this.displayMissingEpisodes, final  List<String> groupedFolders = const [], this.subtitleMode, this.displayCollectionsView, this.displayMyMedia}): _groupedFolders = groupedFolders;
  factory _UserConfiguration.fromJson(Map<String, dynamic> json) => _$UserConfigurationFromJson(json);

/// Audio language preference (ISO code).
@override final  String? audioLanguagePreference;
/// Whether to play the default audio track regardless of language.
@override final  bool? playDefaultAudioTrack;
/// Subtitle language preference (ISO code).
@override final  String? subtitleLanguagePreference;
/// Whether to display subtitles by default.
@override final  bool? displayMissingEpisodes;
/// Grouped folders configuration.
 final  List<String> _groupedFolders;
/// Grouped folders configuration.
@override@JsonKey() List<String> get groupedFolders {
  if (_groupedFolders is EqualUnmodifiableListView) return _groupedFolders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groupedFolders);
}

/// Subtitle playback mode.
@override final  String? subtitleMode;
/// Whether to display collections within the media library.
@override final  bool? displayCollectionsView;
/// Whether to display the "My Media" section on the home screen.
@override final  bool? displayMyMedia;

/// Create a copy of UserConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserConfigurationCopyWith<_UserConfiguration> get copyWith => __$UserConfigurationCopyWithImpl<_UserConfiguration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserConfigurationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserConfiguration&&(identical(other.audioLanguagePreference, audioLanguagePreference) || other.audioLanguagePreference == audioLanguagePreference)&&(identical(other.playDefaultAudioTrack, playDefaultAudioTrack) || other.playDefaultAudioTrack == playDefaultAudioTrack)&&(identical(other.subtitleLanguagePreference, subtitleLanguagePreference) || other.subtitleLanguagePreference == subtitleLanguagePreference)&&(identical(other.displayMissingEpisodes, displayMissingEpisodes) || other.displayMissingEpisodes == displayMissingEpisodes)&&const DeepCollectionEquality().equals(other._groupedFolders, _groupedFolders)&&(identical(other.subtitleMode, subtitleMode) || other.subtitleMode == subtitleMode)&&(identical(other.displayCollectionsView, displayCollectionsView) || other.displayCollectionsView == displayCollectionsView)&&(identical(other.displayMyMedia, displayMyMedia) || other.displayMyMedia == displayMyMedia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,audioLanguagePreference,playDefaultAudioTrack,subtitleLanguagePreference,displayMissingEpisodes,const DeepCollectionEquality().hash(_groupedFolders),subtitleMode,displayCollectionsView,displayMyMedia);

@override
String toString() {
  return 'UserConfiguration(audioLanguagePreference: $audioLanguagePreference, playDefaultAudioTrack: $playDefaultAudioTrack, subtitleLanguagePreference: $subtitleLanguagePreference, displayMissingEpisodes: $displayMissingEpisodes, groupedFolders: $groupedFolders, subtitleMode: $subtitleMode, displayCollectionsView: $displayCollectionsView, displayMyMedia: $displayMyMedia)';
}


}

/// @nodoc
abstract mixin class _$UserConfigurationCopyWith<$Res> implements $UserConfigurationCopyWith<$Res> {
  factory _$UserConfigurationCopyWith(_UserConfiguration value, $Res Function(_UserConfiguration) _then) = __$UserConfigurationCopyWithImpl;
@override @useResult
$Res call({
 String? audioLanguagePreference, bool? playDefaultAudioTrack, String? subtitleLanguagePreference, bool? displayMissingEpisodes, List<String> groupedFolders, String? subtitleMode, bool? displayCollectionsView, bool? displayMyMedia
});




}
/// @nodoc
class __$UserConfigurationCopyWithImpl<$Res>
    implements _$UserConfigurationCopyWith<$Res> {
  __$UserConfigurationCopyWithImpl(this._self, this._then);

  final _UserConfiguration _self;
  final $Res Function(_UserConfiguration) _then;

/// Create a copy of UserConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? audioLanguagePreference = freezed,Object? playDefaultAudioTrack = freezed,Object? subtitleLanguagePreference = freezed,Object? displayMissingEpisodes = freezed,Object? groupedFolders = null,Object? subtitleMode = freezed,Object? displayCollectionsView = freezed,Object? displayMyMedia = freezed,}) {
  return _then(_UserConfiguration(
audioLanguagePreference: freezed == audioLanguagePreference ? _self.audioLanguagePreference : audioLanguagePreference // ignore: cast_nullable_to_non_nullable
as String?,playDefaultAudioTrack: freezed == playDefaultAudioTrack ? _self.playDefaultAudioTrack : playDefaultAudioTrack // ignore: cast_nullable_to_non_nullable
as bool?,subtitleLanguagePreference: freezed == subtitleLanguagePreference ? _self.subtitleLanguagePreference : subtitleLanguagePreference // ignore: cast_nullable_to_non_nullable
as String?,displayMissingEpisodes: freezed == displayMissingEpisodes ? _self.displayMissingEpisodes : displayMissingEpisodes // ignore: cast_nullable_to_non_nullable
as bool?,groupedFolders: null == groupedFolders ? _self._groupedFolders : groupedFolders // ignore: cast_nullable_to_non_nullable
as List<String>,subtitleMode: freezed == subtitleMode ? _self.subtitleMode : subtitleMode // ignore: cast_nullable_to_non_nullable
as String?,displayCollectionsView: freezed == displayCollectionsView ? _self.displayCollectionsView : displayCollectionsView // ignore: cast_nullable_to_non_nullable
as bool?,displayMyMedia: freezed == displayMyMedia ? _self.displayMyMedia : displayMyMedia // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$UserPolicy {

/// Whether the user is an administrator.
 bool? get isAdministrator;/// Whether the user is hidden from login screens.
 bool? get isHidden;/// Whether the user's activity is disabled.
 bool? get isDisabled;/// Maximum allowed bitrate for streaming.
 int? get maxBitrate;/// Allowed tags for content access control.
 List<String> get allowedTags;/// Blocked tags that the user cannot access.
 List<String> get blockedTags;/// Whether the user can manage the server settings.
 bool? get enableMediaPlayback;/// Whether the user can manage live TV.
 bool? get enableLiveTvManagement;/// Whether the user can access live TV.
 bool? get enableLiveTvAccess;/// Whether the user can manage other users.
 bool? get enableUserPreferenceAccess;/// Allowed device identifiers for this user.
 List<String> get enabledDevices;
/// Create a copy of UserPolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPolicyCopyWith<UserPolicy> get copyWith => _$UserPolicyCopyWithImpl<UserPolicy>(this as UserPolicy, _$identity);

  /// Serializes this UserPolicy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPolicy&&(identical(other.isAdministrator, isAdministrator) || other.isAdministrator == isAdministrator)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.isDisabled, isDisabled) || other.isDisabled == isDisabled)&&(identical(other.maxBitrate, maxBitrate) || other.maxBitrate == maxBitrate)&&const DeepCollectionEquality().equals(other.allowedTags, allowedTags)&&const DeepCollectionEquality().equals(other.blockedTags, blockedTags)&&(identical(other.enableMediaPlayback, enableMediaPlayback) || other.enableMediaPlayback == enableMediaPlayback)&&(identical(other.enableLiveTvManagement, enableLiveTvManagement) || other.enableLiveTvManagement == enableLiveTvManagement)&&(identical(other.enableLiveTvAccess, enableLiveTvAccess) || other.enableLiveTvAccess == enableLiveTvAccess)&&(identical(other.enableUserPreferenceAccess, enableUserPreferenceAccess) || other.enableUserPreferenceAccess == enableUserPreferenceAccess)&&const DeepCollectionEquality().equals(other.enabledDevices, enabledDevices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isAdministrator,isHidden,isDisabled,maxBitrate,const DeepCollectionEquality().hash(allowedTags),const DeepCollectionEquality().hash(blockedTags),enableMediaPlayback,enableLiveTvManagement,enableLiveTvAccess,enableUserPreferenceAccess,const DeepCollectionEquality().hash(enabledDevices));

@override
String toString() {
  return 'UserPolicy(isAdministrator: $isAdministrator, isHidden: $isHidden, isDisabled: $isDisabled, maxBitrate: $maxBitrate, allowedTags: $allowedTags, blockedTags: $blockedTags, enableMediaPlayback: $enableMediaPlayback, enableLiveTvManagement: $enableLiveTvManagement, enableLiveTvAccess: $enableLiveTvAccess, enableUserPreferenceAccess: $enableUserPreferenceAccess, enabledDevices: $enabledDevices)';
}


}

/// @nodoc
abstract mixin class $UserPolicyCopyWith<$Res>  {
  factory $UserPolicyCopyWith(UserPolicy value, $Res Function(UserPolicy) _then) = _$UserPolicyCopyWithImpl;
@useResult
$Res call({
 bool? isAdministrator, bool? isHidden, bool? isDisabled, int? maxBitrate, List<String> allowedTags, List<String> blockedTags, bool? enableMediaPlayback, bool? enableLiveTvManagement, bool? enableLiveTvAccess, bool? enableUserPreferenceAccess, List<String> enabledDevices
});




}
/// @nodoc
class _$UserPolicyCopyWithImpl<$Res>
    implements $UserPolicyCopyWith<$Res> {
  _$UserPolicyCopyWithImpl(this._self, this._then);

  final UserPolicy _self;
  final $Res Function(UserPolicy) _then;

/// Create a copy of UserPolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isAdministrator = freezed,Object? isHidden = freezed,Object? isDisabled = freezed,Object? maxBitrate = freezed,Object? allowedTags = null,Object? blockedTags = null,Object? enableMediaPlayback = freezed,Object? enableLiveTvManagement = freezed,Object? enableLiveTvAccess = freezed,Object? enableUserPreferenceAccess = freezed,Object? enabledDevices = null,}) {
  return _then(_self.copyWith(
isAdministrator: freezed == isAdministrator ? _self.isAdministrator : isAdministrator // ignore: cast_nullable_to_non_nullable
as bool?,isHidden: freezed == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool?,isDisabled: freezed == isDisabled ? _self.isDisabled : isDisabled // ignore: cast_nullable_to_non_nullable
as bool?,maxBitrate: freezed == maxBitrate ? _self.maxBitrate : maxBitrate // ignore: cast_nullable_to_non_nullable
as int?,allowedTags: null == allowedTags ? _self.allowedTags : allowedTags // ignore: cast_nullable_to_non_nullable
as List<String>,blockedTags: null == blockedTags ? _self.blockedTags : blockedTags // ignore: cast_nullable_to_non_nullable
as List<String>,enableMediaPlayback: freezed == enableMediaPlayback ? _self.enableMediaPlayback : enableMediaPlayback // ignore: cast_nullable_to_non_nullable
as bool?,enableLiveTvManagement: freezed == enableLiveTvManagement ? _self.enableLiveTvManagement : enableLiveTvManagement // ignore: cast_nullable_to_non_nullable
as bool?,enableLiveTvAccess: freezed == enableLiveTvAccess ? _self.enableLiveTvAccess : enableLiveTvAccess // ignore: cast_nullable_to_non_nullable
as bool?,enableUserPreferenceAccess: freezed == enableUserPreferenceAccess ? _self.enableUserPreferenceAccess : enableUserPreferenceAccess // ignore: cast_nullable_to_non_nullable
as bool?,enabledDevices: null == enabledDevices ? _self.enabledDevices : enabledDevices // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPolicy].
extension UserPolicyPatterns on UserPolicy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPolicy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPolicy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPolicy value)  $default,){
final _that = this;
switch (_that) {
case _UserPolicy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPolicy value)?  $default,){
final _that = this;
switch (_that) {
case _UserPolicy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? isAdministrator,  bool? isHidden,  bool? isDisabled,  int? maxBitrate,  List<String> allowedTags,  List<String> blockedTags,  bool? enableMediaPlayback,  bool? enableLiveTvManagement,  bool? enableLiveTvAccess,  bool? enableUserPreferenceAccess,  List<String> enabledDevices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPolicy() when $default != null:
return $default(_that.isAdministrator,_that.isHidden,_that.isDisabled,_that.maxBitrate,_that.allowedTags,_that.blockedTags,_that.enableMediaPlayback,_that.enableLiveTvManagement,_that.enableLiveTvAccess,_that.enableUserPreferenceAccess,_that.enabledDevices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? isAdministrator,  bool? isHidden,  bool? isDisabled,  int? maxBitrate,  List<String> allowedTags,  List<String> blockedTags,  bool? enableMediaPlayback,  bool? enableLiveTvManagement,  bool? enableLiveTvAccess,  bool? enableUserPreferenceAccess,  List<String> enabledDevices)  $default,) {final _that = this;
switch (_that) {
case _UserPolicy():
return $default(_that.isAdministrator,_that.isHidden,_that.isDisabled,_that.maxBitrate,_that.allowedTags,_that.blockedTags,_that.enableMediaPlayback,_that.enableLiveTvManagement,_that.enableLiveTvAccess,_that.enableUserPreferenceAccess,_that.enabledDevices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? isAdministrator,  bool? isHidden,  bool? isDisabled,  int? maxBitrate,  List<String> allowedTags,  List<String> blockedTags,  bool? enableMediaPlayback,  bool? enableLiveTvManagement,  bool? enableLiveTvAccess,  bool? enableUserPreferenceAccess,  List<String> enabledDevices)?  $default,) {final _that = this;
switch (_that) {
case _UserPolicy() when $default != null:
return $default(_that.isAdministrator,_that.isHidden,_that.isDisabled,_that.maxBitrate,_that.allowedTags,_that.blockedTags,_that.enableMediaPlayback,_that.enableLiveTvManagement,_that.enableLiveTvAccess,_that.enableUserPreferenceAccess,_that.enabledDevices);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPolicy implements UserPolicy {
  const _UserPolicy({this.isAdministrator, this.isHidden, this.isDisabled, this.maxBitrate, final  List<String> allowedTags = const [], final  List<String> blockedTags = const [], this.enableMediaPlayback, this.enableLiveTvManagement, this.enableLiveTvAccess, this.enableUserPreferenceAccess, final  List<String> enabledDevices = const []}): _allowedTags = allowedTags,_blockedTags = blockedTags,_enabledDevices = enabledDevices;
  factory _UserPolicy.fromJson(Map<String, dynamic> json) => _$UserPolicyFromJson(json);

/// Whether the user is an administrator.
@override final  bool? isAdministrator;
/// Whether the user is hidden from login screens.
@override final  bool? isHidden;
/// Whether the user's activity is disabled.
@override final  bool? isDisabled;
/// Maximum allowed bitrate for streaming.
@override final  int? maxBitrate;
/// Allowed tags for content access control.
 final  List<String> _allowedTags;
/// Allowed tags for content access control.
@override@JsonKey() List<String> get allowedTags {
  if (_allowedTags is EqualUnmodifiableListView) return _allowedTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedTags);
}

/// Blocked tags that the user cannot access.
 final  List<String> _blockedTags;
/// Blocked tags that the user cannot access.
@override@JsonKey() List<String> get blockedTags {
  if (_blockedTags is EqualUnmodifiableListView) return _blockedTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockedTags);
}

/// Whether the user can manage the server settings.
@override final  bool? enableMediaPlayback;
/// Whether the user can manage live TV.
@override final  bool? enableLiveTvManagement;
/// Whether the user can access live TV.
@override final  bool? enableLiveTvAccess;
/// Whether the user can manage other users.
@override final  bool? enableUserPreferenceAccess;
/// Allowed device identifiers for this user.
 final  List<String> _enabledDevices;
/// Allowed device identifiers for this user.
@override@JsonKey() List<String> get enabledDevices {
  if (_enabledDevices is EqualUnmodifiableListView) return _enabledDevices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_enabledDevices);
}


/// Create a copy of UserPolicy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPolicyCopyWith<_UserPolicy> get copyWith => __$UserPolicyCopyWithImpl<_UserPolicy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPolicyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPolicy&&(identical(other.isAdministrator, isAdministrator) || other.isAdministrator == isAdministrator)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.isDisabled, isDisabled) || other.isDisabled == isDisabled)&&(identical(other.maxBitrate, maxBitrate) || other.maxBitrate == maxBitrate)&&const DeepCollectionEquality().equals(other._allowedTags, _allowedTags)&&const DeepCollectionEquality().equals(other._blockedTags, _blockedTags)&&(identical(other.enableMediaPlayback, enableMediaPlayback) || other.enableMediaPlayback == enableMediaPlayback)&&(identical(other.enableLiveTvManagement, enableLiveTvManagement) || other.enableLiveTvManagement == enableLiveTvManagement)&&(identical(other.enableLiveTvAccess, enableLiveTvAccess) || other.enableLiveTvAccess == enableLiveTvAccess)&&(identical(other.enableUserPreferenceAccess, enableUserPreferenceAccess) || other.enableUserPreferenceAccess == enableUserPreferenceAccess)&&const DeepCollectionEquality().equals(other._enabledDevices, _enabledDevices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isAdministrator,isHidden,isDisabled,maxBitrate,const DeepCollectionEquality().hash(_allowedTags),const DeepCollectionEquality().hash(_blockedTags),enableMediaPlayback,enableLiveTvManagement,enableLiveTvAccess,enableUserPreferenceAccess,const DeepCollectionEquality().hash(_enabledDevices));

@override
String toString() {
  return 'UserPolicy(isAdministrator: $isAdministrator, isHidden: $isHidden, isDisabled: $isDisabled, maxBitrate: $maxBitrate, allowedTags: $allowedTags, blockedTags: $blockedTags, enableMediaPlayback: $enableMediaPlayback, enableLiveTvManagement: $enableLiveTvManagement, enableLiveTvAccess: $enableLiveTvAccess, enableUserPreferenceAccess: $enableUserPreferenceAccess, enabledDevices: $enabledDevices)';
}


}

/// @nodoc
abstract mixin class _$UserPolicyCopyWith<$Res> implements $UserPolicyCopyWith<$Res> {
  factory _$UserPolicyCopyWith(_UserPolicy value, $Res Function(_UserPolicy) _then) = __$UserPolicyCopyWithImpl;
@override @useResult
$Res call({
 bool? isAdministrator, bool? isHidden, bool? isDisabled, int? maxBitrate, List<String> allowedTags, List<String> blockedTags, bool? enableMediaPlayback, bool? enableLiveTvManagement, bool? enableLiveTvAccess, bool? enableUserPreferenceAccess, List<String> enabledDevices
});




}
/// @nodoc
class __$UserPolicyCopyWithImpl<$Res>
    implements _$UserPolicyCopyWith<$Res> {
  __$UserPolicyCopyWithImpl(this._self, this._then);

  final _UserPolicy _self;
  final $Res Function(_UserPolicy) _then;

/// Create a copy of UserPolicy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isAdministrator = freezed,Object? isHidden = freezed,Object? isDisabled = freezed,Object? maxBitrate = freezed,Object? allowedTags = null,Object? blockedTags = null,Object? enableMediaPlayback = freezed,Object? enableLiveTvManagement = freezed,Object? enableLiveTvAccess = freezed,Object? enableUserPreferenceAccess = freezed,Object? enabledDevices = null,}) {
  return _then(_UserPolicy(
isAdministrator: freezed == isAdministrator ? _self.isAdministrator : isAdministrator // ignore: cast_nullable_to_non_nullable
as bool?,isHidden: freezed == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool?,isDisabled: freezed == isDisabled ? _self.isDisabled : isDisabled // ignore: cast_nullable_to_non_nullable
as bool?,maxBitrate: freezed == maxBitrate ? _self.maxBitrate : maxBitrate // ignore: cast_nullable_to_non_nullable
as int?,allowedTags: null == allowedTags ? _self._allowedTags : allowedTags // ignore: cast_nullable_to_non_nullable
as List<String>,blockedTags: null == blockedTags ? _self._blockedTags : blockedTags // ignore: cast_nullable_to_non_nullable
as List<String>,enableMediaPlayback: freezed == enableMediaPlayback ? _self.enableMediaPlayback : enableMediaPlayback // ignore: cast_nullable_to_non_nullable
as bool?,enableLiveTvManagement: freezed == enableLiveTvManagement ? _self.enableLiveTvManagement : enableLiveTvManagement // ignore: cast_nullable_to_non_nullable
as bool?,enableLiveTvAccess: freezed == enableLiveTvAccess ? _self.enableLiveTvAccess : enableLiveTvAccess // ignore: cast_nullable_to_non_nullable
as bool?,enableUserPreferenceAccess: freezed == enableUserPreferenceAccess ? _self.enableUserPreferenceAccess : enableUserPreferenceAccess // ignore: cast_nullable_to_non_nullable
as bool?,enabledDevices: null == enabledDevices ? _self._enabledDevices : enabledDevices // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$UserDto {

/// Unique identifier for the user.
 String? get id;/// Display name of the user.
 String? get name;/// Server identifier the user belongs to.
 String? get serverId;/// Whether the user account has a password set.
 bool? get hasPassword;/// Whether the user has configured a password.
 bool? get hasConfiguredPassword;/// Whether the user has configured an easy PIN password.
 bool? get hasConfiguredEasyPassword;/// User display and behavior configuration.
 UserConfiguration? get configuration;/// Administrative policy settings for the user.
 UserPolicy? get policy;
/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDtoCopyWith<UserDto> get copyWith => _$UserDtoCopyWithImpl<UserDto>(this as UserDto, _$identity);

  /// Serializes this UserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.serverId, serverId) || other.serverId == serverId)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.hasConfiguredPassword, hasConfiguredPassword) || other.hasConfiguredPassword == hasConfiguredPassword)&&(identical(other.hasConfiguredEasyPassword, hasConfiguredEasyPassword) || other.hasConfiguredEasyPassword == hasConfiguredEasyPassword)&&(identical(other.configuration, configuration) || other.configuration == configuration)&&(identical(other.policy, policy) || other.policy == policy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,serverId,hasPassword,hasConfiguredPassword,hasConfiguredEasyPassword,configuration,policy);

@override
String toString() {
  return 'UserDto(id: $id, name: $name, serverId: $serverId, hasPassword: $hasPassword, hasConfiguredPassword: $hasConfiguredPassword, hasConfiguredEasyPassword: $hasConfiguredEasyPassword, configuration: $configuration, policy: $policy)';
}


}

/// @nodoc
abstract mixin class $UserDtoCopyWith<$Res>  {
  factory $UserDtoCopyWith(UserDto value, $Res Function(UserDto) _then) = _$UserDtoCopyWithImpl;
@useResult
$Res call({
 String? id, String? name, String? serverId, bool? hasPassword, bool? hasConfiguredPassword, bool? hasConfiguredEasyPassword, UserConfiguration? configuration, UserPolicy? policy
});


$UserConfigurationCopyWith<$Res>? get configuration;$UserPolicyCopyWith<$Res>? get policy;

}
/// @nodoc
class _$UserDtoCopyWithImpl<$Res>
    implements $UserDtoCopyWith<$Res> {
  _$UserDtoCopyWithImpl(this._self, this._then);

  final UserDto _self;
  final $Res Function(UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? serverId = freezed,Object? hasPassword = freezed,Object? hasConfiguredPassword = freezed,Object? hasConfiguredEasyPassword = freezed,Object? configuration = freezed,Object? policy = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,serverId: freezed == serverId ? _self.serverId : serverId // ignore: cast_nullable_to_non_nullable
as String?,hasPassword: freezed == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool?,hasConfiguredPassword: freezed == hasConfiguredPassword ? _self.hasConfiguredPassword : hasConfiguredPassword // ignore: cast_nullable_to_non_nullable
as bool?,hasConfiguredEasyPassword: freezed == hasConfiguredEasyPassword ? _self.hasConfiguredEasyPassword : hasConfiguredEasyPassword // ignore: cast_nullable_to_non_nullable
as bool?,configuration: freezed == configuration ? _self.configuration : configuration // ignore: cast_nullable_to_non_nullable
as UserConfiguration?,policy: freezed == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as UserPolicy?,
  ));
}
/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserConfigurationCopyWith<$Res>? get configuration {
    if (_self.configuration == null) {
    return null;
  }

  return $UserConfigurationCopyWith<$Res>(_self.configuration!, (value) {
    return _then(_self.copyWith(configuration: value));
  });
}/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPolicyCopyWith<$Res>? get policy {
    if (_self.policy == null) {
    return null;
  }

  return $UserPolicyCopyWith<$Res>(_self.policy!, (value) {
    return _then(_self.copyWith(policy: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserDto].
extension UserDtoPatterns on UserDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDto value)  $default,){
final _that = this;
switch (_that) {
case _UserDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name,  String? serverId,  bool? hasPassword,  bool? hasConfiguredPassword,  bool? hasConfiguredEasyPassword,  UserConfiguration? configuration,  UserPolicy? policy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.id,_that.name,_that.serverId,_that.hasPassword,_that.hasConfiguredPassword,_that.hasConfiguredEasyPassword,_that.configuration,_that.policy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name,  String? serverId,  bool? hasPassword,  bool? hasConfiguredPassword,  bool? hasConfiguredEasyPassword,  UserConfiguration? configuration,  UserPolicy? policy)  $default,) {final _that = this;
switch (_that) {
case _UserDto():
return $default(_that.id,_that.name,_that.serverId,_that.hasPassword,_that.hasConfiguredPassword,_that.hasConfiguredEasyPassword,_that.configuration,_that.policy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name,  String? serverId,  bool? hasPassword,  bool? hasConfiguredPassword,  bool? hasConfiguredEasyPassword,  UserConfiguration? configuration,  UserPolicy? policy)?  $default,) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.id,_that.name,_that.serverId,_that.hasPassword,_that.hasConfiguredPassword,_that.hasConfiguredEasyPassword,_that.configuration,_that.policy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDto implements UserDto {
  const _UserDto({this.id, this.name, this.serverId, this.hasPassword, this.hasConfiguredPassword, this.hasConfiguredEasyPassword, this.configuration, this.policy});
  factory _UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

/// Unique identifier for the user.
@override final  String? id;
/// Display name of the user.
@override final  String? name;
/// Server identifier the user belongs to.
@override final  String? serverId;
/// Whether the user account has a password set.
@override final  bool? hasPassword;
/// Whether the user has configured a password.
@override final  bool? hasConfiguredPassword;
/// Whether the user has configured an easy PIN password.
@override final  bool? hasConfiguredEasyPassword;
/// User display and behavior configuration.
@override final  UserConfiguration? configuration;
/// Administrative policy settings for the user.
@override final  UserPolicy? policy;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDtoCopyWith<_UserDto> get copyWith => __$UserDtoCopyWithImpl<_UserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.serverId, serverId) || other.serverId == serverId)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.hasConfiguredPassword, hasConfiguredPassword) || other.hasConfiguredPassword == hasConfiguredPassword)&&(identical(other.hasConfiguredEasyPassword, hasConfiguredEasyPassword) || other.hasConfiguredEasyPassword == hasConfiguredEasyPassword)&&(identical(other.configuration, configuration) || other.configuration == configuration)&&(identical(other.policy, policy) || other.policy == policy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,serverId,hasPassword,hasConfiguredPassword,hasConfiguredEasyPassword,configuration,policy);

@override
String toString() {
  return 'UserDto(id: $id, name: $name, serverId: $serverId, hasPassword: $hasPassword, hasConfiguredPassword: $hasConfiguredPassword, hasConfiguredEasyPassword: $hasConfiguredEasyPassword, configuration: $configuration, policy: $policy)';
}


}

/// @nodoc
abstract mixin class _$UserDtoCopyWith<$Res> implements $UserDtoCopyWith<$Res> {
  factory _$UserDtoCopyWith(_UserDto value, $Res Function(_UserDto) _then) = __$UserDtoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name, String? serverId, bool? hasPassword, bool? hasConfiguredPassword, bool? hasConfiguredEasyPassword, UserConfiguration? configuration, UserPolicy? policy
});


@override $UserConfigurationCopyWith<$Res>? get configuration;@override $UserPolicyCopyWith<$Res>? get policy;

}
/// @nodoc
class __$UserDtoCopyWithImpl<$Res>
    implements _$UserDtoCopyWith<$Res> {
  __$UserDtoCopyWithImpl(this._self, this._then);

  final _UserDto _self;
  final $Res Function(_UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? serverId = freezed,Object? hasPassword = freezed,Object? hasConfiguredPassword = freezed,Object? hasConfiguredEasyPassword = freezed,Object? configuration = freezed,Object? policy = freezed,}) {
  return _then(_UserDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,serverId: freezed == serverId ? _self.serverId : serverId // ignore: cast_nullable_to_non_nullable
as String?,hasPassword: freezed == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool?,hasConfiguredPassword: freezed == hasConfiguredPassword ? _self.hasConfiguredPassword : hasConfiguredPassword // ignore: cast_nullable_to_non_nullable
as bool?,hasConfiguredEasyPassword: freezed == hasConfiguredEasyPassword ? _self.hasConfiguredEasyPassword : hasConfiguredEasyPassword // ignore: cast_nullable_to_non_nullable
as bool?,configuration: freezed == configuration ? _self.configuration : configuration // ignore: cast_nullable_to_non_nullable
as UserConfiguration?,policy: freezed == policy ? _self.policy : policy // ignore: cast_nullable_to_non_nullable
as UserPolicy?,
  ));
}

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserConfigurationCopyWith<$Res>? get configuration {
    if (_self.configuration == null) {
    return null;
  }

  return $UserConfigurationCopyWith<$Res>(_self.configuration!, (value) {
    return _then(_self.copyWith(configuration: value));
  });
}/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPolicyCopyWith<$Res>? get policy {
    if (_self.policy == null) {
    return null;
  }

  return $UserPolicyCopyWith<$Res>(_self.policy!, (value) {
    return _then(_self.copyWith(policy: value));
  });
}
}

// dart format on
