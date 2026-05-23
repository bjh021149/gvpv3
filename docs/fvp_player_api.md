# FVP Player API 参考文档

> 基于 fvp `0.36.2` 源码 `lib/src/player.dart` 及 `lib/src/global.dart` 整理。
>
> 以下所有 API 均通过 `package:fvp/mdk.dart` 导出。

---

## 目录

1. [构造与生命周期](#构造与生命周期)
2. [媒体属性](#媒体属性)
3. [播放控制](#播放控制)
4. [轨道管理](#轨道管理)
5. [音量与音频后端](#音量与音频后端)
6. [缓冲与网络](#缓冲与网络)
7. [录制](#录制)
8. [纹理与视频渲染](#纹理与视频渲染)
9. [属性读写 (Property)](#属性读写-property)
10. [回调与事件流](#回调与事件流)
11. [相关枚举与常量](#相关枚举与常量)

---

## 构造与生命周期

### `Player()`

创建播放器实例。内部自动注册原生端口和事件回调。

```dart
final player = Player();
```

### `dispose()`

释放播放器资源。必须调用，否则会造成内存泄漏。

```dart
void dispose() async
```

> ⚠️ **注意**：`dispose()` 内部会先调用 `updateTexture(width: -1)` 释放纹理，再停止播放并删除原生对象。

---

## 媒体属性

### `media`

设置/获取当前媒体。支持 URL、本地文件路径、`assets://path` 等。

```dart
set media(String value)
String get media
```

```dart
player.media = 'https://example.com/video.mp4';
print(player.media);
```

### `mediaInfo`

获取当前媒体的详细信息。每次访问都会从原生层重新读取最新数据。

```dart
MediaInfo get mediaInfo
```

```dart
final info = player.mediaInfo;
print('视频轨道: ${info.video?.length}');
print('音频轨道: ${info.audio?.length}');
```

> 详见 [FVP MediaInfo 类型文档](./fvp_mediainfo_types.md)

### `isLive`

是否为直播流。

```dart
bool get isLive
```

---

## 播放控制

### `state`

设置/获取播放状态。

```dart
set state(PlaybackState value)
PlaybackState get state
```

| 状态 | 说明 |
|------|------|
| `PlaybackState.stopped` | 停止 |
| `PlaybackState.paused` | 暂停 |
| `PlaybackState.playing` | 播放中 |
| `PlaybackState.notRunning` | 未运行 |

```dart
player.state = PlaybackState.playing;  // 播放
player.state = PlaybackState.paused;   // 暂停
player.state = PlaybackState.stopped;  // 停止
```

### `prepare()`

加载媒体并从指定位置解码第一帧。成功后状态变为 `paused`。

```dart
Future<int> prepare({
  int position = 0,
  SeekFlag flags = const SeekFlag(SeekFlag.defaultFlags),
  Future<bool> Function()? callback,
  bool reply = false,
})
```

| 参数 | 说明 |
|------|------|
| `position` | 起始位置（毫秒） |
| `flags` | 定位标志 |
| `callback` | 准备完成后的回调。返回 `false` 可拒绝播放 |
| `reply` | 是否等待 dart 回调结果 |

**返回值**：
- `0`: 成功（或媒体无效时 `streams == 0`）
- `-1`: 已在加载或已加载
- `-4`: 请求位置超出范围
- `-10`: 内部错误

```dart
final pos = await player.prepare(position: 0);
```

### `seek()`

跳转到指定位置。

```dart
Future<int> seek({
  required int position,
  SeekFlag flags = const SeekFlag(SeekFlag.defaultFlags),
})
```

```dart
await player.seek(position: 60000); // 跳到 1 分钟处
```

### `waitFor()`

阻塞等待直到播放器进入指定状态。

```dart
bool waitFor(PlaybackState state, {int timeout = -1})
```

| 参数 | 说明 |
|------|------|
| `timeout` | 超时时间（毫秒），`-1` 表示无限等待 |

```dart
player.waitFor(PlaybackState.paused, timeout: 5000);
```

### `playbackRate`

播放速度。`1.0` 为原速。

```dart
set playbackRate(double value)
double get playbackRate
```

```dart
player.playbackRate = 1.5; // 1.5 倍速
```

### `loop`

循环次数。`-1` 为无限循环，`0` 为不循环。

```dart
set loop(int value)
int get loop
```

```dart
player.loop = -1; // 无限循环
```

### `preloadImmediately`

是否在当前媒体播放结束后立即预加载下一媒体（通过 `setNext()` 设置）。

```dart
set preloadImmediately(bool value)
bool get preloadImmediately
```

### `position`

当前播放位置（毫秒）。

```dart
int get position
```

```dart
final pos = player.position; // ms
final duration = Duration(milliseconds: pos);
```

---

## 轨道管理

### `activeVideoTracks` / `activeAudioTracks` / `activeSubtitleTracks`

设置/获取当前激活的轨道索引列表。传入空列表可禁用该类型所有轨道。

```dart
set activeVideoTracks(List<int> value)
List<int> get activeVideoTracks

set activeAudioTracks(List<int> value)
List<int> get activeAudioTracks

set activeSubtitleTracks(List<int> value)
List<int> get activeSubtitleTracks
```

```dart
// 切换到第 1 条音频轨道
player.activeAudioTracks = [1];

// 禁用字幕
player.activeSubtitleTracks = [];

// 切换到第 0 条视频轨道
player.activeVideoTracks = [0];
```

### `setActiveTracks()`

底层方法，按类型设置激活轨道。

```dart
void setActiveTracks(MediaType type, List<int> value)
```

### `setMedia()`

加载外部轨道（如外挂音轨或字幕）。

```dart
void setMedia(String uri, MediaType type)
```

```dart
// 加载外挂字幕
player.setMedia('/path/to/subtitle.ass', MediaType.subtitle);

// 加载外挂音轨
player.setMedia('/path/to/audio.m4a', MediaType.audio);
```

### `setAsset()`

加载 Flutter asset 作为媒体或外部轨道。

```dart
void setAsset(String asset, {String? package, MediaType? type})
```

```dart
player.setAsset('assets/videos/demo.mp4');
player.setAsset('assets/subtitles/zh.srt', type: MediaType.subtitle);
```

### `setNext()`

设置下一媒体，当前播放结束后自动切换。

```dart
void setNext(
  String uri, {
  int from = 0,
  SeekFlag seekFlag = const SeekFlag(SeekFlag.defaultFlags),
})
```

```dart
player.setNext('https://example.com/next.mp4');
```

### `videoDecoders` / `audioDecoders`

设置/获取解码器优先级列表。

```dart
set videoDecoders(List<String> value)
List<String> get videoDecoders

set audioDecoders(List<String> value)
List<String> get audioDecoders
```

```dart
player.videoDecoders = ['MFT:d3d=11', 'D3D11', 'FFmpeg'];
player.audioDecoders = ['auto'];
```

### `setDecoders()`

底层方法，按类型设置解码器列表。

```dart
void setDecoders(MediaType type, List<String> value)
```

---

## 音量与音频后端

### `volume`

音量。`1.0` 为原始音量。

```dart
set volume(double value)
double get volume
```

```dart
player.volume = 0.5;
```

### `mute`

是否静音。

```dart
set mute(bool value)
bool get mute
```

```dart
player.mute = true;
```

### `audioBackends`

设置音频渲染后端。例如 Android 上可用 `'AudioTrack'`、`'OpenSL'`。

```dart
set audioBackends(List<String> value)
```

```dart
player.audioBackends = ['AudioTrack'];
```

---

## 缓冲与网络

### `buffered()`

返回已缓冲的时长（毫秒）。

```dart
int buffered()
```

```dart
final bufferedMs = player.buffered();
```

### `bufferedTimeRanges()`

返回已缓冲的时间区间列表。

```dart
List<DurationRange> bufferedTimeRanges()
```

```dart
final ranges = player.bufferedTimeRanges();
for (final r in ranges) {
  print('已缓冲: ${r.start} ~ ${r.end}');
}
```

> `DurationRange` 来自 `package:video_player_platform_interface`，包含 `start` 和 `end` 两个 `Duration` 字段。

### `setBufferRange()`

设置缓冲策略。

```dart
void setBufferRange({int min = -1, int max = -1, bool drop = false})
```

| 参数 | 说明 |
|------|------|
| `min` | 最小缓冲时长（毫秒）。默认 `1000`。`< 0` 重置为默认值 |
| `max` | 最大缓冲时长（毫秒）。默认 `4000`。`0` 表示无上限 |
| `drop` | `true` 时丢弃旧非关键帧以降低缓冲时长；`false` 时等待缓冲低于上限再继续 |

```dart
player.setBufferRange(min: 2000, max: 8000, drop: true);
```

---

## 录制

### `record()`

开始/停止录制。

```dart
void record({String? to, String? format})
```

| 参数 | 说明 |
|------|------|
| `to` | 输出文件路径。`null` 表示停止录制 |
| `format` | 输出格式。`null` 由引擎自动推断 |

```dart
player.record(to: '/path/to/output.mp4');
// ... 播放中 ...
player.record(); // 停止录制
```

---

## 纹理与视频渲染

### `textureId`

当前视频纹理 ID 的 `ValueNotifier<int?>`。可用于 `Texture` widget。

```dart
final ValueNotifier<int?> textureId
```

```dart
ValueListenableBuilder<int?>(
  valueListenable: player.textureId,
  builder: (context, id, _) {
    if (id == null) return const SizedBox();
    return Texture(textureId: id);
  },
)
```

### `updateTexture()`

释放当前纹理并创建新纹理。通常在媒体切换后调用。

```dart
Future<int> updateTexture({
  int? width,
  int? height,
  bool? tunnel,
  bool? fit,
})
```

| 参数 | 说明 |
|------|------|
| `width`/`height` | 请求纹理尺寸。均为 `null` 时使用原始视频尺寸；任一 `<= 0` 释放纹理 |
| `tunnel` | Android 专用，是否使用视频隧道模式 |
| `fit` | 是否按比例适配到请求尺寸 |

**返回值**：纹理 ID，失败返回 `-1`。

```dart
final tid = await player.updateTexture();
```

### `textureSize`

获取当前纹理尺寸。

```dart
Future<ui.Size?> get textureSize
```

### `snapshot()`

截取当前渲染帧的 RGBA 数据。

```dart
Future<Uint8List?> snapshot({int? width, int? height})
```

| 参数 | 说明 |
|------|------|
| `width`/`height` | 截图尺寸。未设置时使用当前视频轨道编码尺寸 |

**返回值**：RGBA 字节数组，stride 为 `width * 4`。失败返回 `null`。

```dart
final data = await player.snapshot();
if (data != null) {
  // 可转为 ui.Image 或保存为文件
}
```

### `setAspectRatio()`

设置视频内容显示比例。

```dart
void setAspectRatio(double value)
```

| 常量值 | 说明 |
|--------|------|
| `ignoreAspectRatio` (`0.0`) | 拉伸填满视口 |
| `keepAspectRatio` (`1.192...e-7`) | 保持比例，尽可能大且完整显示 |
| `keepAspectRatioCrop` (`-1.192...e-7`) | 保持比例，尽可能小且覆盖视口 |
| 其他值 | 自定义宽高比 = `width / height` |

```dart
player.setAspectRatio(keepAspectRatio);
```

### `rotate()`

旋转视频内容。

```dart
void rotate(int degree)
```

`degree` 取值：`0`, `90`, `180`, `270`（逆时针）。

```dart
player.rotate(90);
```

### `scale()`

缩放视频内容。

```dart
void scale(double x, double y)
```

```dart
player.scale(1.2, 1.2); // 放大 1.2 倍
```

### `setBackgroundColor()`

设置视频渲染背景色。

```dart
void setBackgroundColor(double r, double g, double b, double a)
```

### `setVideoEffect()`

设置内置视频效果。

```dart
void setVideoEffect(VideoEffect effect, List<double> value)
```

| 效果 | 参数 |
|------|------|
| `VideoEffect.brightness` | `[亮度值]` |
| `VideoEffect.contrast` | `[对比度值]` |
| `VideoEffect.hue` | `[色相值]` |
| `VideoEffect.saturation` | `[饱和度值]` |

```dart
player.setVideoEffect(VideoEffect.brightness, [0.1]);
```

### `setColorSpace()`

设置目标色彩空间。Flutter 目前仅支持 SDR 输出，通常不需要调用。

```dart
void setColorSpace(ColorSpace value)
```

### `setVideoSurfaceSize()` / `setVideoViewport()`

设置视频渲染表面尺寸和视口。Dart 层通常不需要直接调用。

```dart
void setVideoSurfaceSize(int width, int height)
void setVideoViewport(double x, double y, double width, double height)
```

### `renderVideo()`

手动绘制当前视频帧并返回帧时间戳（秒）。Dart 层通常不需要调用。

```dart
double renderVideo()
```

---

## 属性读写 (Property)

### `setProperty()` / `getProperty()`

读写播放器底层属性。属性名和值参考 [MDK Global Options](https://github.com/wang-bin/mdk-sdk/wiki/Global-Options)。

```dart
void setProperty(String name, String value)
String? getProperty(String name)
```

```dart
player.setProperty('video.decoder', 'MFT');
final decoder = player.getProperty('video.decoder');
```

### `setRange()`

设置播放区间（毫秒）。可用于 A-B 循环。

```dart
void setRange({required int from, int to = -1})
```

```dart
player.setRange(from: 0, to: 60000); // 只播放前 1 分钟
```

---

## 回调与事件流

### `onEvent`

媒体事件流。包含错误、解码器等事件。

```dart
Stream<MediaEvent> get onEvent
```

```dart
player.onEvent.listen((event) {
  print('Event: [${event.category}] ${event.detail} (error: ${event.error})');
});
```

`MediaEvent` 字段：
- `error`: 错误码。如果 `category` 是 `"reader.buffering"`，则为进度值 `[0, 100]`
- `category`: 事件类别，例如 `"decoder.video"`、`"reader.buffering"`
- `detail`: 事件详情

### `onStateChanged`

播放状态变化流。

```dart
Stream<({PlaybackState oldValue, PlaybackState newValue})> get onStateChanged
```

```dart
player.onStateChanged.listen((event) {
  print('State: ${event.oldValue} -> ${event.newValue}');
});
```

### `onMediaStatus`

媒体状态变化流。

```dart
Stream<({MediaStatus oldValue, MediaStatus newValue})> get onMediaStatus
```

```dart
player.onMediaStatus.listen((event) {
  if (event.newValue.test(MediaStatus.loaded)) {
    print('媒体加载完成');
  }
});
```

### `onSubtitleText`

字幕文本回调。

```dart
void onSubtitleText(
  void Function(double start, double end, List<String> text)? callback,
)
```

| 参数 | 说明 |
|------|------|
| `start`/`end` | 字幕显示时间范围（秒） |
| `text` | 字幕文本行列表 |

```dart
player.onSubtitleText((start, end, texts) {
  print('字幕 [${start.toStringAsFixed(1)}s ~ ${end.toStringAsFixed(1)}s]: ${texts.join("\\n")}');
});
```

---

## 相关枚举与常量

### PlaybackState

```dart
enum PlaybackState {
  notRunning,
  stopped,
  running,
  playing,
  paused,
}
```

### MediaStatus（状态标志位）

```dart
class MediaStatus {
  static const noMedia;
  static const unloaded;
  static const loading;
  static const loaded;
  static const prepared;
  static const stalled;
  static const buffering;
  static const buffered;
  static const end;
  static const seeking;
  static const invalid;
}
```

使用 `test()` 检查状态：

```dart
if (status.test(MediaStatus.buffering)) {
  print('正在缓冲...');
}
```

### MediaType

```dart
enum MediaType {
  unknown,
  video,
  audio,
  subtitle,
}
```

### SeekFlag

```dart
class SeekFlag {
  static const from0;      // 从时间 0 开始
  static const fromStart;  // 从媒体起始（默认包含）
  static const fromNow;    // 从当前位置相对跳转
  static const frame;      // 精确到帧
  static const keyFrame;   // 跳到最近关键帧
  static const fast;       // 快速定位
  static const inCache;    // 优先在缓存内定位（默认包含）
  static const defaultFlags = keyFrame | fromStart | inCache;
}
```

### ColorSpace

```dart
enum ColorSpace {
  unknown,
  bt709,
  bt2100PQ,
  scrgb,
  bt2100hlg,
}
```

### VideoEffect

```dart
enum VideoEffect {
  brightness,
  contrast,
  hue,
  saturation,
}
```

### 常用常量

```dart
const double timestampEOS = 1.7976931348623157e+308; // EOS 帧时间戳
const double timeScaleForInt = 1000.0;                 // 整数时间戳单位换算
const double ignoreAspectRatio = 0.0;                  // 忽略宽高比
const double keepAspectRatio = 1.1920928955078125e-7;  // 保持比例（完整显示）
const double keepAspectRatioCrop = -1.1920928955078125e-7; // 保持比例（裁剪填充）
```

### 全局函数

```dart
/// 获取 libmdk 版本号
int version()

/// 设置全局选项
void setGlobalOption<T>(String name, T value)

/// 设置日志回调
void setLogHandler(void Function(LogLevel, String)? cb)
```

---

## 完整使用示例

```dart
import 'package:fvp/mdk.dart';

class PlayerService {
  final Player _player = Player();

  Future<void> open(String url) async {
    _player.media = url;
    _player.onStateChanged.listen((event) {
      print('状态变化: ${event.oldValue} -> ${event.newValue}');
    });
    _player.onMediaStatus.listen((event) {
      if (event.newValue.test(MediaStatus.loaded)) {
        final info = _player.mediaInfo;
        print('加载完成: ${info.format}, ${info.duration}ms');
      }
    });
    await _player.prepare();
    _player.state = PlaybackState.playing;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position: position.inMilliseconds);
  }

  void setAudioTrack(int index) {
    _player.activeAudioTracks = [index];
  }

  void disableSubtitle() {
    _player.activeSubtitleTracks = [];
  }

  Future<Uint8List?> takeSnapshot() => _player.snapshot();

  void dispose() {
    _player.dispose();
  }
}
```
