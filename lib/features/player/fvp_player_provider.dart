import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fvp/mdk.dart';

/// 全局 fvp Player 单例
///
/// 在整个应用生命周期内复用同一个 [Player] 实例。
/// 切换视频时通过 [Player.media] + [Player.prepare()] 实现，
/// 不需要 dispose 再重建。
///
/// 该 Provider 在应用启动时由 [main.dart] 预热（通过 `ref.read`），
/// 确保 [fvp.registerWith()] 完成后 Player 已就绪。
final fvpPlayerProvider = Provider<Player>((ref) {
  final player = Player();

  ref.onDispose(() {
    // 应用退出时停止并释放 Player
    player.state = PlaybackState.stopped;
    player.dispose();
  });

  return player;
});
