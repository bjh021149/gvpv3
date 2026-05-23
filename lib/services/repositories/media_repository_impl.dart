/// 媒体数据仓库实现
///
/// 通过 [EmbyApiService] 与 Emby 服务器通信，将原始 API 响应
/// 转换为应用层使用的领域模型。
///
/// **缓存策略**：Repository 层实现"缓存优先"（cache-first）：
/// 1. 生成确定性 cache key
/// 2. 先读 [EmbyCache] → 命中则直接返回
/// 3. 未命中 → 请求 API → 写入缓存 → 返回数据
/// 4. [getPlaybackInfo] 不走缓存（播放 URL 含临时 token）
library;

import 'package:emby_client/core/api/emby_api_service.dart';
import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/playback_info.dart';
import 'package:emby_client/core/models/query_result.dart';
import 'package:emby_client/services/cache/cache.dart';
import 'package:emby_client/services/repositories/media_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// MediaRepository 的 Riverpod Provider
///
/// 通过依赖注入自动获取 [EmbyApiService] 和 [EmbyCache] 实例，
/// 供 UI 层和 ViewModel 层使用。
///
/// 使用示例:
/// ```dart
/// final mediaRepo = ref.watch(mediaRepositoryProvider);
/// final items = await mediaRepo.getItems(limit: 20);
/// ```
final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepositoryImpl(
    ref.watch(embyApiServiceProvider),
    ref.watch(embyCacheProvider),
  );
});

/// [MediaRepository] 的具体实现类
///
/// 封装所有与 Emby API 的交互逻辑，包括:
/// - 查询参数构建与编码
/// - API 响应到领域模型的映射
/// - 错误转换与统一异常处理
/// - **Hive 缓存读写（cache-first）**
class MediaRepositoryImpl implements MediaRepository {
  /// Emby API 服务实例
  final EmbyApiService _apiService;

  /// Hive 缓存实例
  final EmbyCache _cache;

  /// 列表缓存默认最大存活时间
  static const _defaultListMaxAge = Duration(minutes: 5);

  /// 继续观看类列表（UserData 频繁变化）使用更短过期时间
  static const _resumableListMaxAge = Duration(seconds: 30);

  /// 创建仓库实例
  ///
  /// [apiService] 必须为非 null 的 [EmbyApiService] 实例
  /// [cache] 必须为非 null 且已初始化的 [EmbyCache] 实例
  const MediaRepositoryImpl(this._apiService, this._cache);

  // ── 通用缓存辅助方法 ─────────────────────────────────────

  /// 尝试从缓存读取列表，未命中则通过 [fetch] 获取并写入缓存。
  Future<QueryResult<BaseItemDto>> _cachedList({
    required String key,
    required Future<QueryResult<BaseItemDto>> Function() fetch,
    Duration maxAge = _defaultListMaxAge,
    bool includeHeavyFields = false,
    String? sortBy,
  }) async {
    final cached = _cache.getList(
      key,
      includeHeavyFields: includeHeavyFields,
    );
    if (cached != null) return cached;

    final result = await fetch();
    await _cache.putItems(result.items);
    await _cache.putList(
      key: key,
      items: result.items,
      totalRecordCount: result.totalRecordCount,
      sortBy: sortBy,
      maxAge: maxAge,
    );
    return result;
  }

  /// 尝试从缓存读取单条详情，未命中则通过 [fetch] 获取并写入缓存。
  ///
  /// 如果缓存命中，先返回缓存数据（快速响应），然后异步调用 [fetch]
  /// 获取最新数据并更新缓存。UI 可通过 [EmbyCache.watchItem] 监听
  /// 缓存变化，自动刷新显示。
  Future<BaseItemDto> _cachedItem({
    required String itemId,
    required Future<BaseItemDto> Function() fetch,
  }) async {
    final cached = _cache.getItem(itemId, includeHeavyFields: true);
    if (cached != null) {
      // 异步刷新缓存（不阻塞返回）
      fetch().then((result) async {
        await _cache.putItem(result);
      });
      return cached;
    }

    final result = await fetch();
    await _cache.putItem(result);
    return result;
  }

  // ── MediaRepository 实现 ─────────────────────────────────

  @override
  Future<QueryResult<BaseItemDto>> getItems({
    String? parentId,
    String? includeItemTypes,
    String? excludeItemTypes,
    String? sortBy,
    SortOrder? sortOrder,
    int? startIndex,
    int? limit,
    String? searchTerm,
    bool? recursive,
    List<String>? genreIds,
    List<String>? studioIds,
    List<String>? genres,
  }) async {
    final key = CacheKeys.items(
      parentId: parentId,
      includeItemTypes: includeItemTypes,
      excludeItemTypes: excludeItemTypes,
      sortBy: sortBy,
      startIndex: startIndex,
      limit: limit,
      genres: genres,
      studioIds: studioIds,
    );

    return _cachedList(
      key: key,
      sortBy: sortBy,
      fetch: () => _apiService.getItems(
        parentId: parentId,
        includeItemTypes: includeItemTypes,
        excludeItemTypes: excludeItemTypes,
        sortBy: sortBy,
        sortOrder: sortOrder == SortOrder.ascending,
        startIndex: startIndex,
        limit: limit,
        searchTerm: searchTerm,
        recursive: recursive,
        genreIds: genreIds,
        studioIds: studioIds,
        genres: genres,
      ),
    );
  }

  @override
  Future<BaseItemDto> getItemDetail(String itemId) async {
    return _cachedItem(
      itemId: itemId,
      fetch: () => _apiService.getItemDetail(
        itemId,
        fields: 'PrimaryImageAspectRatio,UserData,Genres,Overview,ProductionYear,RunTimeTicks,ProviderIds,Studios,MediaSources,People,OfficialRating,CommunityRating,CriticRating,Path,ImageTags,BackdropImageTags',
      ),
    );
  }

  @override
  Future<BaseItemDto> getSeries(String seriesId) async {
    return _cachedItem(
      itemId: seriesId,
      fetch: () => _apiService.getSeries(seriesId),
    );
  }

  @override
  Future<QueryResult<BaseItemDto>> getSimilarItems(
    String itemId, {
    int limit = 12,
  }) async {
    final key = CacheKeys.similarItems(itemId);

    return _cachedList(
      key: key,
      fetch: () => _apiService.getSimilarItems(itemId, limit: limit),
    );
  }

  @override
  Future<QueryResult<BaseItemDto>> getSeasons(String seriesId) async {
    final key = CacheKeys.seasons(seriesId);

    return _cachedList(
      key: key,
      fetch: () => _apiService.getSeasons(
        seriesId,
        fields: 'PrimaryImageAspectRatio,ImageTags',
      ),
    );
  }

  @override
  Future<QueryResult<BaseItemDto>> getEpisodes(
    String seriesId, {
    String? seasonId,
  }) async {
    final key = CacheKeys.episodes(seriesId, seasonId);

    return _cachedList(
      key: key,
      fetch: () => _apiService.getEpisodes(
        seriesId,
        seasonId: seasonId,
        fields: 'PrimaryImageAspectRatio,ImageTags',
      ),
    );
  }

  @override
  Future<PlaybackInfo> getPlaybackInfo(String itemId) async {
    // PlaybackInfo 包含临时播放 URL，不走缓存
    return _apiService.getPlaybackInfo(itemId);
  }

  @override
  Future<QueryResult<BaseItemDto>> getViews() async {
    final key = CacheKeys.views();

    return _cachedList(
      key: key,
      fetch: () => _apiService.getViews(),
    );
  }

  @override
  Future<QueryResult<BaseItemDto>> getContinueWatching({int limit = 20}) async {
    final key = CacheKeys.continueWatching();

    return _cachedList(
      key: key,
      maxAge: _resumableListMaxAge,
      fetch: () => _apiService.getContinueWatching(limit: limit),
    );
  }

  @override
  Future<QueryResult<BaseItemDto>> getResumableSeries({int limit = 20}) async {
    final key = CacheKeys.resumableSeries();

    return _cachedList(
      key: key,
      maxAge: _resumableListMaxAge,
      fetch: () => _apiService.getResumableSeries(limit: limit),
    );
  }

  @override
  Future<QueryResult<BaseItemDto>> getResumableMovies({int limit = 20}) async {
    final key = CacheKeys.resumableMovies();

    return _cachedList(
      key: key,
      maxAge: _resumableListMaxAge,
      fetch: () => _apiService.getResumableMovies(limit: limit),
    );
  }

  @override
  Future<QueryResult<BaseItemDto>> getLatestItems({
    String? parentId,
    int limit = 20,
  }) async {
    final key = CacheKeys.latestItems(parentId);

    return _cachedList(
      key: key,
      fetch: () => _apiService.getLatestItems(
        parentId: parentId,
        limit: limit,
      ),
    );
  }

  @override
  Future<QueryResult<BaseItemDto>> getChildren(
    String parentId, {
    String? includeItemTypes,
    bool recursive = false,
    int? limit,
  }) async {
    final key = CacheKeys.children(
      parentId,
      includeItemTypes: includeItemTypes,
    );

    return _cachedList(
      key: key,
      fetch: () => _apiService.getChildren(
        parentId,
        includeItemTypes: includeItemTypes,
        recursive: recursive,
        limit: limit,
      ),
    );
  }

  @override
  Future<QueryResult<BaseItemDto>> getMovieRecommendations({
    int itemLimit = 10,
    int categoryLimit = 3,
    String? parentId,
  }) async {
    final key = CacheKeys.movieRecommendations();

    return _cachedList(
      key: key,
      fetch: () => _apiService.getMovieRecommendations(
        itemLimit: itemLimit,
        categoryLimit: categoryLimit,
        parentId: parentId,
      ),
    );
  }

  @override
  Future<BaseItemDto> getStudioDetail(int studioId) async {
    return _apiService.getStudioDetail(studioId);
  }

  @override
  Future<void> getPageDetail(
    String itemId, {
    required String itemType,
    void Function(BaseItemDto series)? onSeriesLoaded,
    void Function(List<BaseItemDto> seasons)? onSeasonsLoaded,
    void Function(List<BaseItemDto> episodes)? onEpisodesLoaded,
  }) async {
    if (itemType == 'Series') {
      // Step 1: Series (cache-first)
      final series = await getSeries(itemId);
      onSeriesLoaded?.call(series);

      // Step 2: Seasons (cache-first)
      final seasonsResult = await getSeasons(itemId);
      onSeasonsLoaded?.call(seasonsResult.items);

      // Step 3: Episodes (cache-first, first season)
      if (seasonsResult.items.isNotEmpty) {
        final firstSeasonId = seasonsResult.items.first.id;
        if (firstSeasonId != null) {
          final episodesResult = await getEpisodes(itemId, seasonId: firstSeasonId);
          onEpisodesLoaded?.call(episodesResult.items);
        }
      }

      await getSimilarItems(itemId);
    } else {
      await getItemDetail(itemId);
      await getSimilarItems(itemId);
    }
  }
}
