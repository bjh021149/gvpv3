> 文档版本: v2.0 | 生成时间: 2026-05-15T10:43:24+08:00
> 说明：基于 package 文档最佳实践的具体改进方案

# Emby Client Flutter 项目行动建议 V2（Package 实践对标版）

---

## 🔴 P0 — 必须立即修复（阻断性/高风险）

---

### 1. dio：统一认证请求走 Dio + 证书白名单

#### 问题
`AuthRepositoryImpl.authenticate()` 直接使用 `HttpClient`，绕过 Dio 拦截器体系，且证书无条件信任所有 host。

#### 改进方案
```dart
// lib/services/repositories/auth_repository_impl.dart

@override
Future<AuthenticationResult> authenticate(
  String serverUrl,
  String username,
  String password,
) async {
  // 使用 Dio 而不是原始 HttpClient
  final authDio = Dio(BaseOptions(
    baseUrl: serverUrl,
    connectTimeout: const Duration(seconds: 10),
  ));

  // 复用证书处理逻辑（白名单模式）
  if (!kIsWeb) {
    authDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          return host == 'localhost' ||
                 host == '127.0.0.1' ||
                 host.startsWith('192.168.') ||
                 host.startsWith('10.');
        };
        return client;
      },
    );
  }

  final deviceName = await ref.read(deviceInfoProvider);
  final deviceId = await ref.read(deviceIdProvider);

  final authHeader = 'MediaBrowser '
      'Client="${AppInfo.clientName}", '
      'Device="$deviceName", '
      'DeviceId="$deviceId", '
      'Version="${AppInfo.version}"';

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

    final result = AuthenticationResult.fromJson(response.data!);
    await _persistAuthData(result, serverUrl, username);
    return result;
  } on DioException catch (e) {
    await logout();
    throw AuthException.fromDioError(e);
  }
}
```

---

### 2. media_kit：实现真正的音轨/字幕切换 + 进度恢复

#### 播放进度恢复
```dart
// 在 PlayerViewModel.build() 中恢复进度

final resumePosition = item.userData?.playbackPositionTicks != null
    ? Duration(microseconds: item.userData!.playbackPositionTicks! ~/ 10)
    : Duration.zero;

await player.open(
  Media(
    streamUrl,
    httpHeaders: {'X-Emby-Token': token ?? ''},
  ),
);

if (resumePosition > Duration.zero) {
  await player.seek(resumePosition);
}
```

#### 音轨切换（真正实现）
```dart
void selectAudioTrack(int index) {
  final current = state.value;
  if (current == null) return;
  if (index < 0 || index >= current.audioTracks.length) return;

  final track = current.audioTracks[index];
  final serverUrl = ref.read(embyBaseUrlProvider);
  final token = ...;

  _requirePlayer.setAudioTrack(
    AudioTrack.uri(
      '$serverUrl/Audio/${track.id}/stream',
      httpHeaders: {'X-Emby-Token': token},
    ),
  );

  _updateState((s) => s.copyWith(selectedAudioIndex: index));
}
```

#### 字幕切换（真正实现）
```dart
void selectSubtitleTrack(int index) {
  final current = state.value;
  if (current == null) return;

  if (index == -1) {
    _requirePlayer.setSubtitleTrack(SubtitleTrack.no());
    _updateState((s) => s.copyWith(selectedSubtitleIndex: -1));
    return;
  }

  final track = current.subtitleTracks[index];
  final serverUrl = ref.read(embyBaseUrlProvider);
  final token = ...;

  _requirePlayer.setSubtitleTrack(
    SubtitleTrack.uri(
      '$serverUrl/Videos/${track.id}/${track.id}.srt',
      title: track.displayTitle ?? 'Subtitle',
      language: track.language ?? 'und',
      httpHeaders: {'X-Emby-Token': token},
    ),
  );

  _updateState((s) => s.copyWith(selectedSubtitleIndex: index));
}
```

#### 安全 dispose
```dart
void _disposePlayer() {
  _cancelControlsTimer();
  for (final sub in _subscriptions) {
    sub.cancel();
  }
  _subscriptions.clear();

  if (_player != null) {
    _player!.pause();
    Future.delayed(const Duration(milliseconds: 100), () {
      _player?.dispose();
      _player = null;
    });
  }
}
```

---

### 3. flutter_secure_storage：升级到 v10 新 API

#### 当前代码
```dart
const FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true), // 已弃用
);
```

#### 改进方案
```dart
const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    migrateOnAlgorithmChange: true,
    migrateWithBackup: true,
  ),
  iOptions: IOSOptions(
    accountName: 'emby_auth',
    accessibility: KeychainAccessibility.first_unlock_this_device,
    useSecureEnclave: true,
  ),
);
```

---

### ✅ 4. cached_network_image_ce：替换所有 Image.network（已解决）

项目已统一使用 `EmbyCachedImage` 封装组件（基于 `cached_network_image_ce`）加载所有 Emby 图片，替代了所有 `Image.network` 和直接调用 `EmbyImageUrl.buildImageUrl` 的用法。

#### 实际执行方案

| 修改项 | 文件 | 说明 |
|--------|------|------|
| 统一封装 | `lib/features/shared/emby_cached_image.dart` | `EmbyCachedImage` 封装 `CachedNetworkImage`，自动注入 Token、计算 2x Retina 尺寸、提供统一错误占位图 |
| 尺寸限制 | `lib/features/home/hero_carousel.dart` | Backdrop 增加 `maxWidth: MediaQuery.of(context).size.width.ceil()` |
| 尺寸限制 | `lib/features/detail/detail_page_background.dart` | Backdrop 增加 `maxWidth: 1280`（配合已有 `maxHeight: 720`） |
| 路径修正 | `lib/core/utils/extensions.dart` | `EmbyImageUrl.buildImageUrl` 删除 `/emby/` 前缀，与 `BaseItemDto.getImageUrl` 格式一致 |
| 死代码清理 | `lib/features/detail/season_episode_list.dart` | 删除未使用的 `thumbnailUrl` / `serverUrl` 变量，移除冗余 `dio_client.dart` import |

#### 关键设计决策

- **Retina 自动适配**：`EmbyCachedImage` 内部 `_effectiveMaxWidth = width * 2`、`_effectiveMaxHeight = height * 2`，无需各调用处手动处理 2x 逻辑。
- **错误占位统一**：默认使用 `Icons.broken_image` + `colorScheme.onSurfaceVariant`，可通过 `errorIcon` 参数覆盖（如剧集缩略图使用 `Icons.videocam_off_outlined`）。

---

## 🟡 P1 — 高优先级（核心体验完善）

---

### 5. flutter_riverpod：首页状态拆分 + 异常处理

#### 首页状态拆分
```dart
// lib/features/home/home_viewmodel.dart

final carouselItemsProvider = FutureProvider.autoDispose<List<BaseItemDto>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  final views = await repo.getViews();
  if (views.items.isEmpty) return [];
  final latest = await repo.getLatestItems(parentId: views.items.first.id, limit: 5);
  return latest.items;
});

final continueWatchingProvider = FutureProvider.autoDispose<List<BaseItemDto>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  final result = await repo.getContinueWatching(limit: 10);
  return result.items;
});

final recentlyAddedProvider = FutureProvider.autoDispose<List<BaseItemDto>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  final views = await repo.getViews();
  if (views.items.isEmpty) return [];
  final latest = await repo.getLatestItems(parentId: views.items.first.id, limit: 10);
  return latest.items;
});
```

#### Widget 中分别 watch
```dart
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carouselAsync = ref.watch(carouselItemsProvider);
    final continueAsync = ref.watch(continueWatchingProvider);
    final recentAsync = ref.watch(recentlyAddedProvider);
    // 各区域独立刷新，互不影响
  }
}
```

#### PlayerViewModel 异常处理改进
```dart
void playPause() {
  try {
    _requirePlayer.playOrPause();
  } on StateError catch (e) {
    debugPrint('[Player] playPause ignored: player not ready ($e)');
  } catch (e, st) {
    debugPrint('[Player] playPause error: $e');
    _updateState((s) => s.copyWith(error: 'Playback control failed: $e'));
  }
}
```

---

### 6. go_router：引入 refreshListenable + 类型安全路由

#### refreshListenable 模式
```dart
// lib/core/auth/auth_notifier.dart

class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }
}

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});
```

```dart
// lib/routes.dart
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/' ||
                          state.matchedLocation == '/login';
      if (!isLoggedIn && !isAuthRoute) return '/';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [ /* ... */ ],
  );
});
```

---

### 7. hive_ce：引入本地缓存层

#### 初始化
```dart
// lib/main.dart
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await Hive.initFlutter();
  
  // 注册适配器（需要为 BaseItemDto 生成 TypeAdapter）
  Hive.registerAdapter(BaseItemDtoAdapter());
  
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const EmbyClientApp(),
  ));
}
```

#### 媒体缓存 Repository
```dart
class MediaCache {
  static const String _boxName = 'media_cache';

  late Box<Map<String, dynamic>> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map<String, dynamic>>(_boxName);
  }

  Future<void> cacheItem(String id, Map<String, dynamic> json) async {
    await _box.put(id, json);
  }

  Map<String, dynamic>? getItem(String id) {
    return _box.get(id);
  }

  Future<void> cacheItems(String key, List<Map<String, dynamic>> items) async {
    await _box.put('_list_$key', {'items': items, 'ts': DateTime.now().millisecondsSinceEpoch});
  }

  List<Map<String, dynamic>>? getItems(String key) {
    final data = _box.get('_list_$key');
    if (data == null) return null;
    final ts = data['ts'] as int?;
    if (ts != null && DateTime.now().millisecondsSinceEpoch - ts > 1800000) {
      return null; // 30分钟过期
    }
    return (data['items'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> clear() async => _box.clear();
}
```

---

### 8. skeletonizer：统一加载态 + 全局配置

#### 全局主题配置
```dart
// lib/app.dart
MaterialApp(
  theme: ThemeData(
    extensions: const [
      SkeletonizerConfigData(
        effect: ShimmerEffect(),
        justifyMultiLineText: true,
      ),
    ],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [
      SkeletonizerConfigData.dark(),
    ],
  ),
)
```

---

### ✅ 9. app_links：实现深度链接（已解决）

项目已集成 `app_links ^7.0.0` 实现深度链接功能，支持自定义 URL Scheme `emby://` 的冷启动和热启动处理。

#### 实际执行方案

**核心服务：** `lib/services/deep_link/deep_link_service.dart`

| 组件 | 说明 |
|------|------|
| `DeepLinkService` | 封装 `AppLinks`，处理冷启动 (`getInitialLink`) 和热启动 (`uriLinkStream`) |
| `resolveUri()` | 静态方法，将 `emby://host/path` 解析为内部路由，仅接受 `emby` scheme 和已知路由前缀 |
| `DeepLinkResult` | 不可变结果类，封装 `path` + `uri` + `isHandled` |

**支持的路径映射：**

| 深度链接 | 内部路由 |
|----------|----------|
| `emby://detail/:id` | `/detail/:id` |
| `emby://player/:id` | `/player/:id` |
| `emby://library` | `/library` |
| `emby://library/:parentId` | `/library/:parentId` |
| `emby://home` | `/home` |
| `emby://settings` | `/settings` |

**`main.dart` 集成：** 使用 `ProviderContainer` + `UncontrolledProviderScope` 在 `runApp` 前获取 `GoRouter` 实例并初始化 `DeepLinkService`。

**平台配置：**
- Android：`AndroidManifest.xml` 添加 `emby` scheme 的 `intent-filter`
- iOS：`Info.plist` 添加 `CFBundleURLTypes` 注册 `emby` scheme

**关键设计决策：**
- 使用 `ProviderContainer` 在 `runApp` 前获取 `GoRouter`，避免依赖全局 `navigatorKey` 或 `BuildContext`
- `resolveUri` 是纯静态方法，便于单元测试
- 无效 scheme 或未知路由被静默忽略（`isHandled: false`），不抛异常
- 查询参数自动保留（如 `?ref=email`）
- 认证状态由 GoRouter 自身的 `redirect` 拦截器处理，深度链接服务不重复校验

---

## 🟢 P2 — 中优先级（优化与打磨）

---

### 10. dio：添加重试 + 请求取消

#### 重试拦截器
```dart
import 'package:dio_smart_retry/dio_smart_retry.dart';

dio.interceptors.add(RetryInterceptor(
  dio: dio,
  logPrint: debugPrint,
  retries: 3,
  retryDelays: const [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 3),
  ],
));
```

---

### 11. flex_color_scheme：修复登录页硬编码颜色

```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E)],
              )
            : LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
      ),
      child: /* ... */,
    ),
  );
}
```

---

### 12. freezed：状态类也使用代码生成

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_state.freezed.dart';

@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
    @Default(false) bool isPlaying,
    @Default(true) bool isLoading,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(1.0) double volume,
    @Default(1.0) double speed,
    @Default([]) List<MediaStream> audioTracks,
    @Default([]) List<MediaStream> subtitleTracks,
    @Default(0) int selectedAudioIndex,
    @Default(-1) int selectedSubtitleIndex,
    String? error,
    @Default(true) bool isControlsVisible,
    @Default(false) bool isBuffering,
    BaseItemDto? item,
    MediaSourceInfo? currentSource,
  }) = _PlayerState;
}
```

---

## 📅 建议迭代路线 V2

| 迭代 | 目标 | 包含事项 | 预估工时 |
|------|------|----------|----------|
| **Sprint 1** | 安全与网络层加固 | P0 #1(Dio统一) + P0 #3(SecureStorage升级) + ~~P0 #4(CachedNetworkImage替换 ✅)~~ | 1-2 天 |
| **Sprint 2** | 播放体验完善 | P0 #2(进度恢复/音轨字幕/安全dispose) + P1 #6(go_router优化) | 3-4 天 |
| **Sprint 3** | 状态管理优化 | P1 #5(首页状态拆分) + P1 #8(skeletonizer统一) + P2 #12(freezed状态类) | 2-3 天 |
| **Sprint 4** | 本地缓存 + 深度链接 | P1 #7(hive_ce缓存 ✅) + ~~P1 #9(app_links ✅)~~ + P2 #10(重试/取消) | 1-2 天 |
| **Sprint 5** | 主题与打磨 | P2 #11(登录页主题) + 国际化(ARB) + 测试补全 | 2-3 天 |
