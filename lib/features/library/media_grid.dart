import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/navigation/detail_navigation.dart';
import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:emby_client/features/shared/media_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A responsive grid of media items that adapts column count based on
/// the current screen layout.
///
/// Supports pagination via [onLoadMore] callback triggered when the user
/// scrolls near the bottom of the grid.
class MediaGrid extends ConsumerStatefulWidget {
  final List<BaseItemDto> items;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;

  const MediaGrid({
    super.key,
    required this.items,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  @override
  ConsumerState<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends ConsumerState<MediaGrid> {
  final ScrollController _scrollController = ScrollController();

  /// Returns the number of columns based on screen type.
  int _getCrossAxisCount(ScreenType type) {
    return switch (type) {
      ScreenType.compact => 3,
      ScreenType.medium => 4,
      ScreenType.expanded => 4,
      ScreenType.large => 6,
      ScreenType.extraLarge => 6,
    };
  }

  /// Returns the aspect ratio of each grid item based on screen type.
  double _getChildAspectRatio(ScreenType type) {
    return switch (type) {
      ScreenType.compact => 0.65,
      ScreenType.medium => 0.72,
      ScreenType.expanded => 0.72,
      ScreenType.large => 0.7,
      ScreenType.extraLarge => 0.7,
    };
  }

  /// Returns the spacing between grid items based on screen type.
  double _getSpacing(ScreenType type) {
    return switch (type) {
      ScreenType.compact => 8.0,
      ScreenType.medium => 12.0,
      ScreenType.expanded => 12.0,
      ScreenType.large => 16.0,
      ScreenType.extraLarge => 16.0,
    };
  }

  void _onItemTap(BuildContext context, BaseItemDto item) {
    navigateToItem(context, ref, item);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollNotification(ScrollNotification notification) {
    if (widget.onLoadMore == null || widget.isLoadingMore) return;

    final metrics = notification.metrics;
    if (metrics.pixels >= metrics.maxScrollExtent * 0.85) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = ScreenLayout.of(context);
    final crossAxisCount = _getCrossAxisCount(layout.type);
    final childAspectRatio = _getChildAspectRatio(layout.type);
    final spacing = _getSpacing(layout.type);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScrollNotification(notification);
        return false;
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: widget.items.length + (widget.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            // Loading more indicator at the bottom
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final item = widget.items[index];
          return Semantics(
            label: item.name,
            button: true,
            onTapHint: '打开 ${item.name}',
            child: GestureDetector(
              onTap: () => _onItemTap(context, item),
              child: MediaCard(item: item),
            ),
          );
        },
      ),
    );
  }
}
