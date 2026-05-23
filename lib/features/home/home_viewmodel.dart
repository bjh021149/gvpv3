import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/query_result.dart';
import 'package:emby_client/services/repositories/media_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// 媒体库 Section 数据模型
// =============================================================================

/// 单个媒体库及其最新项目的数据组合。
///
/// 用于在首页展示"每个媒体库最新添加"的 section。
class LibrarySection {
  /// 媒体库本身（如"电影"、"电视剧"等 CollectionFolder）
  final BaseItemDto library;

  /// 该媒体库最新添加的项目列表
  final List<BaseItemDto> latestItems;

  const LibrarySection({
    required this.library,
    required this.latestItems,
  });
}

/// 计算在指定可用宽度下应获取的卡片数量。
///
/// [availableWidth] 可用于显示卡片的总宽度（已扣除 padding）。
/// [cardWidth] 单个卡片的宽度。
/// [cardSpacing] 卡片之间的间距。
/// [bufferCount] 额外缓冲数量，用于支持水平滚动时显示下一张卡片的一部分。
///
/// 返回应请求的 API limit 数量（至少为 1，不超过 maxLimit）。
int calculateItemLimit({
  required double availableWidth,
  required double cardWidth,
  double cardSpacing = 12.0,
  int bufferCount = 2,
  int maxLimit = 20,
}) {
  if (availableWidth <= 0 || cardWidth <= 0) return maxLimit;
  final visibleCount = (availableWidth / (cardWidth + cardSpacing)).floor();
  final limit = visibleCount + bufferCount;
  return limit.clamp(1, maxLimit);
}

// =============================================================================
// 拆分后的细粒度 Providers（解决 P1-1：HomeState 整页重建问题）
// =============================================================================

/// 内部 Provider：获取用户视图列表
///
/// carousel 和 recentlyAdded 都依赖 views，抽离出来避免重复请求。
final _homeViewsProvider = FutureProvider.autoDispose<QueryResult<BaseItemDto>>(
  (ref) async {
    final repo = ref.read(mediaRepositoryProvider);
    return await repo.getViews();
  },
);

/// 内部 Provider：获取最新条目（limit: 10）
///
/// 被 carouselItemsProvider 和 recentlyAddedProvider 共享，确保只请求一次 API。
final _latestItemsProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) async {
    final views = await ref.watch(_homeViewsProvider.future);
    if (views.items.isEmpty) return [];
    final result = await ref.read(mediaRepositoryProvider).getLatestItems(
      parentId: views.items.first.id,
      limit: 10,
    );
    return result.items;
  },
);

/// Hero carousel 数据源 — 推荐电影（替换原来的最新条目）
final carouselItemsProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) async {
    final repo = ref.read(mediaRepositoryProvider);
    final result = await repo.getMovieRecommendations(
      itemLimit: 10,
      categoryLimit: 3,
    );
    return result.items.take(5).toList();
  },
);

/// 继续观看的电视剧系列
final resumableSeriesProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) async {
    final repo = ref.read(mediaRepositoryProvider);
    final result = await repo.getResumableSeries(limit: 10);
    return result.items;
  },
);

/// 继续观看的电影
final resumableMoviesProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) async {
    final repo = ref.read(mediaRepositoryProvider);
    final result = await repo.getResumableMovies(limit: 10);
    return result.items;
  },
);

/// 继续观看数据源（兼容层，使用旧的 NextUp API）
@Deprecated('Use resumableSeriesProvider or resumableEpisodesProvider instead')
final continueWatchingProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) async {
    final repo = ref.read(mediaRepositoryProvider);
    final result = await repo.getContinueWatching(limit: 10);
    return result.items;
  },
);

/// 最近添加数据源
///
/// **已弃用**：请使用 [librarySectionsProvider] 获取按媒体库分组的新增内容。
@Deprecated('Use librarySectionsProvider for per-library latest items')
final recentlyAddedProvider = FutureProvider.autoDispose<List<BaseItemDto>>(
  (ref) async {
    final items = await ref.watch(_latestItemsProvider.future);
    return items;
  },
);

/// 获取所有媒体库及其最新添加的项目。
///
/// 工作流程：
/// 1. 先调用 [getViews] 获取用户所有媒体库（CollectionFolder）
/// 2. 对每个媒体库并发调用 [getLatestItems] 获取最新项目
/// 3. 返回按媒体库分组的 [LibrarySection] 列表
///
/// UI 层应根据屏幕宽度计算 [calculateItemLimit] 后切片展示，
/// 此处固定获取上限 20 条以覆盖所有屏幕尺寸需求。
final librarySectionsProvider = FutureProvider.autoDispose<List<LibrarySection>>(
  (ref) async {
    final repo = ref.read(mediaRepositoryProvider);
    final viewsResult = await repo.getViews();

    if (viewsResult.items.isEmpty) return [];

    // 并发获取每个媒体库的最新项目
    final futures = viewsResult.items.where((view) {
      // 过滤掉非内容型媒体库（如播放列表、合集等，可选）
      // 保留 CollectionFolder 和手动创建的文件夹
      return view.collectionType != null;
    }).map((view) async {
      final result = await repo.getLatestItems(
        parentId: view.id,
        limit: 20,
      );
      return LibrarySection(
        library: view,
        latestItems: result.items,
      );
    });

    final sections = await Future.wait(futures);

    // 过滤掉没有内容的媒体库
    return sections.where((s) => s.latestItems.isNotEmpty).toList();
  },
);

// =============================================================================
// 兼容层：保留 HomeState / HomeViewModel 供旧代码过渡使用
// =============================================================================

/// Provider for the home view model.
///
/// **已弃用**：请直接使用 [carouselItemsProvider]、[continueWatchingProvider]、
/// [recentlyAddedProvider] 以获取更细粒度的状态更新。
final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);

/// Immutable state object for the home screen.
///
/// **已弃用**：新的细粒度 Provider 不再使用此聚合状态。
class HomeState {
  final List<BaseItemDto> carouselItems;
  final List<BaseItemDto> continueWatching;
  final List<BaseItemDto> recentlyAdded;
  final bool isLoadingMore;

  const HomeState({
    this.carouselItems = const [],
    this.continueWatching = const [],
    this.recentlyAdded = const [],
    this.isLoadingMore = false,
  });

  HomeState copyWith({
    List<BaseItemDto>? carouselItems,
    List<BaseItemDto>? continueWatching,
    List<BaseItemDto>? recentlyAdded,
    bool? isLoadingMore,
  }) {
    return HomeState(
      carouselItems: carouselItems ?? this.carouselItems,
      continueWatching: continueWatching ?? this.continueWatching,
      recentlyAdded: recentlyAdded ?? this.recentlyAdded,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// View model that manages the home screen state.
///
/// **已弃用**：请使用 Riverpod 的 `ref.invalidate(provider)` 模式刷新数据。
class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final mediaRepo = ref.read(mediaRepositoryProvider);

    final QueryResult<BaseItemDto> views;
    final QueryResult<BaseItemDto> continueWatching;
    try {
      views = await mediaRepo.getViews();
      continueWatching = await mediaRepo.getContinueWatching(limit: 10);
    } on Exception catch (e, st) {
      throw AsyncError(e, st);
    }

    List<BaseItemDto> latestItems = [];
    if (views.items.isNotEmpty) {
      try {
        final result = await mediaRepo.getLatestItems(
          parentId: views.items.first.id,
          limit: 10,
        );
        latestItems = result.items;
      } on Exception {
        latestItems = [];
      }
    }

    return HomeState(
      carouselItems: latestItems.take(5).toList(),
      continueWatching: continueWatching.items,
      recentlyAdded: latestItems,
    );
  }

  /// Refresh all home data.
  ///
  /// **已弃用**：新代码应使用 `ref.invalidate(carouselItemsProvider)` 等。
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
