// lib/services/cache/cache_keys.dart
//
// Centralized cache key generator for all Emby API list/item queries.
//
// Keys are deterministic and human-readable for debugging:
//   items|abc123|SortName|0|50
//   detail|abc123
//   seasons|series-xyz

/// {@template cache_keys}
/// Generates consistent cache keys used by [EmbyCache].
///
/// All keys use pipe (`|`) as delimiter to avoid collisions with
/// typical BaseItemDto id characters.
/// {@endtemplate}
abstract class CacheKeys {
  CacheKeys._();

  // ── List keys ──────────────────────────────────────────

  /// Key for [EmbyApiService.getViews].
  static String views() => 'views';

  /// Key for [EmbyApiService.getItems] paginated queries.
  static String items({
    String? parentId,
    String? includeItemTypes,
    String? excludeItemTypes,
    String? sortBy,
    int? startIndex,
    int? limit,
    List<String>? genres,
    List<String>? studioIds,
  }) =>
      'items|${parentId ?? '_'}|${includeItemTypes ?? '_'}|${excludeItemTypes ?? '_'}|${sortBy ?? '_'}|${startIndex ?? 0}|${limit ?? 50}|${genres?.join(',') ?? '_'}|${studioIds?.join(',') ?? '_'}';

  /// Key for [EmbyApiService.getChildren].
  static String children(
    String parentId, {
    String? includeItemTypes,
  }) =>
      'children|$parentId|${includeItemTypes ?? '_'}';

  /// Key for [EmbyApiService.getSimilarItems].
  static String similarItems(String itemId) => 'similar|$itemId';

  /// Key for [EmbyApiService.getSeasons].
  static String seasons(String seriesId) => 'seasons|$seriesId';

  /// Key for [EmbyApiService.getEpisodes].
  static String episodes(
    String seriesId,
    String? seasonId,
  ) =>
      'episodes|$seriesId|${seasonId ?? '_'}';

  /// Key for [EmbyApiService.getContinueWatching].
  static String continueWatching() => 'continue_watching';

  /// Key for [EmbyApiService.getResumableMovies].
  static String resumableMovies() => 'resumable_movies';

  /// Key for [EmbyApiService.getResumableSeries].
  static String resumableSeries() => 'resumable_series';

  /// Key for [EmbyApiService.getLatestItems].
  static String latestItems(String? parentId) =>
      'latest|${parentId ?? '_'}';

  /// Key for [EmbyApiService.getMovieRecommendations].
  static String movieRecommendations() => 'recommendations';

  // ── Single-item keys ───────────────────────────────────

  /// Key for [EmbyApiService.getItemDetail].
  /// Note: item detail is stored by its [itemId] directly in the
  /// core/userdata/child boxes, but a list key is useful for metadata.
  static String itemDetail(String itemId) => 'detail|$itemId';
}
