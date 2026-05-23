import 'package:emby_client/services/repositories/auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 设置页面状态
class SettingsState {
  /// 当前主题模式
  final ThemeMode themeMode;

  /// 服务器地址
  final String? serverUrl;

  /// 用户名
  final String? username;

  /// 是否使用动态取色
  final bool useDynamicColor;

  /// 默认播放速度
  final double defaultPlaybackSpeed;

  /// 应用版本号
  final String? appVersion;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.serverUrl,
    this.username,
    this.useDynamicColor = true,
    this.defaultPlaybackSpeed = 1.0,
    this.appVersion = '1.0.0',
  });

  /// 创建修改后的副本
  SettingsState copyWith({
    ThemeMode? themeMode,
    String? serverUrl,
    String? username,
    bool? useDynamicColor,
    double? defaultPlaybackSpeed,
    String? appVersion,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

/// 设置 ViewModel Provider
final settingsViewModelProvider =
    AsyncNotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);

/// 设置页面 ViewModel
class SettingsViewModel extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final authRepo = ref.read(authRepositoryProvider);
    final serverUrl = authRepo.getServerUrl();
    return SettingsState(
      serverUrl: serverUrl,
      username: authRepo.getUsername(),
      appVersion: '1.0.0',
    );
  }

  /// 退出登录
  Future<void> logout() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    // 导航到登录页由监听方处理
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(themeMode: mode));
    }
  }

  /// 测试服务器连接
  Future<bool> testConnection(String serverUrl) async {
    final authRepo = ref.read(authRepositoryProvider);
    try {
      return await authRepo.testConnection(serverUrl);
    } catch (e) {
      return false;
    }
  }

  /// 清除图片缓存
  Future<void> clearCache() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.clearCache();
  }

  /// 更新服务器地址
  Future<void> updateServerUrl(String serverUrl) async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.setServerUrl(serverUrl);
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(serverUrl: serverUrl));
    }
  }
}
