# Plan: 新增 getPageDetail 预加载方法

## 背景与目标

当前 `preloadDetailData` 仅调用 `getItemDetail(itemId)`，对 Movie 足够，但对 Series 不够完整。

用户要求新增 `getPageDetail` 方法，实现类型感知的全量预加载：
- **Movie**: 预加载 item detail + similar items
- **Series**: 预加载 series detail + seasons + first season episodes + similar items

这样导航到 DetailPage 时，所有首屏数据已提前进入缓存。

## 方案概述

在 `MediaRepository` 层新增 `getPageDetail(String itemId, {required String itemType})` 方法，内部根据 `itemType` 决定加载哪些数据。同步修改 `detail_navigation.dart`，让 `goToDetail` 接收完整的 `BaseItemDto`（从中提取 id 和 type），替代当前只传 itemId 的方式。

## 实施步骤

### 1. Repository 接口添加声明

**文件**: `lib/services/repositories/media_repository.dart`

在接口末尾新增方法：
```dart
Future<void> getPageDetail(String itemId, {required String itemType});
```

### 2. Repository 实现添加逻辑

**文件**: `lib/services/repositories/media_repository_impl.dart`

实现逻辑（不返回数据，仅触发缓存写入）：
```dart
@override
Future<void> getPageDetail(String itemId, {required String itemType}) async {
  if (itemType == 'Series') {
    final item = await getSeries(itemId);
    final seasonsResult = await getSeasons(itemId);
    if (seasonsResult.items.isNotEmpty) {
      final firstSeasonId = seasonsResult.items.first.id;
      if (firstSeasonId != null) {
        await getEpisodes(itemId, seasonId: firstSeasonId);
      }
    }
    await getSimilarItems(itemId);
  } else {
    await getItemDetail(itemId);
    await getSimilarItems(itemId);
  }
}
```

所有内部调用均走 cache-first 流程：缓存已存在时立即返回，不阻塞。

### 3. 修改导航辅助函数

**文件**: `lib/core/navigation/detail_navigation.dart`

将 `goToDetail` 签名从 `(context, ref, itemId)` 改为 `(context, ref, item)`：
```dart
void preloadDetailData(WidgetRef ref, BaseItemDto item) {
  final itemId = item.id;
  if (itemId == null || itemId.isEmpty) return;
  ref.read(mediaRepositoryProvider).getPageDetail(
    itemId,
    itemType: item.type ?? '',
  ).ignore();
}

void goToDetail(BuildContext context, WidgetRef ref, BaseItemDto item) {
  preloadDetailData(ref, item);
  final itemId = item.id;
  if (itemId != null && itemId.isNotEmpty) {
    context.go('/detail/$itemId');
  }
}
```

### 4. 更新所有调用点

所有导航到详情页的地方，将 `goToDetail(context, ref, item.id!)` 改为 `goToDetail(context, ref, item)`：

| 文件 | 当前调用 | 新调用 |
|------|---------|--------|
| `home_page.dart` | `goToDetail(context, ref, item.id!)` | `goToDetail(context, ref, item)` |
| `hero_carousel.dart` | `goToDetail(context, ref, item.id!)` | `goToDetail(context, ref, item)` |
| `continue_watching_row.dart` | `goToDetail(context, ref, item.id!)` | `goToDetail(context, ref, item)` |
| `library_page.dart` | `goToDetail(context, ref, item.id!)` | `goToDetail(context, ref, item)` |
| `media_grid.dart` | `goToDetail(context, ref, item.id!)` | `goToDetail(context, ref, item)` |
| `detail_page.dart` | `goToDetail(context, ref, similarItem.id!)` | `goToDetail(context, ref, similarItem)` |

## 预期效果

- Movie 点击：预加载 item detail + similar items，DetailPage 打开时所有数据已就绪。
- Series 点击：预加载 series detail + seasons + first season episodes + similar items，DetailPage 首屏（背景图、季选择、第一季的集列表）无需额外等待。
- 所有内部调用均走 cache-first，缓存已存在时不会重复请求。
