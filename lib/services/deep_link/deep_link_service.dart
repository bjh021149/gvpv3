import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

/// 深度链接解析结果
///
/// 封装解析后的内部路由路径和查询参数，便于测试和扩展。
class DeepLinkResult {
  /// 解析后的内部路由路径（如 `/detail/123`）
  final String? path;

  /// 原始 URI
  final Uri uri;

  /// 是否被识别为有效的深度链接
  bool get isHandled => path != null;

  const DeepLinkResult._({this.path, required this.uri});

  /// 构造未匹配的结果
  factory DeepLinkResult.unhandled(Uri uri) => DeepLinkResult._(uri: uri);

  /// 构造已处理的结果
  factory DeepLinkResult.handled({required String path, required Uri uri}) {
    return DeepLinkResult._(path: path, uri: uri);
  }

  @override
  String toString() => 'DeepLinkResult(path: $path, uri: $uri)';
}

/// 深度链接服务
///
/// 基于 [app_links](https://pub.dev/packages/app_links) 封装，负责：
/// 1. 监听应用冷启动时的初始深度链接
/// 2. 监听应用运行中的深度链接（热启动）
/// 3. 将外部 URI 解析为应用内部路由路径
/// 4. 通过 [GoRouter] 执行导航
///
/// 支持的自定义 URL Scheme：`emby://`
///
/// | 深度链接 | 内部路由 | 说明 |
/// |----------|----------|------|
/// | `emby://detail/:id` | `/detail/:id` | 详情页 |
/// | `emby://player/:id` | `/player/:id` | 播放页 |
/// | `emby://library` | `/library` | 媒体库 |
/// | `emby://library/:parentId` | `/library/:parentId` | 子媒体库 |
/// | `emby://home` | `/home` | 首页 |
/// | `emby://settings` | `/settings` | 设置 |
///
/// 使用示例：
/// ```dart
/// final service = DeepLinkService(router: router);
/// await service.init();
/// ```
class DeepLinkService {
  final AppLinks _appLinks;
  final GoRouter _router;
  StreamSubscription<Uri>? _subscription;

  /// 最后一次解析的深度链接结果（仅用于调试/测试）
  DeepLinkResult? _lastResult;
  DeepLinkResult? get lastResult => _lastResult;

  DeepLinkService({
    required GoRouter router,
    AppLinks? appLinks,
  })  : _router = router,
        _appLinks = appLinks ?? AppLinks();

  /// 初始化深度链接监听
  ///
  /// 1. 处理冷启动时的初始链接
  /// 2. 订阅后续链接流（热启动）
  Future<void> init() async {
    // 处理冷启动时的初始链接
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }

    // 监听后续链接（热启动）
    _subscription = _appLinks.uriLinkStream.listen(_handleUri);
  }

  /// 处理单个 URI
  ///
  /// 将外部深度链接解析为内部路由路径，并通过 GoRouter 导航。
  /// 若用户未认证，GoRouter 的 [redirect] 会将其重定向到登录页。
  void _handleUri(Uri uri) {
    final result = resolveUri(uri);
    _lastResult = result;

    if (result.isHandled && result.path != null) {
      _router.go(result.path!);
    }
  }

  /// 将外部 URI 解析为内部路由路径
  ///
  /// 解析规则：
  /// - Scheme 必须是 `emby`
  /// - Host 作为一级路径 segment
  /// - 后续 segments 作为路径参数
  ///
  /// 例如 `emby://detail/123` → `/detail/123`
  static DeepLinkResult resolveUri(Uri uri) {
    // 仅处理 emby:// scheme
    if (uri.scheme != 'emby') {
      return DeepLinkResult.unhandled(uri);
    }

    final host = uri.host;
    if (host.isEmpty) {
      return DeepLinkResult.unhandled(uri);
    }

    final segments = <String>[host, ...uri.pathSegments]
        .where((s) => s.isNotEmpty)
        .toList();

    if (segments.isEmpty) {
      return DeepLinkResult.unhandled(uri);
    }

    // 构建内部路径
    final buffer = StringBuffer('/');
    buffer.write(segments.join('/'));

    // 保留查询参数
    if (uri.query.isNotEmpty) {
      buffer.write('?${uri.query}');
    }

    final path = buffer.toString();

    // 验证路径是否匹配已知路由（简化校验：只允许已知前缀）
    if (!_isValidRoute(path)) {
      return DeepLinkResult.unhandled(uri);
    }

    return DeepLinkResult.handled(path: path, uri: uri);
  }

  /// 校验路径是否为应用支持的有效路由前缀
  static bool _isValidRoute(String path) {
    const validPrefixes = [
      '/detail/',
      '/player/',
      '/library',
      '/home',
      '/settings',
    ];

    return validPrefixes.any((prefix) => path.startsWith(prefix));
  }

  /// 释放资源，取消流订阅
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
