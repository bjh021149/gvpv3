import 'package:emby_client/core/api/emby_api_service.dart';
import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/navigation/detail_navigation.dart';
import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:emby_client/core/utils/screen_util.dart';
import 'package:emby_client/features/detail/cast_horizontal_list.dart';
import 'package:emby_client/features/detail/detail_hero_section.dart';
import 'package:emby_client/features/detail/detail_page_background.dart';
import 'package:emby_client/features/detail/detail_viewmodel.dart';
import 'package:emby_client/features/detail/metadata_chips.dart';
import 'package:emby_client/features/detail/overview_section.dart';
import 'package:emby_client/features/detail/season_episode_list.dart';
import 'package:emby_client/features/detail/similar_items_row.dart';
import 'package:emby_client/features/detail/studio_section.dart';
import 'package:emby_client/features/shared/emby_cached_image.dart';
import 'package:emby_client/features/shared/section_header.dart';
import 'package:emby_client/features/shared/shimmer_card.dart';
import 'package:emby_client/services/cache/cache_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
/// Detail page for a media item.
///
/// Displays comprehensive information about a movie, series, or episode
/// using a [CustomScrollView] with slivers. The page includes:
/// - Collapsible [SliverAppBar] with backdrop image
/// - Hero section with poster and play button
/// - Metadata chips (type, runtime, resolution, genres, studios)
/// - Overview / synopsis text
/// - Cast horizontal list
/// - Season/episode list (for series)
/// - Similar items recommendation row
///
/// Usage:
/// ```dart
/// GoRoute(
///   path: '/detail/:id',
///   builder: (context, state) => DetailPage(itemId: state.pathParameters['id']!),
/// )
/// ```
class DetailPage extends StatelessWidget {
  /// The unique identifier of the media item to display.
  final String itemId;

  const DetailPage({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _DetailPageBody(itemId: itemId),
    );
  }
}

/// Internal consumer widget that subscribes to the detail ViewModel.
///
/// Separated from [DetailPage] to use [ConsumerWidget] for Riverpod integration.
class _DetailPageBody extends ConsumerWidget {
  final String itemId;

  const _DetailPageBody({required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemFullProvider(itemId));
    final detailAsync = ref.watch(detailViewModelProvider(itemId));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return _buildEmptyState(context);
        }
        return detailAsync.when(
          data: (state) => _buildContent(context, ref, state, item),
          loading: () => _buildSkeletonLoading(context),
          error: (error, stack) => _buildError(context, ref, error),
        );
      },
      loading: () => _buildSkeletonLoading(context),
      error: (_, __) => _buildError(context, ref, '加载失败'),
    );
  }

  /// Builds the main content with all sections using slivers.
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    DetailState state,
    BaseItemDto item,
  ) {
    final layout = ScreenLayout.of(context);
    final horizontalPadding = layout.horizontalPadding;

    return Stack(
      children: [
        // Full-screen frosted background layer
        Positioned.fill(
          child: DetailPageBackground(item: item),
        ),

        // Scrollable content on top
        CustomScrollView(
          slivers: _buildSlivers(context, ref, state, item, horizontalPadding),
        ),
      ],
    );
  }

  /// Builds all slivers for the scrollable content.
  List<Widget> _buildSlivers(
    BuildContext context,
    WidgetRef ref,
    DetailState state,
    BaseItemDto item,
    double horizontalPadding,
  ) {
    final slivers = <Widget>[
      // Transparent app bar (backdrop is handled by DetailPageBackground)
      _buildSliverAppBar(context, item),

      // Hero section: poster + title + play button
      SliverToBoxAdapter(
        child: DetailHeroSection(
          itemId: itemId,
          onPlay: () {
            if (item.type == 'Series' && state.episodes.isNotEmpty) {
              final episode = state.episodes.firstWhere(
                (e) => e.userData?.played != true,
                orElse: () => state.episodes.first,
              );
              context.push('/player/${episode.id}');
            } else {
              context.push('/player/${item.id}');
            }
          },
        ),
      ),

      // Metadata chips: type, runtime, resolution, genres
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          child: MetadataChips(itemId: itemId),
        ),
      ),

      // Studio section with images
      if (state.studioDetails.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            child: StudioSection(
              studioDetails: state.studioDetails,
              onStudioTap: (studio) => _showRelatedItems(
                context,
                ref,
                title: studio.name ?? '关联作品',
                studioId: studio.id,
              ),
            ),
          ),
        ),

      // Divider between sections
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Divider(),
        ),
      ),

      // Overview / synopsis section
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          child: OverviewSection(itemId: itemId),
        ),
      ),

      // Cast horizontal list
      const SliverToBoxAdapter(
        child: SectionHeader(title: '演职员'),
      ),
      SliverToBoxAdapter(
        child: CastHorizontalList(
          itemId: itemId,
          onPersonTap: (person) => _showRelatedItems(
            context,
            ref,
            title: person.name ?? '关联作品',
            personId: person.id,
          ),
        ),
      ),

      // Season & Episode list (for series)
      if (item.type == 'Series' && state.seasons.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8,
            ),
            child: SeasonEpisodeList(
              seasons: state.seasons,
              episodes: state.episodes,
              selectedSeasonId: state.selectedSeasonId,
              onSelectSeason: (seasonId) {
                ref
                    .read(detailViewModelProvider(itemId).notifier)
                    .selectSeason(seasonId);
              },
              onEpisodeTap: (episodeId) {
                context.push('/player/$episodeId');
              },
            ),
          ),
        ),

      // Similar items recommendation
      if (state.similarItems.isNotEmpty) ...[
        const SliverToBoxAdapter(
          child: SectionHeader(title: '更多推荐'),
        ),
        SliverToBoxAdapter(
          child: Consumer(
            builder: (context, ref, child) {
              return SimilarItemsRow(
                items: state.similarItems,
                onItemTap: (similarItem) {
                  goToDetail(context, ref, similarItem);
                },
              );
            },
          ),
        ),
      ],

      // Bottom padding
      const SliverPadding(
        padding: EdgeInsets.only(bottom: 32),
      ),
    ];

    return slivers;
  }

  /// Builds a minimal transparent sliver app bar.
  ///
  /// The backdrop is rendered by [DetailPageBackground] behind the
  /// scroll view, so the app bar only needs navigation buttons.
  Widget _buildSliverAppBar(
    BuildContext context,
    BaseItemDto item,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 80,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Semantics(
        button: true,
        tooltip: '返回',
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      actions: [
        Semantics(
          button: true,
          tooltip: '更多选项',
          child: IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onPressed: () {
              // TODO: Show options menu (mark as favorite, etc.)
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: const Alignment(0, 0.5),
              colors: [
                colorScheme.scrim.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the skeleton loading placeholder.
  Widget _buildSkeletonLoading(BuildContext context) {
    final layout = ScreenLayout.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        const SliverAppBar(
          pinned: true,
          title: Text('加载中...'),
        ),
        // Hero section skeleton
        SliverToBoxAdapter(
          child: Skeletonizer(
            child: Container(
              height: Screen.height,//320,
              color: colorScheme.surfaceContainerHighest,
              child: const Center(
                child: Bone.circle(size: 80),
              ),
            ),
          ),
        ),
        // Metadata chips skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(layout.horizontalPadding),
            child:const Skeletonizer(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Bone.text(words: 1),
                  Bone.text(words: 1),
                  Bone.text(words: 1),
                  Bone.text(words: 1),
                ],
              ),
            ),
          ),
        ),
        // Overview skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
            child: const Skeletonizer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(words: 1),
                  SizedBox(height: 8),
                  Bone.text(words: 8),
                  SizedBox(height: 4),
                  Bone.text(words: 6),
                ],
              ),
            ),
          ),
        ),
        // Cast skeleton
        SliverToBoxAdapter(
          child: SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
              itemCount: 6,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 80,
                    child: ShimmerCard(),
                  ),
                );
              },
            ),
          ),
        ),
        // Similar items skeleton
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
              itemCount: 6,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 140,
                    child: ShimmerCard(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the error state with retry button.
  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    Object error,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          leading: Semantics(
            button: true,
            tooltip: '返回',
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
            ),
          ),
          title: const Text('加载失败'),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载详情失败',
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
                    label: '重新加载详情',
                    child: FilledButton.icon(
                      onPressed: () {
                        ref.invalidate(detailViewModelProvider(itemId));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('重试'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Shows a bottom sheet with items related to a studio or person.
  void _showRelatedItems(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    String? studioId,
    String? personId,
  }) {
    if (studioId == null && personId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _RelatedItemsSheet(
              title: title,
              studioId: studioId,
              personId: personId,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  /// Builds an empty state when no item data is available.
  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '未找到内容',
                  style: textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet that displays items related to a studio or person.
class _RelatedItemsSheet extends ConsumerStatefulWidget {
  final String title;
  final String? studioId;
  final String? personId;
  final ScrollController scrollController;

  const _RelatedItemsSheet({
    required this.title,
    this.studioId,
    this.personId,
    required this.scrollController,
  });

  @override
  ConsumerState<_RelatedItemsSheet> createState() => _RelatedItemsSheetState();
}

class _RelatedItemsSheetState extends ConsumerState<_RelatedItemsSheet> {
  List<BaseItemDto> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final api = ref.read(embyApiServiceProvider);
      final result = await api.getItems(
        studioIds: widget.studioId != null ? [widget.studioId!] : null,
        personIds: widget.personId != null ? [widget.personId!] : null,
        includeItemTypes: 'Movie,Series',
        recursive: true,
        sortBy: 'ProductionYear',
        sortOrder: false,
        limit: 5,
        fields: 'PrimaryImageAspectRatio,BasicSyncInfo,MediaSourceCount,ProductionYear,ImageTags',
      );
      if (mounted) {
        setState(() {
          _items = result.items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Drag handle
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Divider(height: 1),
        // Content
        Expanded(
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text('加载失败: $_error'),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('暂无关联作品'));
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Center(
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed(
                    'related',
                    queryParameters: {
                      'title': widget.title,
                      if (widget.studioId != null) 'studioId': widget.studioId,
                      if (widget.personId != null) 'personId': widget.personId,
                    },
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('查看更多'),
              ),
            ),
          );
        }
        final item = _items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _RelatedItemCard(
            item: item,
            onTap: () {
              Navigator.of(context).pop();
              goToDetail(context, ref, item);
            },
          ),
        );
      },
    );
  }
}

/// Card for a single related item in the bottom sheet.
class _RelatedItemCard extends StatelessWidget {
  final BaseItemDto item;
  final VoidCallback onTap;

  const _RelatedItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 60,
                height: 90,
                child: item.id != null && item.imageTags?['Primary'] != null
                    ? EmbyCachedImage(
                        itemId: item.id!,
                        imageTagList: [
                          MapEntry('Primary', item.imageTags!['Primary']!),
                        ],
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.movie, size: 24),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? '未知',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.productionYear != null)
                    Text(
                      '${item.productionYear}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (item.type != null)
                    Text(
                      item.type!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
