# package:fvp/mdk.dart 使用文档

> `mdk.dart` 是 **fvp** 包的核心 Dart 入口文件，直接封装了底层 libmdk 播放引擎的全部能力。
>
> 版本：`0.36.2`

---

## 1. 模块导出结构

`mdk.dart` 共导出 3 个模块，涵盖枚举/常量、媒体信息类型、播放器 API：

```dart
// fvp/lib/mdk.dart
export 'src/global.dart';      // 枚举、常量、全局函数、事件类型
export 'src/media_info.dart';  // MediaInfo 及所有流信息类型
export 'src/player.dart';      // Player 类及所有播放控制 API
```

使用时只需导入一次：

```dart
import 'package:fvp/mdk.dart';
```

---

## 2. 快速开始

### 2.1 最小播放示例

```dart
import 'package:fvp/mdk.dart';

Future<void> playVideo(String url) async {
  final player = Player();

  // 设置媒体
  player.media = url;

  // 加载并解码第一帧，成功后状态为 paused
  final pos = await player.prepare();
  if (pos < 0) {
    print('加载失败: $pos');
    return;
  }

  // 开始播放
  player.state = PlaybackState.playing;

  // 监听状态
  player.onStateChanged.listen((event) {
    print('${event.oldValue} -> ${event.newValue}');
  });
}
```

### 2.2 在 Flutter 中显示视频

```dart
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final Player _player;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _player.media = widget.url;
    _player.prepare().then((_) => _player.state = PlaybackState.playing);
  }

  @override
  void dispose() {
    _player.dispose(); // 必须释放
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: _player.textureId,
      builder: (context, textureId, _) {
        if (textureId == null || textureId < 0) {
          return const Center(child: CircularProgressIndicator());
        }
        return Texture(textureId: textureId);
      },
    );
  }
}
```

> `Texture` widget 通过 `player.textureId`（`ValueNotifier<int?>`）自动获取原生纹理 ID。

---

## 3. 核心类型速查

### 3.1 播放器主体

| 类型 | 来源文件 | 说明 |
|------|----------|------|
| `Player` | `player.dart` | 播放器实例，包含所有播放控制 API |
| `MediaEvent` | `global.dart` | 媒体事件（错误、缓冲进度等） |

### 3.2 媒体信息

| 类型 | 来源文件 | 说明 |
|------|----------|------|
| `MediaInfo` | `media_info.dart` | 媒体整体信息（时长、格式、码率、轨道列表） |
| `VideoStreamInfo` | `media_info.dart` | 视频轨道信息（分辨率、帧率、旋转角度） |
| `AudioStreamInfo` | `media_info.dart` | 音频轨道信息（声道、采样率、编码格式） |
| `SubtitleStreamInfo` | `media_info.dart` | 字幕轨道信息（编码格式、元数据） |
| `VideoCodecParameters` | `media_info.dart` | 视频编码参数（codec、宽高、profile、dovi） |
| `AudioCodecParameters` | `media_info.dart` | 音频编码参数（codec、声道、采样率、位深） |
| `SubtitleCodecParameters` | `media_info.dart` | 字幕编码参数（codec、位图尺寸） |
| `ChapterInfo` | `media_info.dart` | 章节信息（起止时间、标题） |
| `ProgramInfo` | `media_info.dart` | 节目信息（多节目流容器，如 TS） |

### 3.3 枚举与常量

| 类型/常量 | 来源文件 | 说明 |
|-----------|----------|------|
| `PlaybackState` | `global.dart` | `stopped` / `playing` / `paused` / `notRunning` |
| `MediaStatus` | `global.dart` | 状态标志位：`loaded`、`buffering`、`seeking`、`end` 等 |
| `MediaType` | `global.dart` | `video` / `audio` / `subtitle` / `unknown` |
| `SeekFlag` | `global.dart` | 定位标志：`fromStart`、`keyFrame`、`fast`、`inCache` 等 |
| `ColorSpace` | `global.dart` | `unknown`、`bt709`、`bt2100PQ`、`scrgb`、`bt2100hlg` |
| `VideoEffect` | `global.dart` | `brightness`、`contrast`、`hue`、`saturation` |
| `LogLevel` | `global.dart` | `off`、`error`、`warning`、`info`、`debug`、`all` |
| `timestampEOS` | `global.dart` | EOS 帧时间戳（`1.7976931348623157e+308`） |
| `ignoreAspectRatio` | `global.dart` | 忽略宽高比（`0.0`） |
| `keepAspectRatio` | `global.dart` | 保持比例完整显示 |
| `keepAspectRatioCrop` | `global.dart` | 保持比例裁剪填充 |

---

## 4. 常用 API 速查

### 4.1 播放控制

```dart
// 加载与播放
player.media = 'url';
await player.prepare();           // 加载媒体
player.state = PlaybackState.playing;
player.state = PlaybackState.paused;
player.state = PlaybackState.stopped;

// 进度
final pos = player.position;      // 当前位置（ms）
await player.seek(position: 60000, flags: SeekFlag(SeekFlag.keyFrame));

// 速度
player.playbackRate = 1.5;        // 1.5x

// 循环
player.loop = -1;                 // 无限循环
```

### 4.2 轨道切换

```dart
// 音频
player.activeAudioTracks = [1];   // 切换到第 2 条音频轨道

// 字幕
player.activeSubtitleTracks = [0]; // 启用第 1 条字幕
player.activeSubtitleTracks = [];  // 禁用字幕

// 外挂轨道
player.setMedia('/path/to/audio.m4a', MediaType.audio);
player.setMedia('/path/to/sub.ass', MediaType.subtitle);
```

### 4.3 音量

```dart
player.volume = 0.5;
player.mute = true;
```

### 4.4 缓冲

```dart
final bufferedMs = player.buffered();
final ranges = player.bufferedTimeRanges();
player.setBufferRange(min: 1000, max: 4000, drop: false);
```

### 4.5 截图

```dart
final rgba = await player.snapshot(width: 1920, height: 1080);
if (rgba != null) {
  // rgba 为 Uint8List，stride = width * 4
}
```

### 4.6 视频渲染控制

```dart
player.setAspectRatio(keepAspectRatio);
player.rotate(90);                // 逆时针 90 度
player.scale(1.2, 1.2);
player.setBackgroundColor(0, 0, 0, 1);
player.setVideoEffect(VideoEffect.brightness, [0.1]);
```

### 4.7 事件监听

```dart
player.onEvent.listen((e) => print('[${e.category}] ${e.detail}'));
player.onStateChanged.listen((e) => print('${e.oldValue} -> ${e.newValue}'));
player.onMediaStatus.listen((e) {
  if (e.newValue.test(MediaStatus.buffered)) print('缓冲完成');
});
player.onSubtitleText((start, end, texts) {
  print('字幕: ${texts.join("\\n")}');
});
```

### 4.8 属性读写

```dart
player.setProperty('video.decoder', 'FFmpeg');
final value = player.getProperty('video.decoder');
```

---

## 5. Player 生命周期与注意事项

### 5.1 安全释放

```dart
// 推荐的释放顺序
player.state = PlaybackState.paused;
await Future.delayed(const Duration(milliseconds: 50));
player.state = PlaybackState.stopped;
await player.dispose();
```

> ⚠️ Linux 平台下，`dispose()` 内部涉及 GL 上下文清理，同步 `stop` 可能导致死锁。建议先 `pause` 再延迟 `stop`。

### 5.2 mediaInfo 访问时机

`player.mediaInfo` 在 `prepare()` 完成且 `MediaStatus.loaded` 后才包含有效数据。提前访问可能得到空列表。

```dart
player.onMediaStatus.listen((event) {
  if (event.newValue.test(MediaStatus.loaded)) {
    final info = player.mediaInfo;
    print('视频轨道: ${info.video?.length}');
  }
});
```

### 5.3 轨道索引规则

- `activeAudioTracks = [index]` 中的 `index` 是**轨道在 `mediaInfo.audio` 中的索引**（从 0 开始），而非 `StreamInfo.index`。
- 但在 `mediaInfo.audio` 列表中，每个 `AudioStreamInfo.index` 通常也等于其在列表中的位置。

---

## 6. 模块详细文档索引

| 文档 | 覆盖范围 |
|------|----------|
| [fvp_mediainfo_types.md](./fvp_mediainfo_types.md) | `MediaInfo`、`StreamInfo`、`CodecParameters`、`ChapterInfo`、`ProgramInfo` 的完整字段定义与 `toString()` 示例 |
| [fvp_player_api.md](./fvp_player_api.md) | `Player` 类全部属性、方法、事件流、枚举与常量的详细说明 |

---

## 7. 最小可运行模板

```dart
import 'package:fvp/mdk.dart';
import 'package:flutter/material.dart';

class MdkPlayerPage extends StatefulWidget {
  final String url;
  const MdkPlayerPage({super.key, required this.url});

  @override
  State<MdkPlayerPage> createState() => _MdkPlayerPageState();
}

class _MdkPlayerPageState extends State<MdkPlayerPage> {
  late final Player _player;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _init();
  }

  Future<void> _init() async {
    _player.media = widget.url;
    _player.onMediaStatus.listen((event) {
      if (event.newValue.test(MediaStatus.loaded)) {
        setState(() => _isReady = true);
      }
    });
    await _player.prepare();
    _player.state = PlaybackState.playing;
  }

  @override
  void dispose() {
    try {
      _player.state = PlaybackState.paused;
      scheduleMicrotask(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        _player.state = PlaybackState.stopped;
        await _player.dispose();
      });
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isReady
            ? ValueListenableBuilder<int?>(
                valueListenable: _player.textureId,
                builder: (_, id, __) =>
                    id == null ? const SizedBox() : Texture(textureId: id),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
```
