// lib/core/api/auth_interceptor.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:emby_client/core/api/dio_client.dart';
import 'package:emby_client/services/repositories/auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// {@template auth_interceptor}
/// Dio interceptor for Emby API authentication.
///
/// Handles token injection via the X-Emby-Token header,
/// device identification headers, and 401 unauthorized responses
/// by redirecting to the login screen.
/// {@endtemplate}
class AuthInterceptor extends Interceptor {
  /// Creates an [AuthInterceptor].
  ///
  /// [ref] is used to access providers for navigation and token storage.
  /// [secureStorage] is a callback to read the access token from secure storage.
  /// [deviceInfo] provides device identification for the Authorization header.
  AuthInterceptor({
    required this.ref,
    required this.secureStorage,
    required this.deviceInfo,
  });

  /// Riverpod container reference for accessing providers.
  final Ref ref;

  /// Callback to read the access token from secure storage.
  final Future<String?> Function() secureStorage;

  /// Device information for the Authorization header.
  final EmbyDeviceInfo deviceInfo;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Inject device identification header
    options.headers[HttpHeaders.authorizationHeader] =
        'MediaBrowser '
        'Client="${deviceInfo.clientName}", '
        'Device="${deviceInfo.deviceName}", '
        'DeviceId="${deviceInfo.deviceId}", '
        'Version="${deviceInfo.version}"';

    // Inject access token for authenticated endpoints
    final token = await secureStorage();
    if (token != null && token.isNotEmpty) {
      options.headers['X-Emby-Token'] = token;
    }

    // Ensure JSON content type for POST/PUT requests
    if (options.method == 'POST' || options.method == 'PUT') {
      options.headers[HttpHeaders.contentTypeHeader] = 'application/json';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    // Handle 401 Unauthorized - token expired or invalid
    if (statusCode == 401) {
      // Prevent infinite refresh loops: if we've already tried refreshing
      // for this request, give up and redirect to login.
      final alreadyRefreshed =
          err.requestOptions.headers.containsKey('X-Auth-Refreshed');

      if (alreadyRefreshed) {
        debugPrint(
          'AuthInterceptor: Received 401 after refresh attempt, giving up',
        );
        await _clearCredentials();
        _redirectToLogin();
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException(
              'Session expired. Please log in again.',
            ),
            type: DioExceptionType.badResponse,
            response: err.response,
          ),
        );
      }

      debugPrint('AuthInterceptor: Received 401, attempting token refresh');

      // Attempt to refresh token using stored username/password
      final authRepo = ref.read(authRepositoryProvider);
      final refreshed = await authRepo.refreshAuthentication();

      if (refreshed) {
        debugPrint('AuthInterceptor: Token refreshed, retrying request');

        // Retry the original request with the new token.
        // Mark it so we don't loop if the server rejects again.
        err.requestOptions.headers['X-Auth-Refreshed'] = '1';

        try {
          final dio = ref.read(dioClientProvider);
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (retryErr) {
          debugPrint(
            'AuthInterceptor: Retry failed after refresh: $retryErr',
          );
          // Fall through to clear credentials and redirect
        }
      }

      debugPrint(
        'AuthInterceptor: Refresh failed, clearing credentials and redirecting',
      );

      // Clear stored credentials
      await _clearCredentials();

      // Navigate to login page if we have a valid context
      _redirectToLogin();

      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(
            'Session expired. Please log in again.',
          ),
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
    }

    // Handle server unavailable (502, 503, 504)
    if (statusCode != null && statusCode >= 502 && statusCode <= 504) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: ServerUnavailableException(
            'Emby server is unavailable (HTTP $statusCode)',
          ),
          type: DioExceptionType.connectionError,
          response: err.response,
        ),
      );
    }

    // Handle connection timeout
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const TimeoutException('Connection timed out. Please check your network.'),
          type: err.type,
          response: err.response,
        ),
      );
    }

    handler.next(err);
  }

  /// Clears stored authentication credentials.
  Future<void> _clearCredentials() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
    } catch (e) {
      debugPrint('AuthInterceptor: Failed to clear credentials: $e');
    }
  }

  /// Redirects the user to the login page.
  void _redirectToLogin() {
    try {
      // Access the navigator through the root navigator key
      // This assumes you have a global navigator key set up
      final context = ref.read(navigatorKeyProvider).currentContext;
      if (context != null && context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      debugPrint('AuthInterceptor: Failed to redirect: $e');
    }
  }
}

/// {@template emby_device_info}
/// Device identification information for Emby API requests.
///
/// Used to construct the Authorization header that identifies
/// the client application and device to the Emby server.
/// {@endtemplate}
class EmbyDeviceInfo {
  /// Creates an [EmbyDeviceInfo].
  const EmbyDeviceInfo({
    this.clientName = 'EmbyFlutter',
    required this.deviceName,
    required this.deviceId,
    this.version = '1.0.0',
  });

  /// Application client name.
  final String clientName;

  /// Human-readable device name.
  final String deviceName;

  /// Unique device identifier (UUID).
  final String deviceId;

  /// Application version string.
  final String version;

  @override
  String toString() =>
      'EmbyDeviceInfo(clientName: $clientName, deviceName: $deviceName, '
      'deviceId: $deviceId, version: $version)';
}

/// Global navigator key provider for accessing context outside of widgets.
///
/// Set this in your MaterialApp/CupertinoApp:
/// ```dart
/// MaterialApp(
///   navigatorKey: ref.watch(navigatorKeyProvider),
///   ...
/// )
/// ```
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => GlobalKey<NavigatorState>(),
);

/// {@template app_exception}
/// Base class for application-specific exceptions.
/// {@endtemplate}
sealed class AppException implements Exception {
  /// {@macro app_exception}
  const AppException(this.message);

  /// Human-readable error message.
  final String message;

  @override
  String toString() => 'AppException: $message';
}

/// {@template unauthorized_exception}
/// Thrown when authentication fails or the session has expired.
/// {@endtemplate}
class UnauthorizedException extends AppException {
  /// {@macro unauthorized_exception}
  const UnauthorizedException(super.message);
}

/// {@template server_unavailable_exception}
/// Thrown when the Emby server is unreachable or returning error status.
/// {@endtemplate}
class ServerUnavailableException extends AppException {
  /// {@macro server_unavailable_exception}
  const ServerUnavailableException(super.message);
}

/// {@template timeout_exception}
/// Thrown when a network request times out.
/// {@endtemplate}
class TimeoutException extends AppException {
  /// {@macro timeout_exception}
  const TimeoutException(super.message);
}

/// {@template network_exception}
/// Thrown when a general network error occurs.
/// {@endtemplate}
class NetworkException extends AppException {
  /// {@macro network_exception}
  const NetworkException(super.message);
}
