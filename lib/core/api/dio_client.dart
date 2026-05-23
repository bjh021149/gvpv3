// lib/core/api/dio_client.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:emby_client/core/api/auth_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template dio_client}
/// Riverpod provider for the Dio HTTP client configured for Emby API.
///
/// Features:
/// - Base URL from SharedPreferences
/// - Authentication interceptor with token injection
/// - Device identification headers
/// - Unified response parsing and error handling
/// - Logging in debug mode
/// {@endtemplate}

/// Provider for SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope overrides',
  );
});

/// 同步获取 Access Token（用于图片加载的 HTTP Header）
///
/// 从 SharedPreferences 缓存读取，避免图片加载时的异步等待。
final accessTokenProvider = Provider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('emby_access_token');
});

/// Provider for the Emby server base URL stored in SharedPreferences.
final embyBaseUrlProvider = Provider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final url = prefs.getString('emby_server_url') ?? '';
  // Remove trailing slash if present
  return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
});

/// Provider for Emby device identification information.
final deviceInfoProvider = Provider<EmbyDeviceInfo>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final deviceName = prefs.getString('device_name') ??
      (kIsWeb ? 'Web Device' : Platform.operatingSystem);
  final deviceId = prefs.getString('device_id') ?? 'flutter-emby-device';

  return EmbyDeviceInfo(
    deviceName: deviceName,
    deviceId: deviceId,
  );
});

/// Provider for the Dio client instance.
///
/// Usage:
/// ```dart
/// final dio = ref.watch(dioClientProvider);
/// final response = await dio.get('/Users');
/// ```
final dioClientProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(embyBaseUrlProvider);
  final deviceInfo = ref.watch(deviceInfoProvider);

  // Create the Dio client
  final dio = DioClient.create(
    baseUrl: baseUrl.isEmpty ? null : baseUrl,
    deviceInfo: deviceInfo,
    secureStorage: () async {
      const secureStorage = FlutterSecureStorage(
        aOptions: AndroidOptions(),
        iOptions: IOSOptions(
          accountName: 'emby_auth',
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );
      return secureStorage.read(key: 'emby_access_token');
    },
    ref: ref,
  );

  return dio;
});

/// {@template dio_client_class}
/// Factory class for creating configured Dio instances.
///
/// Provides centralized configuration for:
/// - Base URL and timeouts
/// - Authentication interceptor
/// - Device identification headers
/// - Response/Error handling
/// - Debug logging
/// {@endtemplate}
class DioClient {
  DioClient._();

  /// Creates a pre-configured Dio instance for Emby API communication.
  ///
  /// [baseUrl] is the Emby server URL (e.g., "http://192.168.1.100:8096").
  /// [deviceInfo] provides device identification for the Authorization header.
  /// [secureStorage] is a callback to read the stored access token.
  /// [ref] is the Riverpod container reference.
  /// [connectTimeout] connection timeout in milliseconds (default: 30000).
  /// [receiveTimeout] receive timeout in milliseconds (default: 30000).
  static Dio create({
    required String? baseUrl,
    required EmbyDeviceInfo deviceInfo,
    required Future<String?> Function() secureStorage,
    required Ref ref,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
  }) {
    final options = BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      sendTimeout: Duration(milliseconds: connectTimeout),
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 600,
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    final dio = Dio(options);

    // Add authentication interceptor
    dio.interceptors.add(
      AuthInterceptor(
        ref: ref,
        secureStorage: secureStorage,
        deviceInfo: deviceInfo,
      ),
    );

    // Add logging interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint(
            '[EmbyApi] REQUEST ${options.method} ${options.path} '
            'headers=${options.headers} query=${options.queryParameters}',
          );
          if (options.data != null) {
            debugPrint('[EmbyApi] REQUEST BODY: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '[EmbyApi] RESPONSE ${response.statusCode} ${response.requestOptions.path}',
          );
          if (response.data != null) {
            final body = response.data.toString();
            debugPrint(
              '[EmbyApi] RESPONSE BODY: ${body.length > 10000 ? '${body.substring(0, 10000)}...' : body}',
            );
          }
          handler.next(response);
        },
        onError: (e, handler) {
          debugPrint(
            '[EmbyApi] ERROR ${e.response?.statusCode} ${e.requestOptions.path} => ${e.message}',
          );
          handler.next(e);
        },
      ),
    );

    // Configure HTTP adapter for platform-specific settings
    if (!kIsWeb) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          // Allow self-signed certificates (common for local Emby servers)
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }

    return dio;
  }

  /// Updates the base URL for an existing Dio instance.
  ///
  /// Useful when the user changes the server URL in settings.
  static void updateBaseUrl(Dio dio, String newBaseUrl) {
    final cleanUrl = newBaseUrl.endsWith('/')
        ? newBaseUrl.substring(0, newBaseUrl.length - 1)
        : newBaseUrl;
    dio.options.baseUrl = cleanUrl;
  }
}

/// {@template api_response}
/// Wrapper for API responses providing typed data and status information.
///
/// [T] is the type of the response data.
/// {@endtemplate}
class ApiResponse<T> {
  /// {@macro api_response}
  const ApiResponse({
    required this.data,
    required this.statusCode,
    this.headers,
  });

  /// The parsed response data.
  final T data;

  /// HTTP status code of the response.
  final int statusCode;

  /// Response headers.
  final Map<String, dynamic>? headers;

  /// Whether the request was successful (2xx status code).
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Whether the request resulted in an error.
  bool get isError => !isSuccess;
}

/// Extension methods for Dio Response to parse common Emby API patterns.
extension ResponseParsing on Response<dynamic> {
  /// Extracts the [Items] array from an Emby query response.
  ///
  /// Returns an empty list if [Items] key is not present.
  List<dynamic> get items => (data as Map<String, dynamic>)['Items'] as List<dynamic>? ?? [];

  /// Extracts the [TotalRecordCount] from an Emby query response.
  ///
  /// Returns 0 if not present.
  int get totalRecordCount =>
      (data as Map<String, dynamic>)['TotalRecordCount'] as int? ?? 0;
}
