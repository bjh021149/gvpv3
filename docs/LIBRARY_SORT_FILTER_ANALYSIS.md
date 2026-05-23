# 媒体库详情页分类和排序功能分析

## 概览

媒体库详情页的分类和排序功能涉及多层架构：
1. **UI层** - FilterSortBar 和 LibraryPage
2. **状态管理** - LibraryViewModel
3. **数据层** - MediaRepositoryImpl
4. **API层** - EmbyApiService
5. **缓存层** - EmbyCache + CacheKeys

---

## 流程图

```
┌─────────────────────────────────────────────────────────────────┐
│ LibraryPage (UI Layer)                                          │
│  - FilterSortBar 显示排序/筛选控件                               │
│  - 监听 libraryViewModelProvider(parentId)                       │
└────────────────┬────────────────────────────────────────────────┘
                 │ ref.watch() / ref.read()
                 ↓
┌─────────────────────────────────────────────────────────────────┐
│ LibraryViewModel (AsyncNotifier)                                │
│  - setSortOption()    - 处理排序变更                             │
│  - setFilter()        - 处理筛选变更 (genre/studio)              │
│  - loadMore()         - 加载更多数据                             │
│  - build()            - 初始化时加载数据                         │
└────────────────┬────────────────────────────────────────────────┘
                 │ 调用
                 ↓
┌─────────────────────────────────────────────────────────────────┐
│ MediaRepositoryImpl (Repository Layer)                           │
│  - getItems()         - 查询项目列表（支持过滤/排序/分页）        │
│  - 缓存优先策略        - cache-first strategy                    │
│    1. 生成 cache key   - CacheKeys.items()                       │
│    2. 查缓存          - EmbyCache.getList()                      │
│    3. 缓存未命中      - 调用 API 获取数据                        │
│    4. 写入缓存        - EmbyCache.putItems()                     │
└────────────────┬────────────────────────────────────────────────┘
                 │ 调用
                 ↓
┌─────────────────────────────────────────────────────────────────┐
│ EmbyApiService (API Layer)                                      │
│  - getItems()         - 构建 query params 并发送 HTTP 请求        │
│  - 响应解析           - 解析 JSON 为 QueryResult<BaseItemDto>    │
└────────────────┬────────────────────────────────────────────────┘
                 │ HTTP GET
                 ↓
┌─────────────────────────────────────────────────────────────────┐
│ Emby Server                                                     │
│  GET /Users/{userId}/Items                                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 详细流程说明

### 1. UI层 - FilterSortBar (排序控件)

**文件**: `lib/features/library/filter_sort_bar.dart`

```dart
class FilterSortBar extends StatelessWidget {
  // 显示4种排序选项
  // - SortOption.name       → 'SortName'       (按名称)
  // - SortOption.dateAdded  → 'DateCreated'    (按添加时间)
  // - SortOption.rating     → 'CommunityRating'(按评分)
  // - SortOption.year       → 'ProductionYear' (按年份)
  
  // 用户选择排序时触发
  onSortChanged(SortOption) → 
    libraryViewModelProvider.notifier.setSortOption(sort)
}
```

**排序选项映射**:

| UI标签 | 枚举值 | API参数值 | 含义 |
|--------|--------|----------|------|
| 名称 | `SortOption.name` | `'SortName'` | 按项目名称字母排序 |
| 添加时间 | `SortOption.dateAdded` | `'DateCreated'` | 按添加到库的时间排序 |
| 评分 | `SortOption.rating` | `'CommunityRating'` | 按社区评分排序 |
| 年份 | `SortOption.year` | `'ProductionYear'` | 按制作年份排序 |

---

### 2. UI层 - 筛选按钮

**文件**: `lib/features/library/library_page.dart` - `_showFilterSheet()`

```dart
// 点击筛选按钮，弹出 BottomSheet
_showFilterSheet(context, ref, state) {
  // 显示两个筛选维度
  
  // 1. 类型筛选 (Genre)
  //    - state.availableGenres 包含所有可用类型
  //    - 用户选择后: onSelected() → 
  //      ref.read(libraryViewModelProvider.notifier).setFilter(
  //        genre: selected_genre,
  //        studioId: current_studioId
  //      )
  
  // 2. 制片公司筛选 (Studio)
  //    - state.availableStudios 包含所有 (studioId, studioName) 对
  //    - 用户选择后: onSelected() →
  //      ref.read(libraryViewModelProvider.notifier).setFilter(
  //        genre: current_genre,
  //        studioId: selected_studioId
  //      )
  
  // "清除筛选" 按钮
  //    - setFilter(genre: null, studioId: null)
}
```

---

### 3. 状态管理 - LibraryViewModel

**文件**: `lib/features/library/library_viewmodel.dart`

#### 初始化 - `build()` 方法

```dart
@override
Future<LibraryState> build() async {
  final mediaRepo = ref.read(mediaRepositoryProvider);
  
  // 步骤1: 获取所有库的顶级视图 (Movies, TV Shows, etc.)
  final viewsResult = await mediaRepo.getViews();
  
  // 步骤2: 如果有 parentId（用户进入具体库），加载数据
  if (parentId != null) {
    // 2a. 获取父级详情，确定类型过滤 (Movie/Series/...)
    final parent = await mediaRepo.getItemDetail(parentId!);
    final filters = _resolveTypeFilters(parent.collectionType);
    // → includeItemTypes: 'Movie' (如果是电影库)
    // → excludeItemTypes: 'Season,Episode' (混合库中排除季/集)
    
    // 2b. 初始化加载第一页数据 (默认按名称排序)
    final itemsResult = await mediaRepo.getItems(
      parentId: parentId,
      includeItemTypes: filters.includeItemTypes,
      excludeItemTypes: filters.excludeItemTypes,
      limit: 50,                              // 每页50项
      sortBy: SortOption.name.sortBy,         // 默认: 'SortName'
      recursive: true,                        // 递归包含子文件夹
    );
    
    // 2c. 加载所有可用的类型 (Genre) 供筛选使用
    final genreResult = await mediaRepo.getItems(
      parentId: parentId,
      includeItemTypes: 'Genre',              // 只查询类型项
      recursive: true,
      limit: 1000,
    );
    availableGenres = genreResult.items.map(g => g.name).toList()
      ..sort();  // 按名称排序
    
    // 2d. 加载所有可用的制片公司 (Studio) 供筛选使用
    final studioResult = await mediaRepo.getItems(
      parentId: parentId,
      includeItemTypes: 'Studio',             // 只查询制片公司项
      recursive: true,
      limit: 1000,
    );
    availableStudios = studioResult.items
      .map(s => MapEntry(s.id, s.name))
      .toList()
      ..sort((a, b) => a.value.compareTo(b.value));  // 按名称排序
  }
  
  return LibraryState(
    items: items,
    views: viewsResult.items,
    totalRecordCount: totalCount,
    availableGenres: availableGenres,
    availableStudios: availableStudios,
    includeItemTypes: filters.includeItemTypes,
    excludeItemTypes: filters.excludeItemTypes,
  );
}

// 类型过滤解析规则
_TypeFilters _resolveTypeFilters(String? collectionType) {
  return switch (collectionType) {
    'movies'   => const _TypeFilters(includeItemTypes: 'Movie'),
    'tvshows'  => const _TypeFilters(includeItemTypes: 'Series'),
    'mixed'    => const _TypeFilters(excludeItemTypes: 'Season,Episode'),
    _          => const _TypeFilters(),  // 其他类型不限制
  };
}
```

#### 排序变更 - `setSortOption()` 方法

```dart
Future<void> setSortOption(SortOption sort) async {
  final current = state.value;
  
  // 如果选择的排序选项相同，无需更新
  if (current == null || current.currentSort == sort) return;
  
  // 如果无 parentId（显示的是库列表），不需要重新加载
  if (parentId == null) {
    state = AsyncData(current.copyWith(currentSort: sort));
    return;
  }
  
  // 步骤1: 更新状态，重置分页，显示加载状态
  state = AsyncData(current.copyWith(
    currentSort: sort,
    items: const [],           // 清空项目列表
    currentPage: 0,            // 重置页码
    isLoadingMore: true,       // 显示加载中
  ));
  
  // 步骤2: 调用 API 获取按新排序方式排列的数据
  final result = await mediaRepo.getItems(
    parentId: parentId,
    includeItemTypes: current.includeItemTypes,
    excludeItemTypes: current.excludeItemTypes,
    limit: 50,
    sortBy: sort.sortBy,              // 新的排序字段
    recursive: true,
    // 保持当前的筛选条件
    genres: current.selectedGenre != null ? [current.selectedGenre!] : null,
    studioIds: current.selectedStudioId != null ? [current.selectedStudioId!] : null,
  );
  
  // 步骤3: 更新状态显示新数据
  state = AsyncData(LibraryState(
    items: result.items,
    currentSort: sort,          // 更新排序选项
    currentPage: 0,
    isLoadingMore: false,
    // ... 保留其他状态
  ));
}
```

**关键点**:
- 排序变更会 **清空当前列表** 并从第一页开始加载
- **保留** 当前选中的筛选条件 (genre/studio)
- 调用 `mediaRepo.getItems()` 时传入新的 `sortBy` 参数

#### 筛选变更 - `setFilter()` 方法

```dart
Future<void> setFilter({String? genre, String? studioId}) async {
  final current = state.value;
  
  // 如果筛选条件未实际变化，返回
  if (current.selectedGenre == genre && 
      current.selectedStudioId == studioId) {
    return;
  }
  
  // 如果无 parentId，只更新状态（不调用 API）
  if (parentId == null) {
    state = AsyncData(current.copyWith(
      selectedGenre: genre,
      selectedStudioId: studioId,
    ));
    return;
  }
  
  // 步骤1: 更新状态，准备重新加载
  state = AsyncData(current.copyWith(
    selectedGenre: genre,
    selectedStudioId: studioId,
    items: const [],
    currentPage: 0,
    isLoadingMore: true,
  ));
  
  // 步骤2: 调用 API 获取符合筛选条件的数据
  final result = await mediaRepo.getItems(
    parentId: parentId,
    includeItemTypes: current.includeItemTypes,
    excludeItemTypes: current.excludeItemTypes,
    limit: 50,
    sortBy: current.currentSort.sortBy,    // 保持当前排序方式
    recursive: true,
    // 新的筛选条件
    genres: genre != null ? [genre] : null,
    studioIds: studioId != null ? [studioId] : null,
  );
  
  // 步骤3: 更新状态
  state = AsyncData(LibraryState(
    items: result.items,
    selectedGenre: genre,
    selectedStudioId: studioId,
    currentPage: 0,
    isLoadingMore: false,
    // ... 保留其他状态
  ));
}
```

**关键点**:
- 筛选变更会 **清空当前列表** 并从第一页开始加载
- **保留** 当前选中的排序方式
- 类型参数: `genres` (字符串列表) 和 `studioIds` (ID列表)

#### 加载更多 - `loadMore()` 方法

```dart
Future<void> loadMore() async {
  final current = state.value;
  
  // 检查是否可以加载更多
  if (current == null ||
      current.isLoadingMore ||
      parentId == null ||
      !current.hasMore) {  // 已加载全部
    return;
  }
  
  // 步骤1: 更新状态
  state = AsyncData(current.copyWith(isLoadingMore: true));
  
  // 步骤2: 计算下一页的起始索引
  final nextPage = current.currentPage + 1;
  final result = await mediaRepo.getItems(
    parentId: parentId,
    includeItemTypes: current.includeItemTypes,
    excludeItemTypes: current.excludeItemTypes,
    limit: 50,
    startIndex: nextPage * 50,            // 计算偏移量
    sortBy: current.currentSort.sortBy,   // 保持排序方式
    recursive: true,
    // 保持筛选条件
    genres: current.selectedGenre != null ? [current.selectedGenre!] : null,
    studioIds: current.selectedStudioId != null ? [current.selectedStudioId!] : null,
  );
  
  // 步骤3: 追加新数据到列表
  state = AsyncData(current.copyWith(
    items: [...current.items, ...result.items],  // 拼接
    isLoadingMore: false,
    currentPage: nextPage,
    totalRecordCount: result.totalRecordCount,
  ));
}
```

**关键点**:
- 分页使用 **偏移量** (startIndex) 而非页码
- `nextPage * pageSize` 计算偏移
- 新数据 **追加** 而非替换

---

### 4. 数据层 - MediaRepositoryImpl

**文件**: `lib/services/repositories/media_repository_impl.dart`

```dart
@override
Future<QueryResult<BaseItemDto>> getItems({
  String? parentId,
  String? includeItemTypes,
  String? excludeItemTypes,
  String? sortBy,
  SortOrder? sortOrder,
  int? startIndex,
  int? limit,
  String? searchTerm,
  bool? recursive,
  List<String>? genreIds,
  List<String>? studioIds,
  List<String>? genres,
}) async {
  // 步骤1: 生成缓存 key
  final key = CacheKeys.items(
    parentId: parentId,
    includeItemTypes: includeItemTypes,
    excludeItemTypes: excludeItemTypes,
    sortBy: sortBy,
    startIndex: startIndex,
    limit: limit,
    genres: genres,
    studioIds: studioIds,
  );
  // 生成的 key 例如: 
  // "items|parent123|Movie|_|SortName|0|50|_|_"
  // "items|parent123|Movie|_|CommunityRating|0|50|Action,Drama|studio456"
  
  // 步骤2: 使用 _cachedList() 实现缓存优先策略
  return _cachedList(
    key: key,
    sortBy: sortBy,
    // fetch 闭包：如果缓存未命中，调用此方法获取数据
    fetch: () => _apiService.getItems(
      parentId: parentId,
      includeItemTypes: includeItemTypes,
      excludeItemTypes: excludeItemTypes,
      sortBy: sortBy,
      sortOrder: sortOrder == SortOrder.ascending,
      startIndex: startIndex,
      limit: limit,
      searchTerm: searchTerm,
      recursive: recursive,
      genreIds: genreIds,
      studioIds: studioIds,
      genres: genres,
    ),
  );
}

/// 缓存优先策略实现
Future<QueryResult<BaseItemDto>> _cachedList({
  required String key,
  required Future<QueryResult<BaseItemDto>> Function() fetch,
  Duration maxAge = _defaultListMaxAge,  // 默认5分钟
  bool includeHeavyFields = false,
  String? sortBy,
}) async {
  // 步骤1: 尝试从 Hive 缓存读取
  final cached = _cache.getList(
    key,
    includeHeavyFields: includeHeavyFields,
  );
  
  if (cached != null) {
    // 缓存命中，直接返回
    debugPrint('[MediaRepository] Cache hit: $key');
    return cached;
  }
  
  // 步骤2: 缓存未命中，调用 API
  debugPrint('[MediaRepository] Cache miss: $key, fetching from API...');
  final result = await fetch();
  
  // 步骤3: 写入缓存
  await _cache.putItems(result.items);  // 写入 item 明细
  await _cache.putList(
    key: key,
    items: result.items,
    totalRecordCount: result.totalRecordCount,
    sortBy: sortBy,
    maxAge: maxAge,
  );
  
  return result;
}
```

**缓存键生成规则**:

```dart
// CacheKeys.items()
static String items({
  String? parentId,
  String? includeItemTypes,
  String? excludeItemTypes,
  String? sortBy,
  int? startIndex,
  int? limit,
  List<String>? genres,
  List<String>? studioIds,
}) =>
    'items|${parentId ?? '_'}|${includeItemTypes ?? '_'}|${excludeItemTypes ?? '_'}|${sortBy ?? '_'}|${startIndex ?? 0}|${limit ?? 50}|${genres?.join(',') ?? '_'}|${studioIds?.join(',') ?? '_'}';
```

**缓存 Key 示例**:

| 场景 | 生成的 Key |
|------|----------|
| 初始化，按名称 | `items\|movie123\|Movie\|_\|SortName\|0\|50\|_\|_` |
| 按评分排序 | `items\|movie123\|Movie\|_\|CommunityRating\|0\|50\|_\|_` |
| 按年份，第2页 | `items\|movie123\|Movie\|_\|ProductionYear\|50\|50\|_\|_` |
| 筛选动作类型 | `items\|movie123\|Movie\|_\|SortName\|0\|50\|Action\|_` |
| 筛选多个类型 | `items\|movie123\|Movie\|_\|SortName\|0\|50\|Action,Drama\|_` |
| 筛选制片公司 | `items\|movie123\|Movie\|_\|SortName\|0\|50\|_\|studio456` |

**缓存策略说明**:

- **缓存优先** (cache-first)
  - 先查缓存，命中直接返回
  - 未命中才调用 API
  
- **过期时间**
  - 普通列表: 5分钟
  - 继续观看列表: 30秒（频繁变化）
  
- **缓存键包含所有查询参数**
  - 排序方式不同 → 不同的缓存键
  - 筛选条件不同 → 不同的缓存键
  - 分页偏移不同 → 不同的缓存键

---

### 5. API层 - EmbyApiService

**文件**: `lib/core/api/emby_api_service.dart`

```dart
Future<QueryResult<BaseItemDto>> getItems({
  String? parentId,
  String? includeItemTypes,
  String? excludeItemTypes,
  String? sortBy,
  bool? sortOrder,              // true = 升序, false = 降序
  int? startIndex,
  int? limit,
  String? searchTerm,
  List<String>? filters,
  bool? recursive,
  String? fields,
  int? imageTypeLimit,
  String? enableImageTypes,
  List<String>? studioIds,
  List<String>? personIds,
  List<String>? genreIds,
  List<String>? genres,        // 按类型名称筛选
}) async {
  try {
    // 步骤1: 构建查询参数
    final response = await dio.get<Map<String, dynamic>>(
      '/Users/$userId/Items',    // Emby API 端点
      queryParameters: <String, dynamic>{
        // 父文件夹 (必需，指定库)
        if (parentId != null) 'ParentId': parentId,
        
        // 类型过滤 (include 和 exclude 通常只用其一)
        if (includeItemTypes != null) 'IncludeItemTypes': includeItemTypes,
        // 例: 'Movie' 或 'Series'
        
        if (excludeItemTypes != null) 'ExcludeItemTypes': excludeItemTypes,
        // 例: 'Season,Episode' 在混合库中排除季和集
        
        // 排序
        if (sortBy != null) 'SortBy': sortBy,
        // 例: 'SortName', 'DateCreated', 'CommunityRating', 'ProductionYear'
        
        if (sortOrder != null) 'SortOrder': sortOrder ? 'Ascending' : 'Descending',
        // 排序方向: 升序/降序
        
        // 分页
        if (startIndex != null) 'StartIndex': startIndex,
        // 起始索引 (0-based)
        
        if (limit != null) 'Limit': limit,
        // 返回项目数量
        
        // 递归
        if (recursive != null) 'Recursive': recursive,
        // true = 包含子文件夹中的项目
        
        // 筛选: 按类型名称
        if (genres != null && genres.isNotEmpty) 'Genres': genres.join(','),
        // 例: 'Action,Drama' 返回包含这些类型标签的项目
        
        // 筛选: 按制片公司ID
        if (studioIds != null && studioIds.isNotEmpty) 'StudioIds': studioIds.join(','),
        // 例: 'studio1,studio2' 返回来自这些制片公司的项目
        
        // 其他参数
        if (genreIds != null && genreIds.isNotEmpty) 'GenreIds': genreIds.join(','),
        if (personIds != null && personIds.isNotEmpty) 'PersonIds': personIds.join(','),
        if (searchTerm != null && searchTerm.isNotEmpty) 'SearchTerm': searchTerm,
        if (filters != null && filters.isNotEmpty) 'Filters': filters.join(','),
        if (fields != null) 'Fields': fields,
        if (imageTypeLimit != null) 'ImageTypeLimit': imageTypeLimit,
        if (enableImageTypes != null) 'EnableImageTypes': enableImageTypes,
        
        // 获取总项目数
        'EnableTotalRecordCount': true,
      }..removeWhere((key, value) => value == null),  // 移除 null 值
    );
    
    // 步骤2: 解析响应
    if (response.data == null) {
      return const QueryResult<BaseItemDto>(items: [], totalRecordCount: 0);
    }
    
    final data = response.data!;
    
    // 解析项目列表
    final items = (data['Items'] as List<dynamic>? ?? [])
        .map((item) => BaseItemDto.fromJson(item as Map<String, dynamic>))
        .toList();
    
    // 解析总数
    final totalCount = data['TotalRecordCount'] as int? ?? items.length;
    
    return QueryResult<BaseItemDto>(
      items: items,
      totalRecordCount: totalCount,
    );
  } on DioException {
    rethrow;  // 让 Repository 层处理错误
  }
}
```

**Emby API 查询参数说明**:

| 参数 | 类型 | 示例 | 说明 |
|------|------|------|------|
| `ParentId` | string | `"abc123"` | 库的ID |
| `IncludeItemTypes` | string | `"Movie"` | 只返回指定类型的项目 |
| `ExcludeItemTypes` | string | `"Season,Episode"` | 排除指定类型的项目 |
| `SortBy` | string | `"SortName"` | 排序字段 |
| `SortOrder` | string | `"Ascending"` | 排序方向 |
| `StartIndex` | int | `50` | 分页起始位置 |
| `Limit` | int | `50` | 返回项目数量 |
| `Recursive` | bool | `true` | 递归查找 |
| `Genres` | string (CSV) | `"Action,Drama"` | 按类型名称筛选 |
| `StudioIds` | string (CSV) | `"abc,def"` | 按制片公司ID筛选 |
| `EnableTotalRecordCount` | bool | `true` | 返回总数 |

**HTTP 请求示例**:

```
GET /Users/user123/Items?ParentId=lib456&IncludeItemTypes=Movie&SortBy=SortName&SortOrder=Ascending&StartIndex=0&Limit=50&Recursive=true&EnableTotalRecordCount=true
```

---

## 关键数据模型

### LibraryState

```dart
class LibraryState {
  // 显示的项目列表
  final List<BaseItemDto> items;
  
  // 顶级库视图 (Movies, TV Shows, etc.)
  final List<BaseItemDto> views;
  
  // 当前排序方式
  final SortOption currentSort;  // name, dateAdded, rating, year
  
  // 当前视图模式
  final ViewMode viewMode;       // grid, list
  
  // 分页信息
  final int currentPage;         // 当前页码 (0-based)
  final int totalRecordCount;    // 总项目数
  final bool isLoadingMore;      // 是否正在加载更多
  
  // 类型过滤
  final String? includeItemTypes;   // 例: 'Movie'
  final String? excludeItemTypes;   // 例: 'Season,Episode'
  
  // 用户选择的筛选条件
  final String? selectedGenre;       // 选中的类型名称
  final String? selectedStudioId;    // 选中的制片公司ID
  
  // 可用的筛选选项（从API加载）
  final List<String> availableGenres;
  final List<MapEntry<String, String>> availableStudios;
  
  // 计算属性
  bool get hasMore => items.length < totalRecordCount;
}
```

### SortOption 枚举

```dart
enum SortOption {
  name('名称', 'SortName'),
  dateAdded('添加时间', 'DateCreated'),
  rating('评分', 'CommunityRating'),
  year('年份', 'ProductionYear');

  final String label;        // UI显示标签
  final String sortBy;       // API参数值
}
```

### QueryResult 模型

```dart
class QueryResult<T> {
  final List<T> items;           // 查询结果列表
  final int totalRecordCount;    // 总项目数（用于分页判断）
}
```

---

## 数据流示例

### 场景1: 用户在电影库中，点击"按评分排序"

```
1. FilterSortBar 上的用户操作
   onSortChanged(SortOption.rating)

2. LibraryPage 处理事件
   ref.read(libraryViewModelProvider(parentId).notifier).setSortOption(SortOption.rating)

3. LibraryViewModel.setSortOption() 执行
   - 更新状态: currentSort = SortOption.rating
   - 清空列表: items = []
   - 显示加载: isLoadingMore = true
   - 调用: mediaRepo.getItems(
       parentId: "lib123",
       includeItemTypes: "Movie",
       sortBy: "CommunityRating"      ← 关键变化
     )

4. MediaRepositoryImpl.getItems() 执行
   - 生成 key: "items|lib123|Movie|_|CommunityRating|0|50|_|_"
   - 查缓存: miss
   - 调用 API

5. EmbyApiService.getItems() 执行
   - HTTP GET /Users/user123/Items?ParentId=lib123&IncludeItemTypes=Movie&SortBy=CommunityRating&SortOrder=Ascending&Limit=50&Recursive=true

6. Emby 服务器返回
   按社区评分排序的电影列表

7. EmbyApiService 解析响应
   QueryResult(items: [Movie1, Movie2, ...], totalRecordCount: 456)

8. MediaRepositoryImpl 缓存结果
   写入 Hive: key="items|lib123|Movie|_|CommunityRating|0|50|_|_"

9. LibraryViewModel 更新状态
   state = AsyncData(LibraryState(
     items: [...],
     currentSort: SortOption.rating,
     isLoadingMore: false,
     totalRecordCount: 456,
   ))

10. UI 自动重建显示新排序结果
```

### 场景2: 用户筛选"动作"类型的电影

```
1. FilterSortBar 中筛选按钮点击
   onFilterPressed() → _showFilterSheet()

2. BottomSheet 显示可用类型
   availableGenres: ["动作", "喜剧", "恐怖", ...]
   用户选择: "动作"

3. LibraryPage 处理选择
   ref.read(libraryViewModelProvider.notifier).setFilter(
     genre: "动作",
     studioId: null
   )

4. LibraryViewModel.setFilter() 执行
   - 更新状态: selectedGenre = "动作"
   - 清空列表: items = []
   - 调用: mediaRepo.getItems(
       parentId: "lib123",
       includeItemTypes: "Movie",
       sortBy: "SortName",
       genres: ["动作"]         ← 关键参数
     )

5. MediaRepositoryImpl.getItems() 执行
   - 生成 key: "items|lib123|Movie|_|SortName|0|50|动作|_"
   - 查缓存: miss (因为之前没有查询过这个组合)
   - 调用 API

6. EmbyApiService.getItems() 执行
   - HTTP GET /Users/user123/Items?ParentId=lib123&IncludeItemTypes=Movie&SortBy=SortName&Genres=动作&Limit=50

7. Emby 服务器返回
   只包含"动作"类型的电影

8. UI 显示筛选后的结果
   同时 FilterSortBar 显示当前排序是 SortOption.name
```

### 场景3: 用户滚动到列表底部，加载第2页

```
1. MediaGrid 或 ListView 检测滚动位置
   NotificationListener 触发加载条件

2. LibraryPage 调用
   ref.read(libraryViewModelProvider.notifier).loadMore()

3. LibraryViewModel.loadMore() 执行
   - 计算: nextPage = 1, startIndex = 1 * 50 = 50
   - 显示加载: isLoadingMore = true
   - 调用: mediaRepo.getItems(
       parentId: "lib123",
       includeItemTypes: "Movie",
       sortBy: "SortName",
       startIndex: 50,            ← 分页参数
       limit: 50,
       genres: ["动作"]           ← 保持筛选条件
     )

4. API 调用与缓存
   - 生成 key: "items|lib123|Movie|_|SortName|50|50|动作|_"
   - 缓存 miss (第2页是新 key)
   - 发送 HTTP GET 请求

5. 更新状态
   state.items = [...prev50, ...next50]  ← 追加而非替换
   state.currentPage = 1
   state.isLoadingMore = false

6. UI 显示拼接后的列表
```

---

## 性能优化细节

### 1. 缓存策略

```dart
// 普通列表缓存 5 分钟
final cached = _cache.getList(key);
if (cached != null) return cached;

// 继续观看列表缓存 30 秒（因为频繁变化）
final cached = _cachedList(
  key: key,
  maxAge: Duration(seconds: 30),  // 更短的过期时间
);
```

### 2. 类型过滤的预加载

```dart
// 初始化时预加载所有可用的筛选选项
availableGenres = await mediaRepo.getItems(
  parentId: parentId,
  includeItemTypes: 'Genre',      // 查询 Genre 类型
);

availableStudios = await mediaRepo.getItems(
  parentId: parentId,
  includeItemTypes: 'Studio',     // 查询 Studio 类型
);
```

### 3. 分页加载

```dart
// 使用偏移量而非页码
startIndex = currentPage * pageSize  // 50, 100, 150, ...

// 追加而非替换
items = [...items, ...newItems]
```

### 4. 状态重置

```dart
// 排序/筛选变更时重置状态
currentPage: 0              // 回到第一页
items: const []             // 清空列表
isLoadingMore: true         // 显示加载
```

---

## 总结

| 层级 | 关键文件 | 主要职责 |
|------|---------|---------|
| **UI** | `library_page.dart`, `filter_sort_bar.dart` | 显示排序/筛选控件，处理用户交互 |
| **状态** | `library_viewmodel.dart` | 管理状态变化，协调数据加载 |
| **数据** | `media_repository_impl.dart` | 实现缓存优先策略，调用 API |
| **API** | `emby_api_service.dart` | 构建查询参数，发送 HTTP 请求 |
| **缓存** | `emby_cache.dart`, `cache_keys.dart` | 存储/查询缓存数据 |

**关键参数流**:

排序选项 → `SortOption.sortBy` → API 的 `SortBy` 参数
筛选条件 → `genres` / `studioIds` 列表 → API 的 `Genres` / `StudioIds` 参数
分页 → `currentPage * pageSize` → API 的 `StartIndex` 参数

**缓存键包含所有查询变量**，确保不同的排序/筛选/分页组合会生成不同的缓存键，避免数据混污。
