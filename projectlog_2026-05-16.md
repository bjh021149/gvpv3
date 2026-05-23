# Project Log — 2026-05-16

## 概述

本次工作围绕 Emby 客户端详情页性能优化、缓存架构修复、媒体库导航逻辑完善展开。核心主题：将 DetailPage 从 monolithic ViewModel 驱动重构为原子化 Hive watch 驱动，同时修复了一系列缓存相关的正确性和性能问题。

---

## 1. StudioName 组件重构

**问题**：StudioSection 逻辑复杂，同时维护图片和 Chip 两种展示形式，代码冗余。

**修改**：
- 新建 `lib/features/detail/studio_name.dart`：类似 `LogoTitle`，优先显示 studio logo 图片，无图则 fallback 到文字名称
- 简化 `StudioSection`：仅使用 `StudioName` 水平列表展示
- 从 `MetadataChips` 中移除 studio chips

**文件变更**：
- `lib/features/detail/studio_name.dart` ➕
- `lib/features/detail/studio_section.dart` ✏️
- `lib/features/detail/metadata_chips.dart` ✏️
- `lib/features/detail/detail_page.dart` ✏️

---

## 2. EmbyCachedImage 错误 fallback 修复

**问题**：当 `imageTagList` 中所有 tag 为空时，组件直接返回 `_buildDefaultError`（broken_image 图标），**忽略用户传入的 `errorWidget`**。导致 `StudioName` 在无图时显示图标而不是 studio 名称文字。

**修复**：`emby_cached_image.dart:158`
```dart
// 修复前
return _buildSizedWidget(_buildDefaultError(colorScheme));

// 修复后
return _buildSizedWidget(errorWidget ?? _buildDefaultError(colorScheme));
```

**文件变更**：
- `lib/features/shared/emby_cached_image.dart` ✏️

---

## 3. 详情页数据预加载（导航前异步执行）

**问题**：用户点击卡片 → 导航 → DetailViewModel 开始加载数据，打开页面时有明显等待。

**方案**：在导航指令之前触发数据预加载，利用 Repository 的 cache-first 策略提前写入缓存。

**实现**：
- 新建 `lib/core/navigation/detail_navigation.dart`：
  - `preloadDetailData(ref, itemId)` — 触发 `getItemDetail`，不阻塞
  - `goToDetail(context, ref, itemId)` — 先预加载，再导航
- 修改 6 个入口点（home、library、hero carousel、continue watching、similar items）统一使用 `goToDetail`

**后续增强**：新增 `getPageDetail` 方法，实现类型感知的全量预加载（见第 4 节）。

**文件变更**：
- `lib/core/navigation/detail_navigation.dart` ➕
- `lib/features/home/home_page.dart` ✏️
- `lib/features/home/hero_carousel.dart` ✏️
- `lib/features/home/continue_watching_row.dart` ✏️
- `lib/features/library/library_page.dart` ✏️
- `lib/features/library/media_grid.dart` ✏️
- `lib/features/detail/detail_page.dart` ✏️

---

## 4. 新增 getPageDetail 预加载方法

**问题**：`preloadDetailData` 仅调用 `getItemDetail(itemId)`，对 Movie 足够，但对 Series 不够完整（缺少 seasons、episodes）。

**方案**：新增 `MediaRepository.getPageDetail(itemId, itemType)`，根据类型决定加载策略：
- **Movie**：`getItemDetail` + `getSimilarItems`
- **Series**：`getSeries` + `getSeasons` + `getEpisodes(firstSeason)` + `getSimilarItems`

**实现**：
- `MediaRepository` / `MediaRepositoryImpl` 新增 `getPageDetail`
- `detail_navigation.goToDetail` 改为接收 `BaseItemDto`（从中提取 id + type）
- 所有调用点从 `goToDetail(context, ref, item.id!)` 改为 `goToDetail(context, ref, item)`

**文件变更**：
- `lib/services/repositories/media_repository.dart` ✏️
- `lib/services/repositories/media_repository_impl.dart` ✏️
- `lib/core/navigation/detail_navigation.dart` ✏️

---

## 5. DetailPage 原子化刷新重构（核心）

**问题诊断**：
1. **Monolithic State 导致全页重建**：`DetailState` 包含 item + similarItems + seasons + episodes + studioDetails，任何子数据变化都触发整个 `CustomScrollView` 重建
2. **`watchItem` 无法感知 heavy fields 变化**：`watchItem` 只监听 `_core` box，但 `putItem` 将 people/studios/genres 写入独立 box。API 刷新后 heavy fields 已更新，但 `_core` 未变 → UI 不刷新 → 用户看到"缺失信息"
3. **Freezed 全量反序列化开销**：每次更新都要从 6 个 box 读取、合并 JSON、反序列化整个 `BaseItemDto`

**方案**：细粒度 Hive Watch + Riverpod StreamProvider

### 5.1 EmbyCache 新增原子化 watch 方法

```dart
watchItemCore(id)     // 监听 _core box
watchItemFull(id)     // 合并所有 6 个 box 的事件流
watchPeople(id)       // 监听 _people box
watchStudios(id)      // 监听 _studios box
watchGenres(id)       // 监听 _genres box
```

**关键修复**：使用**单播** `StreamController`（非 broadcast），在 `return stream` 之前 emit 初始值。单播 controller 会缓存事件直到第一个 listener 订阅，解决了 broadcast controller "事件 emit 时无 listener 导致丢失" 的问题。

### 5.2 新增 StreamProvider

`lib/services/cache/cache_providers.dart`：
```dart
itemCoreProvider    // StreamProvider.family<BaseItemDto?, String>
itemFullProvider    // StreamProvider.family<BaseItemDto?, String>
peopleProvider      // StreamProvider.family<List<PersonDto>?, String>
studiosProvider     // StreamProvider.family<List<StudioDto>?, String>
genresProvider      // StreamProvider.family<List<String>?, String>
```

### 5.3 重构 Section 组件为 ConsumerWidget

每个组件独立监听自己的 Provider：
- `DetailHeroSection` → `itemCoreProvider`
- `MetadataChips` → `itemCoreProvider` + `genresProvider`
- `OverviewSection` → `itemCoreProvider`
- `CastHorizontalList` → `peopleProvider`

### 5.4 简化 DetailViewModel

从 `DetailState` 中移除 `item`，只保留列表级数据：
- `similarItems`
- `seasons` / `episodes`
- `studioDetails`（仍需逐个 API 调用）

ViewModel 仍负责触发初始加载（`getPageDetail`）和判断 `item.type` 以加载 seasons。

### 5.5 DetailPage 架构变化

```
修改前：
DetailPage → DetailViewModel → DetailState(item + similar + seasons + episodes + studios)
                                    ↓
                              整个 CustomScrollView 重建

修改后：
DetailPage → itemFullProvider ──→ DetailHeroSection / MetadataChips / OverviewSection
         → peopleProvider ─────→ CastHorizontalList
         → detailViewModel ────→ SeasonEpisodeList / SimilarItemsRow / StudioSection
```

**文件变更**：
- `lib/services/cache/emby_cache.dart` ✏️（重大修改）
- `lib/services/cache/cache_providers.dart` ➕
- `lib/features/detail/detail_hero_section.dart` ✏️（改为 ConsumerWidget）
- `lib/features/detail/metadata_chips.dart` ✏️（改为 ConsumerWidget）
- `lib/features/detail/overview_section.dart` ✏️（改为 ConsumerWidget）
- `lib/features/detail/cast_horizontal_list.dart` ✏️（改为 ConsumerWidget）
- `lib/features/detail/detail_viewmodel.dart` ✏️（简化 State）
- `lib/features/detail/detail_page.dart` ✏️（使用 Provider 驱动组件）

---

## 6. 媒体库子项目跳转与过滤修复

### 6.1 跳转逻辑修复

**问题**：
- `MediaGrid._onItemTap` 使用 `item.isFolder == true` 判断，但 Emby 中 `Series`、`Season`、`BoxSet` 的 `IsFolder` 也是 `true`，导致 Series 被错误导航到子库
- `_LibraryListTile` 所有类型都直接导航到详情页，包括 Folder/CollectionFolder

**修复**：
- 新建 `navigateToItem(context, ref, item)` 辅助函数，基于 `item.type` 判断：
  - `CollectionFolder` / `Folder` / `BoxSet` → `/library/:id`
  - `Series` / `Movie` / `Episode` / `Season` → `/detail/:id`

### 6.2 子项目类型过滤

**问题**：媒体库请求未根据 collectionType 过滤子项目，导致电视剧库中出现 Season/Episode。

**修复**：
- `EmbyApiService.getItems` / `MediaRepository.getItems` 新增 `excludeItemTypes` 参数
- `LibraryViewModel` 根据 parent 的 `collectionType` 决定过滤策略：
  - `movies` → `includeItemTypes: 'Movie'`
  - `tvshows` → `includeItemTypes: 'Series'`
  - `mixed` → `excludeItemTypes: 'Season,Episode'`
- 过滤参数存入 `LibraryState`，`loadMore()` 和 `setSortOption()` 复用

**文件变更**：
- `lib/core/api/emby_api_service.dart` ✏️
- `lib/services/repositories/media_repository.dart` ✏️
- `lib/services/repositories/media_repository_impl.dart` ✏️
- `lib/features/library/library_viewmodel.dart` ✏️（重大修改）
- `lib/features/library/media_grid.dart` ✏️
- `lib/features/library/library_page.dart` ✏️
- `lib/core/navigation/detail_navigation.dart` ✏️

---

## 7. BaseItemDto 新增 Status 字段

**需求**：显示剧集连载状态（连载中 / 已完结）。

**实现**：
- `BaseItemDto` 新增 `String? status` 字段
- `build_runner` 重新生成 Freezed 代码
- `MetadataChips` 新增状态 chip：
  - `Continuing` → "连载中"
  - `Ended` → "已完结"

**文件变更**：
- `lib/core/models/base_item_dto.dart` ✏️
- `lib/core/models/base_item_dto.freezed.dart` ➕（生成）
- `lib/core/models/base_item_dto.g.dart` ➕（生成）
- `lib/features/detail/metadata_chips.dart` ✏️

---

## 关键 Bug 修复清单

| Bug | 根因 | 修复位置 |
|-----|------|---------|
| watchItem 不感知 heavy fields | 只监听 _core box | EmbyCache.watchItemFull 合并所有 box |
| StreamProvider 永远 loading | broadcast controller emit 时无 listener | 改用单播 StreamController |
| StudioName 无图显示 broken_image | errorWidget 在 _effectiveEntry==null 时被忽略 | emby_cached_image.dart 优先使用 errorWidget |
| Series 被导航到子库 | isFolder==true 包含 Series | navigateToItem 基于 type 判断 |
| 电视剧库出现 Season/Episode | getItems 未过滤类型 | LibraryViewModel 根据 collectionType 过滤 |
| 详情页信息缺失 | 缓存刷新后 UI 不更新 | 原子化刷新，每个组件独立监听 |

---

## 计划文件

- `docs/plans/studio_name_refactor.md`
- `docs/plans/detail_preload.md`
- `docs/plans/get_page_detail.md`
- `docs/plans/detail_page_atomic_refresh.md`
