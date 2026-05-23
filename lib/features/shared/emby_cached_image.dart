import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:emby_client/core/api/dio_client.dart';
import 'package:emby_client/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emby 服务器图片的统一缓存加载组件。
///
/// 封装了 [CachedNetworkImage] + Emby 认证 token + 图片 tag 缓存 key + 尺寸限制。
/// 所有从 Emby 服务器加载图片的地方都应使用此组件，保持行为一致。
///
/// ## 图片加载优先级
///
/// 通过 [imageTagList] 传入有序的 `(type, value)` 键值对列表，组件按 index 顺序
/// 查找第一个 `value` 不为空字符串 `''` 的项，使用该 `type` 和 `value` 构造图片 URL。
///
/// ```dart
/// EmbyCachedImage(
///   itemId: item.id!,
///   imageTagList: [
///     MapEntry('Primary', item.imageTags?['Primary'] ?? ''),
///     MapEntry('Thumb', item.imageTags?['Thumb'] ?? ''),
///   ],
///   width: 140,
///   height: 210,
/// )
/// ```
///
/// ## 尺寸控制
///
/// 组件支持两种尺寸控制方式：
///
/// 1. **简单模式**：只传 [width]/[height]，组件自动计算 API 参数（2x Retina）
/// 2. **精确模式**：同时传 [width]/[height] + [maxWidth]/[maxHeight]
/// 3. **无约束模式**：不传任何尺寸，让父容器决定
///
/// ## 主题集成
///
/// 默认 placeholder / error 颜色从 [ThemeData.colorScheme] 自动获取：
/// - placeholder 背景 → [ColorScheme.surfaceContainerHighest]
/// - error 图标 → [ColorScheme.onSurfaceVariant]
///
/// 可通过 [placeholderColor] / [errorColor] 直接覆写，无需传入整个 widget。
class EmbyCachedImage extends ConsumerWidget {
  /// 媒体项目 ID
  final String itemId;

  /// 图片类型与 tag 的有序列表，按 index 顺序查找第一个有效值
  ///
  /// value 为 `''`（空字符串）的项会被跳过，用于 null-safety 处理。
  /// 例：
  /// ```dart
  /// [
  ///   MapEntry('Primary', 'abc123'),
  ///   MapEntry('Thumb', ''),           // 跳过
  ///   MapEntry('Logo', 'def456'),
  /// ]
  /// ```
  /// → 使用 Primary / abc123
  final List<MapEntry<String, String>> imageTagList;

  /// Widget 显示宽度
  final double? width;

  /// Widget 显示高度
  final double? height;

  /// 限制图片最大宽度（传给 Emby API）
  ///
  /// 为 null 且传了 [width] 时，自动计算为 `width * 2`（Retina）
  final int? maxWidth;

  /// 限制图片最大高度（传给 Emby API）
  ///
  /// 为 null 且传了 [height] 时，自动计算为 `height * 2`（Retina）
  final int? maxHeight;

  /// 图片填充模式
  final BoxFit fit;

  /// 是否显示默认的 [CircularProgressIndicator] 占位
  ///
  /// 为 `true` 且未传入 [placeholder] 时，显示主题色的加载指示器。
  /// 为 `false`（默认）时，显示纯色背景占位。
  final bool showProgressIndicator;

  /// 占位背景颜色（覆写 Theme 默认值）
  ///
  /// 仅对默认 placeholder 生效；传入 [placeholder] 时忽略。
  final Color? placeholderColor;

  /// 加载中的占位 widget（完全覆写默认占位）
  final Widget? placeholder;

  /// 错误图标颜色（覆写 Theme 默认值）
  ///
  /// 仅对默认 error widget 生效；传入 [errorWidget] 时忽略。
  final Color? errorColor;

  /// 错误图标（覆写默认 [Icons.broken_image]）
  ///
  /// 仅对默认 error widget 生效；传入 [errorWidget] 时忽略。
  final IconData? errorIcon;

  /// 加载失败时的占位 widget（完全覆写错误图）
  final Widget? errorWidget;

  const EmbyCachedImage({
    super.key,
    required this.itemId,
    required this.imageTagList,
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.fit = BoxFit.cover,
    this.showProgressIndicator = false,
    this.placeholderColor,
    this.placeholder,
    this.errorColor,
    this.errorIcon,
    this.errorWidget,
  });

  /// 计算传给 Emby API 的 maxWidth
  int? get _effectiveMaxWidth {
    if (maxWidth != null) return maxWidth;
    if (width != null) return (width! * 2).ceil();
    return null;
  }

  /// 计算传给 Emby API 的 maxHeight
  int? get _effectiveMaxHeight {
    if (maxHeight != null) return maxHeight;
    if (height != null) return (height! * 2).ceil();
    return null;
  }

  /// 从 [imageTagList] 中找到第一个有效的 (type, value) 键值对
  ///
  /// 跳过 value 为空字符串 `''` 的项。
  MapEntry<String, String>? get _effectiveEntry {
    for (final entry in imageTagList) {
      if (entry.value.isNotEmpty) return entry;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final serverUrl = ref.read(embyBaseUrlProvider);
    final token = ref.read(accessTokenProvider);

    final effectiveEntry = _effectiveEntry;

    // 没有有效图片 tag，显示用户传入的 errorWidget 或默认错误 widget
    if (effectiveEntry == null) {
      return _buildSizedWidget(errorWidget ?? _buildDefaultError(colorScheme));
    }

    final imageUrl = EmbyImageUrl.buildImageUrl(
      serverUrl: serverUrl,
      itemId: itemId,
      type: effectiveEntry.key,
      tag: effectiveEntry.value,
      maxWidth: _effectiveMaxWidth,
      maxHeight: _effectiveMaxHeight,
    );

    final effectivePlaceholder = placeholder ??
        _buildDefaultPlaceholder(colorScheme);

    final effectiveError = errorWidget ??
        _buildDefaultError(colorScheme);

    final Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: {'X-Emby-Token': token ?? ''},
      fit: fit,
      placeholder:
          placeholder == null ? null : (context, url) => effectivePlaceholder,
      errorBuilder: (context, url, error) => effectiveError,
    );

    return _buildSizedWidget(image);
  }

  /// 如果指定了 width/height，用 SizedBox 包裹子 widget
  Widget _buildSizedWidget(Widget child) {
    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: child,
      );
    }
    return child;
  }

  /// 构建默认占位 widget
  Widget _buildDefaultPlaceholder(ColorScheme colorScheme) {
    final bgColor = placeholderColor ?? colorScheme.surfaceContainerHighest;

    if (showProgressIndicator) {
      return Container(
        color: bgColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(color: bgColor);
  }

  /// 构建默认错误 widget
  Widget _buildDefaultError(ColorScheme colorScheme) {
    return Container(
      color: placeholderColor ?? colorScheme.surfaceContainerHighest,
      child: Icon(
        errorIcon ?? Icons.broken_image,
        color: errorColor ?? colorScheme.onSurfaceVariant,
      ),
    );
  }
}
