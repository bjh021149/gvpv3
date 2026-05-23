import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/features/shared/emby_cached_image.dart';
import 'package:emby_client/features/shared/logo_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 可复用媒体卡片组件，用于展示电影/剧集等媒体的缩略图和标题。
///
/// 标题信息（Logo 优先）叠加在海报图片底部，通过渐变遮罩
/// 保证文字可读性。
class MediaCard extends ConsumerWidget {
  /// 媒体项数据
  final BaseItemDto item;

  /// 点击回调
  final VoidCallback? onTap;

  /// 卡片宽度
  final double? width;

  /// 宽高比
  final double? aspectRatio;

  const MediaCard({
    super.key,
    required this.item,
    this.onTap,
    this.width,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final itemId = item.id;
    if (itemId == null || itemId.isEmpty) {
      return const SizedBox.shrink();
    }
    final cardWidth = width ?? 140;

    return Semantics(
      label: item.name ?? 'Media item',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () {}, // 预留：长按弹出菜单
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: aspectRatio ?? 0.67,
            child: Hero(
              tag: 'media_${item.id}',
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 底层：海报图片
                  EmbyCachedImage(
                    itemId: itemId,
                    imageTagList: [
                      MapEntry('Primary', item.imageTags?['Primary'] ?? ''),
                      MapEntry('Thumb', item.imageTags?['Thumb'] ?? ''),
                    ],
                    width: cardWidth,
                    height: cardWidth / (aspectRatio ?? 0.67),
                    showProgressIndicator: true,
                  ),

                  // Only show title overlay when the item has no images at all.
                  // If there are image tags (Primary, Logo, Backdrop, etc.),
                  // the poster itself identifies the media; no text overlay needed.
                  if (item.imageTags == null || item.imageTags!.isEmpty) ...[
                    // 底部渐变遮罩（保证标题可读）
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              colorScheme.scrim.withValues(alpha: 0.75),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 叠加标题（Logo 优先）
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: LogoTitle(
                        item: item,
                        logoMaxHeight: 24,
                        logoMaxWidth: (cardWidth * 0.8).ceil(),
                        textStyle: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        textColor: Colors.white,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
