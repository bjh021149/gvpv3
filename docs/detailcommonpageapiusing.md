# 详情页（Movie / Series）API 调用流程

**页面**: `DetailPage` (`/detail/:id`)
**核心文件**: `lib/features/detail/detail_page.dart` + `detail_viewmodel.dart`
**数据流**: `itemFullProvider` (atomic cache) + `detailViewModelProvider` (list-level state)

---

## 一、导航前预加载

当用户点击任意作品卡片时，`goToDetail()` 在导航前触发 `preloadDetailData()`：

```dart
void goToDetail(BuildContext context, WidgetRef ref, BaseItemDto item) {
  preloadDetailData(ref, item);  // ← 预加载开始
  context.go('/detail/${item.id}');
}
```

### 1.1 preloadDetailData → getPageDetail

```
GET /Users/{uid}/Items/{itemId}          ← Series (cache-first)
GET /Shows/{itemId}/Seasons               ← Seasons (cache-first)
GET /Shows/{itemId}/Episodes?SeasonId=xxx ← Episodes (cache-first)
GET /Items/{itemId}/Similar?Limit=12      ← Similar items (cache-first)
```

| 参数 | 类型 | 说明 |
|------|------|------|
| `itemId` | 路径参数 | 作品/剧集唯一标识 |
| `Limit` | query | Similar items 返回上限（默认12） |
| `SeasonId` | query | Episodes 请求时指定季 ID |
| `Fields` | query | 返回的字段列表，控制数据量 |

**特点**: 所有请求均走 `cache-first`（`_cachedItem`/`_cachedList`）— 缓存存在时立即返回，同时后台静默刷新缓存。

---

## 二、构建详情页（build 阶段）

### 2.1 itemFullProvider — 作品核心信息

```dart
final itemAsync = ref.watch(itemFullProvider(itemId));
```

内部通过 `EmbyCache.watchItemFull(id)` 返回 `Stream<BaseItemDto?>`：
- **首次**: 从 `_core` / `_userdata` / `_genres` / `_studios` / `_people` / `_mediaSources` box 组装完整对象
- **更新**: 任一 box 变化时自动 re-emit，UI 自动刷新

对应 API:
```
GET /Users/{uid}/Items/{itemId}
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `UserId` | 路径参数 | 当前用户 ID |
| `itemId` | 路径参数 | 作品 ID |
| `Fields` | `PrimaryImageAspectRatio,UserData,Genres,Overview,ProductionYear,RunTimeTicks,ProviderIds,Studios,MediaSources,People,OfficialRating,CommunityRating,CriticRating,Path,ImageTags,BackdropImageTags` | 需要返回的所有字段 |

**用途**: 标题、简介、年份、评分、海报/背景图、演员、制片公司、类型标签、播放源等。

---

### 2.2 detailViewModelProvider — 列表级数据

```dart
final detailAsync = ref.watch(detailViewModelProvider(itemId));
```

#### Step 1: Series 详情（cache-first）
```
GET /Users/{uid}/Items/{itemId}
```
- 同 2.1，但此调用在 `detail_viewmodel.dart` 中用于判断 `item.type`
- 若缓存存在则立即返回，不阻塞 UI

#### Step 2: Similar Items（关联推荐）
```
GET /Items/{itemId}/Similar?Limit=12
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `itemId` | 路径参数 | 参考作品 ID |
| `Limit` | `12` | 返回数量上限 |

#### Step 3: Seasons（仅 Series 类型）
```
GET /Shows/{itemId}/Seasons?Fields=PrimaryImageAspectRatio,ImageTags
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `itemId` | 路径参数 | 剧集 ID |
| `Fields` | `PrimaryImageAspectRatio,ImageTags` | 轻量字段 |

#### Step 4: Episodes（仅 Series 类型，首季）
```
GET /Shows/{itemId}/Episodes?SeasonId={seasonId}&Fields=PrimaryImageAspectRatio,ImageTags
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `itemId` | 路径参数 | 剧集 ID |
| `SeasonId` | query | 季 ID（默认首季） |
| `Fields` | `PrimaryImageAspectRatio,ImageTags` | 轻量字段 |

#### Step 5: Studio 详情图片
```
GET /Users/{uid}/Items/{studioId}?Fields=ImageTags
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `studioId` | 路径参数 | 制片公司 ID（来自 `item.studios`） |
| `Fields` | `ImageTags` | 只取图片字段 |

#### Step 6: 后台刷新（callback 链式）
```dart
getPageDetail(
  itemId,
  itemType: 'Series',
  onSeriesLoaded: (_) {},    // Series 刷新完成
  onSeasonsLoaded: (_) {},   // Seasons 刷新完成
  onEpisodesLoaded: (_) {},  // Episodes 刷新完成
)
```
内部按顺序串行执行:
1. `getSeries(itemId)`
2. `getSeasons(itemId)` → callback
3. `getEpisodes(itemId, firstSeasonId)` → callback
4. `getSimilarItems(itemId)`

**缓存更新 → `watchList` 自动刷新 state**：
- `EmbyCache.watchList('seasons|{itemId}')` → seasons 变化时更新 `DetailState.seasons`
- `EmbyCache.watchList('episodes|{itemId}|{seasonId}')` → episodes 变化时更新 `DetailState.episodes`

---

## 三、用户交互触发的 API 调用

### 3.1 切换 Season（Series 详情页）

用户点击某个 Season Tab/按钮：

```dart
// detail_viewmodel.dart
Future<void> selectSeason(String seasonId) async {
  // 1. 切换 episodes watcher 到新 season
  _watchEpisodes(cache, seasonId);

  // 2. 加载新 season 的 episodes（cache-first）
  final episodesResult = await mediaRepo.getEpisodes(
    itemId,
    seasonId: seasonId,
  );

  state = AsyncValue.data(current.copyWith(
    episodes: episodesResult.items,
    selectedSeasonId: seasonId,
  ));
}
```

对应 API:
```
GET /Shows/{itemId}/Episodes?SeasonId={seasonId}&Fields=PrimaryImageAspectRatio,ImageTags
```

---

### 3.2 点击演员（Person）

用户点击演员头像/名称：

```dart
_showRelatedItems(context, ref, title: person.name, personId: person.id)
```

弹出 BottomSheet 显示该演员最新 5 条作品，点击"查看更多"导航到:
```
/related?title=演员名&personId={personId}
```

对应 API:
```
GET /Users/{uid}/Items?PersonIds={personId}&IncludeItemTypes=Movie,Series&Limit=5&SortBy=ProductionYear
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `PersonIds` | `12345` | 演员 ID |
| `IncludeItemTypes` | `Movie,Series` | 只返回电影和剧集 |
| `Limit` | `5` / `20` | BottomSheet 5条，完整页 20条 |
| `SortBy` | `ProductionYear` | 按年份降序 |
| `SortOrder` | `Descending` | 降序 |

---

### 3.3 点击制片公司（Studio）

用户点击制片公司名称：

```dart
_showRelatedItems(context, ref, title: studio.name, studioId: studio.id)
```

对应 API:
```
GET /Users/{uid}/Items?StudioIds={studioId}&IncludeItemTypes=Movie,Series&Limit=5&SortBy=ProductionYear
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `StudioIds` | `44015` | 制片公司 ID |
| 其他 | 同上 | 同 3.2 |

---

### 3.4 点击类型标签（Genre）

用户点击 Genre Chip（如"爱情"、"科幻"）：

```dart
context.go('/related?title=爱情&genre=爱情')
```

对应 API:
```
GET /Users/{uid}/Items?Genres=爱情&IncludeItemTypes=Movie,Series&Limit=20&SortBy=ProductionYear
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `Genres` | `爱情` | **Genre 名称字符串**（中文自动 URL 编码） |
| `IncludeItemTypes` | `Movie,Series` | 只返回电影和剧集 |
| `Limit` | `20` | 每页数量 |
| `SortBy` | `ProductionYear` | 按年份降序 |

**注意**: Genre 筛选使用**名称字符串**（`Genres` 参数），不是 ID。Studio 筛选使用 ID（`StudioIds` 参数）。

---

### 3.5 点击相似作品（Similar Items）

用户点击推荐栏中的作品卡片：

```dart
goToDetail(context, ref, similarItem)
```

触发新的 `preloadDetailData` + 导航到 `/detail/{newId}`，重复整个**一、二**流程。

---

### 3.6 点击播放

用户点击播放按钮：

```dart
context.go('/player/${item.id}')
```

进入 `PlayerPage`，PlayerViewModel 调用:

```
POST /Items/{itemId}/PlaybackInfo
```
| 参数 | 值 | 说明 |
|------|-----|------|
| `itemId` | 路径参数 | 播放项 ID |
| `UserId` | query | 当前用户 ID |
| `MaxStreamingBitrate` | `140000000` | 最大码率 |
| `AutoOpenLiveStream` | `true` | 自动打开直播流 |

**返回**: `PlaybackInfo` 包含播放 URL、媒体源、字幕/音轨列表等。

---

### 3.7 播放器返回详情页

从 `PlayerPage` 返回时：

```dart
PopScope(
  onPopInvokedWithResult: (didPop, result) {
    context.go('/detail/${state.item?.seriesId ?? itemId}');
  },
)
```

返回目标:
- **Movie**: `/detail/{movieId}`
- **Episode**: `/detail/{seriesId}`（返回到所属剧集详情页）

**注意**: 返回后不会自动刷新，但 `itemFullProvider` 的 `watchItemFull` 会在后台缓存刷新完成后自动更新 UI（如播放进度）。

---

### 3.8 下拉刷新 / 重试

用户点击错误页的"重试"按钮或下拉刷新：

```dart
ref.invalidate(detailViewModelProvider(itemId));
```

这会重新触发 `build()`，重复**二**的全部流程。

---

## 四、完整调用序列图

```
用户点击卡片
    │
    ▼
preloadDetailData() ──→ getPageDetail() ──→ API Series/Seasons/Episodes/Similar
    │                                              │
    │                                              ▼
    │                                         写入 Hive 缓存
    │                                              │
    ▼                                              ▼
导航到 /detail/{id}                          watchList 监听到变化
    │                                              │
    ▼                                              ▼
DetailPage build()                            DetailState 自动更新
    │
    ├──→ itemFullProvider.watchItemFull() ──→ 首次组装 / 缓存更新时刷新
    │
    └──→ detailViewModelProvider.build()
            │
            ├──→ getSeries() ──→ 缓存命中立即返回
            ├──→ getSimilarItems() ──→ 缓存命中立即返回
            ├──→ getSeasons() ──→ 缓存命中立即返回
            ├──→ getEpisodes() ──→ 缓存命中立即返回
            ├──→ _loadStudioDetails() ──→ 逐个 getStudioDetail()
            │
            └──→ 后台: getPageDetail(callback 链式)
                    │
                    ├──→ onSeriesLoaded()
                    ├──→ onSeasonsLoaded() ──→ 缓存更新 ──→ watchList emit
                    └──→ onEpisodesLoaded() ──→ 缓存更新 ──→ watchList emit
```

---

## 五、关键参数速查表

| API | 关键参数 | 值示例 | 说明 |
|-----|---------|--------|------|
| `GET /Users/{uid}/Items/{id}` | `Fields` | 长字段列表 | 控制返回数据量 |
| `GET /Shows/{id}/Seasons` | `Fields` | `PrimaryImageAspectRatio,ImageTags` | 轻量 |
| `GET /Shows/{id}/Episodes` | `SeasonId` | `12345` | 指定季 |
| `GET /Items/{id}/Similar` | `Limit` | `12` | 推荐数量 |
| `GET /Users/{uid}/Items` (Studio) | `StudioIds` | `44015` | **ID** 筛选 |
| `GET /Users/{uid}/Items` (Person) | `PersonIds` | `67890` | **ID** 筛选 |
| `GET /Users/{uid}/Items` (Genre) | `Genres` | `爱情` | **名称** 筛选 |
| `POST /Items/{id}/PlaybackInfo` | `MaxStreamingBitrate` | `140000000` | 码率限制 |
