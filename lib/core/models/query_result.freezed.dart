// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'query_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QueryResult<T> {

/// List of result items.
 List<T> get items;/// Total number of records available (for pagination).
 int get totalRecordCount;
/// Create a copy of QueryResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueryResultCopyWith<T, QueryResult<T>> get copyWith => _$QueryResultCopyWithImpl<T, QueryResult<T>>(this as QueryResult<T>, _$identity);

  /// Serializes this QueryResult to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueryResult<T>&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalRecordCount, totalRecordCount) || other.totalRecordCount == totalRecordCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalRecordCount);

@override
String toString() {
  return 'QueryResult<$T>(items: $items, totalRecordCount: $totalRecordCount)';
}


}

/// @nodoc
abstract mixin class $QueryResultCopyWith<T,$Res>  {
  factory $QueryResultCopyWith(QueryResult<T> value, $Res Function(QueryResult<T>) _then) = _$QueryResultCopyWithImpl;
@useResult
$Res call({
 List<T> items, int totalRecordCount
});




}
/// @nodoc
class _$QueryResultCopyWithImpl<T,$Res>
    implements $QueryResultCopyWith<T, $Res> {
  _$QueryResultCopyWithImpl(this._self, this._then);

  final QueryResult<T> _self;
  final $Res Function(QueryResult<T>) _then;

/// Create a copy of QueryResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalRecordCount = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<T>,totalRecordCount: null == totalRecordCount ? _self.totalRecordCount : totalRecordCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [QueryResult].
extension QueryResultPatterns<T> on QueryResult<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueryResult<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueryResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueryResult<T> value)  $default,){
final _that = this;
switch (_that) {
case _QueryResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueryResult<T> value)?  $default,){
final _that = this;
switch (_that) {
case _QueryResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> items,  int totalRecordCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueryResult() when $default != null:
return $default(_that.items,_that.totalRecordCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> items,  int totalRecordCount)  $default,) {final _that = this;
switch (_that) {
case _QueryResult():
return $default(_that.items,_that.totalRecordCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> items,  int totalRecordCount)?  $default,) {final _that = this;
switch (_that) {
case _QueryResult() when $default != null:
return $default(_that.items,_that.totalRecordCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _QueryResult<T> implements QueryResult<T> {
  const _QueryResult({final  List<T> items = const [], this.totalRecordCount = 0}): _items = items;
  factory _QueryResult.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$QueryResultFromJson(json,fromJsonT);

/// List of result items.
 final  List<T> _items;
/// List of result items.
@override@JsonKey() List<T> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// Total number of records available (for pagination).
@override@JsonKey() final  int totalRecordCount;

/// Create a copy of QueryResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueryResultCopyWith<T, _QueryResult<T>> get copyWith => __$QueryResultCopyWithImpl<T, _QueryResult<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$QueryResultToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueryResult<T>&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalRecordCount, totalRecordCount) || other.totalRecordCount == totalRecordCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalRecordCount);

@override
String toString() {
  return 'QueryResult<$T>(items: $items, totalRecordCount: $totalRecordCount)';
}


}

/// @nodoc
abstract mixin class _$QueryResultCopyWith<T,$Res> implements $QueryResultCopyWith<T, $Res> {
  factory _$QueryResultCopyWith(_QueryResult<T> value, $Res Function(_QueryResult<T>) _then) = __$QueryResultCopyWithImpl;
@override @useResult
$Res call({
 List<T> items, int totalRecordCount
});




}
/// @nodoc
class __$QueryResultCopyWithImpl<T,$Res>
    implements _$QueryResultCopyWith<T, $Res> {
  __$QueryResultCopyWithImpl(this._self, this._then);

  final _QueryResult<T> _self;
  final $Res Function(_QueryResult<T>) _then;

/// Create a copy of QueryResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalRecordCount = null,}) {
  return _then(_QueryResult<T>(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<T>,totalRecordCount: null == totalRecordCount ? _self.totalRecordCount : totalRecordCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
