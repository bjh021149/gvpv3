import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the global navigation history service.
final navigationHistoryProvider = Provider<NavigationHistoryService>((ref) {
  return NavigationHistoryService();
});

/// 记录 GoRouter 导航历史，类似浏览器的前进/后退历史。
///
/// 在 [GoRouter.redirect] 中调用 [onLocationChanged] 来记录每次路由变化。
/// 播放页点击后退时，通过 [previousLocation] 获取进入播放页之前的页面路径。
class NavigationHistoryService {
  final List<String> _history = [];
  String? _current;

  /// 只读的历史记录列表（最早的在前）。
  List<String> get history => List.unmodifiable(_history);

  /// 当前页面路径。
  String? get currentLocation => _current;

  /// 路由变化时调用。相同位置会被去重。
  void onLocationChanged(String location) {
    if (_current == location) return;
    _history.add(location);
    _current = location;
    // 限制历史长度，防止内存泄漏
    if (_history.length > 50) _history.removeAt(0);
  }

  /// 获取进入当前页面前的上一个页面路径。
  ///
  /// 返回 null 表示历史记录不足（例如 deep link 直接进入播放页且之前没有浏览记录）。
  String? get previousLocation {
    if (_history.length < 2) return null;
    return _history[_history.length - 2];
  }

  /// 清空历史记录。
  void clear() {
    _history.clear();
    _current = null;
  }
}
