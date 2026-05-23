import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/features/shared/emby_cached_image.dart';
import 'package:flutter/material.dart';

/// 制片公司名称组件，优先显示 Logo/Primary 图片，否则显示文字名称。
///
/// ## 图片优先逻辑
/// 1. 检查 [studio.imageTags] 中是否存在 `'Primary'` 或 `'Thumb'` 类型的图片
/// 2. 如果存在，使用 [EmbyCachedImage] 加载并显示
/// 3. 如果不存在，显示 [studio.name] 文字
///
/// ## 使用示例
/// ```dart
/// StudioName(studio: studioDetail, maxWidth: 120, maxHeight: 40)
/// ```
class StudioName extends StatelessWidget {
  /// Studio 详情数据（来自 [getStudioDetail]）
  final BaseItemDto studio;

  /// 图片最大宽度
  final double? maxWidth;

  /// 图片最大高度
  final double? maxHeight;

  /// 文字名称样式（覆写 Theme 默认值）
  final TextStyle? textStyle;

  /// 点击回调
  final VoidCallback? onTap;

  const StudioName({
    super.key,
    required this.studio,
    this.maxWidth,
    this.maxHeight,
    this.textStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = studio.name ?? 'Studio';

    Widget child;
    if (studio.id != null) {
      child = EmbyCachedImage(
        itemId: studio.id!,
        imageTagList: [
          MapEntry('Primary', studio.imageTags?['Primary'] ?? ''),
          MapEntry('Thumb', studio.imageTags?['Thumb'] ?? ''),
        ],
        maxWidth: (maxWidth ?? 120).toInt(),
        maxHeight: (maxHeight ?? 40).toInt(),
        fit: BoxFit.contain,
        errorWidget: _buildText(context, colorScheme, name),
      );
    } else {
      child = _buildText(context, colorScheme, name);
    }

    if (onTap != null) {
      child = GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }

  Widget _buildText(BuildContext context, ColorScheme colorScheme, String name) {
    return Text(
      name,
      style: textStyle ??
          TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
    );
  }
}
