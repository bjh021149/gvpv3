# FVP MediaInfo 类型参考文档

> 基于 fvp `0.36.2` 源码 `lib/src/media_info.dart` 整理。
>
> 以下所有类型均通过 `package:fvp/mdk.dart` 导出，可直接使用。

---

## 目录

1. [MediaInfo](#mediainfo)
2. [StreamInfo 体系](#streaminfo-体系)
   - [StreamInfo (基类)](#streaminfo-基类)
   - [VideoStreamInfo](#videostreaminfo)
   - [AudioStreamInfo](#audiostreaminfo)
   - [SubtitleStreamInfo](#subtitlestreaminfo)
3. [CodecParameters 体系](#codecparameters-体系)
   - [CodecParameters (基类)](#codecparameters-基类)
   - [VideoCodecParameters](#videocodecparameters)
   - [AudioCodecParameters](#audiocodecparameters)
   - [SubtitleCodecParameters](#subtitlecodecparameters)
4. [ChapterInfo](#chapterinfo)
5. [ProgramInfo](#programinfo)
6. [toString() 输出示例](#tostring-输出示例)

---

## MediaInfo

媒体文件的整体元信息。通过 `Player.mediaInfo` 获取。

```dart
class MediaInfo {
  /// 起始时间（毫秒）
  int startTime;

  /// 时长（毫秒）。直播流可能为 0；正在录制的流时长可能会变化
  int duration;

  /// 码率（bps）。加载时为容器值，播放时更新为实时值
  int bitRate;

  /// 容器格式名称，例如 mp4、flv
  String? format;

  /// 流总数
  int streams;

  /// 容器级元数据（键值对）
  Map<String, String> metadata;

  /// 音频轨道列表
  List<AudioStreamInfo>? audio;

  /// 视频轨道列表
  List<VideoStreamInfo>? video;

  /// 字幕轨道列表
  List<SubtitleStreamInfo>? subtitle;

  /// 章节信息列表
  List<ChapterInfo>? chapters;

  /// 节目信息列表
  List<ProgramInfo>? programs;
}
```

### 使用示例

```dart
final player = Player();
// ... 加载媒体 ...
final info = player.mediaInfo;

print('格式: ${info.format}');
print('时长: ${info.duration} ms');
print('视频轨道数: ${info.video?.length ?? 0}');
print('音频轨道数: ${info.audio?.length ?? 0}');
print('字幕轨道数: ${info.subtitle?.length ?? 0}');
```

---

## StreamInfo 体系

### StreamInfo (基类)

所有流信息的基类。

```dart
class StreamInfo {
  /// 轨道索引（从 0 开始）
  int index;

  /// 流起始时间（毫秒）
  int startTime;

  /// 流时长（毫秒）
  int duration;

  /// 帧数。如果未检测到可能为 0
  int frames;

  /// 流级元数据（键值对）。常见 key 包括 "language", "title" 等
  Map<String, String> metadata;
}
```

### VideoStreamInfo

```dart
class VideoStreamInfo extends StreamInfo {
  /// 需要顺时针旋转的角度。取值：0, 90, 180, 270
  int rotation;

  /// 视频编码参数
  VideoCodecParameters codec;
}
```

### AudioStreamInfo

```dart
class AudioStreamInfo extends StreamInfo {
  /// 音频编码参数
  AudioCodecParameters codec;
}
```

### SubtitleStreamInfo

```dart
class SubtitleStreamInfo extends StreamInfo {
  /// 字幕编码参数
  SubtitleCodecParameters codec;
}
```

---

## CodecParameters 体系

### CodecParameters (基类)

```dart
class CodecParameters {
  /// 编码器名称，例如 "h264", "aac", "ass"
  String codec;

  /// fourcc 标签值
  int tag;

  /// extradata（无填充数据）。可能为 null
  Uint8List? extra;
}
```

### VideoCodecParameters

```dart
class VideoCodecParameters extends CodecParameters {
  int bitRate;        // 码率
  int profile;        // 编码 profile
  int level;          // 编码 level
  double frameRate;   // 帧率

  /// 像素格式（整数值）
  int format;

  /// 像素格式名称，例如 "yuv420p"
  String? formatName;

  int width;          // 视频宽度
  int height;         // 视频高度
  int bFrames;        // B 帧数量

  /// 像素宽高比 (pixel aspect ratio)
  double par;

  /// 色彩空间
  ColorSpace colorSpace;

  /// Dolby Vision profile
  int doviProfile;
}
```

### AudioCodecParameters

```dart
class AudioCodecParameters extends CodecParameters {
  int bitRate;        // 码率
  int profile;        // 编码 profile
  int level;          // 编码 level
  double frameRate;   // 帧率（对音频通常无意义）
  bool isFloat;       // 是否为浮点采样
  bool isUnsigned;    // 是否为无符号采样
  bool isPlanar;      // 是否为 planar 格式
  int rawSampleSize;  // 原始采样位深
  int channels;       // 声道数
  int sampleRate;     // 采样率（Hz）
  int blockAlign;     // 块对齐
  int frameSize;      // 帧大小
}
```

### SubtitleCodecParameters

```dart
class SubtitleCodecParameters extends CodecParameters {
  /// 显示宽度（仅位图字幕有效）
  int width;

  /// 显示高度（仅位图字幕有效）
  int height;
}
```

---

## ChapterInfo

章节（断点）信息。

```dart
class ChapterInfo {
  /// 章节开始时间（毫秒）
  int startTime;

  /// 章节结束时间（毫秒）
  int endTime;

  /// 章节标题。无标题时为 null
  String? title;
}
```

---

## ProgramInfo

节目流信息（多用于 TS 等多节目流容器）。

```dart
class ProgramInfo {
  /// 节目 ID
  int id;

  /// 包含的流索引列表
  List<int> stream;

  /// 节目级元数据
  Map<String, String> metadata;
}
```

---

## toString() 输出示例

各类型均重写了 `toString()`，可直接用于调试或 UI 展示。

### MediaInfo

```
MediaInfo(range: 0 + 7200000ms, bitRate: 5242880, format: mp4, streams: 3
metadata: {encoder: Lavf58.76.100}
[VideoStreamInfo(...)]
[AudioStreamInfo(...)]
[SubtitleStreamInfo(...)])
```

### VideoStreamInfo

```
VideoStreamInfo(#0, range: 0 + 7200000ms, frames: 180000, rotation: 0
metadata: {language: eng, title: Main Video}
VideoCodecParameters(codec: h264, tag: 0, profile: 100, level: 41, bitRate: 5000000, 1920x1080, 24.0fps, format: yuv420p, bFrames:2))
```

### AudioStreamInfo

```
AudioStreamInfo(#1, range: 0 + 7200000ms, frames: 337500
metadata: {language: jpn, title: Main Audio}
AudioCodecParameters(codec: aac, tag: 0, profile: 1, level: 0, bitRate: 192000, isFloat: false, isUnsigned: false, isPlanar: false, channels: 2 @48000Hz, blockAlign: 0, frameSize: 1024))
```

### SubtitleStreamInfo

```
SubtitleStreamInfo(#2, range: 0 + 7200000ms, frames: 0
metadata: {language: chs, title: Chinese Simplified}
SubtitleCodecParameters(codec: ass, tag: 0, 0x0))
```

### ChapterInfo

```
ChapterInfo(range: 0 ~ 300000ms, title: Opening)
```

### ProgramInfo

```
ProgramInfo(id: 1, streams: [0, 1, 2], metadata: {})
```

---

## 在 UI 中展示轨道信息

由于 fvp 的流信息类型**没有 `displayTitle` 字段**，建议通过以下方式构建展示标签：

```dart
// 直接 toString()（信息最全，但可能较长）
final label = streamInfo.toString();

// 或手动组合关键信息
String buildAudioLabel(AudioStreamInfo info) {
  final lang = info.metadata['language'] ?? '未知';
  final title = info.metadata['title'];
  final codec = info.codec.codec;
  final ch = info.codec.channels;
  final sr = info.codec.sampleRate;
  return title != null
    ? '[$lang] $title ($codec, ${ch}ch, ${sr}Hz)'
    : '[$lang] $codec, ${ch}ch, ${sr}Hz';
}

String buildVideoLabel(VideoStreamInfo info) {
  final c = info.codec;
  return '${c.width}x${c.height} @ ${c.frameRate.toStringAsFixed(1)}fps (${c.codec})';
}

String buildSubtitleLabel(SubtitleStreamInfo info) {
  final lang = info.metadata['language'] ?? '未知';
  final title = info.metadata['title'];
  return title != null ? '[$lang] $title' : '[$lang] 字幕';
}
```
