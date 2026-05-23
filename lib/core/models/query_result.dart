// lib/core/models/query_result.dart

import 'package:freezed_annotation/freezed_annotation.dart';
part 'query_result.freezed.dart';
part 'query_result.g.dart';

/// {@template query_result}
/// Generic query result wrapper for paginated API responses.
///
/// Contains a list of typed items and the total record count
/// for pagination purposes.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys.
/// build.yaml configures json_serializable to use PascalCase for all models.
@Freezed(genericArgumentFactories: true)
abstract class QueryResult<T> with _$QueryResult<T> {
  /// {@macro query_result}
  const factory QueryResult({
    /// List of result items.
    @Default([]) List<T> items,

    /// Total number of records available (for pagination).
    @Default(0) int totalRecordCount,
  }) = _QueryResult<T>;

  /// Creates a [QueryResult] from JSON with a custom item deserializer.
  factory QueryResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$QueryResultFromJson<T>(json, fromJsonT);
}
