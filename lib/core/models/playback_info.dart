// lib/core/models/playback_info.dart

import 'package:emby_client/core/models/media_source_info.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_info.freezed.dart';
part 'playback_info.g.dart';

/// {@template playback_info}
/// Contains playback information for a media item.
///
/// Provides available media sources and error information
/// when playback initialization fails.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys.
/// build.yaml configures json_serializable to use PascalCase for all models.
@freezed
abstract class PlaybackInfo with _$PlaybackInfo {
  /// {@macro playback_info}
  const factory PlaybackInfo({
    /// List of available media sources for playback.
    @Default([]) List<MediaSourceInfo> mediaSources,

    /// Error code if playback information retrieval failed.
    String? errorCode,
  }) = _PlaybackInfo;

  /// Creates a [PlaybackInfo] from JSON.
  factory PlaybackInfo.fromJson(Map<String, dynamic> json) =>
      _$PlaybackInfoFromJson(json);
}
