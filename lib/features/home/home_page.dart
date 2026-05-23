import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/navigation/detail_navigation.dart';
import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:emby_client/features/home/continue_watching_row.dart';
import 'package:emby_client/features/home/hero_carousel.dart';
import 'package:emby_client/features/home/home_viewmodel.dart';
import 'package:emby_client/features/shared/media_card.dart';
import 'package:emby_client/features/shared/section_header.dart';
import 'package:emby_client/features/shared/shimmer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main home page that assembles all home screen sections.
///
/// Uses fine-grained providers ([carouselItemsProvider], [continueWatchingProvider],
/// [recentlyAddedProvider]) instead of watching the entire [HomeState],
/// so that updates to one section do not rebuild the others.
///
/// Shows shimmer placeholders while loading and handles error states.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carouselAsync = ref.watch(carouselItemsProvider);
    final seriesAsync = ref.watch(resumableSeriesProvider);
    final moviesAsync = ref.watch(resumableMoviesProvider);
    final librarySectionsAsync = ref.watch(librarySectionsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(carouselItemsProvider);
          ref.invalidate(resumableSeriesProvider);
          ref.invalidate(resumableMoviesProvider);
          ref.invalidate(librarySectionsProvider);
        },
        child: _buildContentFromProviders(
          context,
          carouselAsync,
          moviesAsync,
          seriesAsync,
          librarySectionsAsync,
          ref,
        ),
      ),
    );
  }

  /// Builds content from independent async providers.
  Widget _buildContentFromProviders(
    BuildContext context,
    AsyncValue<List<BaseItemDto>> carouselAsync,
    AsyncValue<List<BaseItemDto>> moviesAsync,
    AsyncValue<List<BaseItemDto>> seriesAsync,
    AsyncValue<List<LibrarySection>> librarySectionsAsync,
    WidgetRef ref,
  ) {
    final slivers = <Widget>[
      const SliverAppBar(
        floating: true,
        pinned: true,
        title: Text('首页'),
        centerTitle: false,
      ),
    ];

    // Hero carousel
    carouselAsync.whenData((items) {
      if (items.isNotEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: HeroCarousel(items: items),
            ),
          ),
        );
      }
    });

    // Continue watching — Movies section
    moviesAsync.whenData((items) {
      if (items.isNotEmpty) {
        slivers.add(
          const SliverToBoxAdapter(
            child: SectionHeader(title: '继续观看 — 电影'),
          ),
        );
        slivers.add(
          SliverToBoxAdapter(
            child: ContinueWatchingRow(items: items),
          ),
        );
      }
    });

    // Continue watching — TV Series section
    seriesAsync.whenData((items) {
      if (items.isNotEmpty) {
        slivers.add(
          const SliverToBoxAdapter(
            child: SectionHeader(title: '继续观看 — 剧集'),
          ),
        );
        slivers.add(
          SliverToBoxAdapter(
            child: ContinueWatchingRow(items: items),
          ),
        );
      }
    });

    // Library sections: each media library's latest items
    librarySectionsAsync.whenData((sections) {
      for (final section in sections) {
        slivers.add(
          SliverToBoxAdapter(
            child: SectionHeader(
              title: section.library.name ?? 'Unknown Library',
              onViewAll: () {
                // TODO: Navigate to library detail page
              },
            ),
          ),
        );
        slivers.add(
          SliverToBoxAdapter(
            child: _LibrarySectionRow(section: section),
          ),
        );
      }
    });

    // Loading state: show shimmer if ALL are loading
    if (carouselAsync.isLoading &&
        moviesAsync.isLoading &&
        seriesAsync.isLoading &&
        librarySectionsAsync.isLoading) {
      return _buildShimmerLoading(context);
    }

    // Error state: show error if ANY has error and NONE has data
    final hasError = carouselAsync.hasError ||
        moviesAsync.hasError ||
        seriesAsync.hasError ||
        librarySectionsAsync.hasError;
    final hasData = carouselAsync.hasValue ||
        moviesAsync.hasValue ||
        seriesAsync.hasValue ||
        librarySectionsAsync.hasValue;
    if (hasError && !hasData) {
      final firstError = carouselAsync.error ??
          moviesAsync.error ??
          seriesAsync.error ??
          librarySectionsAsync.error;
      return _buildError(context, firstError ?? 'Unknown error', ref);
    }

    slivers.add(const SliverPadding(padding: EdgeInsets.only(bottom: 32)));
    return CustomScrollView(slivers: slivers);
  }

  /// Builds shimmer loading placeholders.
  Widget _buildShimmerLoading(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        const SliverAppBar(
          floating: true,
          pinned: true,
          title: Text('首页'),
        ),
        // Shimmer carousel placeholder
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const ShimmerCard(),
              ),
            ),
          ),
        ),
        // Shimmer section headers and rows
        const SliverToBoxAdapter(
          child: SectionHeader(title: '继续观看'),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
        // Shimmer library sections
        for (int i = 0; i < 3; i++) ...[
          const SliverToBoxAdapter(
            child: SectionHeader(title: '媒体库'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
      ],
    );
  }

  /// Builds the error state with retry button.
  Widget _buildError(BuildContext context, Object error, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          pinned: true,
          title: Text('Home'),
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
                    'Failed to load home content',
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
                    label: 'Retry loading content',
                    child: FilledButton.icon(
                      onPressed: () {
                        ref.invalidate(carouselItemsProvider);
                        ref.invalidate(resumableSeriesProvider);
                        ref.invalidate(resumableMoviesProvider);
                        ref.invalidate(librarySectionsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
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
}

/// A horizontally scrollable row of latest items for a single media library.
///
/// Dynamically calculates how many items to display based on screen width
/// and card dimensions, using [calculateItemLimit].
class _LibrarySectionRow extends ConsumerWidget {
  final LibrarySection section;

  const _LibrarySectionRow({required this.section});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ScreenLayout.of(context);
    final cardWidth = switch (layout.type) {
      ScreenType.compact => 140.0,
      ScreenType.medium => 160.0,
      ScreenType.expanded => 160.0,
      ScreenType.large => 180.0,
      ScreenType.extraLarge => 180.0,
    };

    // Calculate available width (screen width minus horizontal padding on both sides)
    final screenWidth = layout.width;
    final horizontalPadding = layout.horizontalPadding;
    final availableWidth = screenWidth - (horizontalPadding * 2);

    // Calculate how many items to show based on card size and available width
    final itemLimit = calculateItemLimit(
      availableWidth: availableWidth,
      cardWidth: cardWidth,
      cardSpacing: 12.0,
      bufferCount: 2,
      maxLimit: 20,
    );

    // Slice the items to the calculated limit
    final displayItems = section.latestItems.take(itemLimit).toList();

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final item = displayItems[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MediaCard(
              item: item,
              width: cardWidth,
              onTap: () {
                goToDetail(context, ref, item);
              },
            ),
          );
        },
      ),
    );
  }
}
