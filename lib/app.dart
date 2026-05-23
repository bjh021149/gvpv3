import 'package:emby_client/core/theme/app_theme.dart';
import 'package:emby_client/core/theme/theme_notifier.dart';
import 'package:emby_client/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emby Client 应用根组件
///
/// 基于 [ConsumerWidget] 构建，通过 [themeNotifierProvider] 监听主题状态变化。
/// 使用 [MaterialApp.router] 集成 GoRouter 路由系统。
///
/// 主题配置：
/// - 亮色主题：[AppTheme.lightTheme] 基于 FlexColorScheme
/// - 暗色主题：[AppTheme.darkTheme] 基于 FlexColorScheme
/// - 主题模式：由 [ThemeState.mode] 控制
/// - 种子色：支持动态种子色定制
///
/// 国际化：
/// - 支持中文（简体）和英文
class EmbyClientApp extends ConsumerWidget {
  const EmbyClientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeNotifierProvider);

    return themeAsync.when(
      data: (themeState) => MaterialApp.router(
        title: 'Emby Client',
        debugShowCheckedModeBanner: false,
        // 主题配置
        theme: AppTheme.lightTheme(dynamicSeed: themeState.seedColor),
        darkTheme: AppTheme.darkTheme(dynamicSeed: themeState.seedColor),
        themeMode: themeState.mode,
        // 路由配置
        routerConfig: ref.watch(routerProvider),
        // 国际化配置
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
      ),
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
      error: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            color: Colors.black,
            child: const Center(
              child: Text('Error loading theme'),
            ),
          ),
        ),
      ),
    );
  }
}
