import 'package:emby_client/core/widgets/app_text_button.dart';
import 'package:emby_client/features/player/player_viewmodel.dart';
import 'package:emby_client/features/player/progress_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 全屏播放器控制覆盖层。
///
/// 基于 [AnimatedOpacity] 根据 [PlayerState.isControlsVisible] 淡入淡出。
class PlayerControlsOverlay extends ConsumerWidget {
  final String itemId;

  const PlayerControlsOverlay({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(playerViewModelProvider(itemId));

    return stateAsync.when(
      data: (state) => _buildOverlay(context, ref, state),
      loading: () => _buildLoadingOverlay(context),
      error: (err, _) => _buildErrorOverlay(context, err),
    );
  }

  Widget _buildOverlay(BuildContext context, WidgetRef ref, PlayerState state) {
    final viewModel = ref.read(playerViewModelProvider(itemId).notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemName = state.item?.name ?? '播放中';

    return AnimatedOpacity(
      opacity: state.isControlsVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: AbsorbPointer(
        absorbing: !state.isControlsVisible,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.0, 0.2, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ---- 顶部栏 ----
                _TopBar(
                  title: itemName,
                  onBack: () {
                    final router = GoRouter.of(context);

                    if (router.canPop()) {
                      context.pop();
                    } else {

                      final detailId = state.item?.seriesId ?? itemId;
                      context.goNamed('detail', pathParameters: {'id': detailId});
                    }
                  },
                  onHome: () => context.goNamed('home'),
                  onTrack: () => _showTrackDialog(context, viewModel, state),
                  onSource: () => _showSourceDialog(context, viewModel, state),
                ),

                const Spacer(),

                // ---- 中间快进/快退按钮 ----
                _CenterSeekControls(
                  onSeekBackward: () {
                    final target = state.position - const Duration(seconds: 10);
                    viewModel.seek(target.clamp(Duration.zero, state.duration));
                    HapticFeedback.lightImpact();
                  },
                  onSeekForward: () {
                    final target = state.position + const Duration(seconds: 10);
                    viewModel.seek(target.clamp(Duration.zero, state.duration));
                    HapticFeedback.lightImpact();
                  },
                ),

                const Spacer(),

                // ---- 底部栏 ----
                _BottomBar(
                  state: state,
                  viewModel: viewModel,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 轨道选择 Dialog
  // ---------------------------------------------------------------------------
  void _showTrackDialog(
    BuildContext context,
    PlayerViewModel viewModel,
    PlayerState state,
   
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('轨道'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 视频轨道
                if (state.videoTracks?.isNotEmpty ?? false) ...[
                  const _SectionTitle('视频'),
                  ...state.videoTracks!.asMap().entries.map((entry) {
                    final isSelected = entry.key == state.selectedVideoIndex;
                    return _TrackListTile(
                      label: entry.value.toString(),
                      isSelected: isSelected,
                      onTap: () {
                        viewModel.selectVideoTrack(entry.key);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                ],
                // 音频轨道
                if (state.audioTracks?.isNotEmpty ?? false) ...[
                  const Divider(),
                  const _SectionTitle('音频'),
                  ...state.audioTracks!.asMap().entries.map((entry) {
                    final isSelected = entry.key == state.selectedAudioIndex;
                    return _TrackListTile(
                      label: entry.value.toString(),
                      isSelected: isSelected,
                      onTap: () {
                        viewModel.selectAudioTrack(entry.key);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                ],
                // 字幕轨道
                if (state.subtitleTracks?.isNotEmpty ?? false) ...[
                  const Divider(),
                  const _SectionTitle('字幕'),
                  _TrackListTile(
                    label: '关闭字幕',
                    isSelected: state.selectedSubtitleIndex == -1,
                    onTap: () {
                      viewModel.selectSubtitleTrack(-1);
                      Navigator.of(ctx).pop();
                    },
                  ),
                  ...state.subtitleTracks!.asMap().entries.map((entry) {
                    final isSelected = entry.key == state.selectedSubtitleIndex;
                    return _TrackListTile(
                      label: entry.value.toString(),
                      isSelected: isSelected,
                      onTap: () {
                        viewModel.selectSubtitleTrack(entry.key);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // MediaSource 选择 Dialog
  // ---------------------------------------------------------------------------
  void _showSourceDialog(
    BuildContext context,
    PlayerViewModel viewModel,
    PlayerState state,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('源'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: state.mediaSources.asMap().entries.map((entry) {
                final source = entry.value;
                final isSelected = source.id == state.selectedMediaSourceId;
                final detail = _buildSourceDetail(source);
                return _TrackListTile(
                  label: source.name ?? '源 ${entry.key}',
                  subtitle: detail,
                  isSelected: isSelected,
                  onTap: () {
                    if (source.id != null) {
                      viewModel.switchMediaSource(source.id!);
                    }
                    Navigator.of(ctx).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  String _buildSourceDetail(dynamic source) {
    final parts = <String>[];
    final container = source.container;
    if (container != null && container.isNotEmpty) parts.add(container.toUpperCase());
    final size = source.size;
    if (size != null && size > 0) {
      parts.add('${(size / 1e9).toStringAsFixed(1)} GB');
    }
    return parts.join(' | ');
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildErrorOverlay(BuildContext context, Object? error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white70,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            '播放错误',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            error?.toString() ?? '未知错误',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 顶部栏
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onHome;
  final VoidCallback onTrack;
  final VoidCallback onSource;

  const _TopBar({
    required this.title,
    required this.onBack,
    required this.onHome,
    required this.onTrack,
    required this.onSource,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Semantics(
            label: '返回',
            button: true,
            child: Tooltip(
              message: '返回',
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                iconSize: isSmall ? 24 : 28,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmall ? 16 : 18,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 轨道按钮
          AppTextButton(
            label: '轨道',
            variant: AppButtonVariant.outlined,
            foregroundColor: Colors.white,
            onPressed: onTrack,
          ),
          const SizedBox(width: 8),
          // 源按钮
          AppTextButton(
            label: '源',
            variant: AppButtonVariant.outlined,
            foregroundColor: Colors.white,
            onPressed: onSource,
          ),
          const SizedBox(width: 8),
          // 首页按钮
          Semantics(
            label: '首页',
            button: true,
            child: Tooltip(
              message: '首页',
              child: IconButton(
                onPressed: onHome,
                icon: const Icon(Icons.home),
                color: Colors.white,
                iconSize: isSmall ? 24 : 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 中间快进/快退按钮
// ---------------------------------------------------------------------------
class _CenterSeekControls extends StatelessWidget {
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;

  const _CenterSeekControls({
    required this.onSeekBackward,
    required this.onSeekForward,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    final buttonSize = isSmall ? 56.0 : 72.0;
    final iconSize = isSmall ? 32.0 : 40.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            label: '快退 10 秒',
            button: true,
            child: GestureDetector(
              onTap: onSeekBackward,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.replay_10,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),
          Semantics(
            label: '快进 10 秒',
            button: true,
            child: GestureDetector(
              onTap: onSeekForward,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.forward_10,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 底部栏
// ---------------------------------------------------------------------------
class _BottomBar extends StatelessWidget {
  final PlayerState state;
  final PlayerViewModel viewModel;
  final ColorScheme colorScheme;

  const _BottomBar({
    required this.state,
    required this.viewModel,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressSlider(
          position: state.position,
          duration: state.duration,
          onSeek: viewModel.seek,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 8.0 : 16.0,
            vertical: 4.0,
          ),
          child: Row(
            children: [
              // 播放/暂停
              Semantics(
                label: state.isPlaying ? '暂停' : '播放',
                button: true,
                child: Tooltip(
                  message: state.isPlaying ? '暂停' : '播放',
                  child: IconButton(
                    onPressed: viewModel.playPause,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        key: ValueKey<bool>(state.isPlaying),
                        color: Colors.white,
                        size: isSmall ? 32 : 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 全屏切换
                    Semantics(
                      label: state.isFullScreen ? '退出全屏' : '切换全屏',
                      button: true,
                      child: Tooltip(
                        message: state.isFullScreen ? '退出全屏' : '切换全屏',
                        child: IconButton(
                          onPressed: viewModel.toggleFullScreen,
                          icon: Icon(
                            state.isFullScreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                          ),
                          color: Colors.white,
                          iconSize: isSmall ? 24 : 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 缓冲指示器
        if (state.isBuffering)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog 内部组件
// ---------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _TrackListTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TrackListTile({
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall,
            )
          : null,
      trailing: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}


extension on Duration {
  Duration clamp(Duration min, Duration max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}
