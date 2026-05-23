// lib/core/models/authentication_result.dart

import 'package:emby_client/core/models/user_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'authentication_result.freezed.dart';
part 'authentication_result.g.dart';

/// {@template authentication_result}
/// Result of an authentication attempt against the Emby server.
///
/// Contains the access token for subsequent API calls,
/// the server identifier, and the authenticated user profile.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys (e.g. "AccessToken", "ServerId").
/// build.yaml configures json_serializable to map camelCase Dart fields
/// to PascalCase JSON keys automatically for all model classes.
@freezed
abstract class AuthenticationResult with _$AuthenticationResult {
  /// {@macro authentication_result}
  const factory AuthenticationResult({
    /// Access token for authenticated API requests.
    ///
    /// Must be included in the X-Emby-Token header for all subsequent calls.
    String? accessToken,

    /// Server identifier the user authenticated against.
    String? serverId,

    /// Authenticated user profile.
    UserDto? user,
  }) = _AuthenticationResult;

  /// Creates an [AuthenticationResult] from JSON.
  factory AuthenticationResult.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationResultFromJson(json);
}
