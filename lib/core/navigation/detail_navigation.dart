import 'package:emby_client/core/models/base_item_dto.dart';
import 'package:emby_client/services/repositories/media_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 预加载详情页所需的全部数据，不阻塞。
///
/// 根据项目类型决定加载策略：
/// - **Movie**: item detail + similar items
/// - **Series**: series detail + seasons + first season episodes + similar items
void preloadDetailData(WidgetRef ref, BaseItemDto item) {
  final itemId = item.id;
  if (itemId == null || itemId.isEmpty) return;
  ref
      .read(mediaRepositoryProvider)
      .getPageDetail(
        itemId,
        itemType: item.type ?? '',
      )
      .ignore();
}

/// 先预加载详情数据，再导航到详情页。
void goToDetail(BuildContext context, WidgetRef ref, BaseItemDto item) {
  preloadDetailData(ref, item);
  final itemId = item.id;
  if (itemId != null && itemId.isNotEmpty) {
    context.go('/detail/$itemId');
  }
}

/// 根据项目类型决定导航目标。
///
/// - **CollectionFolder / Folder / BoxSet** → 子媒体库 `/library/:id`
/// - **Series / Movie / Episode / Season / Video** → 详情页 `/detail/:id`
///
/// 注意：不要依赖 [BaseItemDto.isFolder]，因为 Emby 中
/// `Series`、`Season`、`BoxSet` 的 `IsFolder` 也是 `true`。
void navigateToItem(BuildContext context, WidgetRef ref, BaseItemDto item) {
  final itemId = item.id;
  if (itemId == null || itemId.isEmpty) return;

  final type = item.type ?? '';
  final folderTypes = {'CollectionFolder', 'Folder', 'BoxSet'};

  if (folderTypes.contains(type)) {
    context.go('/library/$itemId');
  } else {
    goToDetail(context, ref, item);
  }
}
