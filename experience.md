# Experience — Emby Client 开发经验总结

## 1. Hive 缓存与 Stream 的正确使用

### 1.1 Broadcast vs 单播 StreamController

**踩坑**：使用 `StreamController<T>.broadcast()` 时，在 `return controller.stream` **之前** emit 事件，此时没有任何 listener，事件被静默丢弃。

**正确做法**：
- **单播 StreamController**（默认）：缓存事件直到第一个 listener 订阅
  ```dart
  final controller = StreamController<BaseItemDto?>(); // 不是 .broadcast()
  controller.add(initialValue); // 缓存到 buffer
  return controller.stream;     // listener 订阅后收到初始值
  ```
- **Broadcast StreamController**：仅在有 listener 时 emit 才有效。适合"先有 listener 后有事件"的场景，不适合"先创建 controller 后订阅"的场景。

### 1.2 box.watch(key) 的行为

- `box.watch(key: id)` 只在 **该 key 被 put/delete 时** 触发
- 如果 key 初始不存在，第一次 `put` 时会触发
- **不会自动 emit 当前值** — 如果需要初始值，必须手动从 `box.get(id)` 读取并 emit

### 1.3 多 Box 原子化设计

将一个大对象拆分到多个 Hive box 中（core、people、studios、genres 等）的优势：
- 各组件独立刷新，互不影响
- 避免全量反序列化开销
- **代价**：需要为每个 box 提供独立的 watch 方法，Provider 数量增加

**关键原则**：如果 `putItem` 写入多个 box，则 `watchItem` 必须监听所有相关 box 的变化，不能只监听主 box。

---

## 2. Riverpod StreamProvider 的行为

### 2.1 AsyncLoading 的陷阱

`StreamProvider` 的初始状态是 `AsyncLoading()`，直到 stream emit **第一个事件**。如果 stream 永远不 emit（比如 `box.watch` 在没有数据且无人 put 的情况下），Provider 将永远停留在 loading。

**解决**：确保 stream 在创建时立即 emit 一个初始值（即使是 `null`）。

### 2.2 StreamProvider 与 async* generator

`async*` 看起来简洁，但在 Riverpod dispose 时：
- `await for` 循环不会立即停止
- 可能在下一个 `yield` 时抛出 `StateError`

**推荐**：手动管理 `StreamController` + `onCancel`，比 `async*` 更可控。

---

## 3. Emby API 的注意事项

### 3.1 IsFolder 不可靠

Emby 中以下类型的 `IsFolder` 都是 `true`：
- `CollectionFolder`（媒体库）
- `Folder`
- `Series` ⚠️
- `Season` ⚠️
- `BoxSet` ⚠️

**结论**：判断跳转目标时**必须基于 `Type` 字段**，不能依赖 `IsFolder`。

### 3.2 CollectionType 与过滤策略

| CollectionType | 过滤策略 |
|---------------|---------|
| `movies` | `IncludeItemTypes=Movie` |
| `tvshows` | `IncludeItemTypes=Series` |
| `mixed` | `ExcludeItemTypes=Season,Episode` |

**注意**：如果不过滤，`getItems(recursive: true)` 会返回 Season 和 Episode，导致列表混乱。

### 3.3 Image URL 的 type 和 tag 必须匹配

调用 `/Items/{id}/Images/{type}` 时，`type` 参数和 `tag` 参数必须对应：
- ✅ `/Images/Primary?tag=PrimaryTag123`
- ❌ `/Images/Primary?tag=ThumbTag456` → HTTP 500

**EmbyCachedImage 的设计**：使用 `imageTagList: List<MapEntry<String, String>>`，确保 `(type, tag)` 配对正确。

---

## 4. Freezed + json_serializable 踩坑

### 4.1 field_rename: pascal

`build.yaml` 配置了 `field_rename: pascal`，Dart 字段 `genres` 会自动映射到 JSON 的 `Genres`。

**注意**：Hive box 中存储的是 JSON Map，字段名必须是 PascalCase（如 `Genres`、`People`、`ImageTags`）。如果从 box 读取后手动组装 JSON，必须确保 key 是 PascalCase。

### 4.2 修改字段后必须重新生成

修改 `BaseItemDto` 字段后必须运行：
```bash
flutter pub run build_runner build
```

否则 `.freezed.dart` 和 `.g.dart` 不会更新，导致新字段无法反序列化。

---

## 5. 预加载（Preload）策略

### 5.1 不阻塞导航

预加载的核心是"触发但不等待"：
```dart
void preload(WidgetRef ref, String itemId) {
  ref.read(repository).getItemDetail(itemId).ignore();
}
```

使用 `.ignore()` 明确表示不处理 Future 结果，避免 unawaited_future 警告。

### 5.2 缓存优先让预加载无副作用

如果 Repository 实现 cache-first 策略：
- 缓存命中：立即返回，后台刷新 → 预加载瞬间完成
- 缓存未命中：后台请求 → 导航完成后页面打开时可能已命中缓存

**关键**：预加载调用和页面加载调用必须是**同一个缓存 key**。

---

## 6. 导航辅助函数的设计

### 6.1 集中导航逻辑

将"预加载 + 导航"封装在一个函数中：
```dart
void goToDetail(BuildContext context, WidgetRef ref, BaseItemDto item) {
  preloadDetailData(ref, item);
  context.go('/detail/${item.id}');
}
```

好处：
- 所有入口点行为一致
- 避免某个入口忘记预加载
- 便于后续统一修改策略

### 6.2 根据类型决定跳转目标

不要分散判断逻辑，用一个函数统一处理：
```dart
void navigateToItem(BuildContext context, WidgetRef ref, BaseItemDto item) {
  final folderTypes = {'CollectionFolder', 'Folder', 'BoxSet'};
  if (folderTypes.contains(item.type)) {
    context.go('/library/${item.id}');
  } else {
    goToDetail(context, ref, item);
  }
}
```

---

## 7. Flutter 性能优化经验

### 7.1 避免全页重建

Monolithic State 的问题：
```dart
// 不好的设计
class DetailState {
  final Item item;
  final List<Item> similar;
  final List<Item> seasons;
  final List<Item> episodes;
}
// seasons 变化 → 整个页面重建
```

原子化设计：每个子组件独立监听自己的数据流，只重建自己。

### 7.2 骨架屏 vs 空状态

- **骨架屏**：数据正在加载，用户知道内容即将出现
- **空状态**：数据加载完成但为空，用户知道没有内容

**不要混淆**：StreamProvider 的 `loading` 状态显示骨架屏，`data(null)` 应该显示空状态或隐藏组件。

---

## 8. 调试技巧

### 8.1 验证 Hive box 内容

```dart
final cache = ref.read(embyCacheProvider);
print(cache.stats()); // 查看各 box 条目数
```

### 8.2 验证 API 响应字段

使用 curl 直接调用 API，对比响应 JSON 和 Freezed 模型字段：
```bash
curl "$SERVER/Items/$ID?api_key=$KEY&fields=ImageTags,BackdropImageTags"
```

### 8.3 检查 StreamProvider 状态

在 DevTools 的 Provider 页面中观察：
- StreamProvider 是否从 `loading` 变为 `data`
- 如果一直 `loading`，说明 stream 没有 emit 初始值

---

## 9. 代码组织原则

### 9.1 Cache Provider 集中管理

所有基于 Hive watch 的 StreamProvider 放在同一个文件（`cache_providers.dart`），便于维护和发现。

### 9.2 计划文件归档

每个重大重构前写计划文件（`docs/plans/{feature}.md`）：
- 记录问题诊断
- 对比多个方案
- 记录预期效果

便于后续回溯决策原因。

---

## 10. 常见错误速查

| 现象 | 可能原因 | 排查方向 |
|-----|---------|---------|
| StreamProvider 永远 loading | stream 没有 emit 初始值 | 检查 watch 方法是否 emit 了初始值 |
| 缓存刷新后 UI 不更新 | watch 只监听了部分 box | 确认所有被 `putItem` 写入的 box 都被监听 |
| 图片加载 500 | type 和 tag 不匹配 | 检查 `imageTagList` 的 `(type, tag)` 配对 |
| Series 导航到子库 | 使用 `isFolder` 判断 | 改用 `item.type` 判断 |
| 电视剧库出现 Season | `getItems` 未过滤类型 | 根据 `collectionType` 传 `includeItemTypes` |
| Freezed 字段为 null | 未重新运行 build_runner | `flutter pub run build_runner build` |
