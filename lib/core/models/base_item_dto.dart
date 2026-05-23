// lib/core/models/base_item_dto.dart

import 'package:emby_client/core/models/media_source_info.dart';
import 'package:emby_client/core/models/user_item_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_item_dto.freezed.dart';
part 'base_item_dto.g.dart';

/// {@template studio_dto}
/// Represents a production studio associated with a media item.
/// {@endtemplate}
@freezed
abstract class StudioDto with _$StudioDto {
  /// {@macro studio_dto}
  const factory StudioDto({
    /// Unique identifier for the studio.
    int? id,

    /// Name of the studio (e.g., "Marvel Studios").
    String? name,

    /// Image tags for the studio (e.g. Primary, Logo, Backdrop).
    Map<String, String>? imageTags,
  }) = _StudioDto;

  /// Creates a [StudioDto] from JSON.
  factory StudioDto.fromJson(Map<String, dynamic> json) =>
      _$StudioDtoFromJson(json);
}

/// {@template person_dto}
/// Represents a person (actor, director, writer, etc.) associated with a media item.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys.
/// build.yaml configures json_serializable to use PascalCase for all models.
@freezed
abstract class PersonDto with _$PersonDto {
  /// {@macro person_dto}
  const factory PersonDto({
    /// Unique identifier for the person.
    String? id,

    /// Name of the person.
    String? name,

    /// Role the person played (e.g., "Peter Parker" for actors).
    String? role,

    /// Type of contribution (Actor, Director, Writer, Composer, etc.).
    String? type,

    /// Primary image tag for the person's photo.
    String? primaryImageTag,
  }) = _PersonDto;

  /// Creates a [PersonDto] from JSON.
  factory PersonDto.fromJson(Map<String, dynamic> json) =>
      _$PersonDtoFromJson(json);
}

/// {@template base_item_dto}
/// Core media item model representing any content in the Emby library.
///
/// This is the primary model for movies, series, seasons, episodes,
/// and other media types. All fields are nullable for flexible deserialization.
/// {@endtemplate}
/// Emby API returns PascalCase JSON keys.
/// build.yaml configures json_serializable to use PascalCase for all models.
@freezed
abstract class BaseItemDto with _$BaseItemDto {
  /// {@macro base_item_dto}
  const factory BaseItemDto({
    /// Unique identifier for the item.
    String? id,

    /// Display name of the item.
    String? name,

    /// Item type (Movie, Series, Season, Episode, BoxSet, etc.).
    String? type,

    /// Premiere/release date of the item.
    DateTime? premiereDate,

    /// Official content rating (e.g., PG-13, TV-MA).
    String? officialRating,

    /// Community rating from external sources (e.g., IMDb, TMDB).
    double? communityRating,

    /// Critic rating from aggregators (e.g., Rotten Tomatoes).
    double? criticRating,

    /// Map of image type to image tag for constructing image URLs.
    /// Keys: Primary, Art, Backdrop, Banner, Logo, Thumb, Disc.
    Map<String, String>? imageTags,

    /// List of backdrop image tags.
    List<String>? backdropImageTags,

    /// Synopsis/overview of the item.
    String? overview,

    /// Genre tags (e.g., ["科幻", "动作", "冒险"]).
    List<String>? genres,

    /// External provider IDs (e.g., {"Imdb": "tt123456", "Tmdb": "12345"}).
    Map<String, String>? providerIds,

    /// Production studios (e.g., [{"Name": "Marvel Studios", "Id": "7025"}]).
    List<StudioDto>? studios,

    /// Runtime duration in ticks (1 tick = 100 nanoseconds).
    int? runTimeTicks,

    /// Year the item was produced/released.
    int? productionYear,

    /// Whether this item represents a folder/container.
    bool? isFolder,

    /// Parent folder/item identifier.
    String? parentId,

    /// Series ID (for episodes).
    String? seriesId,

    /// Series name (for episodes).
    String? seriesName,

    /// Season name (for episodes).
    String? seasonName,

    /// Episode number within the season.
    int? indexNumber,

    /// Season number (for episodes).
    int? parentIndexNumber,

    /// List of people associated with the item (cast and crew).
    @Default([]) List<PersonDto> people,

    /// List of available media sources for playback.
    @Default([]) List<MediaSourceInfo> mediaSources,

    /// User-specific data (playback progress, favorites, etc.).
    UserItemDataDto? userData,

    /// Collection type for library views (movies, tvshows, music, etc.).
    String? collectionType,

    /// Number of child items in a folder/library.
    int? childCount,

    /// Status for series (e.g., "Continuing" / "Ended").
    /// - "Continuing": 连载中
    /// - "Ended": 已完结
    String? status,
  }) = _BaseItemDto;

  /// Creates a [BaseItemDto] from JSON.
  factory BaseItemDto.fromJson(Map<String, dynamic> json) =>
      _$BaseItemDtoFromJson(json);

  /// Builds an Emby image URL for this item.
  ///
  /// [baseUrl] is the Emby server base URL (e.g., "http://192.168.1.100:8096").
  /// [type] is the image type: Primary, Art, Backdrop, Banner, Logo, Thumb, Disc.
  /// [maxHeight] optionally constrains the image height for thumbnail requests.
  ///
  /// Returns the constructed image URL, or null if required data is missing.
  ///
  /// Example:
  /// ```dart
  /// final url = item.getImageUrl('http://server:8096', 'Primary', maxHeight: 400);
  /// ```
  static String? getImageUrl(
    String? baseUrl,
    String? itemId,
    String type, {
    String? imageTag,
    int? maxHeight,
    int? maxWidth,
    double? quality,
  }) {
    if (baseUrl == null || itemId == null || imageTag == null) return null;

    final buffer = StringBuffer('$baseUrl/Items/$itemId/Images/$type')
      ..write('?tag=$imageTag');

    if (maxHeight != null) buffer.write('&MaxHeight=$maxHeight');
    if (maxWidth != null) buffer.write('&MaxWidth=$maxWidth');
    if (quality != null) buffer.write('&Quality=$quality');

    return buffer.toString();
  }


}
