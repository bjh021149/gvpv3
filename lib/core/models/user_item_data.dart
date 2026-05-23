// lib/core/models/user_item_data.dart

import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_item_data.freezed.dart';
part 'user_item_data.g.dart';

/// {@template user_item_data}
/// Represents user-specific data for a media item.
///
/// Tracks playback progress, favorite status, and watch state
/// for an individual user/item combination.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys.
/// build.yaml configures json_serializable to use PascalCase for all models.
@freezed
abstract class UserItemDataDto with _$UserItemDataDto {
  /// {@macro user_item_data}
  const factory UserItemDataDto({
    /// Current playback position in ticks (1 tick = 100 nanoseconds).
    int? playbackPositionTicks,

    /// Whether the item is marked as favorite by the user.
    bool? isFavorite,

    /// Whether the user likes this item.
    bool? likes,

    /// Whether the item has been fully played.
    bool? played,

    /// Percentage of content that has been played (0.0 - 100.0).
    double? playedPercentage,

    /// Number of unplayed items in a folder/series.
    int? unplayedItemCount,
  }) = _UserItemDataDto;

  /// Creates a [UserItemDataDto] from JSON.
  factory UserItemDataDto.fromJson(Map<String, dynamic> json) =>
      _$UserItemDataDtoFromJson(json);
}
