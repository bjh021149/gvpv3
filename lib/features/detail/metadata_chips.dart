import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/media_stream.dart';
import 'package:emby_client/services/cache/cache_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Displays metadata chips for a media item.
///
/// Uses a [Wrap] layout with [ActionChip] widgets to display:
/// - Media type (Movie / Series / Episode)
/// - Runtime duration
/// - Resolution (if available from media sources)
/// - Genres
///
/// This component independently watches core item data and genres
/// via [itemCoreProvider] and [genresProvider], only rebuilding
/// when those specific fields change.
class MetadataChips extends ConsumerWidget {
  /// The item ID to watch.
  final String itemId;

  const MetadataChips({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemCoreProvider(itemId));
    final genresAsync = ref.watch(genresProvider(itemId));

    return itemAsync.when(
      data: (item) {
        if (item == null) return const SizedBox.shrink();
        final genres = genresAsync.value;
        final chips = _buildChips(context, item, genres);
        if (chips.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: chips,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  List<Widget> _buildChips(
    BuildContext context,
    BaseItemDto item,
    List<String>? genres,
  ) {
    final chips = <Widget>[];

    // Media type chip
    if (item.type != null && item.type!.isNotEmpty) {
      chips.add(
        _MetadataChip(
          icon: _getTypeIcon(item.type!),
          label: _formatType(item.type!),
        ),
      );
    }

    // Runtime chip
    final runtime = _formatRuntime(item);
    if (runtime != null) {
      chips.add(
        _MetadataChip(
          icon: Icons.schedule,
          label: runtime,
        ),
      );
    }

    // Resolution chip (from media sources)
    final resolution = _getResolution(item);
    if (resolution != null) {
      chips.add(
        _MetadataChip(
          icon: Icons.hd_outlined,
          label: resolution,
        ),
      );
    }

    // Genre chips
    if (genres != null && genres.isNotEmpty) {
      for (final genre in genres) {
        chips.add(
          _MetadataChip(
            icon: Icons.theaters_outlined,
            label: genre,
            onPressed: () => context.push(
              '/related?title=${Uri.encodeComponent(genre)}&genre=${Uri.encodeComponent(genre)}',
            ),
          ),
        );
      }
    }

    // Series status chip
    if (item.status != null && item.status!.isNotEmpty) {
      final statusLabel = switch (item.status) {
        'Continuing' => '连载中',
        'Ended' => '已完结',
        _ => item.status!,
      };
      chips.add(
        _MetadataChip(
          icon: Icons.sync_alt_outlined,
          label: statusLabel,
        ),
      );
    }

    return chips;
  }

  IconData _getTypeIcon(String type) {
    return switch (type) {
      'Movie' => Icons.movie_outlined,
      'Series' => Icons.tv_outlined,
      'Episode' => Icons.videocam_outlined,
      'Season' => Icons.folder_outlined,
      'BoxSet' => Icons.collections_outlined,
      _ => Icons.video_library_outlined,
    };
  }

  String _formatType(String type) {
    return switch (type) {
      'Movie' => '电影',
      'Series' => '剧集',
      'Episode' => '单集',
      'Season' => '季',
      'BoxSet' => '合集',
      _ => type,
    };
  }

  String? _formatRuntime(BaseItemDto item) {
    if (item.runTimeTicks == null) return null;
    final totalSeconds = item.runTimeTicks! ~/ 10000000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours小时 $minutes分钟';
    } else if (minutes > 0) {
      return '$minutes分钟';
    }
    return null;
  }

  String? _getResolution(BaseItemDto item) {
    if (item.mediaSources.isEmpty) return null;

    final mediaSource = item.mediaSources.first;
    MediaStream? videoStream;
    for (final stream in mediaSource.mediaStreams) {
      if (stream.type == 'Video') {
        videoStream = stream;
        break;
      }
    }

    if (videoStream != null) {
      final width = videoStream.width;
      final height = videoStream.height;

      if (width != null && height != null) {
        if (width >= 7680) return '8K';
        if (width >= 3840) return '4K';
        if (width >= 2560) return '1440p';
        if (width >= 1920) return '1080p';
        if (width >= 1280) return '720p';
        if (width >= 854) return '480p';
      }
    }

    return null;
  }
}

/// Individual metadata chip widget.
class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _MetadataChip({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: label,
      child: ActionChip(
        avatar: Icon(
          icon,
          size: 16,
          color: colorScheme.onSecondaryContainer,
        ),
        label: Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: colorScheme.secondaryContainer,
        side: BorderSide.none,
        onPressed: onPressed,
      ),
    );
  }
}
