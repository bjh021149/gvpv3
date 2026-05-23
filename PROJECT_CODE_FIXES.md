# Emby Client 代码修复方案（按优先级排序）

> 文档版本: v1.1 | 生成时间: 2026-05-15T10:43:24+08:00 | 更新: 2026-05-15
> 说明：每个问题标注精确的文件路径和行号，附带可直接替换的修改代码
> **修复进度：22 个问题中 9 个已解决（P0×4, P1×4, P2×1）**

---

## 🔴 P0 — 必须立即修复

---

### ✅ P0-1. Hardcoded empty DeviceId — 设备ID硬编码为空（已解决）

**相关文件：**
- `lib/core/api/emby_api_service.dart` 第608-629行

**当前代码：**
```dart
// lib/core/api/emby_api_service.dart:608-629
static String? _buildEmbyAuthorizationHeader({
  String? clientName,
  String? deviceName,
  String? deviceId,
  String? version,
}) {
  final parts = <String>[];
  
    parts.add('Client="CaoVideo"');
  
 
    parts.add('Device="Linux"');
  
  
    parts.add('DeviceId=''');
  
  
    parts.add('Version="1.0.0"');
  
  if (parts.isEmpty) return null;
  return 'MediaBrowser ${parts.join(', ')}';
}
```

**问题说明：** 空 `DeviceId` 导致 Emby 服务器无法区分不同设备，造成播放进度同步混乱、设备管理异常。传入的参数完全被忽略。

**修复代码：**
```dart
static String? _buildEmbyAuthorizationHeader({
  String? clientName,
  String? deviceName,
  String? deviceId,
  String? version,
}) {
  final effectiveClient = clientName?.trim().isNotEmpty == true ? clientName! : 'EmbyFlutter';
  final effectiveDevice = deviceName?.trim().isNotEmpty == true ? deviceName! : 'Unknown Device';
  final effectiveDeviceId = deviceId?.trim().isNotEmpty == true ? deviceId! : 'flutter-emby-device';
  final effectiveVersion = version?.trim().isNotEmpty == true ? version! : '1.0.0';

  return 'MediaBrowser '
      'Client="$effectiveClient", '
      'Device="$effectiveDevice", '
      'DeviceId="$effectiveDeviceId", '
      'Version="$effectiveVersion"';
}
```

**实际执行方案：** 使用传入的参数代替硬编码值，并为每个参数提供合理的默认值（`'EmbyFlutter'` / `'Unknown Device'` / `'unknown-device-id'` / `'1.0.0'`）。`AuthRepositoryImpl.authenticate()` 在调用时传入从 `SharedPreferences` 读取或生成的设备信息。

---

### ✅ P0-2. AuthRepositoryImpl bypasses Dio — 认证请求绕过 Dio 体系（已解决）

**相关文件：**
- `lib/services/repositories/auth_repository_impl.dart` 第76-148行

**当前代码：**
```dart
// lib/services/repositories/auth_repository_impl.dart:76-148
@override
Future<AuthenticationResult> authenticate(
  String serverUrl,
  String username,
  String password,
) async {
  // ... 设备信息读取 ...

  final authHeader =
      'MediaBrowser Client="EmbyFlutter", Device="$effectiveDeviceName", '
      'DeviceId="$effectiveDeviceId", Version="1.0.0"';

  final body = 'Username=${Uri.encodeComponent(username)}'
      '&Pw=${Uri.encodeComponent(password)}';

  final client = HttpClient();  // <-- 原始 HttpClient
  try {
    final request = await client.postUrl(
      Uri.parse('$serverUrl/Users/AuthenticateByName'),
    );
    request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
    request.headers.add('Authorization', authHeader);
    request.headers.add('Accept', 'application/json');
    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    // ...
  } catch (e) {
    // ...
  } finally {
    client.close();
  }
}
```

**问题说明：** 认证请求直接使用 `HttpClient`，导致：① 无法复用 Dio 的拦截器（日志、错误处理）；② 证书处理逻辑不统一；③ 设备头格式与 AuthInterceptor 不一致；④ 无重试机制。

**修复代码：**
```dart
@override
Future<AuthenticationResult> authenticate(
  String serverUrl,
  String username,
  String password,
) async {
  final prefs = await _sharedPrefs;
  final deviceName = prefs.getString('device_name');
  var deviceId = prefs.getString('device_id');
  final effectiveDeviceName =
      (deviceName != null && deviceName.isNotEmpty) ? deviceName : 'Flutter Device';

  if (deviceId == null || deviceId.isEmpty) {
    deviceId = const Uuid().v4();
    await prefs.setString('device_id', deviceId);
  }
  final effectiveDeviceId = deviceId;

  // 使用 Dio 而不是 HttpClient
  final authDio = Dio(BaseOptions(
    baseUrl: serverUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 复用证书白名单逻辑（见 P0-3）
  if (!kIsWeb) {
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

  final authHeader =
      'MediaBrowser Client="EmbyFlutter", Device="$effectiveDeviceName", '
      'DeviceId="$effectiveDeviceId", Version="1.0.0"';

  final body = 'Username=${Uri.encodeComponent(username)}'
      '&Pw=${Uri.encodeComponent(password)}';

  try {
    final response = await authDio.post<Map<String, dynamic>>(
      '/Users/AuthenticateByName',
      data: body,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': authHeader,
          'Accept': 'application/json',
        },
      ),
    );

    if (response.data == null) {
      throw const FormatException('Empty response from server');
    }

    final result = AuthenticationResult.fromJson(response.data!);
    await _persistAuthData(result, serverUrl, username);

    _apiService = EmbyApiService(
      dio: _createDio(serverUrl, result.accessToken!, effectiveDeviceId),
      userId: result.user?.id,
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
```

**同时删除** 原文件中的 `_createDio` 方法（第277-335行），因为它的功能已被 `DioClient.create()` 覆盖。

**实际执行方案：** `authenticate()` 改用 `Dio(BaseOptions(...))` 的 `post()` 发送请求，废弃了 raw `HttpClient`。`catch` 块中调用 `logout()` 清除凭据后 `rethrow`。支持通过构造函数注入 `authDio` 以便单元测试 Mock。`_createDio` 方法仍保留（待后续统一迁移到 `DioClient.create()`）。

---

### P0-3. Certificate trust too broad — 证书无条件信任所有 Host

**相关文件（两处）：**
- `lib/core/api/dio_client.dart` 第172-181行
- `lib/services/repositories/auth_repository_impl.dart` 第323-332行（`_createDio` 中）

**当前代码：**
```dart
// lib/core/api/dio_client.dart:172-181
if (!kIsWeb) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;  // <-- 信任所有
      return client;
    },
  );
}
```

**问题说明：** 生产环境中这是严重的安全风险，中间人攻击可完全绕过 HTTPS。

**修复代码：** 在 `lib/core/api/dio_client.dart` 中添加白名单函数，并替换两处调用。

```dart
// 添加到 lib/core/api/dio_client.dart，放在 DioClient 类外部或作为静态方法

/// 判断 host 是否允许自签名证书
/// 
/// 允许：localhost、127.0.0.1、局域网私有地址段
bool _isAllowedHost(String host) {
  if (host == 'localhost' || host == '127.0.0.1') return true;
  // 192.168.x.x
  if (host.startsWith('192.168.')) return true;
  // 10.x.x.x
  if (host.startsWith('10.')) return true;
  // 172.16.x.x ~ 172.31.x.x
  if (host.startsWith('172.')) {
    final secondOctet = int.tryParse(host.split('.')[1]);
    if (secondOctet != null && secondOctet >= 16 && secondOctet <= 31) return true;
  }
  return false;
}
```

然后替换 `lib/core/api/dio_client.dart` 第172-181行：

```dart
if (!kIsWeb) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return _isAllowedHost(host);
      };
      return client;
    },
  );
}
```

---

### P0-4. flutter_secure_storage deprecated API — 使用已弃用的加密参数

**相关文件（两处）：**
- `lib/core/api/dio_client.dart` 第69-75行
- `lib/services/repositories/auth_repository_impl.dart` 第45-53行

**当前代码：**
```dart
// lib/core/api/dio_client.dart:69-75
const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),  // <-- 已弃用
  iOptions: IOSOptions(
    accountName: 'emby_auth',
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);
```

```dart
// lib/services/repositories/auth_repository_impl.dart:45-53
static const _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,  // <-- 已弃用
  ),
  iOptions: IOSOptions(
    accountName: 'emby_auth',
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);
```

**问题说明：** `encryptedSharedPreferences` 在 flutter_secure_storage v10 中已弃用，依赖的 Jetpack Security 库已被 Google 弃用。

**修复代码（两处均替换）：**

```dart
// 统一提取为共享实例，避免重复创建
const _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    // encryptedSharedPreferences 已弃用，移除
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

然后 `dioClientProvider` 改用这个共享实例：

```dart
final dioClientProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(embyBaseUrlProvider);
  final deviceInfo = ref.watch(deviceInfoProvider);

  final dio = DioClient.create(
    baseUrl: baseUrl.isEmpty ? null : baseUrl,
    deviceInfo: deviceInfo,
    secureStorage: () => _secureStorage.read(key: 'emby_access_token'),
    ref: ref,
  );

  return dio;
});
```

---

### P0-5. New FlutterSecureStorage per read — Provider body 中重复创建实例

**相关文件：**
- `lib/core/api/dio_client.dart` 第60-82行（`dioClientProvider`）

**当前代码：**
```dart
final dioClientProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(embyBaseUrlProvider);
  final deviceInfo = ref.watch(deviceInfoProvider);

  final dio = DioClient.create(
    // ...
    secureStorage: () async {
      const secureStorage = FlutterSecureStorage(/* ... */);  // <-- 每次 watch 都创建
      return secureStorage.read(key: 'emby_access_token');
    },
    // ...
  );
  return dio;
});
```

**问题说明：** `Provider` body 在依赖变化时会重新执行，每次都创建新的 `FlutterSecureStorage` 实例。虽然该对象本身较轻量，但不符合最佳实践。

**修复代码：** 与 P0-4 合并解决 — 将 `FlutterSecureStorage` 提取为文件级 `const` 实例，见 P0-4 的修复。

---

### ✅ P0-6. PlayerViewModel track switching unimplemented — 音轨/字幕切换未实现（已解决）

**相关文件：**
- `lib/features/player/player_viewmodel.dart` 第261-283行

**当前代码：**
```dart
// lib/features/player/player_viewmodel.dart:261-283
void selectAudioTrack(int index) {
  final current = state.value;
  if (current == null) return;
  if (index < 0 || index >= current.audioTracks.length) return;

  _updateState((s) => s.copyWith(selectedAudioIndex: index));

  // TODO: Notify the underlying player of the audio track change.
}

void selectSubtitleTrack(int index) {
  final current = state.value;
  if (current == null) return;
  if (index < -1 || index >= current.subtitleTracks.length) return;

  _updateState((s) => s.copyWith(selectedSubtitleIndex: index));

  // TODO: Notify the underlying player of the subtitle track change.
}
```

**修复代码：**
```dart
void selectAudioTrack(int index) {
  _updateState((s) => s.copyWith(selectedAudioIndex: index));
  _reportStreamSelection();
}

void selectSubtitleTrack(int index) {
  _updateState((s) => s.copyWith(selectedSubtitleIndex: index));
  if (index == -1) {
    _requirePlayer.setSubtitleTrack(SubtitleTrack.no());
  } else {
    _loadExternalSubtitle(index);
  }
  _reportStreamSelection();
}
```

**实际执行方案：** 音轨/字幕切换不再直接操作播放器 URI，而是通过 Emby 的 `PlaybackInfo` 机制：先更新状态，再调用 `_reportStreamSelection()` 通知服务器所选流，由服务器返回新的播放 URL。字幕禁用使用 `SubtitleTrack.no()`，外部字幕通过 `_loadExternalSubtitle(index)` 加载。

---

### ✅ P0-7. PlayerViewModel unsafe dispose — 未先 pause 直接 dispose（已解决）

**相关文件：**
- `lib/features/player/player_viewmodel.dart` 第328-336行

**当前代码：**
```dart
void _disposePlayer() {
  _cancelControlsTimer();
  for (final sub in _subscriptions) {
    sub.cancel();
  }
  _subscriptions.clear();
  _player?.dispose();   // <-- 直接 dispose
  _player = null;
}
```

**问题说明：** media_kit v1.2.6 在 macOS/Windows 存在已知问题，直接 `dispose()` 可能触发 native 层崩溃。

**修复代码：**
```dart
void _disposePlayer() async {
  _cancelControlsTimer();
  for (final sub in _subscriptions) { sub.cancel(); }
  _subscriptions.clear();
  if (_player != null) {
    try { await _player!.pause(); } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 100));
    _player!.dispose();
    _player = null;
  }
}
```

**实际执行方案：** 将 `_disposePlayer()` 改为 `async` 方法，在 `dispose()` 前先 `await player.pause()`，并增加 100ms 延迟确保 native 层资源释放完毕。使用 `try-catch` 包裹 `pause()` 避免 player 已销毁时抛出异常。

---

### P0-8. PlayerViewModel token in URL — API Key 暴露在 URL 中

**相关文件：**
- `lib/features/player/player_viewmodel.dart` 第166-182行

**当前代码：**
```dart
final directUrl =
    '$serverUrl/Videos/$streamId/stream'
    '?Static=true'
    '&api_key=$token';  // <-- token 暴露在 URL
final hlsUrl =
    '$serverUrl/Videos/$streamId/master.m3u8'
    '?api_key=$token';  // <-- token 暴露在 URL

await player.open(Media(directUrl));
```

**问题说明：** `api_key` 出现在 URL 中会被日志记录、浏览器历史缓存。应使用 HTTP Header 传递。

**修复代码：**
```dart
final token = await ref.read(authRepositoryProvider).getAccessToken();

final directUrl = '$serverUrl/Videos/$streamId/stream?Static=true';
final hlsUrl = '$serverUrl/Videos/$streamId/master.m3u8';

await player.open(
  Media(
    directUrl,
    httpHeaders: {'X-Emby-Token': token ?? ''},
  ),
);
```

---

### P0-9. CachedNetworkImage unused — DetailPage 使用 Image.network 无缓存无认证

**相关文件：**
- `lib/features/detail/detail_page.dart` 第256-262行
- `pubspec.yaml` 已依赖 `cached_network_image_ce`

**当前代码：**
```dart
// lib/features/detail/detail_page.dart:256-262
Image.network(
  backdropUrl,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) => Container(
    color: colorScheme.surfaceContainerHighest,
  ),
)
```

**问题说明：** ① 无本地缓存，重复加载；② 未传 `X-Emby-Token` 头，私有服务器可能 401；③ URL 含 `api_key` 时缓存 key 不唯一。

**修复代码：**

首先需要确保 `BaseItemDto.getImageUrl` 返回的 URL 不含 token 参数（token 通过 HTTP Header 传递）。检查 `getImageUrl` 实现，如果它在 URL 中拼接了 `api_key`，需要改为返回裸 URL。

然后修改 DetailPage：

```dart
import 'package:cached_network_image_ce/cached_network_image.dart';

// 在 _buildSliverAppBar 中替换 Image.network
if (backdropUrl != null)
  Consumer(
    builder: (context, ref, child) {
      final token = ref.read(authRepositoryProvider).getAccessToken();
      return CachedNetworkImage(
        imageUrl: backdropUrl,
        fit: BoxFit.cover,
        memCacheWidth: 800,
        maxWidthDiskCache: 1200,
        httpHeaders: {'X-Emby-Token': token ?? ''},
        placeholder: (context, url) => Container(
          color: colorScheme.surfaceContainerHighest,
        ),
        errorWidget: (context, url, error) => Container(
          color: colorScheme.surfaceContainerHighest,
        ),
      );
    },
  )
```

> 注意：`getImageUrl` 的实现未在本次读取范围内，请检查 `lib/core/models/base_item_dto.dart` 中的该方法，确保返回的 URL 不含 `api_key` 参数。



---

## 🟡 P1 — 高优先级

---

### ✅ P1-1. HomePage watches entire HomeState — 全页重建问题（已解决）

**相关文件：**
- `lib/features/home/home_page.dart` 第25行
- `lib/features/home/home_viewmodel.dart` 第8-9行、第42-76行

**当前代码：**
```dart
// lib/features/home/home_page.dart:25
final homeState = ref.watch(homeViewModelProvider);  // <-- watch 整个 State
```

**问题说明：** `HomeState` 包含 carouselItems / continueWatching / recentlyAdded 三个列表。任一列表变化都会触发整个页面的 `ConsumerWidget` rebuild。

**修复代码：** 将 `HomeState` 拆分为三个独立的 `FutureProvider`。

在 `lib/features/home/home_viewmodel.dart` 中，保留 `HomeViewModel` 用于兼容，但新增三个独立的 Provider：

```dart
// 内部共享 Provider：获取视图列表
final _homeViewsProvider = FutureProvider.autoDispose<QueryResult<BaseItemDto>>((ref) async {
  final repo = ref.read(mediaRepositoryProvider);
  return await repo.getViews();
});

// 内部共享 Provider：获取最新条目（limit: 10）
final _latestItemsProvider = FutureProvider.autoDispose<List<BaseItemDto>>((ref) async {
  final views = await ref.watch(_homeViewsProvider.future);
  if (views.items.isEmpty) return [];
  final result = await ref.read(mediaRepositoryProvider).getLatestItems(
    parentId: views.items.first.id, limit: 10,
  );
  return result.items;
});

// 三个独立的外部 Provider
final carouselItemsProvider = FutureProvider.autoDispose<List<BaseItemDto>>((ref) async {
  final items = await ref.watch(_latestItemsProvider.future);
  return items.take(5).toList();
});

final continueWatchingProvider = FutureProvider.autoDispose<List<BaseItemDto>>((ref) async {
  final repo = ref.read(mediaRepositoryProvider);
  final result = await repo.getContinueWatching(limit: 10);
  return result.items;
});

final recentlyAddedProvider = FutureProvider.autoDispose<List<BaseItemDto>>((ref) async {
  final items = await ref.watch(_latestItemsProvider.future);
  return items;
});
```

**实际执行方案：** 
- 拆分为三个独立的 `FutureProvider.autoDispose`：`carouselItemsProvider`、`continueWatchingProvider`、`recentlyAddedProvider`。
- 引入两个内部共享 Provider（`_homeViewsProvider`、`_latestItemsProvider`），确保 `getViews()` 和 `getLatestItems()` 各只请求一次 API，与拆分前 API 调用次数一致。
- `HomePage` 改为分别 watch 三个 Provider，每个 section 独立处理 data/loading/error，任一 Provider 更新只重建对应区域。
- `RefreshIndicator.onRefresh` 改为 `ref.invalidate(...)` 三个 Provider。
- `HomeViewModel` 和 `homeViewModelProvider` 保留为兼容层，标记 `@deprecated`。

然后修改 `lib/features/home/home_page.dart`：

```dart
// 替换整个 build 方法中的 watch 逻辑
@override
Widget build(BuildContext context, WidgetRef ref) {
  final carouselAsync = ref.watch(carouselItemsProvider);
  final continueAsync = ref.watch(continueWatchingProvider);
  final recentAsync = ref.watch(recentlyAddedProvider);

  return Scaffold(
    body: RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(carouselItemsProvider);
        ref.invalidate(continueWatchingProvider);
        ref.invalidate(recentlyAddedProvider);
      },
      child: _buildContentFromProviders(context, carouselAsync, continueAsync, recentAsync),
    ),
  );
}

Widget _buildContentFromProviders(
  BuildContext context,
  AsyncValue<List<BaseItemDto>> carouselAsync,
  AsyncValue<List<BaseItemDto>> continueAsync,
  AsyncValue<List<BaseItemDto>> recentAsync,
) {
  final slivers = <Widget>[
    const SliverAppBar(
      floating: true,
      pinned: true,
      title: Text('Home'),
      centerTitle: false,
    ),
  ];

  // Hero carousel
  carouselAsync.whenData((items) {
    if (items.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: HeroCarousel(items: items),
          ),
        ),
      );
    }
  });

  // Continue watching
  continueAsync.whenData((items) {
    if (items.isNotEmpty) {
      slivers.add(const SliverToBoxAdapter(child: SectionHeader(title: 'Continue Watching')));
      slivers.add(
        SliverToBoxAdapter(child: ContinueWatchingRow(items: items)),
      );
    }
  });

  // Recently added
  recentAsync.whenData((items) {
    if (items.isNotEmpty) {
      slivers.add(const SliverToBoxAdapter(child: SectionHeader(title: 'Recently Added')));
      slivers.add(
        SliverToBoxAdapter(child: _RecentlyAddedRow(items: items)),
      );
    }
  });

  // Loading state: show shimmer if ALL are loading
  if (carouselAsync.isLoading && continueAsync.isLoading && recentAsync.isLoading) {
    return _buildShimmerLoading(context);
  }

  // Error state: show error if ANY has error and NONE has data
  final hasError = carouselAsync.hasError || continueAsync.hasError || recentAsync.hasError;
  final hasData = carouselAsync.hasValue || continueAsync.hasValue || recentAsync.hasValue;
  if (hasError && !hasData) {
    final firstError = carouselAsync.error ?? continueAsync.error ?? recentAsync.error;
    return _buildError(context, firstError ?? 'Unknown error', ref);
  }

  slivers.add(const SliverPadding(padding: EdgeInsets.only(bottom: 32)));
  return CustomScrollView(slivers: slivers);
}
```

---

### ✅ P1-2. HomeViewModel.refresh outdated — 使用过时的手动 refresh 模式（已解决）

**相关文件：**
- `lib/features/home/home_viewmodel.dart` 第79-82行

**当前代码：**
```dart
// lib/features/home/home_viewmodel.dart:79-82
Future<void> refresh() async {
  state = const AsyncLoading<HomeState>();
  state = await AsyncValue.guard(() => build());
}
```

**问题说明：** Riverpod v3 推荐调用方使用 `ref.invalidate(provider)`，由框架自动处理 `AsyncLoading` 状态流转。

**修复代码：** 如果已采用 P1-1 的拆分方案，此问题已自然解决（使用 `ref.invalidate()`）。

如果保留原 `HomeViewModel`，修改为：

```dart
Future<void> refresh() async {
  ref.invalidateSelf();
}
```

**实际执行方案：** `HomeViewModel.refresh()` 已简化为 `ref.invalidateSelf()`，不再手动设置 `AsyncLoading`。新代码中 `HomePage` 的 `RefreshIndicator` 直接使用 `ref.invalidate(carouselItemsProvider)` 等细粒度 Provider，由 Riverpod 自动处理状态流转。

调用方改为：
```dart
onRefresh: () async {
  ref.invalidate(homeViewModelProvider);
},
```

---

### P1-3. GoRouter redirect async on every navigation — 每次导航都异步读存储

**相关文件：**
- `lib/routes.dart` 第31-49行

**当前代码：**
```dart
// lib/routes.dart:31-49
final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final isAuthenticated = await authRepo.isAuthenticated();  // <-- 每次导航都读 SecureStorage
      final isAuthRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/login';
      if (!isAuthenticated && !isAuthRoute) return '/';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    // ...
  );
});
```

**问题说明：** `redirect` 在每次导航时都会执行，`await authRepo.isAuthenticated()` 触发 `SecureStorage` 异步磁盘读取，造成导航延迟。

**修复代码：** 引入 `refreshListenable` + `ChangeNotifier` 模式。

新建 `lib/core/auth/auth_notifier.dart`：

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    if (_isAuthenticated != value) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }
}
```

修改 `lib/routes.dart`：

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,  // <-- 认证状态变化时自动重评估
    redirect: (context, state) {
      final isAuthenticated = authNotifier.isAuthenticated;  // <-- 同步读取
      final isAuthRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/login';
      if (!isAuthenticated && !isAuthRoute) return '/';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    // ... routes 不变
  );
});
```

在认证流程中更新 `AuthNotifier`：

```dart
// lib/services/repositories/auth_repository_impl.dart
// 在 authenticate() 成功后和 logout() 后通知路由

@override
Future<AuthenticationResult> authenticate(...) async {
  // ... 原有逻辑 ...
  final result = AuthenticationResult.fromJson(response.data!);
  await _persistAuthData(result, serverUrl, username);
  
  // 通知路由刷新
  ref.read(authNotifierProvider).setAuthenticated(true);
  
  return result;
}

@override
Future<void> logout() async {
  // ... 清除存储 ...
  ref.read(authNotifierProvider).setAuthenticated(false);
}
```

---

### ✅ P1-4. SettingsPage double navigation shell — 双重导航壳层（已解决）

**相关文件：**
- `lib/features/settings/settings_page.dart` 第24-68行
- `lib/app_shell.dart`（外层已提供 `AppShell`）

**当前代码：**
```dart
// lib/features/settings/settings_page.dart:24-68
@override
Widget build(BuildContext context, WidgetRef ref) {
  return ResponsiveNav(  // <-- 内部又包了一层导航
    currentIndex: 2,
    body: Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: /* ... */,
    ),
  );
}
```

**问题说明：** 外层 `StatefulShellRoute` 已经通过 `AppShell` 提供了底部/侧边导航。`SettingsPage` 内部再包 `ResponsiveNav` 会导致桌面端出现两个导航栏。

**修复代码：** 移除内部的 `ResponsiveNav`：

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Scaffold(
    appBar: AppBar(
      title: Semantics(
        label: '设置页面标题',
        child: Text(
          '设置',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
    ),
    body: SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              const ThemeModeSelector(),
              _buildPlaybackSettingsGroup(context, colorScheme, textTheme),
              const ServerConnectionEditor(),
              const CacheManagement(),
              const AboutAppSection(),
              const SizedBox(height: 16),
              _buildLogoutButton(context, ref, colorScheme, textTheme),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    ),
  );
}
```

**实际执行方案：** 直接移除了 `SettingsPage` 内部的 `ResponsiveNav` 包装，改为直接返回 `Scaffold`。外层 `StatefulShellRoute` 已通过 `AppShell` 提供底部/侧边导航，不再需要在页面内部嵌套导航壳层。

---

### P1-5. PlayerViewModel exception swallowing — 异常被静默吞掉

**相关文件：**
- `lib/features/player/player_viewmodel.dart` 第222-257行多处

**当前代码：**
```dart
void playPause() {
  try {
    _requirePlayer.playOrPause();
  } catch (_) {
    // Player not ready; ignore.
  }
}

void seek(Duration position) {
  try {
    _requirePlayer.seek(position);
  } catch (_) {
    // Player not ready; ignore.
  }
}

void setVolume(double volume) {
  try {
    final clamped = volume.clamp(0.0, 1.0);
    _requirePlayer.setVolume(clamped * 100);
    _updateState((s) => s.copyWith(volume: clamped));
  } catch (_) {
    // Player not ready; ignore.
  }
}
```

**问题说明：** 用户完全不知道操作是否失败，无法诊断问题。

**修复代码：** 区分 `StateError`（player 未就绪，可静默忽略）和其他异常（应记录或上报）。

```dart
void playPause() {
  try {
    _requirePlayer.playOrPause();
  } on StateError catch (e) {
    debugPrint('[Player] playPause ignored: player not ready ($e)');
  } catch (e, st) {
    debugPrint('[Player] playPause error: $e');
    debugPrintStack(stackTrace: st);
    _updateState((s) => s.copyWith(error: 'Playback control failed: $e'));
  }
}

void seek(Duration position) {
  try {
    _requirePlayer.seek(position);
  } on StateError catch (e) {
    debugPrint('[Player] seek ignored: player not ready ($e)');
  } catch (e, st) {
    debugPrint('[Player] seek error: $e');
    debugPrintStack(stackTrace: st);
  }
}

void setVolume(double volume) {
  try {
    final clamped = volume.clamp(0.0, 1.0);
    _requirePlayer.setVolume(clamped * 100);
    _updateState((s) => s.copyWith(volume: clamped));
  } on StateError catch (e) {
    debugPrint('[Player] setVolume ignored: player not ready ($e)');
  } catch (e, st) {
    debugPrint('[Player] setVolume error: $e');
    debugPrintStack(stackTrace: st);
    _updateState((s) => s.copyWith(error: 'Volume control failed: $e'));
  }
}

void setSpeed(double speed) {
  try {
    _requirePlayer.setRate(speed);
    _updateState((s) => s.copyWith(speed: speed));
  } on StateError catch (e) {
    debugPrint('[Player] setSpeed ignored: player not ready ($e)');
  } catch (e, st) {
    debugPrint('[Player] setSpeed error: $e');
    debugPrintStack(stackTrace: st);
  }
}
```

---

### ✅ P1-6. Detail page back button unconditional go('/home') — 返回按钮不智能（已解决）

**相关文件：**
- `lib/features/detail/detail_page.dart` 第231-235行（`_buildSliverAppBar` 中的 leading）

**当前代码：**
```dart
// lib/features/detail/detail_page.dart:231-235
leading: IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () {
    context.go('/home');  // <-- 无条件回首页
  },
),
```

**问题说明：** 从"相似推荐"或"搜索结果"进入详情页时，返回应回到上一页而非强制回首页。

**修复代码：**
```dart
leading: IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  },
),
```

**实际执行方案：** 将 `context.go('/home')` 改为先检查 `context.canPop()`，有历史记录时调用 `context.pop()` 返回上一页，无历史记录时才回退到 `/home`。这样从"相似推荐"或"搜索结果"进入详情页时，返回会回到上一页而非强制回首页。

> 注意：错误页面和空状态的返回按钮已经正确使用了 `canPop()` + `pop()` 模式，只有 `_buildSliverAppBar` 中的返回按钮需要修改。

---

### ✅ P1-7. AuthInterceptor _clearCredentials empty — 401 处理时未清除凭据（已解决）

**相关文件：**
- `lib/core/api/auth_interceptor.dart` 第126-133行

**当前代码：**
```dart
Future<void> _clearCredentials() async {
  try {
    // Clear secure storage
    // Implementation depends on your secure storage provider
  } catch (e) {
    debugPrint('AuthInterceptor: Failed to clear credentials: $e');
  }
}
```

**问题说明：** `// Implementation depends on...` 注释表示未实现。401 时只跳转登录页，实际凭据未清除，可能再次 401 死循环。

**修复代码：** 通过 `ref` 访问 `AuthRepository` 执行登出：

```dart
Future<void> _clearCredentials() async {
  try {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
  } catch (e) {
    debugPrint('AuthInterceptor: Failed to clear credentials: $e');
  }
}
```

需要在 `lib/core/api/auth_interceptor.dart` 顶部导入：
```dart
import 'package:emby_client/services/repositories/auth_repository_impl.dart';
```

**实际执行方案：** `_clearCredentials()` 现在通过 `ref.read(authRepositoryProvider)` 获取 `AuthRepository` 实例并调用 `logout()`，真正清除所有 5 项凭据（accessToken、serverUrl、password、sessionId、userId）。同时新增了 `refreshAuthentication()` 自动刷新机制：首次 401 时尝试用存储的用户名/密码重新认证，成功后重试原请求；若刷新失败或再次 401，则清除凭据并跳转登录页。通过 `X-Auth-Refreshed` header 防止循环刷新。

---

## 🟢 P2 — 中优先级

---

### P2-1. Theme black mode not persisted — 纯黑主题无法持久化

**相关文件：**
- `lib/core/theme/theme_notifier.dart` 第166-179行

**当前代码：**
```dart
// lib/core/theme/theme_notifier.dart:166-179
Future<void> setAppThemeMode(AppThemeMode appMode) async {
  final ThemeMode flutterMode;
  switch (appMode) {
    case AppThemeMode.light:
      flutterMode = ThemeMode.light;
    case AppThemeMode.dark:
      flutterMode = ThemeMode.dark;
    case AppThemeMode.black:
      flutterMode = ThemeMode.dark;  // <-- black 保存为 dark
    case AppThemeMode.system:
      flutterMode = ThemeMode.system;
  }
  await setThemeMode(flutterMode);  // <-- 丢失 black 标志
}
```

**问题说明：** `AppThemeMode.black` 保存时丢失了 black 标志，重启后无法恢复为纯黑主题。

**修复代码：** 新增 `black` 标志的持久化：

```dart
// 在 ThemeNotifier 中新增常量
static const _isBlackModeKey = 'is_black_mode';

@override
Future<ThemeState> build() async {
  final prefs = await SharedPreferences.getInstance();
  final savedMode = prefs.getString(_themeModeKey);
  final savedColor = prefs.getInt(_seedColorKey);
  final savedDynamic = prefs.getBool(_useDynamicKey);
  final savedIsBlack = prefs.getBool(_isBlackModeKey);

  return ThemeState(
    mode: _parseThemeMode(savedMode),
    seedColor: savedColor != null ? Color(savedColor) : null,
    useDynamicColor: savedDynamic ?? true,
    isBlackMode: savedIsBlack ?? false,  // <-- 新增字段
  );
}

Future<void> setAppThemeMode(AppThemeMode appMode) async {
  final prefs = await SharedPreferences.getInstance();
  final ThemeMode flutterMode;
  final bool isBlack;

  switch (appMode) {
    case AppThemeMode.light:
      flutterMode = ThemeMode.light;
      isBlack = false;
    case AppThemeMode.dark:
      flutterMode = ThemeMode.dark;
      isBlack = false;
    case AppThemeMode.black:
      flutterMode = ThemeMode.dark;
      isBlack = true;
    case AppThemeMode.system:
      flutterMode = ThemeMode.system;
      isBlack = false;
  }

  await prefs.setString(_themeModeKey, flutterMode.name);
  await prefs.setBool(_isBlackModeKey, isBlack);

  final current = state.value ?? const ThemeState();
  state = AsyncValue.data(current.copyWith(mode: flutterMode, isBlackMode: isBlack));
}
```

同时 `ThemeState` 需要新增 `isBlackMode` 字段，`AppTheme` 根据此字段决定使用 `darkTheme` 还是 `blackTheme`：

```dart
// lib/core/theme/theme_notifier.dart:30-52
class ThemeState {
  final ThemeMode mode;
  final Color? seedColor;
  final bool useDynamicColor;
  final bool isBlackMode;  // <-- 新增

  AppThemeMode get appThemeMode => switch (mode) {
        ThemeMode.light => AppThemeMode.light,
        ThemeMode.dark => isBlackMode ? AppThemeMode.black : AppThemeMode.dark,
        ThemeMode.system => AppThemeMode.system,
      };

  const ThemeState({
    this.mode = ThemeMode.system,
    this.seedColor,
    this.useDynamicColor = true,
    this.isBlackMode = false,  // <-- 新增
  });

  ThemeState copyWith({
    ThemeMode? mode,
    Color? seedColor,
    bool? useDynamicColor,
    bool? isBlackMode,  // <-- 新增
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      isBlackMode: isBlackMode ?? this.isBlackMode,
    );
  }
  // ... hashCode / == / toString 也需更新
}
```

然后修改 `lib/app.dart` 中的主题选择逻辑：

```dart
// lib/app.dart
themeAsync.when(
  data: (themeState) => MaterialApp.router(
    // ...
    theme: AppTheme.lightTheme(dynamicSeed: themeState.seedColor),
    darkTheme: themeState.isBlackMode
        ? AppTheme.blackTheme(dynamicSeed: themeState.seedColor)
        : AppTheme.darkTheme(dynamicSeed: themeState.seedColor),
    themeMode: themeState.mode,
    // ...
  ),
  // ...
)
```

---

### P2-2. isDarkModeProvider returns false for system — 系统模式判断错误

**相关文件：**
- `lib/core/theme/theme_notifier.dart` 第193-206行

**当前代码：**
```dart
// lib/core/theme/theme_notifier.dart:193-206
final isDarkModeProvider = Provider<bool>((ref) {
  final themeAsync = ref.watch(themeNotifierProvider);
  return themeAsync.when(
    data: (state) {
      if (state.mode == ThemeMode.system) {
        return false;  // <-- 默认 false，不准确
      }
      return state.mode == ThemeMode.dark;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});
```

**问题说明：** `ThemeMode.system` 时直接返回 `false`，忽略了用户实际系统亮度。由于 Provider 无 `BuildContext`，无法通过 `MediaQuery` 判断。

**修复方案：** 将 `isDarkModeProvider` 改为接受 `BuildContext` 的函数，或提供 `PlatformBrightness` 的 Stream。

**方案 A（推荐）：移除全局 Provider，改为 Widget 内判断**

```dart
// 删除 isDarkModeProvider，改为在需要的地方使用：
// final isDark = Theme.of(context).brightness == Brightness.dark;
```

**方案 B（保留 Provider，但需要 FlutterBinding）：**

```dart
final isDarkModeProvider = Provider<bool>((ref) {
  final themeAsync = ref.watch(themeNotifierProvider);
  return themeAsync.when(
    data: (state) {
      if (state.mode == ThemeMode.system) {
        // 使用 PlatformDispatcher 获取系统亮度（近似值，无 BuildContext）
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      }
      return state.mode == ThemeMode.dark || state.isBlackMode;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});
```

---

### P2-3. Login page hardcoded dark colors — 登录页硬编码深色背景

**相关文件：**
- `lib/features/auth/login_page.dart` 第111-133行

**当前代码：**
```dart
// lib/features/auth/login_page.dart:111-133
body: Container(
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0D0D0D),
        Color(0xFF1A1A2E),
        Color(0xFF16213E),
      ],
    ),
  ),
  child: /* ... 表单 ... */
),
```

**问题说明：** 系统亮色模式下登录页极不协调。`_LoginForm` 中也大量使用硬编码 `Colors.white`。

**修复代码：** 使用 `Theme.of(context).colorScheme` 动态取值，或限制为暗色主题场景：

```dart
body: Container(
  decoration: BoxDecoration(
    gradient: Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              Theme.of(context).colorScheme.surface,
            ],
          ),
  ),
  child: /* ... */
),
```

同时 `_LoginForm` 中硬编码的 `Colors.white` 需要替换为 `colorScheme.onSurface`：

```dart
// 将 _LoginForm 中所有 Colors.white 替换为 theme-dependent 颜色
// 例如：
style: const TextStyle(color: Colors.white),  // 旧
style: TextStyle(color: colorScheme.onSurface),  // 新
```

---

### P2-4. hive_ce unused — 依赖已引入但代码中完全未使用

**相关文件：** `pubspec.yaml`

**现状：** `hive_ce: ^2.19.3` 和 `hive_ce_flutter: ^2.19.3` 已在 `pubspec.yaml` 中声明，但代码中没有任何 `import 'package:hive_ce/...'`。

**建议：** 要么：
1. **移除依赖**（如果近期无计划使用）
2. **引入本地缓存层**（见 `PROJECT_RECOMMENDATIONS_V2.md` Sprint 4 建议）

---

### P2-5. app_links unused — 深度链接依赖未使用

**相关文件：** `pubspec.yaml`

**现状：** `app_links: ^7.0.0` 已在 `pubspec.yaml` 中声明，但代码中无任何使用。同时未配置 `AndroidManifest.xml` / `Info.plist` 的 intent filter。

**建议：** 要么：
1. **移除依赖**
2. **实现深度链接处理**（见 `PROJECT_RECOMMENDATIONS_V2.md`）

---

### ✅ P2-6. Zero test coverage — 测试目录为空（已解决）

**相关文件：** `test/` 目录

**现状：** 没有任何测试文件。

**建议入门测试：** 创建 `test/core/api/dio_client_test.dart`：

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:emby_client/services/repositories/auth_repository_impl.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockDio extends Mock implements Dio {}

void main() {
  group('AuthRepositoryImpl', () {
    // ... 9 个测试用例：成功登录、无 SessionInfo、失败登录、logout、
    // refreshAuthentication（成功/缺失凭据）、getSessionId（有/无）、
    // 以及真实服务器集成测试
  });
}
```

**实际执行方案：** 创建了 `test/services/auth_repository_impl_test.dart`，包含 9 个测试用例：
1. 成功登录持久化全部 5 项凭据
2. 无 SessionInfo 时跳过 session_id 写入
3. 登录失败时通过 `logout()` 清除凭据
4. `logout()` 清除所有凭据
5. `refreshAuthentication()` 使用存储凭据重新认证
6. 缺失凭据时 `refreshAuthentication()` 返回 false
7. `getSessionId()` 返回已存储的 session ID
8. `getSessionId()` 未存储时返回 null
9. **真实服务器集成测试**：连接 `http://qqpyf.vip:7001` 验证完整认证流程

所有 9 个测试均已通过。Mocktail 用于 mock `FlutterSecureStorage` 和 `Dio`；`SharedPreferences.setMockInitialValues({})` 用于 mock SharedPreferences。

---

## 📋 修改检查清单

| # | 问题 | 文件 | 行号 | 优先级 | 状态 |
|---|------|------|------|--------|------|
| 1 | Hardcoded DeviceId | `lib/core/api/emby_api_service.dart` | 608-629 | P0 | ✅ |
| 2 | AuthRepositoryImpl bypasses Dio | `lib/services/repositories/auth_repository_impl.dart` | 76-148 | P0 | ✅ |
| 3 | Certificate trust too broad (1) | `lib/core/api/dio_client.dart` | 172-181 | P0 | ☐ |
| 3 | Certificate trust too broad (2) | `lib/services/repositories/auth_repository_impl.dart` | 323-332 | P0 | ☐ |
| 4 | SecureStorage deprecated API (1) | `lib/core/api/dio_client.dart` | 69-75 | P0 | ☐ |
| 4 | SecureStorage deprecated API (2) | `lib/services/repositories/auth_repository_impl.dart` | 45-53 | P0 | ☐ |
| 5 | New SecureStorage per read | `lib/core/api/dio_client.dart` | 60-82 | P0 | ☐ |
| 6 | Track switching unimplemented | `lib/features/player/player_viewmodel.dart` | 261-283 | P0 | ✅ |
| 7 | Unsafe player dispose | `lib/features/player/player_viewmodel.dart` | 328-336 | P0 | ✅ |
| 8 | Token in URL | `lib/features/player/player_viewmodel.dart` | 166-182 | P0 | ☐ |
| 9 | Image.network instead of CachedNetworkImage | `lib/features/detail/detail_page.dart` | 256-262 | P0 | ☐ |
| 10 | HomePage watches entire state | `lib/features/home/home_page.dart` | 25 | P1 | ✅ |
| 10 | HomePage watches entire state | `lib/features/home/home_viewmodel.dart` | 8-76 | P1 | ☐ |
| 11 | Outdated refresh pattern | `lib/features/home/home_viewmodel.dart` | 79-82 | P1 | ✅ |
| 12 | Async redirect on every nav | `lib/routes.dart` | 31-49 | P1 | ☐ |
| 13 | Double nav shell | `lib/features/settings/settings_page.dart` | 24-68 | P1 | ✅ |
| 14 | Exception swallowing | `lib/features/player/player_viewmodel.dart` | 222-257 | P1 | ☐ |
| 15 | Black theme not persisted | `lib/core/theme/theme_notifier.dart` | 166-179 | P2 | ☐ |
| 16 | isDarkModeProvider system bug | `lib/core/theme/theme_notifier.dart` | 193-206 | P2 | ☐ |
| 17 | Login page hardcoded colors | `lib/features/auth/login_page.dart` | 111-133 | P2 | ☐ |
| 18 | Back button unconditional | `lib/features/detail/detail_page.dart` | 231-235 | P2 | ✅ |
| 19 | AuthInterceptor clear empty | `lib/core/api/auth_interceptor.dart` | 126-133 | P2 | ✅ |
| 20 | hive_ce unused | `pubspec.yaml` | - | P2 | ☐ |
| 21 | app_links unused | `pubspec.yaml` | - | P2 | ☐ |
| 22 | Zero test coverage | `test/` | - | P2 | ✅ |
