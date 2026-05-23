/// 认证仓库实现
///
/// 使用 [FlutterSecureStorage] 安全存储敏感信息（Token、密码等），
/// 使用 [SharedPreferences] 存储非敏感的用户配置信息。
///
/// 存储策略:
/// - SecureStorage: `emby_access_token`, `emby_server_url`
/// - SharedPreferences: `emby_user_id`, `emby_username`
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:emby_client/core/models/authentication_result.dart';
import 'package:emby_client/services/cache/emby_cache.dart';
import 'package:emby_client/services/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 判断 host 是否允许自签名证书
///
/// 允许：localhost、127.0.0.1、局域网私有地址段
bool _isAllowedHost(String host) {
  if (host == 'localhost' || host == '127.0.0.1') return true;
  if (host.startsWith('192.168.')) return true;
  if (host.startsWith('10.')) return true;
  if (host.startsWith('172.')) {
    final secondOctet = int.tryParse(host.split('.')[1]);
    if (secondOctet != null && secondOctet >= 16 && secondOctet <= 31) {
      return true;
    }
  }
  return false;
}

/// AuthRepository 的 Riverpod Provider
///
/// 提供单例的 [AuthRepositoryImpl] 实例，供全应用使用。
///
/// 使用示例:
/// ```dart
/// final authRepo = ref.watch(authRepositoryProvider);
/// final isAuth = await authRepo.isAuthenticated();
/// ```
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(cache: ref.watch(embyCacheProvider));
});

/// [AuthRepository] 的具体实现类
///
/// 管理所有认证状态的持久化，使用分层存储策略确保安全性。
class AuthRepositoryImpl implements AuthRepository {
  /// 安全存储实例，用于保存敏感数据
  final FlutterSecureStorage _secureStorage;

  /// 可选的 Dio 实例，用于认证请求（测试注入用）
  final Dio? _authDio;

  /// Hive 缓存实例（用于登出/清除缓存时清理）
  final EmbyCache? _cache;

  /// 创建仓库实例
  ///
  /// [secureStorage] 和 [authDio] 用于测试注入 mock 实例。
  /// [cache] 用于登出时清除本地数据缓存。
  AuthRepositoryImpl({
    FlutterSecureStorage? secureStorage,
    Dio? authDio,
    EmbyCache? cache,
  }) : _secureStorage = secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(
              accountName: 'emby_auth',
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          ),
        _authDio = authDio,
        _cache = cache;

  // SecureStorage Keys
  static const _keyAccessToken = 'emby_access_token';
  static const _keyServerUrl = 'emby_server_url';
  static const _keyPassword = 'emby_password';
  static const _keySessionId = 'emby_session_id';

  // SharedPreferences Keys
  static const _keyUserId = 'emby_user_id';
  static const _keyUsername = 'emby_username';

  /// SharedPreferences 实例（延迟初始化）
  SharedPreferences? _prefs;



  /// 获取 SharedPreferences 实例
  Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<AuthenticationResult> authenticate(
    String serverUrl,
    String username,
    String password,
  ) async {
    // 读取/生成设备信息用于 Authorization header
    final prefs = await _sharedPrefs;
    final deviceName = prefs.getString('device_name');
    var deviceId = prefs.getString('device_id');
    final effectiveDeviceName =
        (deviceName != null && deviceName.isNotEmpty) ? deviceName : 'Flutter Device';

    // 如果没有持久化的 deviceId，生成一个新的 UUID 并保存
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }
    final effectiveDeviceId = deviceId;

    final authHeader =
        'MediaBrowser Client="EmbyFlutter", Device="$effectiveDeviceName", '
        'DeviceId="$effectiveDeviceId", Version="1.0.0"';

    // 使用注入的 Dio 或创建新的（认证请求用临时 Dio）
    final authDio = _authDio ?? Dio(BaseOptions(
      baseUrl: serverUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ));

    // 复用证书白名单逻辑（仅在创建新 Dio 时配置）
    if (_authDio == null && !kIsWeb) {
      authDio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) {
            return _isAllowedHost(host);
          };
          return client;
        },
      );
    }

    try {
      final response = await authDio.post<Map<String, dynamic>>(
        '/Users/AuthenticateByName',
        data: 'Username=${Uri.encodeComponent(username)}'
            '&Pw=${Uri.encodeComponent(password)}',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'Authorization': authHeader},
        ),
      );

      if (response.data == null) {
        throw const FormatException('Empty response from server');
      }

      final json = response.data!;
      final result = AuthenticationResult.fromJson(json);

      // 从响应中提取 SessionInfo.Id（Emby 会话 ID，用于播放上报）
      final sessionInfo = json['SessionInfo'] as Map<String, dynamic>?;
      final sessionId = sessionInfo?['Id'] as String?;

      // 持久化所有凭证：username / pw / apiKey / sessionId / userId
      await _persistAuthData(
        result: result,
        serverUrl: serverUrl,
        username: username,
        password: password,
        sessionId: sessionId,
      );

      return result;
    } on DioException catch (e) {
      debugPrint('[AuthRepositoryImpl] DioException: ${e.message}');
      await logout();
      rethrow;
    } catch (e) {
      debugPrint('[AuthRepositoryImpl] Exception: $e');
      await logout();
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    // 清除 Hive 缓存
    await _cache?.clearAll();

    // 清除安全存储
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyServerUrl);
    await _secureStorage.delete(key: _keyPassword);
    await _secureStorage.delete(key: _keySessionId);

    // 清除 SharedPreferences
    final prefs = await _sharedPrefs;
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyAccessToken);
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.read(key: _keyAccessToken);
      final serverUrl = await _secureStorage.read(key: _keyServerUrl);

      return token != null &&
          token.isNotEmpty &&
          serverUrl != null &&
          serverUrl.isNotEmpty;
    } catch (e) {
      // 读取失败视为未认证
      return false;
    }
  }

  @override
  String? getCurrentUserId() {
    // 同步读取已缓存的 prefs
    if (_prefs == null) return null;
    return _prefs!.getString(_keyUserId);
  }

  @override
  String? getServerUrl() {
    // SecureStorage 只支持异步，但这里提供一个同步备选
    // 实际使用时建议调用方使用异步版本
    if (_prefs == null) return null;

    // 尝试从 prefs 获取缓存的服务器地址（登出时会清除）
    return _prefs!.getString(_keyServerUrl);
  }

  @override
  Future<void> setServerUrl(String serverUrl) async {
    await _secureStorage.write(key: _keyServerUrl, value: serverUrl);
    final prefs = await _sharedPrefs;
    await prefs.setString(_keyServerUrl, serverUrl);
  }

  /// 异步获取服务器地址（推荐）
  ///
  /// 从安全存储中读取服务器地址，比同步版本更可靠。
  Future<String?> getServerUrlAsync() async {
    return _secureStorage.read(key: _keyServerUrl);
  }

  /// 持久化认证数据到存储
  ///
  /// 保存所有凭证：
  /// - username / pw：凭证获取的关键（用于自动刷新）
  /// - apiKey (accessToken)：Emby 服务器鉴定权限的重要手段
  /// - sessionId：与向服务器通知播放开始/结束有关
  /// - userId：用户标识
  Future<void> _persistAuthData({
    required AuthenticationResult result,
    required String serverUrl,
    required String username,
    required String password,
    String? sessionId,
  }) async {
    // 写入安全存储（敏感信息）
    await _secureStorage.write(
      key: _keyAccessToken,
      value: result.accessToken,
    );
    await _secureStorage.write(
      key: _keyServerUrl,
      value: serverUrl,
    );
    await _secureStorage.write(
      key: _keyPassword,
      value: password,
    );
    if (sessionId != null && sessionId.isNotEmpty) {
      await _secureStorage.write(
        key: _keySessionId,
        value: sessionId,
      );
    }

    // 写入 SharedPreferences（非敏感信息 + accessToken 同步缓存供图片加载使用）
    final prefs = await _sharedPrefs;
    await prefs.setString(_keyUserId, result.user!.id!);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyAccessToken, result.accessToken ?? '');
  }

  @override
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _keyAccessToken);
  }

  @override
  String? getAccessTokenSync() {
    if (_prefs == null) return null;
    return _prefs!.getString(_keyAccessToken);
  }

  @override
  String? getUsername() {
    if (_prefs == null) return null;
    return _prefs!.getString(_keyUsername);
  }

  @override
  bool isAuthenticatedSync() {
    // 同步检查：如果 SharedPreferences 已初始化则直接读取
    // 否则返回 false（未初始化时尚未完成认证流程）
    if (_prefs == null) return false;

    final userId = _prefs!.getString(_keyUserId);
    final username = _prefs!.getString(_keyUsername);

    return userId != null &&
        userId.isNotEmpty &&
        username != null &&
        username.isNotEmpty;
  }

  @override
  Future<bool> testConnection(String serverUrl) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: serverUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final response = await dio.get('/System/Info/Public');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 获取当前会话 ID（SessionInfo.Id）
  ///
  /// 用于播放上报（reportPlaybackStart/Progress/Stopped）。
  @override
  Future<String?> getSessionId() async {
    return _secureStorage.read(key: _keySessionId);
  }

  @override
  Future<void> clearCache() async {
    await _cache?.clearAll();
  }

  @override
  Future<bool> refreshAuthentication() async {
    try {
      final serverUrl = await _secureStorage.read(key: _keyServerUrl);
      final username = await _secureStorage.read(key: _keyUsername);
      final password = await _secureStorage.read(key: _keyPassword);

      if (serverUrl == null ||
          serverUrl.isEmpty ||
          username == null ||
          username.isEmpty ||
          password == null ||
          password.isEmpty) {
        debugPrint('[AuthRepository] Refresh failed: missing stored credentials');
        return false;
      }

      debugPrint('[AuthRepository] Attempting token refresh for $username');
      await authenticate(serverUrl, username, password);
      debugPrint('[AuthRepository] Token refresh succeeded');
      return true;
    } catch (e) {
      debugPrint('[AuthRepository] Token refresh failed: $e');
      return false;
    }
  }
}
