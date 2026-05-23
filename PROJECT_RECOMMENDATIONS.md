> 文档版本: v1.0 | 生成时间: 2026-05-15T00:57:22+08:00

# Emby Client Flutter 项目行动建议

---

## 🔴 P0 - 必须立即修复（阻断性问题）

### 1. 补充单元/Widget 测试
**问题**：`test/` 目录完全为空，零测试覆盖意味着任何重构都有引入回归的风险。

**行动**：
- 为 `AuthRepositoryImpl` 和 `MediaRepositoryImpl` 编写单元测试，使用 `ProviderContainer` + Mock Dio
- 为 `HomeViewModel` / `PlayerViewModel` / `DetailViewModel` 编写状态流转测试
- 为关键页面（`LoginPage` / `HomePage` / `PlayerPage`）编写 Widget 测试，覆盖 loading / error / empty / data 四态

**参考实现**：
```dart
// test/services/auth_repository_impl_test.dart
void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepositoryImpl repository;
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      repository = AuthRepositoryImpl();
    });

    tearDown(() => container.dispose());

    test('isAuthenticated returns false when no token stored', () async {
      final result = await repository.isAuthenticated();
      expect(result, false);
    });
  });
}
```

---

### 2. 修复 `_buildEmbyAuthorizationHeader` 硬编码设备信息
**问题**：`DeviceId` 为空字符串，`Device` 写死为 `"Linux"`，会导致 Emby 服务器端设备管理混乱，多设备登录时互相覆盖。

**行动**：
- 使用 `device_info_plus` 获取真实设备信息
- 使用 `uuid` 包生成并持久化唯一 DeviceId
- 将客户端名称提取为可配置常量

**修改建议**：
```dart
// lib/core/constants/app_info.dart
class AppInfo {
  static const String clientName = 'EmbyFlutter';
  static const String version = '1.0.0';
}

// lib/core/api/emby_api_service.dart
static String _buildEmbyAuthorizationHeader({
  required String deviceName,
  required String deviceId,
}) {
  return 'MediaBrowser '
      'Client="${AppInfo.clientName}", '
      'Device="$deviceName", '
      'DeviceId="$deviceId", '
      'Version="${AppInfo.version}"';
}
```

---

### 3. 统一认证请求使用 Dio
**问题**：`AuthRepositoryImpl.authenticate()` 直接调用 `HttpClient`，绕过了 Dio 的拦截器、日志、证书处理体系。

**行动**：
- 重构 `authenticate()` 使用 `DioClient.create()` 创建的实例
- 将认证用的特殊 header 逻辑下沉到 Dio 拦截器中处理
- 删除 `AuthRepositoryImpl._createDio()` 中的重复代码

---

## 🟡 P1 - 高优先级（核心功能完善）

### 4. 实现播放进度恢复
**问题**：播放器启动时总是从 0 开始，没有利用 Emby 返回的 `playbackPositionTicks`。

**行动**：
```dart
// lib/features/player/player_viewmodel.dart
@override
Future<PlayerState> build() async {
  // ... 获取 playbackInfo 和 item ...
  
  // 恢复上次播放进度
  final resumePosition = item.userData?.playbackPositionTicks != null
      ? Duration(microseconds: item.userData!.playbackPositionTicks! ~/ 10)
      : Duration.zero;
  
  await player.open(Media(directUrl));
  if (resumePosition > Duration.zero) {
    await player.seek(resumePosition);
  }
  
  // ...
}
```

---

### 5. 实现音轨/字幕切换（后端联动）
**问题**：当前仅更新 UI 状态，未实际通知播放器切换流。

**行动**：
- 音轨切换：重新请求 `PlaybackInfo` 并指定 `AudioStreamIndex`
- 字幕切换：加载对应字幕流 URL 并通过 media_kit 的 subtitle API 注入
- 对于外部字幕（如 SRT/ASS），使用 media_kit 的 `player.setSubtitleTrack` 或 `SubtitleView`

---

### 6. 引入 ARB 国际化
**问题**：项目中英文混合，且 `flutter_localizations` 已配置但未使用。

**行动**：
1. 在 `l10n.yaml` 中配置 ARB 目录
2. 创建 `lib/l10n/app_en.arb` 和 `lib/l10n/app_zh.arb`
3. 将所有硬编码字符串替换为 `AppLocalizations.of(context).xxx`
4. `AppShell` 中的导航标签应从 ARB 读取

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

---

### 7. 修复 SettingsPage 双重导航壳层
**问题**：`SettingsPage` 内部使用 `ResponsiveNav`，与外层 `StatefulShellRoute` 的 `AppShell` 冲突。

**行动**：
- 移除 `SettingsPage` 中的 `ResponsiveNav` 包装
- 统一使用 `AppShell` 的 `StatefulShellRoute` 管理导航状态

---

## 🟢 P2 - 中优先级（性能与体验优化）

### 8. 拆分首页状态粒度
**问题**：`HomeState` 包含三个独立列表，任一变化触发整页重建。

**行动**：
```dart
// 拆分为三个独立 Provider
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

---

### 9. 图片请求添加尺寸限制
**问题**：多处 `Image.network` 和 `BaseItemDto.getImageUrl` 未限制尺寸，下载原图浪费带宽和内存。

**行动**：
- 所有图片请求统一传入 `maxHeight` / `maxWidth`
- 海报图限制最大宽度 400px，Backdrop 限制最大高度 400px
- 缩略图使用更小尺寸（如 200px）

---

### 10. 自签名证书白名单校验
**问题**：`badCertificateCallback` 无条件返回 `true`，存在中间人攻击风险。

**行动**：
```dart
// lib/core/api/dio_client.dart
final _allowedHosts = <String>{}; // 从用户配置读取

dio.httpClientAdapter = IOHttpClientAdapter(
  createHttpClient: () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // 优先检查白名单
      if (_allowedHosts.contains(host)) return true;
      // 本地网络网段可信任
      if (host.startsWith('192.168.') || host.startsWith('10.')) return true;
      return false;
    };
    return client;
  },
);
```

---

### 11. 统一异常处理策略
**问题**：`PlayerViewModel` 中大量 `catch (_) { ignore }` 吞掉了所有错误。

**行动**：
- 区分可恢复异常和致命异常
- 可恢复异常（如播放器未就绪）记录 warning 日志
- 致命异常（如网络断开）通过 `state = AsyncError(...)` 暴露给 UI

```dart
void playPause() {
  try {
    _requirePlayer.playOrPause();
  } on StateError catch (e) {
    debugPrint('[Player] playPause ignored: $e');
  } catch (e, st) {
    _updateState((s) => s.copyWith(error: 'Playback error: $e'));
  }
}
```

---

## 🔵 P3 - 低优先级（功能扩展）

### 12. 收藏/已观看标记
- 调用 Emby `/UserFavoriteItems` 和 `/UserPlayedItems` API
- 在详情页 AppBar 添加收藏按钮和已观看复选框

### 13. 多用户切换
- 支持保存多个服务器+用户的配置
- 登录页添加用户切换下拉菜单

### 14. 离线缓存（使用 hive_ce）
- 缓存媒体元数据（BaseItemDto）
- 缓存图片缩略图
- 支持下载视频到本地（扩展 `media_kit` 播放本地文件）

### 15. 直播电视 (Live TV) 支持
- 添加 Live TV 路由和页面
- 调用 Emby `/LiveTv/Channels` API 获取频道列表
- 使用 HLS 流播放直播内容

### 16. 引入 `device_info_plus`
- 替换 `Platform.operatingSystem` 获取设备名
- 更准确地向 Emby 服务器报告设备类型

---

## 📅 建议迭代路线

| 迭代 | 目标 | 包含事项 |
|------|------|----------|
| **Sprint 1** | 基础设施加固 | P0 #1(测试) + P0 #2(设备ID) + P0 #3(Dio统一) |
| **Sprint 2** | 播放体验完善 | P1 #4(进度恢复) + P1 #5(音轨字幕) + P2 #9(图片尺寸) |
| **Sprint 3** | 产品化打磨 | P1 #6(国际化) + P1 #7(导航修复) + P2 #8(状态拆分) |
| **Sprint 4** | 安全与健壮 | P2 #10(证书白名单) + P2 #11(异常处理) + P3 #12(收藏) |
| **Sprint 5** | 功能扩展 | P3 #13(多用户) + P3 #14(离线缓存) + P3 #15(Live TV) |
