# V1 审阅中发现、但 V2 遗漏的问题清单（含代码路径与解决方案）

> 文档版本: v1.1 | 更新: 2026-05-15
> 说明：本文档对比 `PROJECT_REVIEW_SUMMARY.md` (v1) 与 `PROJECT_REVIEW_SUMMARY_V2.md` (v2)，
> 列出 v1 已识别但 v2 在 Package 实践对标过程中**未提及或不够具体**的问题。
> 每个问题均标注精确文件路径和行号，附带可直接落地的解决方案。
> **修复进度：14 个问题中 0 个在本文档内解决（7 个已通过在 `PROJECT_CODE_FIXES.md` 中的修复间接解决，见文末进度表）**

---

## 一、架构与代码结构问题

---

### 1. API Service 与 Repository 边界模糊

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第32行

📁 **相关代码文件：**
- `lib/services/repositories/media_repository_impl.dart` 第34-115行
- `lib/services/repositories/media_repository.dart` 第29-126行

**问题：** `MediaRepositoryImpl` 只是 `EmbyApiService` 的简单透传，没有任何领域逻辑封装（缓存、数据转换、异常包装等）。

**当前代码：**
```dart
// lib/services/repositories/media_repository_impl.dart
@override
Future<QueryResult<BaseItemDto>> getItems({...}) async {
  return _apiService.getItems(...);  // 纯透传
}

@override
Future<BaseItemDto> getItemDetail(String itemId) async {
  return _apiService.getItemDetail(itemId);  // 纯透传
}
// ... 所有方法都是直接透传
```

**解决方案：** 在 Repository 层引入异常转换和缓存逻辑。例如：

```dart
// lib/services/repositories/media_repository_impl.dart

@override
Future<QueryResult<BaseItemDto>> getItems({...}) async {
  try {
    return await _apiService.getItems(...);
  } on DioException catch (e) {
    throw _mapDioError(e);
  }
}

@override
Future<BaseItemDto> getItemDetail(String itemId) async {
  try {
    return await _apiService.getItemDetail(itemId);
  } on DioException catch (e) {
    throw _mapDioError(e);
  }
}

/// 将 DioException 转换为应用层异常
AppException _mapDioError(DioException e) {
  final status = e.response?.statusCode;
  if (status == 401) return UnauthorizedException('Authentication required');
  if (status == 404) return NotFoundException('Resource not found');
  if (status != null && status >= 500) return ServerUnavailableException('Server error');
  return NetworkException('Network request failed: ${e.message}');
}
```

**长期改进：** 引入本地缓存层（hive_ce），在 Repository 中先查缓存再请求 API。

---

### 2. 异常类定义位置不当

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第33行

📁 **相关代码文件：**
- `lib/core/api/auth_interceptor.dart` 第196-240行

**问题：** `AppException` / `UnauthorizedException` / `ServerUnavailableException` / `TimeoutException` / `NetworkException` 定义在 `auth_interceptor.dart` 中。异常类属于应用核心概念，不应与具体拦截器耦合。

**当前代码：**
```dart
// lib/core/api/auth_interceptor.dart:196-240
sealed class AppException implements Exception { ... }
class UnauthorizedException extends AppException { ... }
class ServerUnavailableException extends AppException { ... }
class TimeoutException extends AppException { ... }
class NetworkException extends AppException { ... }
```

**解决方案：** 新建 `lib/core/exceptions/app_exception.dart`，将异常类迁移过去：

```dart
// lib/core/exceptions/app_exception.dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => 'AppException: $message';
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class ServerUnavailableException extends AppException {
  const ServerUnavailableException(super.message);
}

class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
```

然后修改所有引用这些异常的文件：
- `lib/core/api/auth_interceptor.dart`：删除异常类定义，改为 `import '../exceptions/app_exception.dart';`
- `lib/core/api/dio_client.dart`：如有引用也需更新
- `lib/services/repositories/auth_repository_impl.dart`：如有引用也需更新

---

## 二、代码质量问题

---

### 3. DetailPage 骨架屏存在 const 重复修饰

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第103行

📁 **相关代码文件：**
- `lib/features/detail/detail_page.dart` 第337行
- `lib/features/detail/detail_page.dart` 第341-347行
- `lib/features/detail/detail_page.dart` 第356-366行

**问题：** `const Skeletonizer` 内部又使用了 `const` 修饰子元素，导致编译器冗余警告。

**当前代码：**
```dart
// detail_page.dart:337
child:const Skeletonizer(  // 外层已有 const 修饰的 Padding，这里不需要 const
  child: Wrap(
    spacing: 8,
    children: const [       // const Column 内部不需要 const
      Bone.text(words: 1),
      // ...
    ],
  ),
),

// detail_page.dart:356-366
child: const Skeletonizer(
  child: Column(
    children: [
      Bone.text(words: 1),
      const SizedBox(height: 8),   // 多余 const
      const   Bone.text(words: 8), // 多余空格 + 多余 const
      const SizedBox(height: 4),   // 多余 const
      const   Bone.text(words: 6), // 多余空格 + 多余 const
    ],
  ),
),
```

**修复代码：**
```dart
// detail_page.dart:335-350
SliverToBoxAdapter(
  child: Padding(
    padding: EdgeInsets.all(layout.horizontalPadding),
    child: const Skeletonizer(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Bone.text(words: 1),
          Bone.text(words: 1),
          Bone.text(words: 1),
          Bone.text(words: 1),
          Bone.text(words: 1),
        ],
      ),
    ),
  ),
),

// detail_page.dart:353-369
SliverToBoxAdapter(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
    child: const Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bone.text(words: 1),
          SizedBox(height: 8),
          Bone.text(words: 8),
          SizedBox(height: 4),
          Bone.text(words: 6),
        ],
      ),
    ),
  ),
),
```

---

### 4. `debugPrint` 大量输出敏感信息

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第168行（安全与隐私）

📁 **相关代码文件：**
- `lib/core/api/dio_client.dart` 第139-167行（日志拦截器打印完整 headers）
- `lib/core/api/emby_api_service.dart` 第80-85行、第99-100行、第159行、第178-180行
- `lib/services/repositories/auth_repository_impl.dart` 第102-104行、第119-120行

**问题：** Debug 模式下，`X-Emby-Token`、完整 URL（含 `api_key`）、用户名密码等敏感信息被打印到日志。

**当前代码：**
```dart
// lib/core/api/dio_client.dart:139-167
onRequest: (options, handler) {
  debugPrint(
    '[EmbyApi] REQUEST ${options.method} ${options.path} '
    'headers=${options.headers} query=${options.queryParameters}',
  );
  if (options.data != null) {
    debugPrint('[EmbyApi] REQUEST BODY: ${options.data}');
  }
  handler.next(options);
},
```

**修复代码：** 创建日志脱敏工具函数：

```dart
// lib/core/api/dio_client.dart（添加到文件顶部或独立 utils 文件）

/// 对 headers 中的敏感字段进行脱敏
Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
  final result = Map<String, dynamic>.from(headers);
  const sensitiveKeys = {'X-Emby-Token', 'Authorization', 'X-MediaBrowser-Token'};
  for (final key in sensitiveKeys) {
    if (result.containsKey(key)) {
      result[key] = '***';
    }
  }
  return result;
}

/// 对 URL 中的敏感参数进行脱敏
String _sanitizeUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final query = Map<String, String>.from(uri.queryParameters);
    const sensitiveParams = {'api_key', 'X-Emby-Token', 'Pw'};
    for (final key in sensitiveParams) {
      if (query.containsKey(key)) {
        query[key] = '***';
      }
    }
    return uri.replace(queryParameters: query).toString();
  } catch (_) {
    return url;
  }
}
```

然后在日志拦截器中使用：

```dart
onRequest: (options, handler) {
  debugPrint(
    '[EmbyApi] REQUEST ${options.method} ${_sanitizeUrl(options.path)} '
    'headers=${_sanitizeHeaders(options.headers)} '
    'query=${options.queryParameters}',
  );
  if (options.data != null) {
    final body = options.data.toString();
    // 对 form-urlencoded body 中的密码脱敏
    final sanitizedBody = body.replaceAll(
      RegExp(r'Pw=([^&]*)'),
      'Pw=***',
    );
    debugPrint('[EmbyApi] REQUEST BODY: $sanitizedBody');
  }
  handler.next(options);
},

onResponse: (response, handler) {
  debugPrint(
    '[EmbyApi] RESPONSE ${response.statusCode} ${response.requestOptions.path}',
  );
  // 不再打印完整 response body，避免 body 中含 token
  handler.next(response);
},
```

同时清理 `emby_api_service.dart` 和 `auth_repository_impl.dart` 中的敏感日志：

```dart
// emby_api_service.dart: 删除或修改第80-85行、99-100行、159行、178-180行的 debugPrint
// auth_repository_impl.dart: 删除或修改第102-104行、119-120行的 debugPrint
```

---

## 三、国际化 (i18n) 细节问题

---

### 5. Semantics 标签中英文混合

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第80行

📁 **相关代码文件：**
- `lib/features/settings/settings_page.dart` 第29行：`label: '设置页面标题'`
- `lib/features/home/home_page.dart` 第124行：`title: 'Continue Watching'`
- `lib/features/home/home_page.dart` 第146行：`title: 'Recently Added'`
- `lib/features/detail/detail_page.dart` 第143行：`SectionHeader(title: 'Cast')`
- `lib/features/detail/detail_page.dart` 第183行：`SectionHeader(title: 'More Like This')`
- `lib/app_shell.dart` 多处：`'首页'` / `'媒体库'` / `'设置'`

**问题：** UI 字符串中英文混杂，且 `Semantics` 标签也未统一。

**解决方案：** 由于项目已配置 `flutter_localizations` 但未使用 ARB，建议统一使用硬编码英文字符串（作为过渡方案），或立即引入 ARB。

**过渡方案（统一为英文）：**
```dart
// settings_page.dart:29
label: 'Settings page title',  // 原为 '设置页面标题'

// home_page.dart:124
title: 'Continue Watching',  // 已是英文，保持

// home_page.dart:146
title: 'Recently Added',  // 已是英文，保持

// detail_page.dart:143
SectionHeader(title: 'Cast'),  // 已是英文，保持

// detail_page.dart:183
SectionHeader(title: 'More Like This'),  // 已是英文，保持

// app_shell.dart（见问题 6）
```

**长期方案：** 引入 ARB 文件，见 `PROJECT_RECOMMENDATIONS.md` P1 #6。

---

### ✅ 6. AppShell 导航项文本写死中文（已解决）

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第81行

📁 **相关代码文件：**
- `lib/app_shell.dart` 第62-76行（NavigationBar）
- `lib/app_shell.dart` 第95-106行（NavigationRail）
- `lib/app_shell.dart` 第147-155行（NavigationDrawer）

**当前代码：**
```dart
// app_shell.dart:62-76
destinations: const [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: '首页',       // <-- 硬编码中文
    tooltip: '首页',
  ),
  NavigationDestination(
    icon: Icon(Icons.video_library_outlined),
    selectedIcon: Icon(Icons.video_library),
    label: '媒体库',     // <-- 硬编码中文
    tooltip: '媒体库',
  ),
  NavigationDestination(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    label: '设置',       // <-- 硬编码中文
    tooltip: '设置',
  ),
],
```

**修复代码（统一为英文）：**
```dart
destinations: const [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home),
    label: 'Home',
    tooltip: 'Home',
  ),
  NavigationDestination(
    icon: Icon(Icons.video_library_outlined),
    selectedIcon: Icon(Icons.video_library),
    label: 'Library',
    tooltip: 'Library',
  ),
  NavigationDestination(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    label: 'Settings',
    tooltip: 'Settings',
  ),
],
```

**实际执行方案：** 将 `NavigationBar`、`NavigationRail`、`NavigationDrawer` 三类导航组件中的 `label` 和 `tooltip` 统一由中文（'首页'/'媒体库'/'设置'）替换为英文（'Home'/'Library'/'Settings'），与项目中其他英文 UI 文本保持一致。

---

## 四、性能问题

---

### ✅ 7. 图片请求未限制尺寸（已解决）

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第155-156行

📁 **相关代码文件：**
- `lib/features/home/hero_carousel.dart` 第146行（`EmbyImageUrl.buildImageUrl` 未传尺寸）
- `lib/features/shared/media_card.dart` 第31行（`EmbyImageUrl.buildImageUrl` 未传尺寸）

**已传参的调用点（正确）：**
- `lib/features/detail/detail_page.dart` 第214-221行：`getImageUrl(..., maxHeight: 400)` ✅
- `lib/features/detail/detail_hero_section.dart` 第79-85行：`getImageUrl(..., maxHeight: 400)` ✅
- `lib/features/detail/detail_hero_section.dart` 第92-99行：`getImageUrl(..., maxHeight: 400)` ✅
- `lib/features/detail/season_episode_list.dart` 第272-278行：`getImageUrl(..., maxWidth: 160)` ✅

**实际执行方案（已完成）：**

项目已统一使用 `EmbyCachedImage` 封装组件加载所有 Emby 图片，该组件内部自动计算 `_effectiveMaxWidth` / `_effectiveMaxHeight`（传入 `width/height * 2`，Retina 2x 尺寸），无需各处手动传参。以下关键位置已添加尺寸限制：

| 位置 | 限制方式 | 说明 |
|------|----------|------|
| `hero_carousel.dart` | `maxWidth: screenWidth.ceil()` | Backdrop 宽度限制为屏幕宽 |
| `detail_page_background.dart` | `maxWidth: 1280, maxHeight: 720` | 全屏毛玻璃背景限制为 1280×720 |
| `media_card.dart` | `width: cardWidth, height: cardWidth / 0.67` | 海报图由 `EmbyCachedImage` 自动计算 2x 尺寸 |
| `season_episode_list.dart` | `width: 120, height: 68` | 剧集缩略图由 `EmbyCachedImage` 自动计算 2x 尺寸 |

同时，`EmbyImageUrl.buildImageUrl` 路径前缀已修正（删除多余的 `/emby/` 前缀），与 `BaseItemDto.getImageUrl` 保持一致。`season_episode_list.dart` 中的死代码（未使用的 `thumbnailUrl` 变量及其依赖的 `serverUrl`）已清理。

---

## 五、UI/UX 问题

---

### 8. 图片错误占位图过于简单

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第129行

📁 **相关代码文件：**
- `lib/features/detail/detail_page.dart` 第259-261行
- `lib/features/detail/detail_hero_section.dart` 第195-197行

**当前代码：**
```dart
// detail_page.dart:259-261
Image.network(
  backdropUrl,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) => Container(
    color: colorScheme.surfaceContainerHighest,  // 纯色背景，无图标
  ),
)
```

**修复代码：**
```dart
// detail_page.dart:255-270（替换 Image.network 为 CachedNetworkImage 时同步修复）
CachedNetworkImage(
  imageUrl: backdropUrl,
  fit: BoxFit.cover,
  httpHeaders: {'X-Emby-Token': token ?? ''},
  placeholder: (context, url) => Container(
    color: colorScheme.surfaceContainerHighest,
  ),
  errorWidget: (context, url, error) => Container(
    color: colorScheme.surfaceContainerHighest,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant, size: 48),
          const SizedBox(height: 8),
          Text('Image unavailable', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    ),
  ),
)
```

---

### 9. 详情页更多选项菜单为空

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第125行

📁 **相关代码文件：**
- `lib/features/detail/detail_page.dart` 第239-248行

**当前代码：**
```dart
// detail_page.dart:239-248
IconButton(
  icon: const Icon(Icons.more_vert),
  onPressed: () {
    // TODO: Show options menu (mark as favorite, etc.)
  },
)
```

**修复代码：** 实现收藏和已观看标记菜单：

```dart
IconButton(
  icon: const Icon(Icons.more_vert),
  onPressed: () => _showOptionsMenu(context, ref, item),
)
```

```dart
void _showOptionsMenu(BuildContext context, WidgetRef ref, BaseItemDto item) {
  final colorScheme = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              item.userData?.isFavorite == true
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: colorScheme.primary,
            ),
            title: Text(item.userData?.isFavorite == true
                ? 'Remove from favorites'
                : 'Add to favorites'),
            onTap: () {
              ref.read(detailViewModelProvider(itemId).notifier)
                  .toggleFavorite();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              item.userData?.played == true
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              color: colorScheme.primary,
            ),
            title: Text(item.userData?.played == true
                ? 'Mark as unwatched'
                : 'Mark as watched'),
            onTap: () {
              ref.read(detailViewModelProvider(itemId).notifier)
                  .togglePlayed();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
```

同时需要在 `DetailViewModel` 中实现 `toggleFavorite()` 和 `togglePlayed()` 方法，调用 Emby API：
- `/Users/{userId}/FavoriteItems/{itemId}` (POST/DELETE)
- `/Users/{userId}/PlayedItems/{itemId}` (POST/DELETE)

---

## 六、依赖/工具问题

---

### ~~10. `palette_generator_master` 包来源存疑~~ ⚠️ 已更正

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第64行

**原 v1 评价：** 认为 `palette_generator_master` 是来源不明的 fork。

**实际情况：** Flutter 官方已于 **2025 年 2 月** 停止维护 `palette_generator`（[flutter/flutter#162960](https://github.com/flutter/flutter/issues/162960)）。`palette_generator_master` 是官方弃用后社区维护的 fork，**项目使用此 fork 是合理选择，不应视为问题**。

📁 **相关代码文件：**
- `pubspec.yaml`
- `lib/features/detail/detail_hero_section.dart` 第6行、第58行

---

### 11. 未引入 `device_info_plus`

**v1 位置：** `PROJECT_RECOMMENDATIONS.md` P3 #16

📁 **相关代码文件：**
- `lib/core/api/dio_client.dart` 第43-44行：使用 `Platform.operatingSystem` 作为设备名
- `lib/services/repositories/auth_repository_impl.dart` 第83-86行：使用 `Flutter Device` 作为默认设备名

**当前代码：**
```dart
// dio_client.dart:43-44
final deviceName = prefs.getString('device_name') ??
    (kIsWeb ? 'Web Device' : Platform.operatingSystem);

// auth_repository_impl.dart:83-86
final effectiveDeviceName =
    (deviceName != null && deviceName.isNotEmpty) ? deviceName : 'Flutter Device';
```

**解决方案：** 引入 `device_info_plus` 获取更准确的设备信息。

```yaml
# pubspec.yaml
dependencies:
  device_info_plus: ^11.0.0
```

```dart
// lib/core/utils/device_info_helper.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoHelper {
  static Future<String> getDeviceName() async {
    if (kIsWeb) return 'Web Device';
    
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model ?? 'Android Device';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name ?? 'iOS Device';
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.prettyName ?? 'Linux Device';
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      return macInfo.computerName ?? 'macOS Device';
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.computerName ?? 'Windows Device';
    }
    return 'Unknown Device';
  }
}
```

然后修改 `deviceInfoProvider`：

```dart
// dio_client.dart
final deviceInfoProvider = Provider<EmbyDeviceInfo>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final cachedName = prefs.getString('device_name');
  final deviceId = prefs.getString('device_id') ?? 'flutter-emby-device';

  return EmbyDeviceInfo(
    deviceName: cachedName ?? Platform.operatingSystem,  // 长期应替换为 DeviceInfoHelper
    deviceId: deviceId,
  );
});
```

> 注意：`deviceInfoProvider` 是同步 Provider，而 `device_info_plus` 需要异步获取。建议改为 `FutureProvider` 或在 `main()` 中预加载设备信息。

---

## 七、功能缺失（v1 提到但 v2 未提及）

---

### 12. 收藏/已观看标记

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第125行

📁 **相关代码文件：**
- `lib/features/detail/detail_page.dart` 第239-248行（more_vert 按钮为空）
- `lib/features/detail/detail_viewmodel.dart`（需要新增 toggleFavorite/togglePlayed 方法）

**说明：** 详情页 `more_vert` 菜单为空，没有实现收藏/已观看标记。API 层已支持（`UserItemDataDto` 中有 `isFavorite` / `played` 字段），但 UI 和 ViewModel 层未实现。

**实现方向：**
- 在 `DetailViewModel` 中添加 `toggleFavorite()` 和 `togglePlayed()` 方法
- 调用 Emby API：`POST/DELETE /Users/{userId}/FavoriteItems/{itemId}` 和 `/Users/{userId}/PlayedItems/{itemId}`
- 在 `detail_page.dart` 的 `more_vert` 菜单中触发

---

### 13. 多用户切换

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第126行

📁 **相关代码文件：**
- `lib/features/auth/login_page.dart`
- `lib/services/repositories/auth_repository_impl.dart`

**说明：** Emby 支持多用户，但当前只有单用户流程。需要扩展认证仓库以支持保存多个用户配置。

---

### 14. Live TV 支持

**v1 位置：** `PROJECT_REVIEW_SUMMARY.md` 第127行

📁 **相关代码文件：** 暂无（功能完全缺失）

**说明：** Emby API 支持 `/LiveTv/Channels` 获取频道列表，但项目中没有任何 Live TV 相关的代码。

---

## 📊 遗漏问题汇总表

| 类别 | 问题数 | 具体问题 |
|------|--------|----------|
| 架构/结构 | 2 | API Service ↔ Repository 边界模糊、异常类位置不当 |
| 代码质量 | 2 | const 重复修饰、debugPrint 泄露敏感信息 |
| 国际化 | 1 | Semantics 中英文混合 |
| 性能 | 1 | 图片请求未限制尺寸 |
| UI/UX | 2 | 错误占位图过于简单、更多选项菜单为空 |
| 依赖/工具 | 1 | 未引入 device_info_plus |
| 功能缺失 | 3 | 收藏/已观看、多用户、Live TV |

**合计：13 个问题**

> 注：`palette_generator_master` 已排除。Flutter 官方于 2025 年 2 月停止维护原版 `palette_generator`，该社区 fork 的使用是合理选择。

---

## 📊 修复进度跟踪

以下问题已在 `PROJECT_CODE_FIXES.md` 的对应修复中完成，本文档不再重复追踪：

| 本文档 Issue | 对应 CODE_FIXES | 状态 | 实际执行方案摘要 |
|---|---|---|---|
| — | P0-1 设备ID硬编码 | ✅ | `_buildEmbyAuthorizationHeader` 使用传入参数 + 默认值 |
| — | P0-2 AuthRepositoryImpl bypasses Dio | ✅ | `authenticate()` 改用 `Dio.post()`，支持注入 `authDio` 测试 |
| — | P0-6 音轨/字幕切换未实现 | ✅ | 通过 `_reportStreamSelection()` + `_loadExternalSubtitle()` + `SubtitleTrack.no()` 实现 |
| — | P0-7 播放器 unsafe dispose | ✅ | `await player.pause()` + 100ms 延迟后再 `dispose()` |
| — | P1-1 首页状态粒度拆分 | ✅ | 拆分为 `carouselItemsProvider` / `continueWatchingProvider` / `recentlyAddedProvider`，共享内部 `_homeViewsProvider` / `_latestItemsProvider` 保证 API 调用次数不变 |
| — | P1-2 refresh 模式更新 | ✅ | `refresh()` 改为 `ref.invalidateSelf()`，新代码使用 `ref.invalidate(...)` |
| — | P1-4 SettingsPage 双重导航壳层 | ✅ | 移除内部 `ResponsiveNav`，直接返回 `Scaffold` |
| 6 | AppShell 导航项硬编码中文 | ✅ | 统一替换为英文 'Home'/'Library'/'Settings' |
| 7 | 图片请求未限制尺寸 | ✅ | 统一使用 `EmbyCachedImage` 封装组件，内部自动计算 2x Retina 尺寸；关键位置已手动限制（Hero Carousel `maxWidth: screenWidth`、DetailPageBackground `maxWidth: 1280`） |
| — | P1-7 AuthInterceptor 401 未清除凭据 | ✅ | `_clearCredentials()` 调用 `authRepo.logout()`；新增自动刷新机制 |
| — | P2-6 零测试覆盖 | ✅ | 创建 `auth_repository_impl_test.dart`，9 个测试全部通过（含真实服务器集成测试） |

**本文档中尚未解决的问题（11 个）**：1, 2, 3, 4, 5, 8, 9, 11, 12, 13, 14
