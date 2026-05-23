// lib/core/models/media_source_info.dart

import 'package:emby_client/core/models/media_stream.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_source_info.freezed.dart';
part 'media_source_info.g.dart';

/// {@template media_source_info}
/// Represents a media source (file/stream) for a media item.
///
/// Contains information about the container format, streaming URLs,
/// direct play/transcoding support, and associated media streams.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys.
/// build.yaml configures json_serializable to use PascalCase for all models.
@freezed
abstract class MediaSourceInfo with _$MediaSourceInfo {
  /// {@macro media_source_info}
  const factory MediaSourceInfo({
    /// Unique identifier for the media source.
    String? id,

    /// Human-readable name of the media source.
    String? name,

    /// File system path to the media file.
    String? path,

    /// Transfer protocol (File, Http, Rtmp, Rtsp, etc.).
    String? protocol,

    /// Source type (Default, Grouping, Placeholder).
    String? type,

    /// File size in bytes.
    int? size,

    /// Container format (e.g., mp4, mkv, avi).
    String? container,

    /// URL for direct streaming without transcoding.
    String? directStreamUrl,

    /// URL for transcoded streaming.
    String? transcodingUrl,

    /// Whether the source supports direct stream.
    bool? supportsDirectStream,

    /// Whether the source supports transcoding.
    bool? supportsTranscoding,

    /// List of media streams (video, audio, subtitle).
    @Default([]) List<MediaStream> mediaStreams,

    /// Video type (VideoFile, Iso, Dvd, BluRay).
    String? videoType,
  }) = _MediaSourceInfo;

  /// Creates a [MediaSourceInfo] from JSON.
  factory MediaSourceInfo.fromJson(Map<String, dynamic> json) =>
      _$MediaSourceInfoFromJson(json);
}
