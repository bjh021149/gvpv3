/// 媒体数据仓库接口
/// 
/// 定义了与 Emby 媒体库交互的所有操作，包括获取项目列表、
/// 详情、相似推荐、剧集信息、播放信息等。
library;

import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/playback_info.dart';
import 'package:emby_client/core/models/query_result.dart';

/// 排序顺序枚举
enum SortOrder {
  /// 升序排列
  ascending('Ascending'),

  /// 降序排列
  descending('Descending');

  /// API 使用的字符串值
  final String apiValue;

  const SortOrder(this.apiValue);
}

/// 媒体仓库抽象接口
/// 
/// 遵循 Repository 模式，封装所有媒体数据的获取逻辑，
/// 使 ViewModel 层无需关心底层 API 实现细节。
abstract class MediaRepository {
  /// 获取媒体项目列表
  ///
  /// 参数:
  /// - [parentId]: 父文件夹/库 ID，用于筛选特定目录下的内容
  /// - [includeItemTypes]: 包含的项目类型（如 "Movie", "Series"）
  /// - [sortBy]: 排序字段（如 "SortName", "DateCreated"）
  /// - [sortOrder]: 排序顺序（升序/降序）
  /// - [startIndex]: 分页起始索引
  /// - [limit]: 每页数量限制
  /// - [searchTerm]: 搜索关键词
  ///
  /// 返回: 包含 [BaseItemDto] 列表的查询结果
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
  });

  /// 获取单个项目的详细信息
  ///
  /// 参数:
  /// - [itemId]: 媒体项目唯一标识符
  ///
  /// 返回: 项目详情 [BaseItemDto]
  ///
  /// 异常: 当项目不存在或网络请求失败时抛出异常
  Future<BaseItemDto> getItemDetail(String itemId);

  /// 获取电视剧（Series）的详细信息
  ///
  /// 参数:
  /// - [seriesId]: 电视剧系列唯一标识符
  ///
  /// 返回: 电视剧详情 [BaseItemDto]
  Future<BaseItemDto> getSeries(String seriesId);

  /// 获取与指定项目相似的推荐内容
  ///
  /// 参数:
  /// - [itemId]: 参考项目的 ID
  /// - [limit]: 返回结果数量上限，默认为 12
  ///
  /// 返回: 相似项目列表
  Future<QueryResult<BaseItemDto>> getSimilarItems(
    String itemId, {
    int limit = 12,
  });

  /// 获取剧集的所有季（Season）信息
  ///
  /// 参数:
  /// - [seriesId]: 剧集系列 ID
  ///
  /// 返回: 季列表
  Future<QueryResult<BaseItemDto>> getSeasons(String seriesId);

  /// 获取指定剧集的集（Episode）列表
  ///
  /// 参数:
  /// - [seriesId]: 剧集系列 ID
  /// - [seasonId]: 特定季的 ID，为 null 则返回所有集
  ///
  /// 返回: 集列表
  Future<QueryResult<BaseItemDto>> getEpisodes(
    String seriesId, {
    String? seasonId,
  });

  /// 获取媒体项目的播放信息
  ///
  /// 包含播放 URL、字幕轨道、音轨等必要信息。
  ///
  /// 参数:
  /// - [itemId]: 要播放的项目 ID
  ///
  /// 返回: [PlaybackInfo] 包含所有播放所需信息
  Future<PlaybackInfo> getPlaybackInfo(String itemId);

  /// 获取用户媒体库视图
  ///
  /// 返回用户有权限访问的所有媒体库的概览列表。
  Future<QueryResult<BaseItemDto>> getViews();

  /// 获取"继续观看"列表（下一集，仅电视剧）
  ///
  /// **已弃用**：请使用 [getResumableSeries] 和 [getResumableEpisodes]
  /// 以获取更符合"继续观看"语义的数据。
  ///
  /// 参数:
  /// - [limit]: 返回结果数量上限，默认为 20
  Future<QueryResult<BaseItemDto>> getContinueWatching({int limit = 20});

  /// 获取继续观看的电视剧系列
  ///
  /// 返回用户已开始观看但未完成的电视剧（Series 级别）。
  ///
  /// 参数:
  /// - [limit]: 返回结果数量上限，默认为 20
  Future<QueryResult<BaseItemDto>> getResumableSeries({int limit = 20});

  /// 获取继续观看的电影
  ///
  /// 返回用户已开始观看但未完成的电影（Movie 级别）。
  ///
  /// 参数:
  /// - [limit]: 返回结果数量上限，默认为 20
  Future<QueryResult<BaseItemDto>> getResumableMovies({int limit = 20});

  /// 获取文件夹/集合的子项目
  ///
  /// 用于获取 `isFolder: true` 的项目（如 CollectionFolder、Folder、Season）
  /// 内部的子项目。
  ///
  /// 参数:
  /// - [parentId]: 父文件夹/集合 ID
  /// - [includeItemTypes]: 过滤子项目类型（如 "Movie", "Series", "Episode"）
  /// - [recursive]: 是否递归获取子文件夹内容
  /// - [limit]: 返回结果数量上限
  Future<QueryResult<BaseItemDto>> getChildren(
    String parentId, {
    String? includeItemTypes,
    bool recursive = false,
    int? limit,
  });

  /// 获取电影推荐列表（用于 Hero Carousel）
  ///
  /// 返回个性化推荐电影，按分类扁平化为单一列表（已去重）。
  ///
  /// 参数:
  /// - [itemLimit]: 每个分类的推荐数量上限
  /// - [categoryLimit]: 分类数量上限
  /// - [parentId]: 可选，限定特定媒体库
  Future<QueryResult<BaseItemDto>> getMovieRecommendations({
    int itemLimit = 10,
    int categoryLimit = 3,
    String? parentId,
  });

  /// 获取最新添加的媒体项目
  ///
  /// 参数:
  /// - [parentId]: 父文件夹/库 ID，为 null 则查询所有库
  /// - [limit]: 返回结果数量上限，默认为 20
  Future<QueryResult<BaseItemDto>> getLatestItems({
    String? parentId,
    int limit = 20,
  });

  /// 获取制片公司详情
  ///
  /// Studio 在 Emby 中也是一种 Item，因此返回 [BaseItemDto]。
  /// 详情中包含 [imageTags]，可用于构建图片 URL。
  ///
  /// 参数:
  /// - [studioId]: Studio 的整数 ID（来自 [StudioDto.id]）
  Future<BaseItemDto> getStudioDetail(int studioId);

  /// 预加载详情页所需的全部数据到缓存。
  ///
  /// 根据项目类型决定加载策略：
  /// - **Movie**: item detail + similar items
  /// - **Series**: series detail + seasons + first season episodes + similar items
  ///
  /// 所有内部调用均走 cache-first 流程，缓存已存在时立即返回。
  /// 调用方无需 await，不会阻塞 UI。
  ///
  /// [onSeriesLoaded] / [onSeasonsLoaded] / [onEpisodesLoaded] 在每个阶段
  /// 完成后调用，可用于更新 UI state。
  Future<void> getPageDetail(
    String itemId, {
    required String itemType,
    void Function(BaseItemDto series)? onSeriesLoaded,
    void Function(List<BaseItemDto> seasons)? onSeasonsLoaded,
    void Function(List<BaseItemDto> episodes)? onEpisodesLoaded,
  });
}
