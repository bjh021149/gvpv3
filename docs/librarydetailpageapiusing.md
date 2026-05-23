# 媒体库详情页 API 调用流程

**页面**: `LibraryPage` (带 `parentId` 参数)
**ViewModel**: `LibraryViewModel`
**文件**: `lib/features/library/library_page.dart` + `library_viewmodel.dart`

---

## 一、进入页面初始化 (`build()`)

当用户点击进入某个媒体库（如"电影"、`parentId=43011`）时，`LibraryViewModel.build()` 被触发，按顺序执行以下 API 调用：

### 1.1 获取所有媒体库视图
```
GET /Users/{UserId}/Views?IncludeExternalContent=true
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `UserId` | 路径参数 | 当前用户 ID |
| `IncludeExternalContent` | `true` | 包含 channels/live tv 等外部视图 |

**用途**: 获取顶部导航栏/侧边栏的媒体库列表，用于跨库跳转。

**响应**: `QueryResult<BaseItemDto>` — 14 个 `CollectionFolder`。

---

### 1.2 获取当前媒体库详情
```
GET /Users/{UserId}/Items/{parentId}
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `UserId` | 路径参数 | 当前用户 ID |
| `parentId` | 路径参数 | 当前媒体库 ID (如 `43011`) |

**用途**: 获取 `CollectionType`（如 `movies`/`tvshows`/`boxsets`），决定后续 `IncludeItemTypes`。

**响应**: `BaseItemDto` — 关键字段：
```json
{
  "Name": "电影",
  "Type": "CollectionFolder",
  "CollectionType": "movies",
  "Subviews": ["movies", "collections", "genres", "movies", "folders"]
}
```

**→ `CollectionType` → `IncludeItemTypes` 映射**:
| CollectionType | IncludeItemTypes | ExcludeItemTypes |
|---------------|------------------|------------------|
| `movies` | `Movie` | — |
| `tvshows` | `Series` | — |
| `mixed` | — | `Season,Episode` |
| 其他 | — | — |

---

### 1.3 获取媒体库内容（第一页）
```
GET /Users/{UserId}/Items?ParentId={parentId}&IncludeItemTypes={type}&Limit=50&SortBy=SortName&Recursive=true
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `UserId` | 路径参数 | 当前用户 ID |
| `ParentId` | `43011` | 当前媒体库 ID |
| `IncludeItemTypes` | `Movie` / `Series` / ... | 由 CollectionType 决定 |
| `ExcludeItemTypes` | `Season,Episode` | mixed 类型时设置 |
| `Limit` | `50` | 每页数量 |
| `SortBy` | `SortName` | 默认按名称排序 |
| `Recursive` | `true` | 递归包含子文件夹 |

**用途**: 加载媒体库第一页内容，显示在网格/列表中。

**响应**: `QueryResult<BaseItemDto>` — `TotalRecordCount` 用于判断是否有更多页。

---

### 1.4 获取完整 Genre 列表
```
GET /Users/{UserId}/Items?ParentId={parentId}&IncludeItemTypes=Genre&Recursive=true&Limit=1000
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `ParentId` | `43011` | 当前媒体库 ID |
| `IncludeItemTypes` | `Genre` | 只返回 Genre 类型 |
| `Recursive` | `true` | 递归 |
| `Limit` | `1000` | 足够大以获取全部 |

**用途**: 填充筛选 BottomSheet 的 Genre 选项。从返回的 `BaseItemDto.name` 提取。

**响应示例**: 32 个 Genre
```
Action, Adventure, Animation, Anime, 爱情, Comedy, 动画, Documentary, ...
```

---

### 1.5 获取完整 Studio 列表
```
GET /Users/{UserId}/Items?ParentId={parentId}&IncludeItemTypes=Studio&Recursive=true&Limit=1000
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `ParentId` | `43011` | 当前媒体库 ID |
| `IncludeItemTypes` | `Studio` | 只返回 Studio 类型 |
| `Recursive` | `true` | 递归 |
| `Limit` | `1000` | 足够大以获取全部 |

**用途**: 填充筛选 BottomSheet 的 Studio 选项。从返回的 `BaseItemDto.id` + `name` 提取。

**响应示例**: 7523 个 Studio
```
571499 | "Sam" Productions
63446  | 1 Production Film
...
```

---

## 二、用户交互触发的 API 调用

### 2.1 滚动到底部加载更多 (`loadMore()`)
```
GET /Users/{UserId}/Items?ParentId={parentId}&IncludeItemTypes={type}&Limit=50&StartIndex={nextPage*50}&SortBy={sort}&Recursive=true&Genres={genre?}&StudioIds={studioId?}
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `StartIndex` | `50`, `100`, `150`... | 分页偏移 |
| `Genres` | `爱情` (URL编码) | 仅当选择了 Genre 筛选时 |
| `StudioIds` | `44015` | 仅当选择了 Studio 筛选时 |

**触发条件**: 滚动到距离底部 15% 时。

---

### 2.2 切换排序 (`setSortOption()`)
```
GET /Users/{UserId}/Items?ParentId={parentId}&IncludeItemTypes={type}&Limit=50&SortBy={newSort}&Recursive=true&Genres={genre?}&StudioIds={studioId?}
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `SortBy` | `SortName` / `DateCreated` / `CommunityRating` / `ProductionYear` | 用户选择的排序字段 |

**注意**: 切换排序会重置分页到第 0 页，重新加载全部内容。

---

### 2.3 应用筛选 (`setFilter()`)
```
GET /Users/{UserId}/Items?ParentId={parentId}&IncludeItemTypes={type}&Limit=50&SortBy={sort}&Recursive=true&Genres={genreName}&StudioIds={studioId}
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `Genres` | `爱情`, `喜剧` ... | Genre 名称（中文需 URL 编码，Dio 自动处理） |
| `StudioIds` | `44015`, `44460` ... | Studio ID（数字字符串） |

**调用方式**: BottomSheet 中点击 chip 时传入**完整状态**，保留另一维度的筛选：
```dart
// 点击 Genre chip
ref.read(...).setFilter(
  genre: isSelected ? null : genre,
  studioId: state.selectedStudioId,  // 保留当前 Studio 筛选
);

// 点击 Studio chip
ref.read(...).setFilter(
  genre: state.selectedGenre,        // 保留当前 Genre 筛选
  studioId: isSelected ? null : entry.key,
);
```

**注意**: Genre 和 Studio 可以**组合筛选**（同时传入两者）。

---

### 2.4 清除筛选
显式传入 `null` 清除两个筛选条件：
```dart
ref.read(libraryViewModelProvider(parentId).notifier).setFilter(
  genre: null,
  studioId: null,
);
```

---

### 2.5 下拉刷新 (`refresh()`)
调用 `ref.invalidateSelf()`，重新触发 `build()`，执行 **1.1 → 1.5** 全部 5 个请求。

---

## 三、筛选参数与 Subviews 的映射

当前代码未根据 `Subviews` 动态控制筛选选项的显示，但 API 层面已支持：

| Subview 存在 | 对应 API | 筛选选项 |
|-------------|---------|---------|
| `genres` | `IncludeItemTypes=Genre` | Genre 筛选 Chip |
| `studios` | `IncludeItemTypes=Studio` | Studio 筛选 Chip |
| `movies` | `IncludeItemTypes=Movie` | 内容主列表 |
| `series` | `IncludeItemTypes=Series` | 内容主列表 |
| `collections` | `IncludeItemTypes=BoxSet` | — |
| `folders` | `IncludeItemTypes=Folder` | — |

---

## 四、完整请求序列示例

用户进入"电影"库（`parentId=43011`，`CollectionType=movies`）：

```
# 1. 获取视图列表
GET /Users/{uid}/Views?IncludeExternalContent=true

# 2. 获取当前库详情
GET /Users/{uid}/Items/43011

# 3. 获取电影列表（第1页）
GET /Users/{uid}/Items?ParentId=43011&IncludeItemTypes=Movie&Limit=50&SortBy=SortName&Recursive=true

# 4. 获取所有 Genre
GET /Users/{uid}/Items?ParentId=43011&IncludeItemTypes=Genre&Recursive=true&Limit=1000

# 5. 获取所有 Studio
GET /Users/{uid}/Items?ParentId=43011&IncludeItemTypes=Studio&Recursive=true&Limit=1000
```

用户选择 Genre "爱情"：

```
# 6. 筛选后的电影列表
GET /Users/{uid}/Items?ParentId=43011&IncludeItemTypes=Movie&Limit=50&SortBy=SortName&Recursive=true&Genres=%E7%88%B1%E6%83%85
```

---

## 五、关键注意事项

1. **Genre 名称中文编码**: Dio 自动 URL 编码 query 参数，代码中无需手动处理
2. **Studio 使用 ID 筛选**: `StudioIds` 参数使用 Studio 的 `id`，不是名称
3. **Genre 使用名称筛选**: `Genres` 参数使用 Genre 的 `name`，不是 ID
4. **并发请求**: `build()` 中 items/genres/studios 三个请求**串行**执行（可优化为并行 `Future.wait`）
5. **缓存策略**: `getViews()` 和 `getItems()` 通过 `MediaRepositoryImpl._cachedList` 走 Hive 缓存

6. **缓存 key 必须包含筛选参数**: `CacheKeys.items()` 的 key 格式为：
   ```
   items|{parentId}|{includeItemTypes}|{excludeItemTypes}|{sortBy}|{startIndex}|{limit}|{genres}|{studioIds}
   ```
   如果缺少 `genres`/`studioIds`，筛选请求会命中未筛选内容的缓存，导致筛选不生效。此前曾因此出现 Genre/Studio 请求共用同一缓存 key 的 bug。
