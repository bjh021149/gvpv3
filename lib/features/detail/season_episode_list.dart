import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/features/shared/emby_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays a season tab bar and episode list for series-type media.
///
/// Features:
/// - Horizontal scrollable season tabs (one-tap season switching)
/// - Episode list with thumbnail, episode number, title, runtime, and progress
/// - Tap on an episode navigates to the player
class SeasonEpisodeList extends StatelessWidget {
  /// List of available seasons.
  final List<BaseItemDto> seasons;

  /// List of episodes for the selected season.
  final List<BaseItemDto> episodes;

  /// ID of the currently selected season.
  final String? selectedSeasonId;

  /// Callback when a season is selected.
  final ValueChanged<String> onSelectSeason;

  /// Callback when an episode is tapped.
  final ValueChanged<String> onEpisodeTap;

  const SeasonEpisodeList({
    super.key,
    required this.seasons,
    required this.episodes,
    this.selectedSeasonId,
    required this.onSelectSeason,
    required this.onEpisodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '剧集',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // Season tabs
        if (seasons.length > 1)
          _buildSeasonTabs(context)
        else if (seasons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              seasons.first.name ?? '第 ${seasons.first.indexNumber ?? 1} 季',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),

        // Episode list
        if (episodes.isNotEmpty)
          SizedBox(
            height: (episodes.length * 100.0).clamp(300, 600),
            child: _EpisodeList(
              episodes: episodes,
              onEpisodeTap: onEpisodeTap,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  '暂无剧集',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Builds the horizontal scrollable season tabs.
  Widget _buildSeasonTabs(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final season = seasons[index];
          final isSelected = season.id == selectedSeasonId;

          return Semantics(
            selected: isSelected,
            button: true,
            label: season.name ?? '第 ${season.indexNumber ?? index + 1} 季',
            child: GestureDetector(
              onTap: () => onSelectSeason(season.id ?? ''),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  season.name ?? '第${season.indexNumber ?? index + 1}季',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Scrollable list of episodes.
class _EpisodeList extends StatelessWidget {
  /// List of episodes to display.
  final List<BaseItemDto> episodes;

  /// Callback when an episode is tapped.
  final ValueChanged<String> onEpisodeTap;

  const _EpisodeList({
    required this.episodes,
    required this.onEpisodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: episodes.length,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final episode = episodes[index];
        return _EpisodeTile(
          episode: episode,
          onTap: () {
            if (episode.id != null) {
              onEpisodeTap(episode.id!);
            }
          },
        );
      },
    );
  }
}

/// Individual episode list tile.
class _EpisodeTile extends ConsumerWidget {
  /// The episode to display.
  final BaseItemDto episode;

  /// Callback when tapped.
  final VoidCallback onTap;

  const _EpisodeTile({
    required this.episode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Format runtime
    final runtime = _formatRuntime(episode.runTimeTicks);

    // Playback progress
    final progressPercent = episode.userData?.playedPercentage ?? 0;
    final isPlayed = episode.userData?.played ?? false;

    return Semantics(
      button: true,
      label:
          '第${episode.indexNumber}集: ${episode.name}${runtime != null ? ', $runtime' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              _buildThumbnail(context),

              const SizedBox(width: 12),

              // Episode info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Episode number and title
                    Row(
                      children: [
                        // Episode number badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'E${episode.indexNumber ?? '?'}',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Episode title
                        Expanded(
                          child: Text(
                            episode.name ?? '未命名剧集',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Runtime
                    if (runtime != null)
                      Text(
                        runtime,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                    // Episode overview (truncated)
                    if (episode.overview != null &&
                        episode.overview!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          episode.overview!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ),

                    // Playback progress bar
                    if (progressPercent > 0 && !isPlayed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _PlaybackProgressBar(
                          percent: progressPercent / 100,
                        ),
                      ),

                    // Watched indicator
                    if (isPlayed)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '已看完',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Play icon
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.play_circle_outline,
                  color: colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the episode thumbnail image.
  Widget _buildThumbnail(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: EmbyCachedImage(
        itemId: episode.id!,
        imageTagList: [
          MapEntry('Primary', episode.imageTags?['Primary'] ?? ''),
          MapEntry('Thumb', episode.imageTags?['Thumb'] ?? ''),
        ],
        width: 120,
        height: 68,
        fit: BoxFit.cover,
        showProgressIndicator: true,
        errorIcon: Icons.videocam_off_outlined,
      ),
    );
  }

  /// Formats runtime ticks into a human-readable string.
  String? _formatRuntime(int? ticks) {
    if (ticks == null) return null;

    final totalSeconds = ticks ~/ 10000000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours小时 $minutes分钟';
    } else if (minutes > 0) {
      return '$minutes分钟';
    }
    return null;
  }
}

/// Playback progress bar widget.
class _PlaybackProgressBar extends StatelessWidget {
  /// Progress as a fraction (0.0 to 1.0).
  final double percent;

  const _PlaybackProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 3,
        child: LinearProgressIndicator(
          value: percent.clamp(0.0, 1.0),
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ),
    );
  }
}
