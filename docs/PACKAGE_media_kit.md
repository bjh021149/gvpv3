> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# media_kit ^1.2.6 + media_kit_video ^2.0.1 使用方法

## 1. 概述

`media_kit` 是 Flutter 生态中最强大的跨平台视频/音频播放库，基于 `libmpv`（原生平台）和 HTML5 `<video>`（Web）。支持 Android、iOS、macOS、Windows、Linux 和 Web 六大平台。

**核心优势：**
- 跨平台统一 API
- 支持几乎所有视频/音频格式（通过 FFmpeg）
- GPU 硬件加速
- 播放列表管理
- 音轨/字幕切换
- 自定义 HTTP 请求头

---

## 2. 依赖配置

```yaml
dependencies:
  media_kit: ^1.2.6
  media_kit_video: ^2.0.1
  media_kit_libs_video: ^1.0.7
```

**说明：**
- `media_kit`：核心 API（Player、Media、Playlist）
- `media_kit_video`：视频渲染（VideoController、Video Widget）
- `media_kit_libs_video`：原生库依赖（libmpv + FFmpeg）

---

## 3. 初始化

```dart
import 'package:media_kit/media_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized(); // 必须！初始化原生库
  runApp(const MyApp());
}
```

---

## 4. 基础播放

### 4.1 创建 Player 与 VideoController
```dart
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerScreen extends StatefulWidget {
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    
    // 播放单个媒体
    player.open(Media('https://example.com/video.mp4'));
    
    // 或播放列表
    player.open(
      Playlist([
        Media('https://example.com/ep1.mp4'),
        Media('https://example.com/ep2.mp4'),
      ]),
    );
  }

  @override
  void dispose() {
    player.dispose(); // 必须释放资源！
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Video(controller: controller),
    );
  }
}
```

### 4.2 使用 `Video` Widget
```dart
Video(
  controller: controller,
  // 自适应平台控制条
  controls: AdaptiveVideoControls,
  // 或 Material 风格
  // controls: MaterialVideoControls,
  // 或 iOS 风格
  // controls: CupertinoVideoControls,
  // 或禁用控制条
  // controls: NoVideoControls,
)
```

---

## 5. 播放控制

### 5.1 基本控制
```dart
// 播放/暂停
await player.play();
await player.pause();
await player.playOrPause(); // 切换

// 跳转
await player.seek(Duration(minutes: 5, seconds: 30));

// 音量 (0.0 ~ 100.0)
await player.setVolume(50.0);

// 倍速
await player.setRate(1.5); // 1.5x

// 静音
await player.setMute(true);
```

### 5.2 播放列表控制
```dart
// 下一集/上一集
await player.next();
await player.previous();

// 跳转到指定索引
await player.jump(2);

// 循环模式
await player.setPlaylistMode(PlaylistMode.none);   // 不循环
await player.setPlaylistMode(PlaylistMode.single); // 单曲循环
await player.setPlaylistMode(PlaylistMode.loop);   // 列表循环

// 随机播放
await player.setShuffle(true);
```

---

## 6. 状态监听

### 6.1 流式监听
```dart
// 播放状态
player.stream.playing.listen((playing) {
  print('Playing: $playing');
});

// 播放位置
player.stream.position.listen((position) {
  print('Position: $position');
});

// 总时长
player.stream.duration.listen((duration) {
  print('Duration: $duration');
});

// 缓冲状态
player.stream.buffering.listen((buffering) {
  print('Buffering: $buffering');
});

// 缓冲进度
player.stream.buffer.listen((buffer) {
  print('Buffered: $buffer');
});

// 播放完成
player.stream.completed.listen((completed) {
  if (completed) print('Playback completed');
});

// 错误
player.stream.error.listen((error) {
  print('Error: $error');
});
```

### 6.2 同步获取当前状态
```dart
final state = player.state;
print('Current position: ${state.position}');
print('Is playing: ${state.playing}');
print('Volume: ${state.volume}');
```

---

## 7. 音轨与字幕切换

### 7.1 获取可用轨道
```dart
// 音频轨道
final audioTracks = player.state.tracks.audio;
// 视频轨道
final videoTracks = player.state.tracks.video;
// 字幕轨道
final subtitleTracks = player.state.tracks.subtitle;
```

### 7.2 切换轨道
```dart
// 切换音频（track.id 为 null 表示禁用）
await player.setAudioTrack(AudioTrack.uri('https://example.com/audio.mp3'));
// 或使用已有轨道
await player.setAudioTrack(audioTracks[1]);

// 切换字幕
await player.setSubtitleTrack(SubtitleTrack.uri('https://example.com/subtitle.srt'));
// 禁用字幕
await player.setSubtitleTrack(SubtitleTrack.no()); // 或 SubtitleTrack.auto()
```

### 7.3 外部字幕加载
```dart
await player.setSubtitleTrack(
  SubtitleTrack.uri(
    'https://example.com/subtitle.srt',
    title: 'English',
    language: 'en',
  ),
);
```

---

## 8. 自定义 HTTP 请求头（认证流）

```dart
final headers = {
  'Authorization': 'Bearer YOUR_TOKEN',
  'Cookie': 'session=abc123',
};

player.open(
  Media(
    'https://example.com/video.mp4',
    httpHeaders: headers,
  ),
);
```

---

## 9. 截图功能

```dart
final bytes = await player.screenshot();
if (bytes != null) {
  final image = Image.memory(bytes);
  // 显示或保存
}
```

---

## 10. 自定义渲染配置

```dart
final controller = VideoController(
  player,
  configuration: const VideoControllerConfiguration(
    enableHardwareAcceleration: true, // 默认开启 GPU 加速
    width: 1920,  // 限制渲染分辨率（性能优化）
    height: 1080,
  ),
);
```

---

## 11. 自定义控制条

```dart
Video(
  controller: controller,
  controls: (state) {
    // 完全自定义控制条
    return Stack(
      children: [
        // 点击区域
        GestureDetector(
          onTap: () => state.widget.controller.player.playOrPause(),
        ),
        // 进度条
        Positioned(
          bottom: 0,
          child: StreamBuilder<Duration>(
            stream: state.widget.controller.player.stream.position,
            builder: (context, snapshot) {
              return LinearProgressIndicator(
                value: snapshot.data?.inMilliseconds ?? 0 / 
                       state.widget.controller.player.state.duration.inMilliseconds,
              );
            },
          ),
        ),
      ],
    );
  },
)
```

---

## 12. 注意事项与常见问题

### 12.1 资源释放
**必须调用 `player.dispose()`**，否则会导致内存泄漏甚至崩溃。

### 12.2 Web 平台限制
- Web 不支持所有格式，依赖浏览器原生解码
- Web 缓存使用 IndexedDB，性能低于原生文件系统
- 部分功能（如截图）在 Web 上不可用

### 12.3 已知问题
- **v1.2.6 在 macOS/Windows  dispose 时可能崩溃**：确保在 `dispose()` 前停止播放
```dart
@override
void dispose() {
  player.pause(); // 先暂停
  await Future.delayed(Duration(milliseconds: 100));
  player.dispose();
  super.dispose();
}
```

---

## 13. 项目集成建议

当前项目已正确使用 `media_kit` 基础播放。建议改进：

1. **实现播放进度恢复**：启动时 seek 到 Emby 返回的 `playbackPositionTicks`
2. **实现真正的音轨/字幕切换**：当前仅 UI 切换，应调用 `player.setAudioTrack` / `player.setSubtitleTrack`
3. **添加自定义 HTTP 头**：Emby 流需要 `X-Emby-Token`，应通过 `Media.httpHeaders` 传入
4. **处理 HLS/DASH 流**：优先尝试 HLS，失败时降级到 Direct Stream
5. **截图功能**：用于详情页预览缩略图
6. **资源释放优化**：dispose 前先 pause，避免 macOS/Windows 崩溃
