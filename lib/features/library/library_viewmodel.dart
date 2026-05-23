import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/services/repositories/media_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the library view model.
/// Accepts an optional parentId to browse into a specific library.
final libraryViewModelProvider =
    AsyncNotifierProvider.family<LibraryViewModel, LibraryState, String?>(
  LibraryViewModel.new,
);

/// Sort options available in the library.
enum SortOption {
  name('名称', 'SortName'),
  dateAdded('添加时间', 'DateCreated'),
  rating('评分', 'CommunityRating'),
  year('年份', 'ProductionYear');

  final String label;
  final String sortBy;

  const SortOption(this.label, this.sortBy);
}

/// View mode for displaying library items.
enum ViewMode {
  grid('网格视图'),
  list('列表视图');

  final String label;

  const ViewMode(this.label);
}

/// Immutable state object for the library screen.
class LibraryState {
  final List<BaseItemDto> items;
  final List<BaseItemDto> views;
  final bool isLoadingMore;
  final SortOption currentSort;
  final ViewMode viewMode;
  final String? parentId;
  final int currentPage;
  final int totalRecordCount;

  /// Item type filter derived from the parent collection type.
  final String? includeItemTypes;

  /// Item type exclusion filter derived from the parent collection type.
  final String? excludeItemTypes;

  /// Selected genre filter (genre name, used with Emby `Genres` param).
  final String? selectedGenre;

  /// Selected studio filter.
  final String? selectedStudioId;

  /// Available genres fetched from the API for this library.
  final List<String> availableGenres;

  /// Available studios fetched from the API for this library.
  /// Each entry is (studioId, studioName).
  final List<MapEntry<String, String>> availableStudios;

  const LibraryState({
    this.items = const [],
    this.views = const [],
    this.isLoadingMore = false,
    this.currentSort = SortOption.name,
    this.viewMode = ViewMode.grid,
    this.parentId,
    this.currentPage = 0,
    this.totalRecordCount = 0,
    this.includeItemTypes,
    this.excludeItemTypes,
    this.selectedGenre,
    this.selectedStudioId,
    this.availableGenres = const [],
    this.availableStudios = const [],
  });

  /// Whether there are more items available to load.
  bool get hasMore => items.length < totalRecordCount;

  LibraryState copyWith({
    List<BaseItemDto>? items,
    List<BaseItemDto>? views,
    bool? isLoadingMore,
    SortOption? currentSort,
    ViewMode? viewMode,
    String? parentId,
    int? currentPage,
    int? totalRecordCount,
    String? includeItemTypes,
    String? excludeItemTypes,
    String? selectedGenre,
    String? selectedStudioId,
    List<String>? availableGenres,
    List<MapEntry<String, String>>? availableStudios,
  }) {
    return LibraryState(
      items: items ?? this.items,
      views: views ?? this.views,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentSort: currentSort ?? this.currentSort,
      viewMode: viewMode ?? this.viewMode,
      parentId: parentId ?? this.parentId,
      currentPage: currentPage ?? this.currentPage,
      totalRecordCount: totalRecordCount ?? this.totalRecordCount,
      includeItemTypes: includeItemTypes ?? this.includeItemTypes,
      excludeItemTypes: excludeItemTypes ?? this.excludeItemTypes,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      selectedStudioId: selectedStudioId ?? this.selectedStudioId,
      availableGenres: availableGenres ?? this.availableGenres,
      availableStudios: availableStudios ?? this.availableStudios,
    );
  }
}

/// View model that manages the library screen state.
class LibraryViewModel extends AsyncNotifier<LibraryState> {
  static const int _pageSize = 50;

  /// The parent ID passed as the family argument.
  final String? parentId;

  LibraryViewModel(this.parentId);

  @override
  Future<LibraryState> build() async {
    final mediaRepo = ref.read(mediaRepositoryProvider);

    // Fetch available views
    final viewsResult = await mediaRepo.getViews();

    // Determine item type filters based on parent collection type
    String? includeItemTypes;
    String? excludeItemTypes;
    if (parentId != null) {
      final parent = await mediaRepo.getItemDetail(parentId!);
      final filters = _resolveTypeFilters(parent.collectionType);
      includeItemTypes = filters.includeItemTypes;
      excludeItemTypes = filters.excludeItemTypes;
    }

    // Fetch items within the parent library
    List<BaseItemDto> items = [];
    int totalCount = 0;
    List<String> availableGenres = [];
    List<MapEntry<String, String>> availableStudios = [];
    if (parentId != null) {
      final itemsResult = await mediaRepo.getItems(
        parentId: parentId,
        includeItemTypes: includeItemTypes,
        excludeItemTypes: excludeItemTypes,
        limit: _pageSize,
        sortBy: SortOption.name.sortBy,
        recursive: true,
      );
      items = itemsResult.items;
      totalCount = itemsResult.totalRecordCount;

      // Fetch all available genres and studios for this library
      final genreResult = await mediaRepo.getItems(
        parentId: parentId,
        includeItemTypes: 'Genre',
        recursive: true,
        limit: 1000,
      );
      availableGenres = genreResult.items
          .map((g) => g.name)
          .whereType<String>()
          .toList()
        ..sort();

      final studioResult = await mediaRepo.getItems(
        parentId: parentId,
        includeItemTypes: 'Studio',
        recursive: true,
        limit: 1000,
      );
      availableStudios = studioResult.items
          .map((s) {
            final id = s.id;
            final name = s.name;
            if (id != null && name != null) {
              return MapEntry(id, name);
            }
            return null;
          })
          .whereType<MapEntry<String, String>>()
          .toList()
        ..sort((a, b) => a.value.compareTo(b.value));
    }

    return LibraryState(
      items: items,
      views: viewsResult.items,
      parentId: parentId,
      totalRecordCount: totalCount,
      includeItemTypes: includeItemTypes,
      excludeItemTypes: excludeItemTypes,
      availableGenres: availableGenres,
      availableStudios: availableStudios,
    );
  }

  /// Resolves type filters based on the parent's [collectionType].
  ///
  /// | CollectionType | IncludeItemTypes | ExcludeItemTypes |
  /// |----------------|------------------|------------------|
  /// | movies         | Movie            | —                |
  /// | tvshows        | Series           | —                |
  /// | mixed          | —                | Season,Episode   |
  /// | others         | —                | —                |
  _TypeFilters _resolveTypeFilters(String? collectionType) {
    return switch (collectionType) {
      'movies' => const _TypeFilters(includeItemTypes: 'Movie'),
      'tvshows' => const _TypeFilters(includeItemTypes: 'Series'),
      'mixed' => const _TypeFilters(excludeItemTypes: 'Season,Episode'),
      _ => const _TypeFilters(),
    };
  }

  /// Load more items for the current parent library.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        current.isLoadingMore ||
        parentId == null ||
        !current.hasMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final mediaRepo = ref.read(mediaRepositoryProvider);
      final nextPage = current.currentPage + 1;
      final result = await mediaRepo.getItems(
        parentId: parentId,
        includeItemTypes: current.includeItemTypes,
        excludeItemTypes: current.excludeItemTypes,
        limit: _pageSize,
        startIndex: nextPage * _pageSize,
        sortBy: current.currentSort.sortBy,
        recursive: true,
        genres: current.selectedGenre != null ? [current.selectedGenre!] : null,
        studioIds: current.selectedStudioId != null ? [current.selectedStudioId!] : null,
      );

      final updated = current.copyWith(
        items: [...current.items, ...result.items],
        isLoadingMore: false,
        currentPage: nextPage,
        totalRecordCount: result.totalRecordCount,
      );
      state = AsyncData(updated);
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Change the current sort option and reload items.
  Future<void> setSortOption(SortOption sort) async {
    final current = state.value;
    if (current == null || current.currentSort == sort) return;

    if (parentId == null) {
      // No items to sort, just update the sort preference
      state = AsyncData(current.copyWith(currentSort: sort));
      return;
    }

    // Update sort state and reset pagination
    state = AsyncData(current.copyWith(
      currentSort: sort,
      items: const [],
      currentPage: 0,
      isLoadingMore: true,
    ));

    try {
      final mediaRepo = ref.read(mediaRepositoryProvider);
      final result = await mediaRepo.getItems(
        parentId: parentId,
        includeItemTypes: current.includeItemTypes,
        excludeItemTypes: current.excludeItemTypes,
        limit: _pageSize,
        sortBy: sort.sortBy,
        recursive: true,
        genres: current.selectedGenre != null ? [current.selectedGenre!] : null,
        studioIds: current.selectedStudioId != null ? [current.selectedStudioId!] : null,
      );

      state = AsyncData(LibraryState(
        items: result.items,
        views: current.views,
        isLoadingMore: false,
        currentSort: sort,
        viewMode: current.viewMode,
        parentId: parentId,
        currentPage: 0,
        totalRecordCount: result.totalRecordCount,
        includeItemTypes: current.includeItemTypes,
        excludeItemTypes: current.excludeItemTypes,
        selectedGenre: current.selectedGenre,
        selectedStudioId: current.selectedStudioId,
        availableGenres: current.availableGenres,
        availableStudios: current.availableStudios,
      ));
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Toggle between grid and list view modes.
  void setViewMode(ViewMode mode) {
    final current = state.value;
    if (current == null || current.viewMode == mode) return;

    state = AsyncData(current.copyWith(viewMode: mode));
  }

  /// Set genre and/or studio filter and reload items.
  ///
  /// [genre] and [studioId] are the *desired* final values.
  /// Pass `null` to clear a filter, pass the current value to keep it.
  Future<void> setFilter({String? genre, String? studioId}) async {
    final current = state.value;
    if (current == null) return;

    final newGenre = genre;
    final newStudioId = studioId;

    if (current.selectedGenre == newGenre &&
        current.selectedStudioId == newStudioId) {
      return;
    }

    if (parentId == null) {
      state = AsyncData(current.copyWith(
        selectedGenre: newGenre,
        selectedStudioId: newStudioId,
      ));
      return;
    }

    state = AsyncData(current.copyWith(
      selectedGenre: newGenre,
      selectedStudioId: newStudioId,
      items: const [],
      currentPage: 0,
      isLoadingMore: true,
    ));

    try {
      final mediaRepo = ref.read(mediaRepositoryProvider);
      final result = await mediaRepo.getItems(
        parentId: parentId,
        includeItemTypes: current.includeItemTypes,
        excludeItemTypes: current.excludeItemTypes,
        limit: _pageSize,
        sortBy: current.currentSort.sortBy,
        recursive: true,
        genres: newGenre != null ? [newGenre] : null,
        studioIds: newStudioId != null ? [newStudioId] : null,
      );

      state = AsyncData(LibraryState(
        items: result.items,
        views: current.views,
        isLoadingMore: false,
        currentSort: current.currentSort,
        viewMode: current.viewMode,
        parentId: parentId,
        currentPage: 0,
        totalRecordCount: result.totalRecordCount,
        includeItemTypes: current.includeItemTypes,
        excludeItemTypes: current.excludeItemTypes,
        selectedGenre: newGenre,
        selectedStudioId: newStudioId,
        availableGenres: current.availableGenres,
        availableStudios: current.availableStudios,
      ));
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Refresh the library data.
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Internal helper for type filter resolution.
class _TypeFilters {
  final String? includeItemTypes;
  final String? excludeItemTypes;

  const _TypeFilters({
    this.includeItemTypes,
    this.excludeItemTypes,
  });
}
