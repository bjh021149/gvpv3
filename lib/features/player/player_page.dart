import 'dart:async';
import 'dart:io';

import 'package:emby_client/features/player/player_controls_overlay.dart';
import 'package:emby_client/features/player/player_viewmodel.dart';
import 'package:emby_client/features/player/unified_player_gestures.dart';
import 'package:emby_client/features/player/video_surface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// Full-screen player page that displays video content using fvp.
///
/// The page manages system UI (immersive mode), renders the [VideoSurface]
/// as the bottom layer, and overlays [PlayerControlsOverlay] on top.
/// Gestures are handled by [UnifiedPlayerGestures]:
/// - Tap toggles controls
/// - Double-tap seeks ±10s
/// - Left vertical drag adjusts brightness
/// - Right vertical drag adjusts volume
/// - Horizontal drag scrubs the timeline
class PlayerPage extends ConsumerStatefulWidget {
  final String itemId;

  const PlayerPage({
    super.key,
    required this.itemId,
  });

  /// Convenience route builder.
  static Route<void> route(String itemId) {
    return MaterialPageRoute<void>(
      builder: (_) => PlayerPage(itemId: itemId),
      fullscreenDialog: true,
    );
  }

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  @override
  void initState() {
    super.initState();
    _enterFullScreen();
  }

  @override
  void dispose() {
    _exitFullScreen();
    super.dispose();
  }

  /// Enter immersive full-screen mode hiding system overlays.
  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Restore system UI when leaving the player.
  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(playerViewModelProvider(widget.itemId));
    final viewModel = ref.read(playerViewModelProvider(widget.itemId).notifier);

    ref.listen(
      playerViewModelProvider(widget.itemId).select((v) => v.value?.isFullScreen),
      (prev, next) {
        if (next != null && prev != next) {
          _applyFullScreen(next);
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            _exitFullScreen();
          }
        },
        child: stateAsync.when(
          data: (state) => _PlayerContent(
            itemId: widget.itemId,
            state: state,
            viewModel: viewModel,
          ),
          loading: () => const _LoadingView(),
          error: (err, _) => _ErrorView(
            error: err,
            onBack: () {
              _exitFullScreen();
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ),
    );
  }

  /// Apply full-screen state using window_manager on desktop and SystemChrome on mobile.
  Future<void> _applyFullScreen(bool fullScreen) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await windowManager.setFullScreen(fullScreen);
    }
    if (fullScreen) {
      _enterFullScreen();
    } else {
      _exitFullScreen();
    }
  }
}

// ---------------------------------------------------------------------------
// Internal player content widget — Stack layout with gesture indicators
// ---------------------------------------------------------------------------
class _PlayerContent extends StatefulWidget {
  final String itemId;
  final PlayerState state;
  final PlayerViewModel viewModel;

  const _PlayerContent({
    required this.itemId,
    required this.state,
    required this.viewModel,
  });

  @override
  State<_PlayerContent> createState() => _PlayerContentState();
}

class _PlayerContentState extends State<_PlayerContent> {
  // Volume indicator
  bool _showVolumeIndicator = false;
  double _volumeValue = 1.0;

  // Brightness indicator
  bool _showBrightnessIndicator = false;
  double _brightnessValue = 0.5;

  // Seek indicator
  bool _showSeekIndicator = false;
  double _seekDeltaSeconds = 0;
  Duration _seekBasePosition = Duration.zero;

  Timer? _hideIndicatorTimer;

  void _startHideTimer() {
    _hideIndicatorTimer?.cancel();
    _hideIndicatorTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showVolumeIndicator = false;
          _showBrightnessIndicator = false;
          _showSeekIndicator = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _hideIndicatorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final viewModel = widget.viewModel;

    return UnifiedPlayerGestures(
      onTap: viewModel.toggleControls,
      onDoubleTap: () {
        viewModel.playPause();
        HapticFeedback.lightImpact();
      },
      onVolumeAdjust: (delta) {
        setState(() {
          _volumeValue = (_volumeValue + delta).clamp(0.0, 1.0);
          _showVolumeIndicator = true;
          _showBrightnessIndicator = false;
          _showSeekIndicator = false;
        });
        viewModel.setVolume(_volumeValue);
        _startHideTimer();
      },
      onBrightnessAdjust: (delta) {
        setState(() {
          _brightnessValue = (_brightnessValue + delta).clamp(0.0, 1.0);
          _showBrightnessIndicator = true;
          _showVolumeIndicator = false;
          _showSeekIndicator = false;
        });
        _startHideTimer();
      },
      onSeekStart: () {
        setState(() {
          _seekDeltaSeconds = 0;
          _seekBasePosition = state.position;
          _showSeekIndicator = true;
          _showVolumeIndicator = false;
          _showBrightnessIndicator = false;
        });
      },
      onSeekUpdate: (deltaSeconds) {
        setState(() {
          _seekDeltaSeconds += deltaSeconds;
        });
      },
      onSeekEnd: () {
        final target = _seekBasePosition +
            Duration(seconds: _seekDeltaSeconds.round());
        final clamped = target.clamp(Duration.zero, state.duration);
        viewModel.seek(clamped);
        _startHideTimer();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Video surface (bottom).
          const Positioned.fill(
            child: VideoSurface(),
          ),

          // Layer 2: Controls overlay (top).
          Positioned.fill(
            child: PlayerControlsOverlay(itemId: widget.itemId),
          ),

          // Brightness indicator (left side).
          if (_showBrightnessIndicator)
            _buildIndicator(
              alignment: Alignment.centerLeft,
              value: _brightnessValue,
              icon: Icons.brightness_6,
              label: '亮度',
            ),

          // Volume indicator (right side).
          if (_showVolumeIndicator)
            _buildIndicator(
              alignment: Alignment.centerRight,
              value: _volumeValue,
              icon: _volumeValue == 0
                  ? Icons.volume_off
                  : _volumeValue < 0.5
                      ? Icons.volume_down
                      : Icons.volume_up,
              label: '音量',
            ),

          // Seek indicator (bottom center).
          if (_showSeekIndicator)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: _SeekIndicator(
                  deltaSeconds: _seekDeltaSeconds.round(),
                  targetPosition: _seekBasePosition +
                      Duration(seconds: _seekDeltaSeconds.round()),
                ),
              ),
            ),

          // Buffering indicator.
          if (state.isBuffering && !state.isLoading)
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicator({
    required Alignment alignment,
    required double value,
    required IconData icon,
    required String label,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 48,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    width: 4,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          heightFactor: value.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(value.clamp(0.0, 1.0) * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seek indicator overlay
// ---------------------------------------------------------------------------
class _SeekIndicator extends StatelessWidget {
  final int deltaSeconds;
  final Duration targetPosition;

  const _SeekIndicator({
    required this.deltaSeconds,
    required this.targetPosition,
  });

  @override
  Widget build(BuildContext context) {
    final sign = deltaSeconds >= 0 ? '+' : '';
    final timeStr =
        '${targetPosition.inMinutes.remainder(60).toString().padLeft(2, '0')}:'''
        '${targetPosition.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                deltaSeconds >= 0
                    ? Icons.fast_forward
                    : Icons.fast_rewind,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$sign${deltaSeconds}s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            timeStr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading view
// ---------------------------------------------------------------------------
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '加载中...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onBack;

  const _ErrorView({
    required this.error,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white70,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '播放错误',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'An unknown error occurred.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回'),
            ),
          ],
        ),
      ),
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
