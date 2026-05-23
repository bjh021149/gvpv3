import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/navigation/detail_navigation.dart';
import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:emby_client/features/library/empty_library_placeholder.dart';
import 'package:emby_client/features/library/filter_sort_bar.dart';
import 'package:emby_client/features/library/library_viewmodel.dart';
import 'package:emby_client/features/library/media_grid.dart';
import 'package:emby_client/features/shared/media_card.dart';
import 'package:emby_client/features/shared/shimmer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The library page that displays media collections.
///
/// When no [parentId] is provided, shows a grid of library views
/// (Movies, TV Shows, etc.). When [parentId] is set, displays
/// items within that library with filter/sort controls.
class LibraryPage extends ConsumerWidget {
  final String? parentId;

  const LibraryPage({super.key, this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryViewModelProvider(parentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('媒体库'),
        centerTitle: false,
        leading:
            parentId != null
                ? Semantics(
                  button: true,
                  label: '返回',
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: '返回',
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/library');
                      }
                    },
                  ),
                )
                : null,
        actions: [
          Semantics(
            button: true,
            label: '刷新媒体库',
            child: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '刷新',
              onPressed: () {
                ref.read(libraryViewModelProvider(parentId).notifier).refresh();
              },
            ),
          ),
        ],
      ),
      body: libraryAsync.when(
        data: (state) => _LibraryContent(parentId: parentId, state: state),
        loading: () => _buildShimmerLoading(context),
        error:
            (error, stack) => _buildError(context, error, () {
              ref
                  .read(libraryViewModelProvider(parentId).notifier)
                  .refresh();
            }),
      ),
    );
  }

  /// Builds shimmer loading placeholders for the library.
  Widget _buildShimmerLoading(BuildContext context) {
    final layout = ScreenLayout.of(context);
    final crossAxisCount = switch (layout.type) {
      ScreenType.compact => 3,
      ScreenType.medium => 4,
      ScreenType.expanded => 4,
      ScreenType.large => 6,
      ScreenType.extraLarge => 6,
    };

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => const ShimmerCard(),
    );
  }

  /// Builds the error state with retry capability.
  Widget _buildError(
    BuildContext context,
    Object error,
    VoidCallback onRetry,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              '加载媒体库失败',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Semantics(
              button: true,
              label: '重新加载媒体库',
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The main library content that switches between views and items.
class _LibraryContent extends ConsumerWidget {
  final String? parentId;
  final LibraryState state;

  const _LibraryContent({required this.parentId, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If no parentId, show the list of library views
    if (parentId == null) {
      return _LibraryViewsGrid(views: state.views);
    }

    // If parentId is set, show items with filter/sort bar
    return Column(
      children: [
        FilterSortBar(
          currentSort: state.currentSort,
          currentViewMode: state.viewMode,
          onSortChanged: (sort) {
            ref.read(libraryViewModelProvider(parentId).notifier).setSortOption(sort);
          },
          onViewModeChanged: (mode) {
            ref.read(libraryViewModelProvider(parentId).notifier).setViewMode(mode);
          },
          onFilterPressed: () => _showFilterSheet(context, ref, state),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                state.viewMode == ViewMode.grid
                    ? _buildGridView(context, ref)
                    : _buildListView(context, ref),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(BuildContext context, WidgetRef ref) {
    if (state.items.isEmpty && !state.isLoadingMore) {
      return EmptyLibraryPlaceholder(
        message: '该媒体库暂无内容',
        icon: Icons.folder_open_outlined,
        onActionPressed: () {
          ref.read(libraryViewModelProvider(parentId).notifier).refresh();
        },
        actionLabel: '刷新',
      );
    }

    return MediaGrid(
      items: state.items,
      isLoadingMore: state.isLoadingMore,
      onLoadMore: () {
        ref.read(libraryViewModelProvider(parentId).notifier).loadMore();
      },
    );
  }

  Widget _buildListView(BuildContext context, WidgetRef ref) {
    if (state.items.isEmpty && !state.isLoadingMore) {
      return EmptyLibraryPlaceholder(
        message: '该媒体库暂无内容',
        icon: Icons.folder_open_outlined,
        onActionPressed: () {
          ref.read(libraryViewModelProvider(parentId).notifier).refresh();
        },
        actionLabel: '刷新',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (state.isLoadingMore || !state.hasMore) return false;
        final metrics = notification.metrics;
        if (metrics.pixels >= metrics.maxScrollExtent * 0.85) {
          ref.read(libraryViewModelProvider(parentId).notifier).loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final item = state.items[index];
          return _LibraryListTile(item: item);
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref, LibraryState state) {
    final genres = state.availableGenres;
    final studios = state.availableStudios;

    if (genres.isEmpty && studios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可用筛选条件')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '筛选',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (state.selectedGenre != null || state.selectedStudioId != null)
                      TextButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          ref.read(libraryViewModelProvider(parentId).notifier).setFilter(
                            genre: null,
                            studioId: null,
                          );
                        },
                        child: const Text('清除筛选'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Genre section
                if (genres.isNotEmpty) ...[
                  Text(
                    '类型',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: genres.map((genre) {
                      final isSelected = state.selectedGenre == genre;
                      return FilterChip(
                        label: Text(genre),
                        selected: isSelected,
                        onSelected: (_) {
                          Navigator.of(sheetContext).pop();
                          ref.read(libraryViewModelProvider(parentId).notifier).setFilter(
                            genre: isSelected ? null : genre,
                            studioId: state.selectedStudioId,
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                // Studio section
                if (studios.isNotEmpty) ...[
                  Text(
                    '制片公司',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: studios.map((entry) {
                      final isSelected = state.selectedStudioId == entry.key;
                      return FilterChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (_) {
                          Navigator.of(sheetContext).pop();
                          ref.read(libraryViewModelProvider(parentId).notifier).setFilter(
                            genre: state.selectedGenre,
                            studioId: isSelected ? null : entry.key,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Grid of top-level library views (Movies, TV Shows, etc.)
class _LibraryViewsGrid extends StatelessWidget {
  final List<BaseItemDto> views;

  const _LibraryViewsGrid({required this.views});

  @override
  Widget build(BuildContext context) {
    if (views.isEmpty) {
      return const EmptyLibraryPlaceholder(
        message: '未找到媒体库',
        icon: Icons.folder_outlined,
      );
    }

    final layout = ScreenLayout.of(context);
    final crossAxisCount = switch (layout.type) {
      ScreenType.compact => 2,
      ScreenType.medium => 3,
      ScreenType.expanded => 3,
      ScreenType.large => 4,
      ScreenType.extraLarge => 4,
    };

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: views.length,
      itemBuilder: (context, index) {
        final view = views[index];
        return _LibraryViewCard(view: view);
      },
    );
  }
}

/// A card representing a top-level library view.
class _LibraryViewCard extends StatelessWidget {
  final BaseItemDto view;

  const _LibraryViewCard({required this.view});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: view.name,
      button: true,
      onTapHint: '打开 ${view.name} 媒体库',
      child: GestureDetector(
        onTap: () => context.push('/library/${view.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForCollectionType(view.collectionType),
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  view.name ?? '未知',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (view.childCount != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${view.childCount} 个项目',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCollectionType(String? collectionType) {
    return switch (collectionType) {
      'movies' => Icons.movie,
      'tvshows' => Icons.tv,
      'music' => Icons.music_note,
      'books' => Icons.book,
      'photos' => Icons.photo_library,
      'games' => Icons.games,
      'playlists' => Icons.playlist_play,
      'livetv' => Icons.live_tv,
      _ => Icons.folder,
    };
  }
}

/// A list tile for displaying media items in list view mode.
class _LibraryListTile extends ConsumerWidget {
  final BaseItemDto item;

  const _LibraryListTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: item.name,
      button: true,
      onTapHint: '打开 ${item.name}',
      child: InkWell(
        onTap: () => navigateToItem(context, ref, item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 120,
                  child: MediaCard(item: item),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? '未命名',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.productionYear != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${item.productionYear}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (item.overview != null && item.overview!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.overview!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (item.communityRating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.communityRating}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Navigate arrow
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
