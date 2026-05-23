// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authentication_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthenticationResult {

/// Access token for authenticated API requests.
///
/// Must be included in the X-Emby-Token header for all subsequent calls.
 String? get accessToken;/// Server identifier the user authenticated against.
 String? get serverId;/// Authenticated user profile.
 UserDto? get user;
/// Create a copy of AuthenticationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticationResultCopyWith<AuthenticationResult> get copyWith => _$AuthenticationResultCopyWithImpl<AuthenticationResult>(this as AuthenticationResult, _$identity);

  /// Serializes this AuthenticationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationResult&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.serverId, serverId) || other.serverId == serverId)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,serverId,user);

@override
String toString() {
  return 'AuthenticationResult(accessToken: $accessToken, serverId: $serverId, user: $user)';
}


}

/// @nodoc
abstract mixin class $AuthenticationResultCopyWith<$Res>  {
  factory $AuthenticationResultCopyWith(AuthenticationResult value, $Res Function(AuthenticationResult) _then) = _$AuthenticationResultCopyWithImpl;
@useResult
$Res call({
 String? accessToken, String? serverId, UserDto? user
});


$UserDtoCopyWith<$Res>? get user;

}
/// @nodoc
class _$AuthenticationResultCopyWithImpl<$Res>
    implements $AuthenticationResultCopyWith<$Res> {
  _$AuthenticationResultCopyWithImpl(this._self, this._then);

  final AuthenticationResult _self;
  final $Res Function(AuthenticationResult) _then;

/// Create a copy of AuthenticationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = freezed,Object? serverId = freezed,Object? user = freezed,}) {
  return _then(_self.copyWith(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,serverId: freezed == serverId ? _self.serverId : serverId // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDto?,
  ));
}
/// Create a copy of AuthenticationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDtoCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserDtoCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthenticationResult].
extension AuthenticationResultPatterns on AuthenticationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthenticationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthenticationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthenticationResult value)  $default,){
final _that = this;
switch (_that) {
case _AuthenticationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthenticationResult value)?  $default,){
final _that = this;
switch (_that) {
case _AuthenticationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? accessToken,  String? serverId,  UserDto? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthenticationResult() when $default != null:
return $default(_that.accessToken,_that.serverId,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? accessToken,  String? serverId,  UserDto? user)  $default,) {final _that = this;
switch (_that) {
case _AuthenticationResult():
return $default(_that.accessToken,_that.serverId,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? accessToken,  String? serverId,  UserDto? user)?  $default,) {final _that = this;
switch (_that) {
case _AuthenticationResult() when $default != null:
return $default(_that.accessToken,_that.serverId,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthenticationResult implements AuthenticationResult {
  const _AuthenticationResult({this.accessToken, this.serverId, this.user});
  factory _AuthenticationResult.fromJson(Map<String, dynamic> json) => _$AuthenticationResultFromJson(json);

/// Access token for authenticated API requests.
///
/// Must be included in the X-Emby-Token header for all subsequent calls.
@override final  String? accessToken;
/// Server identifier the user authenticated against.
@override final  String? serverId;
/// Authenticated user profile.
@override final  UserDto? user;

/// Create a copy of AuthenticationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthenticationResultCopyWith<_AuthenticationResult> get copyWith => __$AuthenticationResultCopyWithImpl<_AuthenticationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthenticationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthenticationResult&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.serverId, serverId) || other.serverId == serverId)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,serverId,user);

@override
String toString() {
  return 'AuthenticationResult(accessToken: $accessToken, serverId: $serverId, user: $user)';
}


}

/// @nodoc
abstract mixin class _$AuthenticationResultCopyWith<$Res> implements $AuthenticationResultCopyWith<$Res> {
  factory _$AuthenticationResultCopyWith(_AuthenticationResult value, $Res Function(_AuthenticationResult) _then) = __$AuthenticationResultCopyWithImpl;
@override @useResult
$Res call({
 String? accessToken, String? serverId, UserDto? user
});


@override $UserDtoCopyWith<$Res>? get user;

}
/// @nodoc
class __$AuthenticationResultCopyWithImpl<$Res>
    implements _$AuthenticationResultCopyWith<$Res> {
  __$AuthenticationResultCopyWithImpl(this._self, this._then);

  final _AuthenticationResult _self;
  final $Res Function(_AuthenticationResult) _then;

/// Create a copy of AuthenticationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = freezed,Object? serverId = freezed,Object? user = freezed,}) {
  return _then(_AuthenticationResult(
accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,serverId: freezed == serverId ? _self.serverId : serverId // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDto?,
  ));
}

/// Create a copy of AuthenticationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDtoCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserDtoCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
