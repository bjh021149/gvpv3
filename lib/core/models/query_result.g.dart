// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QueryResult<T> _$QueryResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _QueryResult<T>(
  items: (json['Items'] as List<dynamic>?)?.map(fromJsonT).toList() ?? const [],
  totalRecordCount: (json['TotalRecordCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$QueryResultToJson<T>(
  _QueryResult<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'Items': instance.items.map(toJsonT).toList(),
  'TotalRecordCount': instance.totalRecordCount,
};
