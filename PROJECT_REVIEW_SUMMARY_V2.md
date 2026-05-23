> 文档版本: v2.0 | 生成时间: 2026-05-15T10:43:24+08:00
> 说明：基于 package 文档最佳实践的二次深度审阅

# Emby Client Flutter 项目二次审阅总结（Package 实践对标版）

## 📋 审阅方法

本次审阅将项目中每个核心 Package 的实际使用方式，与其官方文档推荐的最新最佳实践进行逐一对标，识别差距与改进空间。

---

## 1. flutter_riverpod ^3.2.1 — 状态管理层

### 项目现状
- ✅ 使用 `AsyncNotifierProvider` + `AsyncValue` 模式，架构正确
- ✅ 使用 `FamilyAsyncNotifier` 处理参数化状态（Player/Detail）
- ✅ `ref.invalidate()` 在 DetailPage 错误处理中使用正确

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| 使用 `ref.invalidate(provider)` 替代手动 refresh | HomeViewModel.refresh() 仍手动设置 `AsyncLoading` + `AsyncValue.guard` | 🔴 中 |
| 拆分独立 Provider 减少重建粒度 | HomeState 包含 3 个列表，任一变化触发整页重建 | 🔴 高 |
| 使用 `dependencies: [...]` 声明 | 所有 Provider 未声明依赖 | 🟡 低 |
| 考虑 `@riverpod` 代码生成 | 未使用 riverpod_annotation | 🟢 可选 |
| `catch` 块至少记录 error | PlayerViewModel 大量 `catch (_) { ignore }` | 🔴 高 |
| 使用 `AsyncValue.requireValue` | 多处使用 `state.valueOrNull` 后手动判断 | 🟡 低 |

### 关键问题
**PlayerViewModel 异常静默：**
```dart
void playPause() {
  try {
    _requirePlayer.playOrPause();
  } catch (_) {
    // Player not ready; ignore.  ← 用户完全不知道操作失败
  }
}
```
Riverpod v3 推荐至少记录异常，区分可恢复错误和致命错误。

📁 **相关代码文件：**
- `lib/features/player/player_viewmodel.dart` 第222-257行（多处 `catch (_) { // ignore }`）
- `lib/features/home/home_viewmodel.dart` 第79-82行（过时 refresh 模式）
- `lib/features/home/home_page.dart` 第25行（watch 整个 HomeState）

**HomeViewModel refresh 模式过时：**
```dart
// 当前实现（v2 风格）
Future<void> refresh() async {
  state = const AsyncLoading<HomeState>();
  state = await AsyncValue.guard(() => build());
}
```
v3 推荐调用方直接使用 `ref.invalidate(homeViewModelProvider)`，由框架自动处理状态流转。

---

## 2. go_router ^17.2.3 — 路由管理层

### 项目现状
- ✅ 使用 `StatefulShellRoute.indexedStack` 管理底部导航，正确
- ✅ 路由结构清晰，认证/主壳层/独立页面分层合理
- ✅ 通过 Riverpod Provider 管理 GoRouter 实例

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| 使用 `refreshListenable` 响应式刷新 | redirect 中每次导航同步调用 `isAuthenticated()` | 🔴 高 |
| 类型安全路由 (`go_router_builder`) | 全部使用字符串路径 | 🟡 中 |
| tab 切换使用 `go` 而非 `push` | AppShell 中使用 `goBranch`，正确 | ✅ 已达标 |
| 全屏路由使用 `parentNavigatorKey` | Detail/Player 未设置 `parentNavigatorKey` | 🟡 中 |
| 导航键集中声明 + `debugLabel` | 未声明 GlobalKey | 🟡 低 |
| 错误页面提供返回路径 | errorBuilder 提供 Go Home 按钮 | ✅ 已达标 |

### 关键问题
**认证检查性能瓶颈：**
```dart
redirect: (context, state) async {
  final isAuthenticated = await authRepo.isAuthenticated();
  // 每次导航都触发 SecureStorage 读取（异步磁盘 I/O）
}
```
最佳实践：使用 `refreshListenable` + `Listenable` 模式，认证状态变化时自动重评估，而非每次导航都读取存储。

📁 **相关代码文件：**
- `lib/routes.dart` 第31-49行（redirect 中 `await authRepo.isAuthenticated()`）
- `lib/features/settings/settings_page.dart` 第24-68行（内部嵌套 `ResponsiveNav`）

**SettingsPage 双重导航壳层：**
`SettingsPage` 内部嵌套 `ResponsiveNav(currentIndex: 2)`，与外层 `StatefulShellRoute` 的 `AppShell` 叠加，导致桌面端出现两个导航栏。

---

## 3. dio ^5.9.2 — 网络请求层

### 项目现状
- ✅ 拦截器架构正确（AuthInterceptor + LogInterceptor）
- ✅ 设备识别头注入完整
- ✅ 平台适配（IOHttpClientAdapter + 自签名证书）

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| 单一 Dio Factory 创建 | DioClient.create 和 AuthRepositoryImpl._createDio 重复 | 🔴 高 |
| 认证请求统一走 Dio | AuthRepositoryImpl.authenticate() 直接使用 HttpClient | 🔴 高 |
| 证书白名单校验 | `badCertificateCallback = (cert, host, port) => true` | 🔴 高 |
| 请求取消（CancelToken） | 页面 dispose 时未取消进行中的请求 | 🟡 中 |
| 重试机制（RetryInterceptor） | 未配置 | 🟡 中 |
| 统一异常封装 | DioException 直接透传，未转换为应用层异常 | 🟡 中 |

### 关键问题
**认证绕过 Dio 体系：**
```dart
// AuthRepositoryImpl.authenticate() — 直接使用 HttpClient
final client = HttpClient();
final request = await client.postUrl(Uri.parse('$serverUrl/Users/AuthenticateByName'));
```
这导致：设备识别头格式不一致、日志拦截器无法记录、证书处理失效、无法享受 Dio 的拦截器链。

**证书全信任：**
```dart
client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
```
生产环境风险极高，中间人攻击可完全绕过 HTTPS。

📁 **相关代码文件：**
- `lib/core/api/dio_client.dart` 第172-181行（`badCertificateCallback = (cert, host, port) => true`）
- `lib/services/repositories/auth_repository_impl.dart` 第323-332行（`_createDio` 中重复的全信任证书）
- `lib/services/repositories/auth_repository_impl.dart` 第76-148行（`authenticate()` 使用 `HttpClient` 绕过 Dio）

---

## 4. media_kit ^1.2.6 — 视频播放层

### 项目现状
- ✅ `MediaKit.ensureInitialized()` 在 main() 中正确调用
- ✅ `Player` + `VideoController` 分离架构正确
- ✅ 播放状态监听（playing/position/duration/buffering）
- ✅ 全屏沉浸模式处理正确

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| 播放进度恢复 | 未使用 `playbackPositionTicks` 恢复 | 🔴 高 |
| 音轨切换调用 `setAudioTrack` | 仅更新 UI 状态，TODO 注释标注未实现 | 🔴 高 |
| 字幕切换调用 `setSubtitleTrack` | 仅更新 UI 状态，TODO 注释标注未实现 | 🔴 高 |
| 自定义 HTTP 头认证 | 直接拼接 URL 含 `api_key`，未使用 `Media.httpHeaders` | 🟡 中 |
| HLS 流优先 / 降级策略 | 优先 Direct Stream，无降级处理 | 🟡 中 |
| dispose 前 pause | 直接 dispose，未先 pause | 🟡 中 |
| 截图功能 | 未使用 `player.screenshot()` | 🟢 可选 |

### 关键问题
**dispose 安全风险：**
```dart
// PlayerViewModel._disposePlayer()
_player?.dispose();
```
media_kit v1.2.6 在 macOS/Windows 存在已知问题：直接 dispose 可能触发 "Callback invoked after deleted" 崩溃。最佳实践是先 `await player.pause()` 再 dispose。

**URL 拼接方式：**
```dart
final directUrl = '$serverUrl/Videos/$streamId/stream?Static=true&api_key=$token';
```
推荐方式：使用 `Media(url, httpHeaders: {'X-Emby-Token': token})`，避免 token 暴露在 URL 中。

📁 **相关代码文件：**
- `lib/features/player/player_viewmodel.dart` 第166-182行（URL 拼接 `api_key=$token`）
- `lib/features/player/player_viewmodel.dart` 第261-283行（音轨/字幕切换 TODO）
- `lib/features/player/player_viewmodel.dart` 第328-336行（直接 dispose 未 pause）

---

## 5. freezed ^3.2.5 — 数据模型层

### 项目现状
- ✅ `BaseItemDto` / `PlaybackInfo` / `QueryResult` 等核心模型使用 `@freezed`
- ✅ `fromJson` / `toJson` 自动生成
- ✅ `part '*.freezed.dart'` / `part '*.g.dart'` 结构正确

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| 状态类也使用 `@freezed` | `HomeState` / `PlayerState` / `DetailState` 手写 copyWith | 🟡 中 |
| 使用 `sealed` + Union Types | `AsyncValue` 已用，但应用层状态未用 | 🟢 可选 |
| `@JsonKey(name: '...')` 字段映射 | 部分 Emby 字段名与 Dart 规范不一致，未映射 | 🟡 低 |
| `includeIfNull: false` | 未配置，JSON 输出含大量 null | 🟢 可选 |

---

## 6. flex_color_scheme ^8.4.0 — 主题系统层

### 项目现状
- ✅ 三种主题模式（light/dark/black）完整
- ✅ `FlexSubThemesData` 圆角/阴影配置细致
- ✅ 动态种子色支持
- ✅ Material 3 规范遵循

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| `interactionEffects` 显式声明 | 显式设为 `true`，正确（v8 默认 false） | ✅ 已达标 |
| 使用 `DynamicSchemeVariant` | 仅使用 `FlexSchemeColor.from` | 🟢 可选 |
| `useMaterial3Typography` | 未显式设置 | 🟡 低 |
| 全局 Skeletonizer 主题扩展 | 未配置 | 🟡 低 |

### 关键问题
**登录/服务器配置页硬编码深色背景：**
```dart
decoration: const BoxDecoration(
  gradient: LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E), Color(0xFF16213E)],
  ),
),
```
这些页面在系统亮色模式下极不协调。最佳实践是使用 `Theme.of(context).colorScheme` 动态取值，或限制为暗色主题场景。

📁 **相关代码文件：**
- `lib/features/auth/login_page.dart` 第111-133行（硬编码深色渐变）
- `lib/core/theme/theme_notifier.dart` 第166-179行（black 模式丢失标志）
- `lib/core/theme/theme_notifier.dart` 第193-206行（`isDarkModeProvider` system 模式默认 false）

---

## 7. flutter_secure_storage ^10.2.0 — 安全存储层

### 项目现状
- ✅ Token/服务器地址分层存储策略正确
- ✅ iOS Keychain 配置正确（accountName + accessibility）

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| v10 新默认构造函数 | `encryptedSharedPreferences: true`（已弃用） | 🔴 高 |
| `migrateWithBackup: true` | 未配置 | 🟡 中 |
| `storageNamespace` 隔离 | 未使用 | 🟢 可选 |
| iOS `useSecureEnclave` | 未使用 | 🟢 可选 |
| 监听数据可用性变化 | 未监听 | 🟢 可选 |

### 关键问题
**使用已弃用 API：**
```dart
const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);
```
v10 中 `encryptedSharedPreferences` 已标记为 deprecated，Jetpack Security 库已被 Google 弃用。应改用默认的 `AndroidOptions()`（RSA OAEP + AES-GCM）。

📁 **相关代码文件：**
- `lib/core/api/dio_client.dart` 第69-75行（provider body 中创建新 `FlutterSecureStorage` 实例）
- `lib/services/repositories/auth_repository_impl.dart` 第45-53行（静态 `_secureStorage` 使用 `encryptedSharedPreferences: true`）

---

## 8. hive_ce ^2.19.3 — 本地存储层

### 项目现状
- ⚠️ `pubspec.yaml` 已依赖 `hive_ce` 和 `hive_ce_flutter`
- ❌ 代码中完全未使用，仍全部使用 `SharedPreferences`

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| 缓存媒体元数据 | 未使用 | 🔴 高 |
| 用户配置存储 | 使用 SharedPreferences | 🟡 中 |
| 观看历史本地记录 | 未使用 | 🟡 中 |
| 离线播放列表 | 未使用 | 🟢 可选 |

📁 **相关代码文件：**
- `pubspec.yaml`（已依赖 `hive_ce` + `hive_ce_flutter`，但代码中无任何 import）

---

## 9. cached_network_image_ce ^4.6.4 — 图片缓存层

### 项目现状
- ⚠️ `pubspec.yaml` 已依赖
- ❌ 项目中大量使用 `Image.network`，未使用 `CachedNetworkImage`

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| 使用 `CachedNetworkImage` 替代 `Image.network` | DetailPage backdrop 用 `Image.network` | 🔴 高 |
| 限制 `memCacheWidth/Height` | 未配置 | 🟡 中 |
| 传入认证 HTTP 头 | Emby 图片未传 `X-Emby-Token` | 🔴 高 |
| 自定义 `cacheKey`（去除 token） | URL 含 `api_key` 参数 | 🟡 低 |
| 预缓存详情页图片 | 未实现 | 🟡 中 |

📁 **相关代码文件：**
- `pubspec.yaml`（已依赖 `cached_network_image_ce`）
- `lib/features/detail/detail_page.dart` 第256-262行（使用 `Image.network` 而非 `CachedNetworkImage`）

---

## 10. skeletonizer ^2.1.3 — 骨架屏层

### 项目现状
- ✅ DetailPage 使用 `Skeletonizer` + `Bone`
- ✅ 已导入 `skeletonizer` 包

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| 全局 `SkeletonizerConfigData` 主题扩展 | 未配置 | 🟡 中 |
| 统一自动骨架化替代手动 shimmer | HomePage 仍使用手动 `ShimmerCard` | 🟡 中 |
| 暗色主题骨架色适配 | 未确认暗色下骨架颜色 | 🟡 低 |
| `SliverSkeletonizer` | Sliver 场景未使用 | 🟡 低 |

---

## 11. app_links ^7.0.0 — 深度链接层

### 项目现状
- ⚠️ `pubspec.yaml` 已依赖
- ❌ 代码中完全未使用
- ❌ 未配置 `Info.plist` / `AndroidManifest.xml`

### 与最佳实践的差距
| 最佳实践 | 项目现状 | 差距评估 |
|----------|----------|----------|
| 处理外部分享链接 | 未实现 | 🔴 高 |
| 与 GoRouter 集成 | 未实现 | 🔴 高 |
| iOS `FlutterDeepLinkingEnabled = false` | 未配置 | 🟡 中 |
| AppDelegate 冷启动处理 | 未配置 | 🟡 中 |

📁 **相关代码文件：**
- `pubspec.yaml`（已依赖 `app_links: ^7.0.0`，但代码中无任何 import）
- `android/app/src/main/AndroidManifest.xml`（未配置 intent filter）
- `ios/Runner/Info.plist`（未配置 URL scheme）

---

## 📊 综合评估矩阵

| Package | 当前使用度 | 与最佳实践差距 | 改进优先级 |
|---------|-----------|---------------|-----------|
| flutter_riverpod | 高 | 中 | 🟡 P1 |
| go_router | 高 | 中 | 🟡 P1 |
| dio | 高 | 高 | 🔴 P0 |
| media_kit | 高 | 高 | 🔴 P0 |
| freezed | 高 | 低 | 🟢 P2 |
| flex_color_scheme | 高 | 低 | 🟢 P2 |
| flutter_secure_storage | 中 | 高 | 🔴 P0 |
| hive_ce | 低（未使用） | 高 | 🟡 P1 |
| cached_network_image_ce | 低（未使用） | 高 | 🔴 P0 |
| skeletonizer | 中 | 中 | 🟡 P1 |
| app_links | 低（未使用） | 高 | 🟡 P1 |
