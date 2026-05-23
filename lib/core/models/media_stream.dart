// lib/core/models/media_stream.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_stream.freezed.dart';
part 'media_stream.g.dart';

/// {@template media_stream}
/// Represents a media stream (video, audio, or subtitle) within a media source.
///
/// A media stream contains codec information, language metadata, and
/// playback configuration flags.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys.
/// build.yaml configures json_serializable to use PascalCase for all models.
///
/// Explicit [@JsonKey] annotations on [isDefault] and [isExternal] below
/// remain valid and take precedence if needed.
@freezed
abstract class MediaStream with _$MediaStream {
  /// {@macro media_stream}
  const factory MediaStream({
    /// Stream index within the container.
    int? index,

    /// Stream type: Video, Audio, or Subtitle.
    String? type,

    /// Codec name (e.g., h264, aac, ass).
    String? codec,

    /// ISO language code (e.g., eng, jpn, chi).
    String? language,

    /// Display title for the stream.
    String? title,

    /// Whether this stream is selected by default.
    @JsonKey(name: 'IsDefault') bool? isDefault,

    /// Whether this is an external subtitle file.
    @JsonKey(name: 'IsExternal') bool? isExternal,

    /// File path for external streams.
    String? path,

    /// Human-readable display title combining codec and language.
    String? displayTitle,

    /// Video height in pixels (for video streams).
    int? height,

    /// Video width in pixels (for video streams).
    int? width,

    /// Audio channel layout (e.g., stereo, 5.1, 7.1).
    String? channelLayout,
  }) = _MediaStream;

  /// Creates a [MediaStream] from JSON.
  factory MediaStream.fromJson(Map<String, dynamic> json) =>
      _$MediaStreamFromJson(json);
}
