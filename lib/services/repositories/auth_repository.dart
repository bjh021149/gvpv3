/// 认证仓库接口
///
/// 定义用户认证相关的所有操作，包括登录、登出和认证状态查询。
/// 实现类负责管理 Token、服务器地址等敏感信息的持久化存储。
library;

import 'package:emby_client/core/models/authentication_result.dart';

/// 认证仓库抽象接口
///
/// 遵循 Repository 模式，将认证逻辑与存储细节封装，
/// 支持多种存储后端（secure_storage、shared_preferences 等）。
abstract class AuthRepository {
  /// 用户登录认证
  ///
  /// 向指定的 Emby 服务器发送认证请求，成功后持久化保存
  /// 访问令牌和服务器配置。
  ///
  /// 参数:
  /// - [serverUrl]: Emby 服务器地址，如 `http://192.168.1.100:8096`
  /// - [username]: 用户名
  /// - [password]: 密码（明文，由 API 层进行安全传输）
  ///
  /// 返回: [AuthenticationResult] 包含访问令牌和用户信息
  ///
  /// 异常:
  /// - [AuthenticationException] 认证失败（用户名/密码错误）
  /// - [NetworkException] 无法连接到服务器
  /// - [ServerException] 服务器返回错误响应
  Future<AuthenticationResult> authenticate(
    String serverUrl,
    String username,
    String password,
  );

  /// 用户登出
  ///
  /// 清除所有持久化的认证信息，包括:
  /// - 访问令牌 (Access Token)
  /// - 服务器地址
  /// - 用户基本信息
  ///
  /// 调用后 [isAuthenticated] 将返回 `false`。
  Future<void> logout();

  /// 检查当前是否已认证
  ///
  /// 通过检查本地存储的访问令牌有效性来判断。
  /// 注意: 此方法不验证令牌在服务器端是否仍然有效。
  ///
  /// 返回: `true` 如果存在有效的本地认证状态
  Future<bool> isAuthenticated();

  /// 获取当前登录用户的 ID
  ///
  /// 返回: 用户 ID 字符串，未登录时返回 `null`
  String? getCurrentUserId();

  /// 获取当前配置的服务器地址
  ///
  /// 返回: 服务器 URL 字符串，未配置时返回 `null`
  String? getServerUrl();

  /// 设置服务器地址
  ///
  /// [serverUrl] 为新的 Emby 服务器地址。
  Future<void> setServerUrl(String serverUrl);

  /// 获取当前登录用户的用户名
  ///
  /// 返回: 用户名字符串，未登录时返回 `null`
  String? getUsername();

  /// 同步检查当前是否已认证
  ///
  /// 用于路由守卫等需要同步判断认证状态的场景。
  /// 注意: 此方法可能在初始化完成前被调用，返回结果可能不准确。
  ///
  /// 返回: `true` 如果存在本地认证状态
  bool isAuthenticatedSync();

  /// 测试服务器连接
  ///
  /// [serverUrl] 为目标服务器地址。
  ///
  /// 返回: `true` 如果服务器可达且响应正常。
  Future<bool> testConnection(String serverUrl);

  /// 清除本地缓存
  Future<void> clearCache();

  /// 获取当前访问令牌
  ///
  /// 返回: Access Token 字符串，未登录时返回 `null`
  Future<String?> getAccessToken();

  /// 同步获取访问令牌（用于图片加载等同步场景）
  ///
  /// 从 SharedPreferences 缓存中读取，可能落后于 SecureStorage。
  /// 返回: Access Token 字符串，未登录时返回 `null`
  String? getAccessTokenSync();

  /// 获取当前会话 ID（SessionInfo.Id）
  ///
  /// 用于播放上报（reportPlaybackStart/Progress/Stopped）。
  /// 返回: Session ID 字符串，未登录时返回 `null`
  Future<String?> getSessionId();

  /// 尝试使用已保存的凭证刷新认证
  ///
  /// 使用 SecureStorage 中保存的 username / password
  /// 重新调用 `authenticate()` 获取新的 Access Token。
  ///
  /// 返回: `true` 如果刷新成功并获取了新 Token，`false` 如果失败
  Future<bool> refreshAuthentication();
}
