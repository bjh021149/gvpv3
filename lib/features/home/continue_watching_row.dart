import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/user_item_data.dart';
import 'package:emby_client/core/navigation/detail_navigation.dart';
import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:emby_client/features/shared/media_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A horizontally scrollable row of "Continue Watching" items.
/// Each card displays the media poster and a small progress indicator
/// in the top-right corner. Long-press on a card opens a context menu.
class ContinueWatchingRow extends ConsumerWidget {
  final List<BaseItemDto> items;

  const ContinueWatchingRow({super.key, required this.items});

  void _onItemTap(BuildContext context, BaseItemDto item, WidgetRef ref) {
    goToDetail(context, ref, item);
  }

  void _onItemLongPress(BuildContext context, BaseItemDto item, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.play_arrow, color: colorScheme.primary),
                title: const Text('Resume Playback'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/player/${item.id}');
                },
              ),
              ListTile(
                leading: Icon(Icons.replay, color: colorScheme.primary),
                title: const Text('Play from Beginning'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/player/${item.id}?startFromBeginning=true');
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline, color: colorScheme.primary),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.of(context).pop();
                  goToDetail(context, ref, item);
                },
              ),
              if (item.userData != null && item.userData!.isFavorite == true)
          
              
                ListTile(
                  leading: Icon(Icons.favorite, color: colorScheme.primary),
                  title: const Text('Remove from Favorites'),
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: implement toggle favorite
              })
                
                  
                
              else
                ListTile(
                  leading: Icon(Icons.favorite_border, color: colorScheme.primary),
                  title: const Text('Add to Favorites'),
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: implement toggle favorite
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: Text('Remove', style: TextStyle(color: colorScheme.error)),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: implement remove from continue watching
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Calculates playback progress as a value between 0.0 and 1.0.
  ///
  /// Priority:
  /// 1. Use [UserItemDataDto.playedPercentage] if available (0.0 - 100.0).
  /// 2. Fallback to [playbackPositionTicks] / [runTimeTicks].
  double _getProgress(BaseItemDto item) {
    final userData = item.userData;
    if (userData == null) return 0.0;

    // Prefer server-calculated percentage
    final playedPercentage = userData.playedPercentage;
    if (playedPercentage != null && playedPercentage > 0) {
      return playedPercentage / 100.0;
    }

    // Fallback: calculate from position / runtime
    final playback = userData.playbackPositionTicks ?? 0;
    final runtime = item.runTimeTicks;
    if (runtime != null && runtime > 0) {
      return (playback / runtime).clamp(0.0, 1.0);
    }

    return 0.0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final layout = ScreenLayout.of(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final progress = _getProgress(item);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Semantics(
              label: '${item.name}, ${(progress * 100).toInt()}% watched',
              button: true,
              onTapHint: 'Resume watching ${item.name}',
              child: GestureDetector(
                onTap: () => _onItemTap(context, item, ref),
                onLongPress: () => _onItemLongPress(context, item, ref),
                child: Stack(
                  children: [
                    MediaCard(item: item, width: 140),
                    // Progress bar at the bottom of the card
                    Positioned(
                      left: 4,
                      right: 4,
                      bottom: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: colorScheme.onSurface.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
