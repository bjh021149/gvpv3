import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/features/shared/emby_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 媒体标题组件，优先显示 Logo 图片，否则显示文字标题。
///
/// ## 图片优先逻辑
/// 1. 检查 [BaseItemDto.imageTags] 中是否存在 `'Logo'` 类型的图片
/// 2. 如果存在，使用 [EmbyCachedImage] 加载并显示 Logo
/// 3. 如果不存在，根据 [BaseItemDto.type] 显示格式化的文字标题
///
/// ## 文字标题格式
/// - `Movie` → 电影名称
/// - `Series` → 剧集名称
/// - `Season` → 剧集名称 - 季名称
/// - `Episode` → 剧集名称 S{季}E{集} - 集名称
/// - 其他 → 名称
///
/// ## 样式
/// 文字样式优先从 [ThemeData.textTheme] 获取，颜色跟随主题，支持外部覆写。
///
/// ## 布局说明
/// 本组件不处理对齐，返回的 widget 宽度为内容自适应宽度。
/// 调用方应在外部通过 `Column(crossAxisAlignment: CrossAxisAlignment.start)`、
/// `Align` 或 `Row` 等方式控制对齐。
///
/// 使用示例：
/// ```dart
/// Column(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   children: [
///     LogoTitle(
///       item: movieItem,
///       logoMaxHeight: 80,
///       textStyle: Theme.of(context).textTheme.headlineMedium,
///     ),
///     Text('2024'),
///   ],
/// )
/// ```
class LogoTitle extends ConsumerWidget {
  /// 媒体项目数据
  final BaseItemDto item;

  /// Logo 图片 API 最大高度（限制服务器返回图片尺寸）
  final int? logoMaxHeight;

  /// Logo 图片 API 最大宽度（限制服务器返回图片尺寸）
  final int? logoMaxWidth;

  /// 文字标题样式（覆写 Theme 默认值）
  final TextStyle? textStyle;

  /// 文字标题颜色（覆写 [textStyle] 中的颜色）
  final Color? textColor;

  /// 文字对齐方式
  final TextAlign? textAlign;

  /// 文字最大行数
  final int? maxLines;

  /// 文字溢出处理
  final TextOverflow? overflow;

  const LogoTitle({
    super.key,
    required this.item,
    this.logoMaxHeight,
    this.logoMaxWidth,
    this.textStyle,
    this.textColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// 判断是否存在 Logo 图片
  bool get _hasLogo {
    final logoTag = item.imageTags?['Logo'];
    return logoTag != null && logoTag.isNotEmpty;
  }

  /// 根据 [BaseItemDto.type] 构建文字标题
  String get _titleText {
    final type = item.type;
    final name = item.name;

    switch (type) {
      case 'Episode':
        final seriesName = item.seriesName;
        final seasonNum = item.parentIndexNumber;
        final episodeNum = item.indexNumber;
        final parts = <String>[];

        if (seriesName != null && seriesName.isNotEmpty) {
          parts.add(seriesName);
        }
        if (seasonNum != null || episodeNum != null) {
          final season = seasonNum != null ? 'S${seasonNum.toString().padLeft(2, '0')}' : '';
          final episode = episodeNum != null ? 'E${episodeNum.toString().padLeft(2, '0')}' : '';
          parts.add('$season$episode');
        }
        if (name != null && name.isNotEmpty) {
          parts.add(name);
        }

        return parts.isNotEmpty ? parts.join(' · ') : 'Unknown Episode';

      case 'Season':
        final seriesName = item.seriesName;
        if (seriesName != null &&
            seriesName.isNotEmpty &&
            name != null &&
            name.isNotEmpty) {
          return '$seriesName · $name';
        }
        return name ?? 'Unknown Season';

      case 'Movie':
      case 'Series':
      default:
        return name ?? 'Unknown';
    }
  }

  /// 从 Theme 构建文字样式
  TextStyle _buildTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.titleLarge ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

    var effectiveStyle = textStyle ?? defaultStyle;

    if (textColor != null) {
      effectiveStyle = effectiveStyle.copyWith(color: textColor);
    }

    return effectiveStyle;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_hasLogo && item.id != null) {
      return EmbyCachedImage(
        itemId: item.id!,
        imageTagList: [
          MapEntry('Logo', item.imageTags?['Logo'] ?? ''),
          MapEntry('Primary', item.imageTags?['Primary'] ?? ''),
        ],
        maxWidth: logoMaxWidth,
        maxHeight: logoMaxHeight,
        fit: BoxFit.contain,
        errorWidget: _buildText(context),
      );
    }

    return _buildText(context);
  }

  /// 构建文字标题 Widget
  Widget _buildText(BuildContext context) {
    return Text(
      _titleText,
      style: _buildTextStyle(context),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
