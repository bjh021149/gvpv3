# 播放器（PlayerPage）API 调用流程

**页面**: `PlayerPage` (`/player/:id`)
**核心文件**: `lib/features/player/player_page.dart` + `player_viewmodel.dart`
**全局单例**: `fvpPlayerProvider` → 全局唯一的 `Player()` 实例

---

## 一、进入播放器时的 API 调用

### 1.1 获取播放信息（PlaybackInfo）

```
POST /Items/{itemId}/PlaybackInfo
```

| 参数 | 值 | 说明 |
|------|-----|------|
| `itemId` | 路径参数 | 播放项 ID |
| `UserId` | query | 当前用户 ID |
| `MaxStreamingBitrate` | `140000000` | 最大码率（140Mbps） |
| `AutoOpenLiveStream` | `true` | 自动打开直播流 |

**用途**: 获取媒体源列表（MediaSources）、每个源的播放 URL（DirectStreamUrl / TranscodingUrl）、字幕/音轨列表（MediaStreams）。

**返回**: `PlaybackInfo` — 关键字段：
```json
{
  "MediaSources": [
    {
      "Id": "141313",
      "DirectStreamUrl": "http://server/...",
      "TranscodingUrl": null,
      "MediaStreams": [
        {"Type": "Video", "Index": 0, ...},
        {"Type": "Audio", "Index": 1, "Language": "chi", ...},
        {"Type": "Subtitle", "Index": 2, "Language": "chi", ...}
      ]
    }
  ]
}
```

**注意**: 不走缓存（PlaybackInfo 包含临时播放 URL）。

---

### 1.2 获取作品详情（item detail）

```
GET /Users/{uid}/Items/{itemId}
```

| 参数 | 值 | 说明 |
|------|-----|------|
| `itemId` | 路径参数 | 播放项 ID |
| `Fields` | 长字段列表 | 完整信息 |

**用途**: 获取作品名称、播放进度（`userData.playbackPositionTicks`）、封面图等。

**缓存**: 走 `_cachedItem` — 先返回缓存，后台刷新。

---

## 二、播放器生命周期与上报

### 2.1 播放器初始化流程

```
PlayerViewModel.build()
    │
    ├──→ 1. getPlaybackInfo(itemId) ──→ 获取播放 URL
    │
    ├──→ 2. getItemDetail(itemId) ──→ 获取作品信息 + 播放进度
    │
    ├──→ 3. player.prepare(url, position: resumeMs)
    │       resumeMs = item.userData?.playbackPositionTicks ~/ 10000
    │
    ├──→ 4. 选择默认音轨/字幕轨
    │
    └──→ 5. 开始播放 + 启动上报定时器
```

---

### 2.2 播放上报（Playback Reporting）

播放器启动后，三个上报定时器持续运行：

#### A. 播放开始（Start）
```
POST /Users/{uid}/PlayingItems/{itemId}?MediaSourceId={msId}&CanSeek=true
```

| 参数 | 值 | 说明 |
|------|-----|------|
| `UserId` | 路径参数 | 当前用户 ID |
| `itemId` | 路径参数 | 播放项 ID |
| `MediaSourceId` | query | 当前媒体源 ID |
| `CanSeek` | `true` | 支持 seek |
| `AudioStreamIndex` | `0/1/...` | 当前音轨索引（可选） |
| `SubtitleStreamIndex` | `0/1/...` | 当前字幕轨索引（可选） |

**触发**: 播放器进入 playing 状态时调用一次。

**注意**: 部分服务器版本返回 400 `Value cannot be null. (Parameter 'key')`，属服务器兼容性问题。

---

#### B. 播放进度（Progress）
```
POST /Users/{uid}/PlayingItems/{itemId}/Progress?MediaSourceId={msId}&PositionTicks={ticks}&IsPaused={bool}
```

| 参数 | 值 | 说明 |
|------|-----|------|
| `MediaSourceId` | query | 当前媒体源 ID |
| `PositionTicks` | `long` | 当前播放位置（ticks，1 tick = 100ns） |
| `IsPaused` | `true`/`false` | 是否暂停 |
| `IsMuted` | `true`/`false` | 是否静音（可选） |
| `VolumeLevel` | `0-100` | 音量（可选） |

**触发**: 每 3 秒调用一次（`Timer.periodic`）。

**注意**: 切换音轨/字幕时不再重新上报，只上报位置。

---

#### C. 播放停止（Stopped）
```
POST /Sessions/Playing/Stopped
Body: {
  "ItemId": "{itemId}",
  "MediaSourceId": "{msId}",
  "PositionTicks": {ticks}
}
```

| Body 字段 | 值 | 说明 |
|----------|-----|------|
| `ItemId` | 播放项 ID | — |
| `MediaSourceId` | 媒体源 ID | — |
| `PositionTicks` | 当前位置 | 用于服务器记录播放进度 |

**触发**:
- 用户点击返回按钮退出播放器
- 播放完成（position >= duration * 0.9）
- `PlayerViewModel` dispose 时

---

## 三、用户交互触发的 API 调用

### 3.1 切换音轨

```dart
void selectAudioTrack(int index) {
  player.setAudioDecoders([' FFmpeg']);  // fvp 本地切换
  // 不再调用 API 上报
}
```

**说明**: 纯本地操作，通过 fvp 的 `setAudioDecoders` / `setProperty` 切换。不触发 API 调用。

---

### 3.2 切换字幕轨

```dart
void selectSubtitleTrack(int index) {
  player.setSubtitleDecoders([' FFmpeg']);  // fvp 本地切换
  // 不再调用 API 上报
}
```

**说明**: 同上，纯本地操作。

---

### 3.3 切换全屏

```dart
void toggleFullScreen() {
  // 更新 state
  state = state.copyWith(isFullScreen: !state.isFullScreen);
  // PlayerPage 监听变化后调用 windowManager.setFullScreen()
}
```

**说明**: 不涉及 API 调用。桌面端使用 `window_manager`，移动端使用 `SystemChrome`。

---

### 3.4 拖动进度条（Seek）

```dart
player.seek(position);
```

**说明**: 纯本地操作。下一次 progress 上报会自动带上新位置。

---

### 3.5 返回按钮（PopScope）

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) {
    // 1. 上报 Stopped
    reportPlaybackStopped(positionTicks);
    // 2. 停止播放器
    _player.state = PlaybackState.stopped;
    // 3. 导航回详情页
    context.go('/detail/${seriesId ?? itemId}');
  },
)
```

**注意**: `canPop: false` 拦截系统返回键，确保先执行上报和清理再导航。

---

## 四、播放器 Dispose（Linux GL 死锁修复）

```dart
ref.onDispose(() {
  _cancelControlsTimer();
  _stopTimers();
  _detachPlayerListeners();
  
  // 修复 Linux 上 GL 资源清理死锁
  try { _player.state = PlaybackState.paused; } catch (_) {}
  scheduleMicrotask(() async {
    await Future.delayed(const Duration(milliseconds: 50));
    try { _player.state = PlaybackState.stopped; } catch (_) {}
  });
});
```

**问题**: Linux 下同步 `stopped` 会导致 fvp GL dispose 线程死锁（`try to cleanup gl resources in dispose thread`）。

**方案**: 先 `pause`，再 `scheduleMicrotask` 延迟 `stop`。

---

## 五、关键参数速查表

| API | 关键参数 | 值 | 说明 |
|-----|---------|-----|------|
| `POST /Items/{id}/PlaybackInfo` | `MaxStreamingBitrate` | `140000000` | 140Mbps |
| `POST /Items/{id}/PlaybackInfo` | `AutoOpenLiveStream` | `true` | 自动打开直播流 |
| `POST /Users/{uid}/PlayingItems/{id}` | `MediaSourceId` | `141313` | 媒体源 ID |
| `POST /Users/{uid}/PlayingItems/{id}` | `CanSeek` | `true` | 支持 seek |
| `POST /Users/{uid}/PlayingItems/{id}/Progress` | `PositionTicks` | `600000000` | 当前位置 |
| `POST /Users/{uid}/PlayingItems/{id}/Progress` | `IsPaused` | `false` | 是否暂停 |
| `POST /Sessions/Playing/Stopped` | `ItemId` | body | 播放项 ID |
| `POST /Sessions/Playing/Stopped` | `PositionTicks` | body | 停止位置 |

---

## 六、上报时序图

```
进入播放器
    │
    ├──→ reportPlaybackStart() ──→ POST /Users/{uid}/PlayingItems/{id}
    │       （播放开始时调用一次）
    │
    ├──→ [每 3 秒] reportPlaybackProgress()
    │       └──→ POST /Users/{uid}/PlayingItems/{id}/Progress?PositionTicks=...
    │
    ├──→ 用户点击返回
    │       │
    │       ├──→ reportPlaybackStopped() ──→ POST /Sessions/Playing/Stopped
    │       │       Body: {ItemId, MediaSourceId, PositionTicks}
    │       │
    │       └──→ context.go('/detail/{id}')
    │
    └──→ 播放完成（position >= duration * 0.9）
            │
            └──→ reportPlaybackStopped() ──→ 同上
```
