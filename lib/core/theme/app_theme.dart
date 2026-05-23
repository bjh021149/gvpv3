import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// {@template app_theme}
/// 应用主题配置类，基于 flex_color_scheme 构建。
///
/// 提供三种主题模式：
/// - [lightTheme]：亮色主题
/// - [darkTheme]：暗色主题
/// - [blackTheme]：纯黑 OLED 主题
///
/// 所有主题均遵循 Material 3 设计规范，并针对 Emby 品牌色进行定制。
/// {@endtemplate}
class AppTheme {
  /// 私有构造函数，防止实例化
  AppTheme._();

  /// Emby 品牌蓝色种子色
  static const Color seedColor = Color(0xFF4CA3DD);

  /// 亮色主题基础配置
  static final _lightSubThemes = const FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnLevel: 20,
    useM2StyleDividerInM3: true,
    // 圆角配置
    cardRadius: 12.0,
    popupMenuRadius: 8.0,
    dialogRadius: 16.0,
    bottomSheetRadius: 20.0,
    inputDecoratorRadius: 12.0,
    inputDecoratorUnfocusedHasBorder: false,
    chipRadius: 8.0,
    elevatedButtonRadius: 12.0,
    outlinedButtonRadius: 12.0,
    textButtonRadius: 8.0,
    // 阴影与高度
    cardElevation: 1.0,
    // 导航栏
    bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
    // 开关与滑块
    switchSchemeColor: SchemeColor.primary,
    checkboxSchemeColor: SchemeColor.primary,
    radioSchemeColor: SchemeColor.primary,
    // AppBar
    appBarCenterTitle: true,
    // TabBar
    tabBarIndicatorSize: TabBarIndicatorSize.tab,
  );

  /// 暗色主题基础配置
  static final _darkSubThemes = const FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnLevel: 20,
    useM2StyleDividerInM3: true,
    // 圆角配置（与亮色一致）
    cardRadius: 12.0,
    popupMenuRadius: 8.0,
    dialogRadius: 16.0,
    bottomSheetRadius: 20.0,
    inputDecoratorRadius: 12.0,
    inputDecoratorUnfocusedHasBorder: false,
    chipRadius: 8.0,
    elevatedButtonRadius: 12.0,
    outlinedButtonRadius: 12.0,
    textButtonRadius: 8.0,
    // 暗色模式下降低阴影
    cardElevation: 0.5,
    // 导航栏
    bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
    // 开关与滑块
    switchSchemeColor: SchemeColor.primary,
    checkboxSchemeColor: SchemeColor.primary,
    radioSchemeColor: SchemeColor.primary,
    // AppBar
    appBarCenterTitle: true,
    // TabBar
    tabBarIndicatorSize: TabBarIndicatorSize.tab,
  );

  /// {@macro light_theme}
  ///
  /// 基于 FlexScheme.blue 构建亮色主题。
  /// [dynamicSeed] 可选动态种子色，优先于默认蓝色方案。
  static ThemeData lightTheme({Color? dynamicSeed}) {
    return FlexThemeData.light(
      scheme: FlexScheme.blue,
      colors: dynamicSeed != null
          ? FlexSchemeColor.from(
              primary: dynamicSeed,
              primaryContainer: dynamicSeed.withValues(alpha: 0.2),
              secondary: dynamicSeed.withValues(alpha: 0.8),
            )
          : null,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 10,
      appBarStyle: FlexAppBarStyle.surface,
      appBarOpacity: 0.95,
      appBarElevation: 0.5,
      subThemesData: _lightSubThemes,
      useMaterial3: true,
      useMaterial3ErrorColors: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      // 字体与排版
      fontFamily: 'Roboto',
      // 页面过渡
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// {@macro dark_theme}
  ///
  /// 基于 FlexScheme.blue 构建暗色主题。
  /// [dynamicSeed] 可选动态种子色。
  static ThemeData darkTheme({Color? dynamicSeed}) {
    return FlexThemeData.dark(
      scheme: FlexScheme.blue,
      colors: dynamicSeed != null
          ? FlexSchemeColor.from(
              primary: dynamicSeed,
              primaryContainer: dynamicSeed.withValues(alpha: 0.3),
              secondary: dynamicSeed.withValues(alpha: 0.7),
            )
          : null,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 15,
      appBarStyle: FlexAppBarStyle.surface,
      appBarOpacity: 0.95,
      appBarElevation: 0.5,
      subThemesData: _darkSubThemes,
      useMaterial3: true,
      useMaterial3ErrorColors: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      // 字体与排版
      fontFamily: 'Roboto',
      // 页面过渡
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// {@macro black_theme}
  ///
  /// 纯黑 OLED 主题，适用于 AMOLED 屏幕设备。
  /// 使用纯黑背景 [#FF000000] 以降低功耗。
  /// [dynamicSeed] 可选动态种子色。
  static ThemeData blackTheme({Color? dynamicSeed}) {
    final baseDark = darkTheme(dynamicSeed: dynamicSeed);

    return baseDark.copyWith(
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.black,
      cardColor: const Color(0xFF111111),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF111111),
      ),
      bottomSheetTheme: baseDark.bottomSheetTheme.copyWith(
        backgroundColor: const Color(0xFF111111),
        modalBackgroundColor: const Color(0xFF111111),
      ),
      cardTheme: baseDark.cardTheme.copyWith(
        color: const Color(0xFF111111),
        shadowColor: Colors.transparent,
      ),
      navigationBarTheme: baseDark.navigationBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      drawerTheme: baseDark.drawerTheme.copyWith(
        backgroundColor: const Color(0xFF111111),
      ),
      popupMenuTheme: baseDark.popupMenuTheme.copyWith(
        color: const Color(0xFF1A1A1A),
      ),
      chipTheme: baseDark.chipTheme.copyWith(
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      dividerTheme: baseDark.dividerTheme.copyWith(
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );
  }
}
