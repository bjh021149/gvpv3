/// 认证模块 ViewModel
///
/// 管理用户认证状态的完整生命周期，包括服务器配置、登录、登出等操作。
/// 通过 [AsyncNotifier] 向 UI 层提供响应式的认证状态。
library;

import 'package:emby_client/services/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 认证状态数据类
///
/// 不可变对象，通过 [copyWith] 方法创建更新后的副本。
/// 包含用户认证的所有相关状态信息。
class AuthState {
  /// 是否已认证
  final bool isAuthenticated;

  /// 服务器地址
  final String? serverUrl;

  /// 用户名
  final String? username;

  /// 错误信息
  final String? error;

  /// 创建认证状态
  ///
  /// 所有参数均为可选，默认未认证状态。
  const AuthState({
    this.isAuthenticated = false,
    this.serverUrl,
    this.username,
    this.error,
  });

  /// 创建状态的副本并覆盖指定字段
  ///
  /// [error] 字段特殊处理: 传入 `null` 会清除现有错误，
  /// 不传值则保持原值。
  AuthState copyWith({
    bool? isAuthenticated,
    String? serverUrl,
    String? username,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      error: error,
    );
  }

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, '
        'serverUrl: $serverUrl, username: $username, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.serverUrl == serverUrl &&
        other.username == username &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(isAuthenticated, serverUrl, username, error);
  }
}

/// 认证 ViewModel Provider
///
/// 使用 [AsyncNotifierProvider] 提供响应式的认证状态管理。
///
/// 使用示例:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final authAsync = ref.watch(authViewModelProvider);
///     return authAsync.when(
///       data: (state) => Text(state.isAuthenticated ? '已登录' : '未登录'),
///       loading: () => const CircularProgressIndicator(),
///       error: (e, _) => Text('错误: $e'),
///     );
///   }
/// }
/// ```
final authViewModelProvider =
    AsyncNotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);

/// 认证 ViewModel
///
/// 继承 [AsyncNotifier] 管理 [AuthState]，处理所有认证相关的业务逻辑。
/// 自动在初始化时检查本地存储的认证状态。
class AuthViewModel extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final authRepo = ref.read(authRepositoryProvider);
    final isAuth = await authRepo.isAuthenticated();
    if (isAuth) {
      return AuthState(
        isAuthenticated: true,
        serverUrl: authRepo.getServerUrl(),
      );
    }
    return const AuthState();
  }

  /// 用户登录认证
  ///
  /// 向指定服务器发送认证请求，成功则更新认证状态，
  /// 失败则将错误信息写入状态。
  ///
  /// 参数:
  /// - [serverUrl]: Emby 服务器地址
  /// - [username]: 用户名
  /// - [password]: 密码
  Future<void> authenticate(
    String serverUrl,
    String username,
    String password,
  ) async {
    state = const AsyncValue.loading();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.authenticate(
        serverUrl,
        username,
        password,
      );
      state = AsyncValue.data(
        AuthState(
          isAuthenticated: result.accessToken != null,
          serverUrl: serverUrl,
          username: username,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 用户登出
  ///
  /// 清除所有认证状态并恢复到未登录状态。
  Future<void> logout() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    state = const AsyncValue.data(AuthState());
  }
}
