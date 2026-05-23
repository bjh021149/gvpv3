import 'dart:async';

import 'package:emby_client/core/api/dio_client.dart';
import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/core/models/media_source_info.dart';
import 'package:emby_client/features/player/fvp_player_provider.dart';
import 'package:emby_client/services/repositories/auth_repository_impl.dart';
import 'package:emby_client/services/repositories/media_repository_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fvp/mdk.dart';

/// Provider for the player view model, keyed by item ID.
final playerViewModelProvider =
    AsyncNotifierProvider.family<PlayerViewModel, PlayerState, String>(
  PlayerViewModel.new,
);

/// Immutable state representing the current player configuration and playback status.
class PlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double volume;
  final List<VideoStreamInfo>? videoTracks;
  final List<AudioStreamInfo>? audioTracks;
  final List<SubtitleStreamInfo>? subtitleTracks;
  final int selectedVideoIndex;
  final int selectedAudioIndex;
  final int selectedSubtitleIndex;
  final List<MediaSourceInfo> mediaSources;
  final String? selectedMediaSourceId;
  final String? error;
  final bool isControlsVisible;
  final bool isBuffering;
  final bool isFullScreen;
  final BaseItemDto? item;
  final MediaSourceInfo? currentSource;

  const PlayerState({
    this.isPlaying = false,
    this.isLoading = true,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.videoTracks = const [],
    this.audioTracks = const [],
    this.subtitleTracks = const [],
    this.selectedVideoIndex = 0,
    this.selectedAudioIndex = 0,
    this.selectedSubtitleIndex = -1,
    this.mediaSources = const [],
    this.selectedMediaSourceId,
    this.error,
    this.isControlsVisible = true,
    this.isBuffering = false,
    this.isFullScreen = false,
    this.item,
    this.currentSource,
  });

  PlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? volume,
    List<VideoStreamInfo>? videoTracks,
    List<AudioStreamInfo>? audioTracks,
    List<SubtitleStreamInfo>? subtitleTracks,
    int? selectedVideoIndex,
    int? selectedAudioIndex,
    int? selectedSubtitleIndex,
    List<MediaSourceInfo>? mediaSources,
    String? selectedMediaSourceId,
    String? error,
    bool? isControlsVisible,
    bool? isBuffering,
    bool? isFullScreen,
    BaseItemDto? item,
    MediaSourceInfo? currentSource,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      videoTracks: videoTracks ?? this.videoTracks,
      audioTracks: audioTracks ?? this.audioTracks,
      subtitleTracks: subtitleTracks ?? this.subtitleTracks,
      selectedVideoIndex: selectedVideoIndex ?? this.selectedVideoIndex,
      selectedAudioIndex: selectedAudioIndex ?? this.selectedAudioIndex,
      selectedSubtitleIndex: selectedSubtitleIndex ?? this.selectedSubtitleIndex,
      mediaSources: mediaSources ?? this.mediaSources,
      selectedMediaSourceId: selectedMediaSourceId ?? this.selectedMediaSourceId,
      error: error,
      isControlsVisible: isControlsVisible ?? this.isControlsVisible,
      isBuffering: isBuffering ?? this.isBuffering,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      item: item ?? this.item,
      currentSource: currentSource ?? this.currentSource,
    );
  }
}

/// ViewModel that manages media playback using fvp.
///
/// Design rules:
/// - [mediaInfo] is ONLY read after [MediaStatus.loaded] is true.
/// - [build()] blocks until loaded so it can return the final state directly,
///   eliminating any race between the async event stream and Riverpod's initial
///   state assignment.
/// - Runtime updates (buffering, end, state changes) are driven by
///   [PlaybackState] and [MediaStatus] streams.
class PlayerViewModel extends AsyncNotifier<PlayerState> {
  final String itemId;
  PlayerViewModel(this.itemId);

  Timer? _controlsHideTimer;
  Timer? _positionTimer;
  StreamSubscription? _stateSub;
  StreamSubscription? _mediaSub;

  Player get _player => ref.read(fvpPlayerProvider);

  @override
  Future<PlayerState> build() async {
    ref.onDispose(() {
      _cancelControlsTimer();
      _stopTimers();
      _detachPlayerListeners();
      try {
        _player.state = PlaybackState.paused;
        
      } catch (_) {}
      scheduleMicrotask(() async {
        await _player.updateTexture(width: -1);
         _player.setActiveTracks(MediaType.video, [-1]);
         _player.setActiveTracks(MediaType.audio, [-1]);
         _player.setActiveTracks(MediaType.subtitle, [-1]);
        await Future.delayed(const Duration(milliseconds: 50));
        try {
          _player.state = PlaybackState.stopped;
        } catch (_) {}
      });
    });

    try {
      final mediaRepo = ref.read(mediaRepositoryProvider);
      debugPrint('[Player] Fetching playback info for itemId=$itemId');
      final playbackInfo = await mediaRepo.getPlaybackInfo(itemId);
      final item = await mediaRepo.getItemDetail(itemId);

      final sources = playbackInfo.mediaSources;
      if (sources.isEmpty) {
        return PlayerState(
          isLoading: false,
          error: 'No media sources available',
          item: item,
        );
      }

      final source = sources.firstWhere(
        (s) => s.supportsDirectStream == true,
        orElse: () => sources.first,
      );

      final serverUrl = ref.read(embyBaseUrlProvider);
      final token = await ref.read(authRepositoryProvider).getAccessToken();
      final streamId = source.id ?? itemId;
      final directUrl =
          '$serverUrl/Videos/$streamId/stream'
          '?Static=true'
          '&api_key=$token';
      debugPrint('[Player] directUrl=$directUrl');

      final player = _player;
      // Attach runtime listeners BEFORE prepare() so no event is lost.
      
      _attachRuntimeListeners();
      player.media = directUrl;
      player.volume = 1.0;
      player.setBufferRange(min: 10000, max: 500000, drop: false);
      

      final resumeTicks = item.userData?.playbackPositionTicks ?? 0;
      final resumeMs = resumeTicks ~/ 10000;
      final result = await player.prepare(position: resumeMs);
      debugPrint('[Player] prepare result: $result');

      if (result == -10 || result == -4) {
        _detachPlayerListeners();
        return PlayerState(
          isLoading: false,
          error: '视频准备失败 (code $result)',
          item: item,
        );
      }

      // === CRITICAL: block until MediaStatus.loaded ===
      // mediaInfo is only safe to read after this.
      try {
        await _waitForMediaLoaded(timeout: const Duration(seconds: 15));
      } on TimeoutException catch (_) {
        _detachPlayerListeners();
        return PlayerState(
          isLoading: false,
          error: '媒体加载超时',
          item: item,
        );
      }

      // === Read mediaInfo (guaranteed loaded) ===
      final info = player.mediaInfo;

      final selectedAudioIndex =
          (info.audio != null && info.audio!.isNotEmpty) ? 0 : -1;
      final selectedSubtitleIndex =
          (info.subtitle != null && info.subtitle!.isNotEmpty) ? 0 : -1;

      if (selectedAudioIndex >= 0) {
        try { player.activeAudioTracks = [selectedAudioIndex]; } catch (_) {}
      }
      if (selectedSubtitleIndex >= 0) {
        try { player.activeSubtitleTracks = [selectedSubtitleIndex]; } catch (_) {}
      }

      await player.updateTexture();
      player.state = PlaybackState.playing;
      _startPositionTimer();

      return PlayerState(
        isLoading: false,
        isPlaying: true,
        videoTracks: info.video,
        audioTracks: info.audio,
        subtitleTracks: info.subtitle,
        duration: Duration(milliseconds: info.duration),
        selectedAudioIndex: selectedAudioIndex,
        selectedSubtitleIndex: selectedSubtitleIndex,
        mediaSources: sources,
        selectedMediaSourceId: source.id,
        item: item,
        currentSource: source,
      );
    } catch (e, st) {
      debugPrint('[Player] build error: $e\n$st');
      return PlayerState(isLoading: false, error: e.toString());
    }
  }

  /// Blocks the caller until [MediaStatus.loaded] becomes true.
  Future<void> _waitForMediaLoaded({Duration timeout = const Duration(seconds: 15)}) async {
    final player = _player;
    if (player.mediaStatus.test(MediaStatus.loaded)) return;

    final completer = Completer<void>();
    late StreamSubscription sub;
    sub = player.onMediaStatus.listen((event) {
      if (event.newValue.test(MediaStatus.loaded)) {
        sub.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    await completer.future.timeout(
      timeout,
      onTimeout: () {
        sub.cancel();
        throw TimeoutException('Media load timeout');
      },
    );
  }

  /// Handles runtime events: buffering, playback end, errors.
  /// Initial loaded setup is done synchronously in [build] to avoid races.
  void _attachRuntimeListeners() {
    final player = _player;

    _stateSub = player.onStateChanged.listen((event) {
      final isPlaying = event.newValue == PlaybackState.playing;
      _updateState((s) => s.copyWith(isPlaying: isPlaying));
    });

    _mediaSub = player.onMediaStatus.listen((event) {
      final newStatus = event.newValue;

      final isBuffering = newStatus.test(MediaStatus.buffering) ||
          newStatus.test(MediaStatus.stalled);
      _updateState((s) => s.copyWith(isBuffering: isBuffering));

      if (newStatus.test(MediaStatus.invalid)) {
        _updateState((s) => s.copyWith(
              isLoading: false,
              isBuffering: false,
              error: s.error ?? '媒体加载失败或格式不支持',
            ));
      }

      if (newStatus.test(MediaStatus.end)) {
        _updateState((s) => s.copyWith(isPlaying: false));
      }
    });
  }

  void _startPositionTimer() {
    _stopTimers();
    final player = _player;
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      try {
        final posMs = player.position;
        _updateState((s) => s.copyWith(
              position: Duration(milliseconds: posMs),
            ));
      } catch (_) {}
    });
  }

  void _stopTimers() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  void _detachPlayerListeners() {
    _stateSub?.cancel();
    _stateSub = null;
    _mediaSub?.cancel();
    _mediaSub = null;
  }

  void playPause() {
    try {
      final player = _player;
      if (player.state == PlaybackState.playing) {
        player.state = PlaybackState.paused;
      } else {
        player.state = PlaybackState.playing;
      }
    } catch (_) {}
  }

  void toggleFullScreen() {
    final current = state.value;
    if (current == null) return;
    _updateState((s) => s.copyWith(isFullScreen: !s.isFullScreen));
  }

  void seek(Duration position) {
    try {
      _player.seek(position: position.inMilliseconds);
    } catch (_) {}
  }

  void setVolume(double volume) {
    try {
      final clamped = volume.clamp(0.0, 1.0);
      _player.volume = clamped;
      _updateState((s) => s.copyWith(volume: clamped));
    } catch (_) {}
  }

  Future<void> switchMediaSource(String sourceId) async {
    final current = state.value;
    if (current == null) return;
    if (sourceId == current.selectedMediaSourceId) return;

    final source = current.mediaSources.firstWhere(
      (s) => s.id == sourceId,
      orElse: () => current.currentSource!,
    );

    try {
      final resumePos = _player.position;

      final serverUrl = ref.read(embyBaseUrlProvider);
      final token = await ref.read(authRepositoryProvider).getAccessToken();
      final streamId = source.id ?? itemId;
      final directUrl =
          '$serverUrl/Videos/$streamId/stream'
          '?Static=true'
          '&api_key=$token';

      _stopTimers();

      _updateState((s) => s.copyWith(
            isLoading: true,
            isPlaying: false,
            isBuffering: false,
            selectedMediaSourceId: sourceId,
            currentSource: source,
            videoTracks: const [],
            audioTracks: const [],
            subtitleTracks: const [],
            selectedVideoIndex: 0,
            selectedAudioIndex: 0,
            selectedSubtitleIndex: -1,
            duration: Duration.zero,
            position: Duration.zero,
            error: null,
          ));

      _player.media = directUrl;
      final result = await _player.prepare(position: resumePos);
      if (result == -10 || result == -4) {
        _updateState((s) => s.copyWith(
              isLoading: false,
              error: '切换源失败 (code $result)',
            ));
        return;
      }

      await _waitForMediaLoaded();

      final info = _player.mediaInfo;

      final selectedAudioIndex =
          (info.audio != null && info.audio!.isNotEmpty) ? 0 : -1;
      final selectedSubtitleIndex =
          (info.subtitle != null && info.subtitle!.isNotEmpty) ? 0 : -1;

      if (selectedAudioIndex >= 0) {
        try { _player.activeAudioTracks = [selectedAudioIndex]; } catch (_) {}
      }
      if (selectedSubtitleIndex >= 0) {
        try { _player.activeSubtitleTracks = [selectedSubtitleIndex]; } catch (_) {}
      }

      await _player.updateTexture();
      _player.state = PlaybackState.playing;
      _startPositionTimer();

      _updateState((s) => s.copyWith(
            isLoading: false,
            isPlaying: true,
            videoTracks: info.video,
            audioTracks: info.audio,
            subtitleTracks: info.subtitle,
            duration: Duration(milliseconds: info.duration),
            selectedAudioIndex: selectedAudioIndex,
            selectedSubtitleIndex: selectedSubtitleIndex,
          ));
    } catch (e, st) {
      debugPrint('[Player] switchMediaSource error: $e\n$st');
      _updateState((s) => s.copyWith(
            isLoading: false,
            error: '切换源失败: $e',
          ));
    }
  }

  void selectVideoTrack(int index) {
    final current = state.value;
    if (current == null) return;
    final tracks = current.videoTracks;
    if (tracks == null || index < 0 || index >= tracks.length) return;

    try {
      _player.activeVideoTracks = [index];
      _updateState((s) => s.copyWith(selectedVideoIndex: index));
    } catch (_) {}
  }

  void selectAudioTrack(int index) {
    final current = state.value;
    if (current == null) return;
    final tracks = current.audioTracks;
    if (tracks == null || index < 0 || index >= tracks.length) return;

    try {
      _player.activeAudioTracks = [index];
      _updateState((s) => s.copyWith(selectedAudioIndex: index));
    } catch (e) {
      debugPrint('[PlayerViewModel] Failed to switch audio track: $e');
    }
  }

  void selectSubtitleTrack(int index) {
    final current = state.value;
    if (current == null) return;

    if (index == -1) {
      try { _player.activeSubtitleTracks = []; } catch (_) {}
      _updateState((s) => s.copyWith(selectedSubtitleIndex: -1));
      return;
    }

    final tracks = current.subtitleTracks;
    if (tracks == null || index < 0 || index >= tracks.length) return;

    try { _player.activeSubtitleTracks = [index]; } catch (_) {}
    _updateState((s) => s.copyWith(selectedSubtitleIndex: index));
  }

  void toggleControls() {
    final current = state.value;
    if (current == null) return;
    final willShow = !current.isControlsVisible;
    _updateState((s) => s.copyWith(isControlsVisible: willShow));
    if (willShow) {
      _startControlsHideTimer();
    } else {
      _cancelControlsTimer();
    }
  }

  void showControlsTemporarily() {
    _updateState((s) => s.copyWith(isControlsVisible: true));
    _startControlsHideTimer();
  }

  void _startControlsHideTimer() {
    _cancelControlsTimer();
    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      final current = state.value;
      if (current != null && current.isPlaying) {
        _updateState((s) => s.copyWith(isControlsVisible: false));
      }
    });
  }

  void _cancelControlsTimer() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = null;
  }

  void _updateState(PlayerState Function(PlayerState) updater) {
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(updater(current));
    }
  }
}
