import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Callback types for progress slider interactions.
typedef PositionCallback = void Function(Duration position);

/// A styled slider that shows playback progress, buffered amount, and duration.
///
/// Supports tap-to-seek, drag-to-scrub, and displays formatted timestamps.
class ProgressSlider extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final Duration? bufferedPosition;
  final ValueChanged<Duration> onSeek;

  const ProgressSlider({
    super.key,
    required this.position,
    required this.duration,
    this.bufferedPosition,
    required this.onSeek,
  });

  @override
  State<ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<ProgressSlider> {
  bool _dragging = false;
  double _dragValue = 0.0;

  String get _currentLabel {
    if (_dragging) {
      return _formatDuration(
        Duration(milliseconds: (_dragValue * widget.duration.inMilliseconds).round()),
      );
    }
    return _formatDuration(widget.position);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final maxMs = widget.duration.inMilliseconds;
    final value = maxMs > 0
        ? (_dragging
                ? _dragValue * maxMs
                : widget.position.inMilliseconds)
            .clamp(0, maxMs)
            .toDouble()
        : 0.0;

    final bufferedMs = widget.bufferedPosition?.inMilliseconds ?? 0;
    final bufferedValue = maxMs > 0
        ? bufferedMs.clamp(0, maxMs).toDouble() / maxMs
        : 0.0;

    final progressValue = maxMs > 0 ? value / maxMs : 0.0;

    return Semantics(
      label: 'Progress bar, ${_formatDuration(widget.position)} of ${_formatDuration(widget.duration)}',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null || maxMs <= 0) return;
          final localPos = box.globalToLocal(details.globalPosition);
          final ratio = (localPos.dx / box.size.width).clamp(0.0, 1.0);
          final targetMs = (ratio * maxMs).round();
          HapticFeedback.lightImpact();
          widget.onSeek(Duration(milliseconds: targetMs));
        },
        onHorizontalDragStart: (_) {
          setState(() => _dragging = true);
        },
        onHorizontalDragUpdate: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null || maxMs <= 0) return;
          final localPos = details.localPosition;
          final ratio = (localPos.dx / box.size.width).clamp(0.0, 1.0);
          setState(() => _dragValue = ratio);
        },
        onHorizontalDragEnd: (_) {
          final targetMs = (_dragValue * maxMs).round();
          widget.onSeek(Duration(milliseconds: targetMs));
          setState(() => _dragging = false);
        },
        onHorizontalDragCancel: () {
          setState(() => _dragging = false);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar track with buffered indicator.
              SizedBox(
                height: 20,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background track (unplayed).
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    // Buffered track.
                    if (bufferedValue > 0)
                      FractionallySizedBox(
                        widthFactor: bufferedValue,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ),
                    // Played track.
                    FractionallySizedBox(
                      widthFactor: progressValue,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                    // Thumb indicator.
                    FractionallySizedBox(
                      widthFactor: progressValue,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Time labels.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      _formatDuration(widget.duration),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats a [Duration] into `HH:MM:SS` or `MM:SS`.
  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      final hh = hours.toString().padLeft(2, '0');
      return '$hh:$mm:$ss';
    }
    return '$mm:$ss';
  }
}
