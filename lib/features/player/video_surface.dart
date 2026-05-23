import 'package:emby_client/features/player/fvp_player_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that renders video output from the fvp [Player] via Texture.
///
/// Listens to [Player.textureId] ValueNotifier and renders a Flutter [Texture]
/// widget when the texture is available.
class VideoSurface extends ConsumerWidget {
  const VideoSurface({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(fvpPlayerProvider);
    return ValueListenableBuilder<int?>(
      valueListenable: player.textureId,
      builder: (context, textureId, _) {
        if (textureId == null) {
          return const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
              ),
            ),
          );
        }
        return Center(
          child: AspectRatio(
            aspectRatio: _resolveAspectRatio(player),
            child: Texture(textureId: textureId),
          ),
        );
      },
    );
  }

  /// Resolve aspect ratio from fvp Player's mediaInfo.
  static double _resolveAspectRatio(dynamic player) {
    try {
      final mi = player.mediaInfo;
      final video = mi.video;
      if (video == null || video.isEmpty) return 16 / 9;
      final codec = video.first.codec;
      final w = codec.width;
      final h = codec.height;
      if (w <= 0 || h <= 0) return 16 / 9;
      return w / h;
    } catch (_) {
      return 16 / 9;
    }
  }
}
