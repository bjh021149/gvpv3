import 'package:emby_client/app.dart';
import 'package:emby_client/core/api/dio_client.dart';
import 'package:emby_client/routes.dart';
import 'package:emby_client/services/cache/emby_cache.dart';
import 'package:emby_client/services/deep_link/deep_link_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

/// 应用程序入口点
///
/// 初始化顺序：
/// 1. [WidgetsFlutterBinding.ensureInitialized] - 确保 Flutter 绑定已初始化
/// 2. [fvp.registerWith] - 注册 fvp 视频播放引擎
/// 3. [SharedPreferences.getInstance] - 初始化本地持久化存储
/// 4. [SystemChrome.setPreferredOrientations] - 设置支持的所有屏幕方向
/// 5. [runApp] 启动应用，包裹在 [ProviderScope] 中
///
/// 支持的屏幕方向：
/// - [DeviceOrientation.portraitUp] - 竖屏向上
/// - [DeviceOrientation.portraitDown] - 竖屏向下
/// - [DeviceOrientation.landscapeLeft] - 横屏向左
/// - [DeviceOrientation.landscapeRight] - 横屏向右
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
  }
  fvp.registerWith(); // 注册 fvp 视频播放引擎

  // 初始化 SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 初始化 Hive
  await Hive.initFlutter();
  final cache = EmbyCache();
  await cache.init();

  // 设置首选方向 - 支持所有方向（视频播放需要横屏）
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 创建 ProviderContainer 以便在 runApp 前获取 GoRouter
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      embyCacheProvider.overrideWithValue(cache),
    ],
  );

  // 初始化深度链接服务
  final router = container.read(routerProvider);
  final deepLinkService = DeepLinkService(router: router);
  await deepLinkService.init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const EmbyClientApp(),
    ),
  );
}
