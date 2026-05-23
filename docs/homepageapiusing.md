# 首页（HomePage）API 调用流程

**页面**: `HomePage` (`/home`)
**核心文件**: `lib/features/home/home_page.dart` + `home_viewmodel.dart`
**数据流**: 多个细粒度 `FutureProvider.autoDispose` 并行加载，避免整页重建

---

## 一、Provider 与 API 映射

首页使用 6 个独立的 `FutureProvider` 并行获取数据，每个 provider 对应一个 UI Section：

| Provider | UI Section | API | 说明 |
|----------|-----------|-----|------|
| `_homeViewsProvider` | — | `getViews()` | 获取媒体库列表（被其他 provider 依赖） |
| `carouselItemsProvider` | Hero Carousel | `getMovieRecommendations()` | 推荐电影（首屏大图） |
| `resumableSeriesProvider` | 继续观看 | `getResumableSeries(limit=10)` | 未看完的剧集 |
| `resumableMoviesProvider` | 继续观看 | `getResumableMovies(limit=10)` | 未看完的电影 |
| `continueWatchingProvider` | 继续观看（兼容） | `getContinueWatching(limit=10)` | NextUp API |
| `librarySectionsProvider` | 最近添加（按库分组） | `getViews()` + `getLatestItems()` | 每个媒体库的最新内容 |

---

## 二、各 Provider 详细 API

### 2.1 _homeViewsProvider — 媒体库视图列表

```
GET /Users/{uid}/Views?IncludeExternalContent=true
```

| 参数 | 值 | 说明 |
|------|-----|------|
| `UserId` | 路径参数 | 当前用户 ID |
| `IncludeExternalContent` | `true` | 包含外部视图 |

**用途**: 获取用户所有媒体库（CollectionFolder），作为其他 provider 的依赖基础。

**缓存**: `CacheKeys.views()` → `views`

---

### 2.2 carouselItemsProvider — Hero 轮播推荐

```
GET /Movies/Recommendations?ItemLimit=10&CategoryLimit=3
```

| 参数 | 值 | 说明 |
|------|-----|------|
| `ItemLimit` | `10` | 每个分类返回的条目数 |
| `CategoryLimit` | `3` | 分类数量 |

**用途**: 首屏大图轮播，展示推荐电影。UI 层取前 5 条展示。

**缓存**: `CacheKeys.movieRecommendations()` → `recommendations`

---

### 2.3 resumableSeriesProvider — 未看完的剧集

```
GET /Shows/NextUp?Limit=10
```

| 参数 | 值 | 说明 |
|------|-----|------|
| `Limit` | `10` | 返回数量上限 |

**用途**: 展示用户未看完的剧集系列的下一集。

**缓存**: `CacheKeys.resumableSeries()` → `resumable_series`

---

### 2.4 resumableMoviesProvider — 未看完的电影

```
GET /Users/{uid}/Items?Filters=IsResumable&IncludeItemTypes=Movie&Limit=10
```

| 参数 | 值 | 说明 |
|------|-----|------|
| `Filters` | `IsResumable` | 只返回有播放进度的 |
| `IncludeItemTypes` | `Movie` | 只返回电影 |
| `Limit` | `10` | 返回数量上限 |

**用途**: 展示用户未看完的电影。

**缓存**: `CacheKeys.resumableMovies()` → `resumable_movies`

---

### 2.5 continueWatchingProvider — 继续观看（兼容层）

```
GET /Users/{uid}/Items?Filters=IsResumable&Limit=10
```

| 参数 | 值 | 说明 |
|------|-----|------|
| `Filters` | `IsResumable` | 只返回有播放进度的 |
| `Limit` | `10` | 返回数量上限 |

**用途**: 旧的 NextUp API，兼容层。新代码建议使用 `resumableSeriesProvider` + `resumableMoviesProvider`。

**缓存**: `CacheKeys.continueWatching()` → `continue_watching`

---

### 2.6 librarySectionsProvider — 按库分组的最新添加

**Step 1**: 获取媒体库列表（同 2.1）
```
GET /Users/{uid}/Views?IncludeExternalContent=true
```

**Step 2**: 对每个媒体库并发获取最新项目
```
GET /Users/{uid}/Items?ParentId={libraryId}&Limit=20&SortBy=DateCreated&SortOrder=Descending&Filters=IsRecentlyAdded
```

| 参数 | 值 | 说明 |
|------|-----|------|
| `ParentId` | 媒体库 ID | 如 `43011`（电影库） |
| `Limit` | `20` | 固定获取 20 条，UI 层根据屏幕宽度切片 |
| `SortBy` | `DateCreated` | 按添加时间排序 |
| `SortOrder` | `Descending` | 降序（最新在前） |
| `Filters` | `IsRecentlyAdded` | 只返回最近添加的 |

**用途**: 首页底部的"最近添加"section，按媒体库分组展示（如"电影-最近添加"、"电视剧-最近添加"）。

**并发**: 使用 `Future.wait` 并发请求所有媒体库，避免串行等待。

**缓存**: `CacheKeys.latestItems(parentId)` → `latest|{parentId}`

---

## 三、用户交互触发的 API 调用

### 3.1 点击作品卡片

```dart
goToDetail(context, ref, item)
```

触发 `preloadDetailData(ref, item)`（见 `detailcommonpageapiusing.md`），然后导航到 `/detail/{itemId}`。

---

### 3.2 点击"继续观看"

用户点击 continue watching 行的作品：

- **Movie**: 直接进入播放器 `/player/{movieId}`
- **Series**: 进入剧集详情 `/detail/{seriesId}`

```dart
// continue_watching_row.dart
ListTile(
  title: const Text('Resume Playback'),
  onTap: () {
    Navigator.of(context).pop();
    context.push('/player/${item.id}');
  },
)
```

---

### 3.3 下拉刷新

```dart
ref.invalidate(carouselItemsProvider);
ref.invalidate(resumableSeriesProvider);
ref.invalidate(resumableMoviesProvider);
ref.invalidate(librarySectionsProvider);
```

独立刷新各个 section，避免整页重建。

---

## 四、完整调用序列

```
HomePage build()
    │
    ├──→ carouselItemsProvider ──→ getMovieRecommendations(limit=10, categoryLimit=3)
    │
    ├──→ resumableSeriesProvider ──→ getResumableSeries(limit=10)
    │
    ├──→ resumableMoviesProvider ──→ getResumableMovies(limit=10)
    │
    ├──→ continueWatchingProvider ──→ getContinueWatching(limit=10)
    │
    └──→ librarySectionsProvider
            │
            ├──→ Step 1: getViews() ──→ [电影, 电视剧, 国产剧, ...]
            │
            └──→ Step 2: Future.wait([
                     getLatestItems(电影库),
                     getLatestItems(电视剧库),
                     getLatestItems(国产剧库),
                     ...
                 ])
```

---

## 五、关键参数速查表

| API | 关键参数 | 值 | 说明 |
|-----|---------|-----|------|
| `GET /Users/{uid}/Views` | `IncludeExternalContent` | `true` | 包含外部视图 |
| `GET /Movies/Recommendations` | `ItemLimit` | `10` | 每类条目数 |
| `GET /Movies/Recommendations` | `CategoryLimit` | `3` | 分类数 |
| `GET /Shows/NextUp` | `Limit` | `10` | 返回数量 |
| `GET /Users/{uid}/Items` (Resumable) | `Filters` | `IsResumable` | 有播放进度 |
| `GET /Users/{uid}/Items` (Latest) | `Filters` | `IsRecentlyAdded` | 最近添加 |
| `GET /Users/{uid}/Items` (Latest) | `SortBy` | `DateCreated` | 按添加时间 |
| `GET /Users/{uid}/Items` (Latest) | `SortOrder` | `Descending` | 降序 |
