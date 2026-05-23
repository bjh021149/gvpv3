# Plan: DetailPage 原子化刷新重构

## 问题诊断

### 1. 大 State 导致全页重建

当前 `DetailViewModel` 用 `AsyncNotifier` 管理一个 monolithic `DetailState`：
```dart
class DetailState {
  final BaseItemDto? item;           // core + heavy fields
  final List<BaseItemDto> similarItems;
  final List<BaseItemDto> seasons;
  final List<BaseItemDto> episodes;
  final List<BaseItemDto> studioDetails;
}
```

任何子数据变化（如 studio details 加载完成 → `state = AsyncValue.data(current.copyWith(studioDetails: newDetails))`）都会触发整个 `CustomScrollView` 重建。

### 2. `watchItem` 无法感知 heavy fields 变化（正确性 Bug）

当前 `watchItem` 实现：
```dart
Stream<BaseItemDto?> watchItem(String id) {
  return _core.watch(key: id).map((_) => getItem(id, includeHeavyFields: true));
}
```

它只监听 `_core` box。但 `putItem` 的写入策略是：
- `overview/year/rating` → `_core`
- `people` → `_people`（独立 box）
- `studios` → `_studios`（独立 box）
- `genres` → `_genres`（独立 box）

**后果**：API 刷新后 people/studios/genres 已更新到各自 box，但 `_core` 未变 → `watchItem` 不触发 → UI 不刷新。

这是用户看到"缺失了很多信息"的根因之一。

### 3. Freezed 全量反序列化开销

`getItem` 每次从 6 个 box 读取、合并成 Map、再 `BaseItemDto.fromJson(json)`。即使只有 `people` 变了，也要反序列化整个对象。

## 方案对比

### 方案 A：细粒度 Hive Watch + StreamProvider（推荐）

保留 Freezed 模型，但为每个 box 提供独立的 watch 方法和 Riverpod StreamProvider。组件只监听自己需要的数据源。

**核心改动**：
1. `EmbyCache` 新增 4 个细粒度 watch 方法：
   - `watchItemCore(id)` → 监听 `_core`，返回轻量 BaseItemDto（不含 heavy fields）
   - `watchPeople(id)` → 监听 `_people`，返回 `List<PersonDto>?`
   - `watchStudios(id)` → 监听 `_studios`，返回 `List<StudioDto>?`
   - `watchGenres(id)` → 监听 `_genres`，返回 `List<String>?`
   - `watchItemFull(id)` → 监听所有相关 boxes（合并事件流），返回完整 BaseItemDto

2. 新增 5 个 Riverpod `StreamProvider.family`：
   ```dart
   final itemCoreProvider = StreamProvider.family<BaseItemDto?, String>(...);
   final peopleProvider = StreamProvider.family<List<PersonDto>?, String>(...);
   final studiosProvider = StreamProvider.family<List<StudioDto>?, String>(...);
   final genresProvider = StreamProvider.family<List<String>?, String>(...);
   final itemFullProvider = StreamProvider.family<BaseItemDto?, String>(...);
   ```

3. **重构 DetailPage 为"无状态容器"**：
   - `DetailPage` 不再依赖 `DetailViewModel`
   - 每个 Section 组件独立消费自己的 Provider
   - 例如 `CastHorizontalList` 内部 `ref.watch(peopleProvider(itemId))`

4. **保留简化的 `DetailViewModel`**：
   - 只负责触发初始数据加载（`getPageDetail`）
   - 负责 seasons/episodes 的加载（列表数据不走 item cache）
   - 不负责状态聚合

**优点**：
- 每个组件独立刷新，互不影响
- 修复 `watchItem` 不感知 heavy fields 的 bug
- 反序列化开销从"全对象"降到"只反序列化该组件需要的子对象"
- 保留 Freezed 类型安全

**缺点**：
- Provider 数量增加
- 组件层级增加一层 Consumer/StreamBuilder

### 方案 B：直接暴露原始 JSON，零反序列化

放弃 Freezed `fromJson`，组件直接消费 Hive box 的原始 `Map<String, dynamic>` / `List<dynamic>` 数据。

**核心改动**：
1. `EmbyCache` watch 方法返回 `Stream<Map<String, dynamic>?>` / `Stream<List<dynamic>?>`
2. 组件内部用 `json['Name']`、`json['Role']` 访问字段
3. 彻底移除 `BaseItemDto.fromJson` 在 DetailPage 路径中的使用

**优点**：
- 零反序列化开销
- 最简单直接

**缺点**：
- 完全失去类型安全
- 字段名必须与 PascalCase JSON key 硬编码匹配
- 难以维护，PascalCase key 拼写错误不会编译报错
- 与项目现有架构（所有页面都用 BaseItemDto）割裂

### 方案 C：混合——Core 保留 Freezed，Heavy 用轻量 Value Object

折中方案：
- `_core` 数据仍用 `BaseItemDto.fromJson`（字段少，反序列化快）
- `_people` / `_studios` / `_genres` 用独立 watch 方法，反序列化为独立轻量模型

这与方案 A 本质相同，只是强调"core 全量反序列化可接受，heavy 字段独立反序列化"。

## 推荐方案：方案 A

理由：
1. **修复现有 bug**：`watchItem` 不感知 heavy fields 的问题需要被解决
2. **性能与类型安全平衡**：独立反序列化 `List<PersonDto>` 比反序列化整个 `BaseItemDto` 快得多，同时保留类型安全
3. **架构一致性**：与项目现有的 Riverpod + Freezed 架构保持一致
4. **可扩展**：以后新增字段（如 `MediaSources`）只需新增一个 Provider，不影响已有组件

## 实施步骤

### 1. EmbyCache 新增细粒度 watch 方法

```dart
Stream<BaseItemDto?> watchItemCore(String id) {
  return _core.watch(key: id).map((event) {
    final raw = event.value;
    if (raw == null) return null;
    try {
      return BaseItemDto.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (_) {
      return null;
    }
  });
}

Stream<List<PersonDto>?> watchPeople(String id) {
  return _people.watch(key: id).map((event) {
    final raw = event.value;
    if (raw == null) return null;
    final list = List<dynamic>.from(raw as List);
    return list.map((json) => PersonDto.fromJson(Map<String, dynamic>.from(json))).toList();
  });
}

Stream<List<StudioDto>?> watchStudios(String id) { ... }
Stream<List<String>?> watchGenres(String id) { ... }

Stream<BaseItemDto?> watchItemFull(String id) {
  // 合并所有相关 box 的 watch 事件
  return Rx.combineLatest([
    _core.watch(key: id),
    _userdata.watch(key: id),
    _genres.watch(key: id),
    _studios.watch(key: id),
    _people.watch(key: id),
  ], (_) => getItem(id, includeHeavyFields: true));
}
```

### 2. 新增 StreamProvider

在 `lib/services/cache/cache_providers.dart` 中集中定义：
```dart
final itemCoreProvider = StreamProvider.family<BaseItemDto?, String>((ref, id) {
  return ref.watch(embyCacheProvider).watchItemCore(id);
});

final peopleProvider = StreamProvider.family<List<PersonDto>?, String>((ref, id) {
  return ref.watch(embyCacheProvider).watchPeople(id);
});
// ... studios, genres, itemFull
```

### 3. 重构 DetailPage Section 组件

每个组件改为 `ConsumerWidget`，内部监听自己的 Provider：

```dart
class DetailHeroSection extends ConsumerWidget {
  final String itemId;
  // ...
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemCoreProvider(itemId));
    return itemAsync.when(
      data: (item) => item != null ? _buildContent(context, item) : const SizedBox.shrink(),
      loading: () => const SkeletonHero(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

同理重构：
- `OverviewSection` → `itemCoreProvider`（取 overview）
- `MetadataChips` → `itemCoreProvider` + `genresProvider`
- `CastHorizontalList` → `peopleProvider`
- `StudioSection` → `studiosProvider`（原始 studios）+ `watchStudioDetail`（Studio 图片）

### 4. 简化 DetailViewModel

```dart
class DetailViewModel extends AsyncNotifier<DetailPageVmState> {
  // 只保留 seasons/episodes/similarItems（列表数据不走 item cache）
  // 以及触发初始加载的入口
}
```

### 5. 计划文件

保存到 `docs/plans/detail_page_atomic_refresh.md`
