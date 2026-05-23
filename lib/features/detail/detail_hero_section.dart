import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:emby_client/features/shared/emby_cached_image.dart';
import 'package:emby_client/features/shared/logo_title.dart';
import 'package:emby_client/services/cache/cache_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail hero section with poster, title, metadata, and play button.
///
/// Uses a horizontal layout (poster left, info right) similar to
/// Netflix/Disney+ detail pages. The backdrop is handled by the
/// SliverAppBar above this section.
///
/// This component independently watches the item core data via
/// [itemCoreProvider] and only rebuilds when core fields change.
class DetailHeroSection extends ConsumerWidget {
  /// The item ID to watch.
  final String itemId;

  /// Callback when the play button is tapped.
  final VoidCallback onPlay;

  const DetailHeroSection({
    super.key,
    required this.itemId,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemCoreProvider(itemId));

    return itemAsync.when(
      data: (item) => item != null
          ? _buildContent(context, item)
          : const SizedBox.shrink(),
      loading: () => _buildSkeleton(context),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(BuildContext context, BaseItemDto item) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final layout = ScreenLayout.of(context);
    final horizontalPadding = layout.horizontalPadding;

    final posterWidth = switch (layout.type) {
      ScreenType.compact => 120.0,
      ScreenType.medium => 140.0,
      _ => 160.0,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPoster(context, item, posterWidth),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                LogoTitle(
                  item: item,
                  logoMaxHeight: 48,
                  textStyle: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                _buildMetadataRow(context, item),
                const SizedBox(height: 16),
                _buildPlayButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(BuildContext context, BaseItemDto item, double posterWidth) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemId = item.id;
    if (itemId == null || itemId.isEmpty) {
      return SizedBox(width: posterWidth);
    }

    return Hero(
      tag: 'media_$itemId',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: posterWidth,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 0.67,
            child: EmbyCachedImage(
              itemId: itemId,
              imageTagList: [
                MapEntry('Primary', item.imageTags?['Primary'] ?? ''),
                MapEntry('Thumb', item.imageTags?['Thumb'] ?? ''),
              ],
              width: posterWidth,
              height: posterWidth / 0.67,
              fit: BoxFit.cover,
              showProgressIndicator: true,
              errorWidget: Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.movie,
                  color: colorScheme.onSurfaceVariant,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, BaseItemDto item) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final parts = <Widget>[];

    if (item.productionYear != null) {
      parts.add(
        Text(
          '${item.productionYear}',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (item.communityRating != null) {
      if (parts.isNotEmpty) {
        parts.add(_buildDotSeparator(context));
      }
      parts.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: colorScheme.tertiary,
            ),
            const SizedBox(width: 4),
            Text(
              item.communityRating!.toStringAsFixed(1),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (item.officialRating != null) {
      if (parts.isNotEmpty) {
        parts.add(_buildDotSeparator(context));
      }
      parts.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            item.officialRating!,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 0,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts,
    );
  }

  Widget _buildDotSeparator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.circle,
        size: 4,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      tooltip: '播放',
      child: FilledButton.icon(
        onPressed: onPlay,
        icon: const Icon(Icons.play_arrow, size: 20),
        label: const Text('播放'),
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final layout = ScreenLayout.of(context);
    final horizontalPadding = layout.horizontalPadding;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
