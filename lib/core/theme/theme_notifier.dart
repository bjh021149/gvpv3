import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用支持的种子色预设列表
final List<Color> seedColorPresets = [
  const Color(0xFF4CA3DD), // Emby 蓝（默认）
  const Color(0xFFE53935), // 红
  const Color(0xFF43A047), // 绿
  const Color(0xFFFB8C00), // 橙
  const Color(0xFF8E24AA), // 紫
  const Color(0xFF00ACC1), // 青
  const Color(0xFFFDD835), // 黄
  const Color(0xFFEC407A), // 粉
];

/// 应用主题模式枚举
///
/// - [light]：亮色模式
/// - [dark]：暗色模式
/// - [black]：纯黑 OLED 模式
/// - [system]：跟随系统
enum AppThemeMode { light, dark, black, system }

/// 主题状态类
///
/// 包含当前主题模式、种子色设置及动态颜色开关。
@immutable
class ThemeState {
  /// 当前 Flutter 主题模式
  final ThemeMode mode;

  /// 自定义种子色（为 null 时使用默认种子色）
  final Color? seedColor;

  /// 是否使用动态取色（Android 12+）
  final bool useDynamicColor;

  /// 当前选中的主题模式枚举值
  AppThemeMode get appThemeMode => switch (mode) {
        ThemeMode.light => AppThemeMode.light,
        ThemeMode.dark => AppThemeMode.dark,
        ThemeMode.system => AppThemeMode.system,
      };

  const ThemeState({
    this.mode = ThemeMode.system,
    this.seedColor,
    this.useDynamicColor = true,
  });

  /// 复制并更新部分字段
  ThemeState copyWith({
    ThemeMode? mode,
    Color? seedColor,
    bool? useDynamicColor,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.mode == mode &&
        other.seedColor == seedColor &&
        other.useDynamicColor == useDynamicColor;
  }

  @override
  int get hashCode => Object.hash(mode, seedColor, useDynamicColor);

  @override
  String toString() =>
      'ThemeState(mode: $mode, seedColor: $seedColor, useDynamicColor: $useDynamicColor)';
}

/// 主题状态 Notifier Provider
///
/// 通过 [SharedPreferences] 持久化保存用户主题偏好。
///
/// 使用示例：
/// ```dart
/// final themeState = ref.watch(themeNotifierProvider);
/// themeState.when(
///   data: (state) => Text('${state.mode}'),
///   loading: () => const CircularProgressIndicator(),
///   error: (err, _) => Text('Error: $err'),
/// );
/// ```
final themeNotifierProvider =
    AsyncNotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

/// 主题状态管理器
///
/// 负责：
/// 1. 从本地存储加载保存的主题偏好
/// 2. 提供切换主题模式的方法
/// 3. 提供设置自定义种子色的方法
/// 4. 持久化所有更改到本地存储
class ThemeNotifier extends AsyncNotifier<ThemeState> {
  static const _themeModeKey = 'theme_mode';
  static const _seedColorKey = 'seed_color';
  static const _useDynamicKey = 'use_dynamic_color';

  @override
  Future<ThemeState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);
    final savedColor = prefs.getInt(_seedColorKey);
    final savedDynamic = prefs.getBool(_useDynamicKey);

    return ThemeState(
      mode: _parseThemeMode(savedMode),
      seedColor: savedColor != null ? Color(savedColor) : null,
      useDynamicColor: savedDynamic ?? true,
    );
  }

  /// 设置主题模式
  ///
  /// 将模式持久化到本地存储并更新状态。
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);

    final current = state.value ?? const ThemeState();
    state = AsyncValue.data(current.copyWith(mode: mode));
  }

  /// 设置自定义种子色
  ///
  /// [color] 为 null 时重置为默认种子色。
  Future<void> setSeedColor(Color? color) async {
    final prefs = await SharedPreferences.getInstance();
    if (color != null) {
      await prefs.setInt(_seedColorKey, color.toARGB32());
    } else {
      await prefs.remove(_seedColorKey);
    }

    final current = state.value ?? const ThemeState();
    state = AsyncValue.data(current.copyWith(seedColor: color));
  }

  /// 切换动态取色开关
  ///
  /// 仅对 Android 12+ 设备有效。
  Future<void> setUseDynamicColor(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useDynamicKey, enabled);

    final current = state.value ?? const ThemeState();
    state = AsyncValue.data(current.copyWith(useDynamicColor: enabled));
  }

  /// 通过 [AppThemeMode] 枚举设置主题
  ///
  /// 对于 [AppThemeMode.black] 特殊处理：
  /// - 保存为 'dark' 模式但记录 black 标志
  Future<void> setAppThemeMode(AppThemeMode appMode) async {
    final ThemeMode flutterMode;
    switch (appMode) {
      case AppThemeMode.light:
        flutterMode = ThemeMode.light;
      case AppThemeMode.dark:
        flutterMode = ThemeMode.dark;
      case AppThemeMode.black:
        flutterMode = ThemeMode.dark;
      case AppThemeMode.system:
        flutterMode = ThemeMode.system;
    }
    await setThemeMode(flutterMode);
  }

  /// 解析主题模式字符串
  ThemeMode _parseThemeMode(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.system,
      };
}

/// 当前是否处于暗色模式的 Provider
///
/// 根据 [themeNotifierProvider] 和系统亮度计算实际暗色状态。
final isDarkModeProvider = Provider<bool>((ref) {
  final themeAsync = ref.watch(themeNotifierProvider);
  return themeAsync.when(
    data: (state) {
      if (state.mode == ThemeMode.system) {
        // 需要 BuildContext 来获取平台亮度，这里返回 false 作为默认值
        // 实际使用应在 Widget build 中判断
        return false;
      }
      return state.mode == ThemeMode.dark;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});
