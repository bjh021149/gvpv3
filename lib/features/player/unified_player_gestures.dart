import 'dart:async';
import 'package:flutter/material.dart';

enum _GestureMode { none, seeking, volume, brightness }

enum _TouchState { idle, down, sliding }

/// 统一播放器手势组件，使用原始指针事件精确识别多种手势。
///
/// 支持的交互：
/// - 单击 → [onTap]（位移 < 20px，时长 < 200ms）
/// - 双击 → [onDoubleTap]（两次间隔 < 300ms）
/// - 左侧垂直滑动 → [onBrightnessAdjust]（deltaFraction，负值增加）
/// - 右侧垂直滑动 → [onVolumeAdjust]（deltaFraction，负值增加）
/// - 水平滑动 → [onSeekStart] / [onSeekUpdate]（deltaSeconds）/ [onSeekEnd]
/// - 双指捏合 → [onPinchIn] / [onPinchOut]
class UnifiedPlayerGestures extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final void Function(double deltaFraction)? onVolumeAdjust;
  final void Function(double deltaFraction)? onBrightnessAdjust;
  final VoidCallback? onSeekStart;
  final void Function(double deltaSeconds)? onSeekUpdate;
  final VoidCallback? onSeekEnd;
  final VoidCallback? onPinchIn;
  final VoidCallback? onPinchOut;

  /// 单击最大位移（像素）。
  final double tapDisplacementThreshold;

  /// 单击最长持续时间。
  final Duration tapDurationThreshold;

  /// 双击两次点击最大间隔。
  final Duration doubleTapInterval;

  /// 进入滑动模式的最小位移。
  final double directionThreshold;

  /// 触发捏合的最小距离变化（像素）。
  final double pinchThreshold;

  /// 单指启动延迟：若期间出现第二指则进入双指模式。
  final Duration singleStartDelay;

  /// 灵敏度（负值自动按屏幕尺寸计算）。
  final double volumeSensitivity;
  final double brightnessSensitivity;
  final double seekSensitivity;

  const UnifiedPlayerGestures({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onVolumeAdjust,
    this.onBrightnessAdjust,
    this.onSeekStart,
    this.onSeekUpdate,
    this.onSeekEnd,
    this.onPinchIn,
    this.onPinchOut,
    this.tapDisplacementThreshold = 20.0,
    this.tapDurationThreshold = const Duration(milliseconds: 200),
    this.doubleTapInterval = const Duration(milliseconds: 300),
    this.directionThreshold = 10.0,
    this.pinchThreshold = 30.0,
    this.singleStartDelay = const Duration(milliseconds: 150),
    this.volumeSensitivity = -1,
    this.brightnessSensitivity = -1,
    this.seekSensitivity = -1,
  });

  @override
  State<UnifiedPlayerGestures> createState() => _UnifiedPlayerGesturesState();
}

class _UnifiedPlayerGesturesState extends State<UnifiedPlayerGestures> {
  _TouchState _state = _TouchState.idle;
  Offset _downPos = Offset.zero;
  Duration _downTime = Duration.zero;
  double _totalDx = 0;
  double _totalDy = 0;
  _GestureMode _mode = _GestureMode.none;
  bool _isLeftSide = false;

  double _screenHeight = 1;
  double _screenWidth = 1;

  // 双击检测
  Duration? _lastTapTime;
  Offset? _lastTapPos;
  Timer? _singleTapTimer;

  // 单指启动延迟
  Timer? _singleStartTimer;
  Offset _pendingDownPos = Offset.zero;
  Duration _pendingDownTime = Duration.zero;

  // 双指捏合
  final Map<int, Offset> _activePointers = {};
  bool _isPinching = false;
  double _pinchStartDistance = 0;
  double _totalPinchChange = 0;

  double get _volumeSensitivity => widget.volumeSensitivity >= 0
      ? widget.volumeSensitivity
      : 2.0 / _screenHeight;

  double get _brightnessSensitivity => widget.brightnessSensitivity >= 0
      ? widget.brightnessSensitivity
      : 2.0 / _screenHeight;

  double get _seekSensitivity => widget.seekSensitivity >= 0
      ? widget.seekSensitivity
      : 90.0 / _screenWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _screenHeight = size.height;
    _screenWidth = size.width;
  }

  @override
  void dispose() {
    _singleTapTimer?.cancel();
    _singleStartTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isPinching) {
      _activePointers[event.pointer] = event.localPosition;
      return;
    }

    if (_activePointers.isNotEmpty) {
      _activePointers[event.pointer] = event.localPosition;
      if (_activePointers.length == 2) {
        _singleStartTimer?.cancel();
        _singleStartTimer = null;
        if (_mode == _GestureMode.seeking) {
          widget.onSeekEnd?.call();
        }
        _state = _TouchState.idle;
        _isPinching = true;
        final points = _activePointers.values.toList();
        _pinchStartDistance = (points[0] - points[1]).distance;
        _totalPinchChange = 0;
      }
      return;
    }

    _activePointers[event.pointer] = event.localPosition;
    _pendingDownPos = event.localPosition;
    _pendingDownTime = event.timeStamp;

    _singleStartTimer?.cancel();
    _singleStartTimer = Timer(widget.singleStartDelay, _startSingleGesture);
  }

  void _startSingleGesture() {
    _singleStartTimer = null;
    _downPos = _pendingDownPos;
    _downTime = _pendingDownTime;
    _totalDx = 0;
    _totalDy = 0;
    _mode = _GestureMode.none;
    _isLeftSide = _downPos.dx < _screenWidth / 2;
    _state = _TouchState.down;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_activePointers.containsKey(event.pointer)) return;
    _activePointers[event.pointer] = event.localPosition;

    if (_isPinching) {
      if (_activePointers.length == 2) {
        final points = _activePointers.values.toList();
        final currentDistance = (points[0] - points[1]).distance;
        _totalPinchChange = currentDistance - _pinchStartDistance;
      }
      return;
    }

    if (_singleStartTimer != null) return;
    if (_state == _TouchState.idle) return;

    _totalDx = event.localPosition.dx - _downPos.dx;
    _totalDy = event.localPosition.dy - _downPos.dy;

    if (_state == _TouchState.down) {
      if (_totalDy.abs() > widget.directionThreshold) {
        _state = _TouchState.sliding;
        _mode = _isLeftSide ? _GestureMode.brightness : _GestureMode.volume;
      } else if (_totalDx.abs() > widget.directionThreshold) {
        _state = _TouchState.sliding;
        _mode = _GestureMode.seeking;
        widget.onSeekStart?.call();
      }
    }

    if (_state == _TouchState.sliding) {
      switch (_mode) {
        case _GestureMode.brightness:
          widget.onBrightnessAdjust?.call(
            -event.delta.dy * _brightnessSensitivity,
          );
        case _GestureMode.volume:
          widget.onVolumeAdjust?.call(-event.delta.dy * _volumeSensitivity);
        case _GestureMode.seeking:
          widget.onSeekUpdate?.call(event.delta.dx * _seekSensitivity);
        case _GestureMode.none:
          break;
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_activePointers.containsKey(event.pointer)) return;
    _activePointers.remove(event.pointer);

    if (_isPinching) {
      if (_activePointers.length < 2) {
        if (_totalPinchChange.abs() > widget.pinchThreshold) {
          if (_totalPinchChange > 0) {
            widget.onPinchOut?.call();
          } else {
            widget.onPinchIn?.call();
          }
        }
        _isPinching = false;
        _pinchStartDistance = 0;
        _totalPinchChange = 0;
        _activePointers.clear();
      }
      return;
    }

    if (_singleStartTimer != null) {
      _singleStartTimer?.cancel();
      _singleStartTimer = null;
      final duration = event.timeStamp - _pendingDownTime;
      final displacement = (event.localPosition - _pendingDownPos).distance;
      if (duration < widget.tapDurationThreshold &&
          displacement < widget.tapDisplacementThreshold) {
        _handlePossibleTap(event.localPosition, event.timeStamp);
      }
      return;
    }

    if (_state == _TouchState.idle) return;

    final duration = event.timeStamp - _downTime;
    final displacement = _totalDx.abs() + _totalDy.abs();

    if (_state == _TouchState.down &&
        duration < widget.tapDurationThreshold &&
        displacement < widget.tapDisplacementThreshold) {
      _handlePossibleTap(event.localPosition, event.timeStamp);
    } else if (_state == _TouchState.sliding && _mode == _GestureMode.seeking) {
      widget.onSeekEnd?.call();
    }

    _state = _TouchState.idle;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_activePointers.containsKey(event.pointer)) return;
    _activePointers.remove(event.pointer);
    if (_isPinching && _activePointers.length < 2) {
      _isPinching = false;
      _pinchStartDistance = 0;
      _totalPinchChange = 0;
      _activePointers.clear();
    }
    _singleStartTimer?.cancel();
    _singleStartTimer = null;
    _state = _TouchState.idle;
  }

  void _handlePossibleTap(Offset pos, Duration now) {
    if (_lastTapTime != null &&
        _lastTapPos != null &&
        (now - _lastTapTime!) < widget.doubleTapInterval &&
        (_lastTapPos! - pos).distance < 50) {
      _singleTapTimer?.cancel();
      _singleTapTimer = null;
      _lastTapTime = null;
      _lastTapPos = null;
      widget.onDoubleTap?.call();
    } else {
      _singleTapTimer?.cancel();
      _lastTapTime = now;
      _lastTapPos = pos;
      _singleTapTimer = Timer(const Duration(milliseconds: 300), () {
        widget.onTap?.call();
        _lastTapTime = null;
        _lastTapPos = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: widget.child,
    );
  }
}
