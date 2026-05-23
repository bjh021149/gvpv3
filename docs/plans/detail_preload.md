# Plan: 详情页数据预加载（导航前异步执行）

## 背景与目标

当前行为：用户点击媒体卡片 → 导航到 `/detail/:id` → `DetailViewModel.build()` 开始异步加载数据。

目标行为：用户点击媒体卡片 → **先触发详情数据预加载（不阻塞 UI）** → 执行导航 → `DetailViewModel.build()` 调用时大概率直接命中缓存，实现“秒开”体验。

## 方案概述

创建一个统一的导航辅助模块 `detail_navigation.dart`，提供 `goToDetail(context, ref, itemId)` 函数。该函数在内部先调用 `mediaRepo.getItemDetail(itemId)`（不 await，仅触发 Repository 的 cache-first 流程），然后立即执行 `context.go('/detail/$itemId')`。

由于 Repository 的 `_cachedItem` 已实现缓存优先策略：
- **缓存命中**：立即返回缓存数据，同时后台异步刷新；预加载不阻塞导航。
- **缓存未命中**：发起 API 请求，返回后写入缓存；导航完成后 `DetailViewModel` 再次调用 `getSeries(itemId)` 时将命中缓存。

## 实施步骤

### 1. 新建导航辅助文件

**文件**: `lib/core/navigation/detail_navigation.dart`

内容：
- `void preloadDetailData(WidgetRef ref, String itemId)` — 触发 `mediaRepo.getItemDetail(itemId)`，不 await。
- `void goToDetail(BuildContext context, WidgetRef ref, String itemId)` — 先 `preloadDetailData`，再 `context.go('/detail/$itemId')`。

### 2. 修改各入口点的导航逻辑

以下文件在导航到详情页前，统一调用 `goToDetail(context, ref, itemId)`：

| 文件 | 当前导航代码 | 需要做的修改 |
|------|-------------|-------------|
| `lib/features/home/home_page.dart` | `MediaCard` 的 `onTap: () => context.go('/detail/${item.id}')` | 改为 `onTap: () => goToDetail(context, ref, item.id!)` |
| `lib/features/home/hero_carousel.dart` | `_onItemTap` 中 `context.go('/detail/${item.id}')` | 将 `HeroCarousel` 改为 `ConsumerStatefulWidget`，`_onItemTap` 中使用 `goToDetail` |
| `lib/features/home/continue_watching_row.dart` | `_onItemTap` 和 dialog "View Details" 中 `context.go('/detail/${item.id}')` | 将 `ContinueWatchingRow` 改为 `ConsumerWidget`，两处均使用 `goToDetail` |
| `lib/features/library/library_page.dart` | `InkWell` 的 `onTap: () => context.go('/detail/${item.id}')` | 改为使用 `goToDetail(context, ref, item.id!)`（LibraryPage 已是 ConsumerWidget） |
| `lib/features/library/media_grid.dart` | `_onItemTap` 中 `context.go('/detail/${item.id}')`（非 folder 分支） | 将 `MediaGrid` 改为 `ConsumerStatefulWidget`，非 folder 分支使用 `goToDetail` |
| `lib/features/detail/detail_page.dart` | `SimilarItemsRow` 的 `onItemTap` 中 `context.go('/detail/${similarItem.id}')` | 在 `SimilarItemsRow` 外包裹 `Consumer`，获取 ref 后调用 `goToDetail` |

**不需要修改的文件**：
- `lib/features/detail/similar_items_row.dart`：仅接收外部 `onItemTap` 回调，逻辑在 `detail_page.dart` 中处理。
- `lib/features/shared/media_card.dart`：`onTap` 是外部传入的，不侵入卡片内部逻辑，保持组件复用性。

### 3. 关键代码示例

**detail_navigation.dart**:
```dart
import 'package:emby_client/services/repositories/media_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 预加载详情页主 item 数据到缓存，不阻塞。
///
/// 触发 [MediaRepository.getItemDetail] 的 cache-first 流程：
/// - 若缓存已存在，立即返回缓存并后台刷新。
/// - 若缓存不存在，发起请求并在返回后写入缓存。
void preloadDetailData(WidgetRef ref, String itemId) {
  // ignore: unawaited_futures
  ref.read(mediaRepositoryProvider).getItemDetail(itemId);
}

/// 先预加载详情数据，再导航到详情页。
void goToDetail(BuildContext context, WidgetRef ref, String itemId) {
  preloadDetailData(ref, itemId);
  context.go('/detail/$itemId');
}
```

**detail_page.dart 中 SimilarItemsRow 的修改示例**:
```dart
Consumer(
  builder: (context, ref, child) {
    return SimilarItemsRow(
      items: state.similarItems,
      onItemTap: (similarItem) {
        goToDetail(context, ref, similarItem.id!);
      },
    );
  },
)
```

## 预期效果

- 用户点击卡片后，导航动画与数据请求并行执行。
- 若此前访问过该详情页，缓存命中 → DetailPage 打开时立即显示完整数据。
- 若首次访问，API 请求在点击瞬间已启动，DetailPage 打开时等待时间显著缩短。
- 无额外副作用：预加载不 await，不阻塞导航；失败时静默忽略（Repository 层已处理异常）。
