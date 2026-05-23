import 'dart:async';

import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/query_result.dart';
import 'package:emby_client/services/cache/cache_keys.dart';
import 'package:emby_client/services/cache/emby_cache.dart';
import 'package:emby_client/services/repositories/media_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the detail page ViewModel.
///
/// Manages list-level data that does not fit the single-item cache model:
/// - Similar items
/// - Seasons & episodes
/// - Studio details (fetched individually per studio)
///
/// Core item data (title, overview, people, genres) is consumed directly
/// by section components via atomic cache providers (e.g. [itemCoreProvider],
/// [peopleProvider], [genresProvider]) and does NOT flow through this ViewModel.
final detailViewModelProvider =
    AsyncNotifierProvider.family<DetailViewModel, DetailState, String>(
  DetailViewModel.new,
);

/// State for list-level detail page data.
class DetailState {
  /// List of similar/recommended items.
  final List<BaseItemDto> similarItems;

  /// List of seasons (for series type).
  final List<BaseItemDto> seasons;

  /// List of episodes for the selected season.
  final List<BaseItemDto> episodes;

  /// Currently selected season ID.
  final String? selectedSeasonId;

  /// Studio details with images (fetched via [getStudioDetail]).
  final List<BaseItemDto> studioDetails;

  const DetailState({
    this.similarItems = const [],
    this.seasons = const [],
    this.episodes = const [],
    this.selectedSeasonId,
    this.studioDetails = const [],
  });

  DetailState copyWith({
    List<BaseItemDto>? similarItems,
    List<BaseItemDto>? seasons,
    List<BaseItemDto>? episodes,
    String? selectedSeasonId,
    List<BaseItemDto>? studioDetails,
  }) {
    return DetailState(
      similarItems: similarItems ?? this.similarItems,
      seasons: seasons ?? this.seasons,
      episodes: episodes ?? this.episodes,
      selectedSeasonId: selectedSeasonId ?? this.selectedSeasonId,
      studioDetails: studioDetails ?? this.studioDetails,
    );
  }
}

/// ViewModel for list-level detail data.
///
/// Uses hive_ce [Box.watch] to automatically refresh UI when cache updates.
/// The loading flow is:
/// 1. [build] returns cached data immediately (cache-first via [_cachedItem/_cachedList])
/// 2. Sets up [watchList] listeners for seasons/episodes
/// 3. Triggers background refresh via [getPageDetail] with callbacks
class DetailViewModel extends AsyncNotifier<DetailState> {
  final String itemId;

  DetailViewModel(this.itemId);

  StreamSubscription<QueryResult<BaseItemDto>?>? _seasonsSub;
  StreamSubscription<QueryResult<BaseItemDto>?>? _episodesSub;

  @override
  Future<DetailState> build() async {
    final mediaRepo = ref.read(mediaRepositoryProvider);
    final cache = ref.read(embyCacheProvider);

    // 1. Cache-first load: these return immediately if cached
    final item = await mediaRepo.getSeries(itemId);
    final similarResult = await mediaRepo.getSimilarItems(itemId, limit: 12);

    List<BaseItemDto> seasons = [];
    List<BaseItemDto> episodes = [];
    String? selectedSeasonId;
    if (item.type == 'Series') {
      final seasonsResult = await mediaRepo.getSeasons(itemId);
      seasons = seasonsResult.items;
      if (seasons.isNotEmpty) {
        selectedSeasonId = seasons.first.id;
        final episodesResult = await mediaRepo.getEpisodes(
          itemId,
          seasonId: selectedSeasonId,
        );
        episodes = episodesResult.items;
      }

      // 2. Set up hive_ce watch listeners for auto-refresh
      _watchSeasons(cache);
      if (selectedSeasonId != null) {
        _watchEpisodes(cache, selectedSeasonId);
      }
    }

    final studioDetails = await _loadStudioDetails(item);

    // 3. Background refresh with callback chain: Series → Seasons → Episodes
    unawaited(
      mediaRepo.getPageDetail(
        itemId,
        itemType: item.type ?? '',
        onSeriesLoaded: (_) {
          // Series core data flows through itemFullProvider (atomic cache),
          // no need to manually update state here.
        },
        onSeasonsLoaded: (_) {
          // Cache updated → watchList stream emits → state auto-refreshes
        },
        onEpisodesLoaded: (_) {
          // Cache updated → watchList stream emits → state auto-refreshes
        },
      ),
    );

    ref.onDispose(() {
      _seasonsSub?.cancel();
      _episodesSub?.cancel();
    });

    return DetailState(
      similarItems: similarResult.items,
      seasons: seasons,
      episodes: episodes,
      selectedSeasonId: selectedSeasonId,
      studioDetails: studioDetails,
    );
  }

  /// Watches the seasons list cache for changes.
  void _watchSeasons(EmbyCache cache) {
    _seasonsSub?.cancel();
    _seasonsSub = cache.watchList(CacheKeys.seasons(itemId)).listen((result) {
      final current = state.value;
      if (current != null && result != null) {
        state = AsyncValue.data(current.copyWith(seasons: result.items));
      }
    });
  }

  /// Watches the episodes list cache for the given [seasonId].
  void _watchEpisodes(EmbyCache cache, String seasonId) {
    _episodesSub?.cancel();
    _episodesSub = cache
        .watchList(CacheKeys.episodes(itemId, seasonId))
        .listen((result) {
      final current = state.value;
      if (current != null && result != null) {
        state = AsyncValue.data(current.copyWith(episodes: result.items));
      }
    });
  }

  /// Loads studio details for the given [item].
  Future<List<BaseItemDto>> _loadStudioDetails(BaseItemDto item) async {
    final studios = item.studios;
    if (studios == null || studios.isEmpty) return const [];

    final current = state.value;
    final loadedIds = current?.studioDetails.map((s) => s.id).toSet() ?? {};
    final newDetails = List<BaseItemDto>.from(current?.studioDetails ?? []);
    final mediaRepo = ref.read(mediaRepositoryProvider);

    for (final studio in studios) {
      final studioId = studio.id;
      if (studioId != null && !loadedIds.contains(studioId.toString())) {
        try {
          final detail = await mediaRepo.getStudioDetail(studioId);
          newDetails.add(detail);
        } catch (_) {
          // Ignore studio detail fetch errors
        }
      }
    }

    final latest = state.value;
    if (latest != null && newDetails.length != latest.studioDetails.length) {
      state = AsyncValue.data(latest.copyWith(studioDetails: newDetails));
    }

    return newDetails;
  }

  /// Selects a season and loads its episodes.
  Future<void> selectSeason(String seasonId) async {
    final current = state.value;
    if (current == null) return;

    final mediaRepo = ref.read(mediaRepositoryProvider);
    final cache = ref.read(embyCacheProvider);

    // Switch the episodes watcher to the new season
    _watchEpisodes(cache, seasonId);

    final episodesResult = await mediaRepo.getEpisodes(
      itemId,
      seasonId: seasonId,
    );

    state = AsyncValue.data(
      current.copyWith(
        episodes: episodesResult.items,
        selectedSeasonId: seasonId,
      ),
    );
  }
}
