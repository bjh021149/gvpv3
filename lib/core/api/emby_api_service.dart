// lib/core/api/emby_api_service.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:emby_client/core/api/dio_client.dart';
import 'package:emby_client/core/models/authentication_result.dart';
import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/playback_info.dart';
import 'package:emby_client/core/models/query_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// {@template emby_api_service}
/// Service class for all Emby API operations.
///
/// Provides typed methods for authentication, media browsing,
/// playback management, and user-specific operations.
///
/// Usage:
/// ```dart
/// final api = ref.watch(embyApiServiceProvider);
/// final items = await api.getItems(parentId: 'some-id');
/// ```
/// {@endtemplate}
class EmbyApiService {
  /// {@macro emby_api_service}
  const EmbyApiService({required this.dio, required this.userId});

  /// Dio HTTP client for API requests.
  final Dio dio;

  /// Currently authenticated user ID.
  final String? userId;

  // ==================== AUTHENTICATION ====================

  /// Authenticates a user with username and password.
  ///
  /// [username] is the Emby account username.
  /// [password] is the plaintext password.
  /// [clientName], [deviceName], [deviceId], [version] are used to build
  /// the Emby Authorization header for device identification.
  ///
  /// Returns [AuthenticationResult] containing access token and user info.
  /// Throws [DioException] on network or authentication failure.
  Future<AuthenticationResult> authenticate(
    String username,
    String password, {
    String? clientName,
    String? deviceName,
    String? deviceId,
    String? version,
  }) async {
    // Build Emby Authorization header with device info
    final authHeader = _buildEmbyAuthorizationHeader(
      clientName: clientName,
      deviceName: deviceName,
      deviceId: deviceId,
      version: version,
    );

    // Manually encode as application/x-www-form-urlencoded
    // Dio's default transformer does NOT auto-encode Map for this content type.
    final encodedBody = <String, String>{
      'Username': username,
      'Pw': password,
    }.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    debugPrint('[EmbyApiService] POST ${dio.options.baseUrl}/Users/AuthenticateByName');
    debugPrint('[EmbyApiService] Headers: ${{
      'Content-Type': Headers.formUrlEncodedContentType,
      if (authHeader != null) 'Authorization': authHeader,
    }}');
    debugPrint('[EmbyApiService] Body: $encodedBody');

    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/Users/AuthenticateByName',
        data: encodedBody,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            if (authHeader != null) 'Authorization': authHeader,
          },
        ),
      );

      debugPrint('[EmbyApiService] Response status: ${response.statusCode}');
      debugPrint('[EmbyApiService] Response data: ${jsonEncode(response.data)}');

      if (response.data == null) {
        throw const FormatException('Empty response from server');
      }

      return AuthenticationResult.fromJson(response.data!);
    } on DioException catch (e) {
      debugPrint('[EmbyApiService] DioException: ${e.message}');
      debugPrint('[EmbyApiService] DioException response: ${e.response?.data}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[EmbyApiService] Exception: $e');
      throw DioException(
        requestOptions: RequestOptions(path: '/Users/AuthenticateByName'),
        error: 'Authentication parsing error: $e',
        stackTrace: stackTrace,
      );
    }
  }

  // ==================== MEDIA BROWSING ====================

  /// Queries items from the Emby library with optional filters.
  ///
  /// [parentId] filters by parent folder/item.
  /// [includeItemTypes] comma-separated item types (Movie, Series, Episode, etc.).
  /// [sortBy] sort field (SortName, DateCreated, PremiereDate, etc.).
  /// [sortOrder] true for ascending, false for descending.
  /// [startIndex] pagination offset.
  /// [limit] maximum number of items to return.
  /// [searchTerm] text search query.
  /// [filters] additional query filters.
  /// [recursive] include child items recursively.
  /// [fields] additional fields to include in the response.
  /// [imageTypeLimit] limit for image types.
  /// [enableImageTypes] comma-separated image types to include.
  ///
  /// Returns a [QueryResult] of [BaseItemDto].
  Future<QueryResult<BaseItemDto>> getItems({
    String? parentId,
    String? includeItemTypes,
    String? excludeItemTypes,
    String? sortBy,
    bool? sortOrder,
    int? startIndex,
    int? limit,
    String? searchTerm,
    List<String>? filters,
    bool? recursive,
    String? fields,
    int? imageTypeLimit,
    String? enableImageTypes,
    List<String>? studioIds,
    List<String>? personIds,
    List<String>? genreIds,
    List<String>? genres,
  }) async {
    assert(userId != null, 'userId is required for getItems');

    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/Users/$userId/Items',
        queryParameters: <String, dynamic>{
          if (parentId != null) 'ParentId': parentId,
          if (includeItemTypes != null) 'IncludeItemTypes': includeItemTypes,
          if (excludeItemTypes != null) 'ExcludeItemTypes': excludeItemTypes,
          if (sortBy != null) 'SortBy': sortBy,
          if (sortOrder != null) 'SortOrder': sortOrder ? 'Ascending' : 'Descending',
          if (startIndex != null) 'StartIndex': startIndex,
          if (limit != null) 'Limit': limit,
          if (searchTerm != null && searchTerm.isNotEmpty) 'SearchTerm': searchTerm,
          if (filters != null && filters.isNotEmpty) 'Filters': filters.join(','),
          if (recursive != null) 'Recursive': recursive,
          if (fields != null) 'Fields': fields,
          if (imageTypeLimit != null) 'ImageTypeLimit': imageTypeLimit,
          if (enableImageTypes != null) 'EnableImageTypes': enableImageTypes,
          if (studioIds != null && studioIds.isNotEmpty)
            'StudioIds': studioIds.join(','),
          if (personIds != null && personIds.isNotEmpty)
            'PersonIds': personIds.join(','),
          if (genreIds != null && genreIds.isNotEmpty)
            'GenreIds': genreIds.join(','),
          if (genres != null && genres.isNotEmpty)
            'Genres': genres.join(','),
          'EnableTotalRecordCount': true,
        }..removeWhere((key, value) => value == null),
      );

      if (response.data == null) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      final data = response.data!;
      final items = (data['Items'] as List<dynamic>? ?? [])
          .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList();
      final totalCount = data['TotalRecordCount'] as int? ?? items.length;

      return QueryResult<BaseItemDto>(
        items: items,
        totalRecordCount: totalCount,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Gets children items of a folder/collection item.
  ///
  /// [parentId] the folder/collection item ID (item with `isFolder: true`).
  /// [includeItemTypes] filter by item types (Movie, Series, Episode, etc.).
  /// [recursive] whether to include items in sub-folders recursively.
  /// [limit] maximum number of items to return.
  ///
  /// Returns a [QueryResult] of [BaseItemDto].
  Future<QueryResult<BaseItemDto>> getChildren(
    String parentId, {
    String? includeItemTypes,
    bool recursive = false,
    int? limit,
  }) async {
    assert(userId != null, 'userId is required for getChildren');

    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/Users/$userId/Items',
        queryParameters: <String, dynamic>{
          'ParentId': parentId,
          if (includeItemTypes != null) 'IncludeItemTypes': includeItemTypes,
          'Recursive': recursive,
          if (limit != null) 'Limit': limit,
          'Fields': 'PrimaryImageAspectRatio,UserData,IsFolder',
          'EnableTotalRecordCount': true,
        },
      );

      if (response.data == null) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      final data = response.data!;
      final items = (data['Items'] as List<dynamic>? ?? [])
          .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList();
      final totalCount = data['TotalRecordCount'] as int? ?? items.length;

      return QueryResult<BaseItemDto>(
        items: items,
        totalRecordCount: totalCount,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Gets detailed information about a specific item.
  ///
  /// [itemId] the unique identifier of the item.
  ///
  /// Returns a [BaseItemDto] with full details.
  ///
  /// [fields] optional comma-separated list of fields to include
  /// (e.g. 'Studios,Genres,People,ImageTags').
  Future<BaseItemDto> getItemDetail(
    String itemId, {
    String? fields,
  }) async {
    assert(userId != null, 'userId is required for getItemDetail');

    try {
      final query = <String, dynamic>{};
      if (fields != null && fields.isNotEmpty) {
        query['Fields'] = fields;
      }

      final response = await dio.get<Map<String, dynamic>>(
        '/Users/$userId/Items/$itemId',
        queryParameters: query.isNotEmpty ? query : null,
      );

      if (response.data == null) {
        throw const FormatException('Empty response from server');
      }

      return BaseItemDto.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }

  /// Gets a studio detail by its [studioId].
  ///
  /// Studio is also an Item in Emby, so this internally calls
  /// [getItemDetail] with the stringified ID.
  Future<BaseItemDto> getStudioDetail(int studioId) async {
    return getItemDetail(
      studioId.toString(),
      fields: 'ImageTags',
    );
  }

  /// Gets detailed information about a TV series.
  ///
  /// [seriesId] the unique identifier of the series.
  ///
  /// Returns a [BaseItemDto] with full series details including
  /// backdrop images, genres, studios, people, and other metadata.
  Future<BaseItemDto> getSeries(String seriesId) async {
    return getItemDetail(
      seriesId,
      fields: 'PrimaryImageAspectRatio,UserData,Genres,Overview,ProductionYear,RunTimeTicks,ProviderIds,Studios,MediaSources,People,OfficialRating,CommunityRating,CriticRating,Path,ImageTags,BackdropImageTags',
    );
  }

  /// Gets items similar to the specified item.
  ///
  /// [itemId] the unique identifier of the reference item.
  /// [limit] maximum number of similar items to return (default: 10).
  ///
  /// Returns a [QueryResult] of [BaseItemDto].
  Future<QueryResult<BaseItemDto>> getSimilarItems(
    String itemId, {
    int limit = 10,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/Items/$itemId/Similar',
        queryParameters: {'Limit': limit},
      );

      if (response.data == null) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      final data = response.data!;
      final items = (data['Items'] as List<dynamic>? ?? [])
          .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList();
      final totalCount = data['TotalRecordCount'] as int? ?? items.length;

      return QueryResult<BaseItemDto>(
        items: items,
        totalRecordCount: totalCount,
      );
    } on DioException {
      rethrow;
    }
  }

  // ==================== SERIES & EPISODES ====================

  /// Gets all seasons for a TV series.
  ///
  /// [seriesId] the unique identifier of the series.
  /// [fields] additional fields to include.
  ///
  /// Returns a [QueryResult] of [BaseItemDto] representing seasons.
  Future<QueryResult<BaseItemDto>> getSeasons(
    String seriesId, {
    String? fields,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/Shows/$seriesId/Seasons',
        queryParameters: <String, dynamic>{
          'UserId': userId,
          if (fields != null) 'Fields': fields,
        }..removeWhere((key, value) => value == null),
      );

      if (response.data == null) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      final data = response.data!;
      final items = (data['Items'] as List<dynamic>? ?? [])
          .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList();
      final totalCount = data['TotalRecordCount'] as int? ?? items.length;

      return QueryResult<BaseItemDto>(
        items: items,
        totalRecordCount: totalCount,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Gets episodes for a specific season of a TV series.
  ///
  /// [seriesId] the unique identifier of the series.
  /// [seasonId] the unique identifier of the season.
  /// [fields] additional fields to include.
  ///
  /// Returns a [QueryResult] of [BaseItemDto] representing episodes.
  Future<QueryResult<BaseItemDto>> getEpisodes(
    String seriesId, {
    String? seasonId,
    String? fields,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/Shows/$seriesId/Episodes',
        queryParameters: <String, dynamic>{
          if (seasonId != null) 'SeasonId': seasonId,
          'UserId': userId,
          if (fields != null) 'Fields': fields,
        }..removeWhere((key, value) => value == null),
      );

      if (response.data == null) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      final data = response.data!;
      final items = (data['Items'] as List<dynamic>? ?? [])
          .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList();
      final totalCount = data['TotalRecordCount'] as int? ?? items.length;

      return QueryResult<BaseItemDto>(
        items: items,
        totalRecordCount: totalCount,
      );
    } on DioException {
      rethrow;
    }
  }

  // ==================== PLAYBACK ====================

  /// Gets playback information for a media item.
  ///
  /// [itemId] the unique identifier of the item to play.
  ///
  /// Returns [PlaybackInfo] with available media sources and stream URLs.
  Future<PlaybackInfo> getPlaybackInfo(String itemId) async {
    assert(userId != null, 'userId is required for getPlaybackInfo');

    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/Items/$itemId/PlaybackInfo',
        queryParameters: {'UserId': userId},
      );

      if (response.data == null) {
        return const PlaybackInfo();
      }

      debugPrint('[EmbyApiService] Raw PlaybackInfo JSON: ${jsonEncode(response.data)}');
      return PlaybackInfo.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }

  // ==================== USER VIEWS & HOME ====================

  /// Gets the user's media library views (folders).
  ///
  /// Returns a [QueryResult] of [BaseItemDto] representing library views.
  Future<QueryResult<BaseItemDto>> getViews() async {
    assert(userId != null, 'userId is required for getViews');

    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/Users/$userId/Views',
        queryParameters: const {'IncludeExternalContent': true},
      );

      if (response.data == null) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      final data = response.data!;
      final items = (data['Items'] as List<dynamic>? ?? [])
          .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList();
      final totalCount = data['TotalRecordCount'] as int? ?? items.length;

      return QueryResult<BaseItemDto>(
        items: items,
        totalRecordCount: totalCount,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Gets the latest added media items.
  ///
  /// [parentId] the parent folder/library ID.
  /// [limit] maximum number of items to return (default: 20).
  ///
  /// Returns a [QueryResult] of [BaseItemDto].
  Future<QueryResult<BaseItemDto>> getLatestItems({
    String? parentId,
    int limit = 20,
  }) async {
    assert(userId != null, 'userId is required for getLatestItems');

    try {
      final response = await dio.get<dynamic>(
        '/Users/$userId/Items/Latest',
        queryParameters: <String, dynamic>{
          if (parentId != null) 'ParentId': parentId,
          'Limit': limit,
        }..removeWhere((key, value) => value == null),
      );

      if (response.data == null) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      // /Items/Latest returns a direct array, not a QueryResult wrapper
      final List<dynamic> rawItems;
      if (response.data is List) {
        rawItems = response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        rawItems = (response.data as Map<String, dynamic>)['Items'] as List<dynamic>? ?? [];
      } else {
        rawItems = [];
      }

      final items = rawItems
          .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList();

      return QueryResult<BaseItemDto>(
        items: items,
        totalRecordCount: items.length,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Gets the "Continue Watching" list (next up episodes).
  ///
  /// [limit] maximum number of items to return (default: 24).
  /// [fields] additional fields to include.
  ///
  /// Returns a [QueryResult] of [BaseItemDto].
  Future<QueryResult<BaseItemDto>> getContinueWatching({
    int limit = 24,
    String? fields,
  }) async {
    assert(userId != null, 'userId is required for getContinueWatching');

    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/Shows/NextUp',
        queryParameters: <String, dynamic>{
          'UserId': userId,
          'Limit': limit,
          if (fields != null) 'Fields': fields,
        }..removeWhere((key, value) => value == null),
      );

      if (response.data == null) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      final data = response.data!;
      final items = (data['Items'] as List<dynamic>? ?? [])
          .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList();
      final totalCount = data['TotalRecordCount'] as int? ?? items.length;

      return QueryResult<BaseItemDto>(
        items: items,
        totalRecordCount: totalCount,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Gets resumable (continue watching) TV series.
  ///
  /// 实现逻辑：
  /// 1. 先请求继续观看的单集（Episode + IsResumable）
  /// 2. 从单集中提取 seriesId，按系列去重
  /// 3. 返回去重后的系列列表（以 Episode 中的 seriesName 作为显示名称）
  ///
  /// [limit] maximum number of series to return (default: 20).
  ///
  /// Returns a [QueryResult] of [BaseItemDto] representing unique series.
  Future<QueryResult<BaseItemDto>> getResumableSeries({int limit = 20}) async {
    assert(userId != null, 'userId is required for getResumableSeries');

    try {
      // 第一步：获取继续观看的单集
      final response = await dio.get<Map<String, dynamic>>(
        '/Users/$userId/Items',
        queryParameters: <String, dynamic>{
          'Filters': 'IsResumable',
          'IncludeItemTypes': 'Episode',
          'Limit': limit * 3, // 多取一些以便去重后仍有足够数据
          'SortBy': 'DatePlayed',
          'SortOrder': 'Descending',
          'Fields': 'PrimaryImageAspectRatio,UserData,Genres,Overview,ProductionYear,RunTimeTicks,SeriesName,SeasonName,IndexNumber,ParentIndexNumber,ProviderIds,Studios',
          'Recursive': true,
          'EnableTotalRecordCount': true,
        },
      );

      if (response.data == null) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      final data = response.data!;
      final episodes = (data['Items'] as List<dynamic>? ?? [])
          .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList();

      // 第二步：按 seriesId 去重，保留最近观看的一集信息
      final seenSeriesIds = <String>{};
      final uniqueSeries = <BaseItemDto>[];

      for (final episode in episodes) {
        final sid = episode.seriesId;
        if (sid == null || sid.isEmpty) continue;
        if (seenSeriesIds.contains(sid)) continue;

        seenSeriesIds.add(sid);
        // 构造一个"Series"对象用于展示（id=seriesId, name=seriesName）
        uniqueSeries.add(
          BaseItemDto(
            id: sid,
            name: episode.seriesName ?? episode.name ?? 'Unknown Series',
            type: 'Series',
            seriesId: sid,
            seriesName: episode.seriesName,
            userData: episode.userData,
            imageTags: episode.imageTags,
            productionYear: episode.productionYear,
          ),
        );

        if (uniqueSeries.length >= limit) break;
      }

      return QueryResult<BaseItemDto>(
        items: uniqueSeries,
        totalRecordCount: uniqueSeries.length,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Gets resumable (continue watching) movies.
  ///
  /// Uses `/Users/{userId}/Items?Filters=IsResumable&IncludeItemTypes=Movie`
  /// to return movies that the user has started watching but not finished.
  ///
  /// [limit] maximum number of items to return (default: 20).
  ///
  /// Returns a [QueryResult] of [BaseItemDto].
  Future<QueryResult<BaseItemDto>> getResumableMovies({int limit = 20}) async {
    assert(userId != null, 'userId is required for getResumableMovies');

    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/Users/$userId/Items',
        queryParameters: <String, dynamic>{
          'Filters': 'IsResumable',
          'IncludeItemTypes': 'Movie',
          'Limit': limit,
          'SortBy': 'DatePlayed',
          'SortOrder': 'Descending',
          'Fields': 'PrimaryImageAspectRatio,UserData,Genres,Overview,ProductionYear,RunTimeTicks,ProviderIds,Studios',
          'Recursive': true,
          'EnableTotalRecordCount': true,
        },
      );

      if (response.data == null) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      final data = response.data!;
      final items = (data['Items'] as List<dynamic>? ?? [])
          .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
          .toList();
      final totalCount = data['TotalRecordCount'] as int? ?? items.length;

      return QueryResult<BaseItemDto>(
        items: items,
        totalRecordCount: totalCount,
      );
    } on DioException {
      rethrow;
    }
  }

  /// Gets movie recommendations for the hero carousel.
  ///
  /// Uses `/Movies/Recommendations` to fetch personalized movie recommendations
  /// grouped by category (e.g., "Because You Watched", "Similar To Recently Played").
  ///
  /// Flattens all category items into a single deduplicated list suitable
  /// for the hero carousel display.
  ///
  /// [itemLimit] maximum items per category (default: 10).
  /// [categoryLimit] maximum number of categories (default: 3).
  /// [parentId] optional parent library ID to restrict recommendations.
  ///
  /// Returns a [QueryResult] of [BaseItemDto] containing recommended movies.
  Future<QueryResult<BaseItemDto>> getMovieRecommendations({
    int itemLimit = 10,
    int categoryLimit = 3,
    String? parentId,
  }) async {
    assert(userId != null, 'userId is required for getMovieRecommendations');

    try {
      final response = await dio.get<List<dynamic>>(
        '/Movies/Recommendations',
        queryParameters: <String, dynamic>{
          'UserId': userId,
          'ItemLimit': itemLimit,
          'CategoryLimit': categoryLimit,
          if (parentId != null) 'ParentId': parentId,
          'EnableImages': true,
          'EnableUserData': true,
          'Fields': 'PrimaryImageAspectRatio,Overview,ProductionYear',
        },
      );

      if (response.data == null || response.data!.isEmpty) {
        return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
      }

      // Flatten all recommendation categories into a single deduplicated list
      final seenIds = <String>{};
      final movies = <BaseItemDto>[];

      for (final category in response.data!) {
        final categoryMap = category as Map<String, dynamic>;
        final items = categoryMap['Items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final itemMap = item as Map<String, dynamic>;
          final movie = BaseItemDto.fromJson(itemMap);
          final id = movie.id;
          if (id == null || id.isEmpty) continue;
          if (seenIds.contains(id)) continue;

          seenIds.add(id);
          movies.add(movie);
        }
      }

      return QueryResult<BaseItemDto>(
        items: movies,
        totalRecordCount: movies.length,
      );
    } on DioException {
      rethrow;
    }
  }

  // ==================== PLAYBACK REPORTING ====================

  /// Reports that playback has started for a media item.
  ///
  /// [itemId] the unique identifier of the playing item.
  /// [mediaSourceId] the media source being played.
  /// [audioStreamIndex] selected audio stream index.
  /// [subtitleStreamIndex] selected subtitle stream index.
  /// [playMethod] playback method (DirectPlay, DirectStream, Transcode).
  ///
  /// Returns true if the report was successful.
  Future<bool> reportPlaybackStart(
    String itemId,
    String mediaSourceId, {
    int? audioStreamIndex,
    int? subtitleStreamIndex,
    String? playMethod,
  }) async {
    final uid = userId;
    if (uid == null || uid.isEmpty) {
      debugPrint('[EmbyApiService] reportPlaybackStart skipped: no userId');
      return false;
    }
    try {
      final response = await dio.post(
        '/Users/$uid/PlayingItems/$itemId',
        queryParameters: {
          'MediaSourceId': mediaSourceId,
          'CanSeek': true,
          if (audioStreamIndex != null) 'AudioStreamIndex': audioStreamIndex,
          if (subtitleStreamIndex != null)
            'SubtitleStreamIndex': subtitleStreamIndex,
          if (playMethod != null) 'PlayMethod': playMethod,
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      rethrow;
    }
  }

  /// Reports playback progress for a media item.
  ///
  /// [itemId] the unique identifier of the playing item.
  /// [mediaSourceId] the media source being played.
  /// [positionTicks] current playback position in ticks.
  /// [isPaused] whether playback is currently paused.
  /// [isMuted] whether audio is muted.
  /// [volumeLevel] current volume level (0-100).
  /// [audioStreamIndex] selected audio stream index.
  /// [subtitleStreamIndex] selected subtitle stream index.
  /// [playMethod] playback method (DirectPlay, DirectStream, Transcode).
  ///
  /// Returns true if the report was successful.
  Future<bool> reportPlaybackProgress(
    String itemId,
    String mediaSourceId, {
    required int positionTicks,
    bool? isPaused,
    bool? isMuted,
    int? volumeLevel,
    String? playMethod,
  }) async {
    final uid = userId;
    if (uid == null || uid.isEmpty) {
      debugPrint('[EmbyApiService] reportPlaybackProgress skipped: no userId');
      return false;
    }
    try {
      final response = await dio.post(
        '/Users/$uid/PlayingItems/$itemId/Progress',
        queryParameters: {
          'MediaSourceId': mediaSourceId,
          'PositionTicks': positionTicks,
          if (isPaused != null) 'IsPaused': isPaused,
          if (isMuted != null) 'IsMuted': isMuted,
          if (volumeLevel != null) 'VolumeLevel': volumeLevel,
          if (playMethod != null) 'PlayMethod': playMethod,
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      rethrow;
    }
  }

  /// Reports that playback has stopped for a media item.
  ///
  /// [itemId] the unique identifier of the stopped item.
  /// [mediaSourceId] the media source that was playing.
  /// [positionTicks] final playback position in ticks.
  /// [playedPercentage] percentage of content that was played (0.0-100.0).
  ///
  /// Returns true if the report was successful.
  Future<bool> reportPlaybackStopped(
    String itemId,
    String mediaSourceId, {
    required int positionTicks,
    double? playedPercentage,
  }) async {
    try {
      final response = await dio.post(
        '/Sessions/Playing/Stopped',
        data: {
          'ItemId': itemId,
          'MediaSourceId': mediaSourceId,
          'PositionTicks': positionTicks,
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException {
      rethrow;
    }
  }

  // ==================== HELPERS ====================

  /// Builds the Emby `Authorization` header value.
  ///
  /// Format:
  /// ```
  /// MediaBrowser Client="{client}", Device="{device}", DeviceId="{deviceId}", Version="{version}"
  /// ```
  static String? _buildEmbyAuthorizationHeader({
    String? clientName,
    String? deviceName,
    String? deviceId,
    String? version,
  }) {
    final effectiveClient = clientName?.trim().isNotEmpty == true ? clientName! : 'EmbyFlutter';
    final effectiveDevice = deviceName?.trim().isNotEmpty == true ? deviceName! : 'Unknown Device';
    final effectiveDeviceId = deviceId?.trim().isNotEmpty == true ? deviceId! : 'flutter-emby-device';
    final effectiveVersion = version?.trim().isNotEmpty == true ? version! : '1.0.0';

    return 'MediaBrowser '
        'Client="$effectiveClient", '
        'Device="$effectiveDevice", '
        'DeviceId="$effectiveDeviceId", '
        'Version="$effectiveVersion"';
  }
}

// ==================== PROVIDERS ====================

/// Provider for the authenticated user ID.
///
/// This provider reads the user ID from SharedPreferences and should
/// be overridden after successful authentication.
final userIdProvider = Provider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('emby_user_id');
});

/// Provider for the Emby API service instance.
///
/// Automatically picks up the authenticated user ID and configured Dio client.
///
/// Usage:
/// ```dart
/// final api = ref.watch(embyApiServiceProvider);
/// final items = await api.getItems();
/// ```
final embyApiServiceProvider = Provider<EmbyApiService>((ref) {
  final dio = ref.watch(dioClientProvider);
  final userId = ref.watch(userIdProvider);

  return EmbyApiService(
    dio: dio,
    userId: userId,
  );
});
