# Emby API 接口文档

> 本文档基于 GrassVideoPlayer Emby V2 (gvpv2) 项目代码生成，涵盖 `lib/emby_api/` 目录下所有 API 接口的用途、参数、响应模型及 curl 示例。
>
> **认证方式说明**：
> - 大部分接口通过 `api_key` 查询参数进行认证（`?api_key=xxx`），由 `DioProvider` 拦截器自动注入。
> - 登录接口使用 `Authorization: MediaBrowser Client=...` 请求头。
> - 下文 curl 示例中 `$API_KEY` 表示 Emby AccessToken，`$SERVER_URL` 表示服务器地址（如 `http://localhost:8096`），`$USER_ID` 表示用户 ID。

---

## 目录

1. [认证 (Authentication)](#1-认证-authentication)
2. [统一 API 服务 (EmbyApiService)](#2-统一-api-服务-embyapiservice)
3. [图片服务 (ImageApi)](#3-图片服务-imageapi)
4. [项目详情 (ItemDetailApi)](#4-项目详情-itemdetailapi)
5. [播放信息 (PlaybackInfoApi)](#5-播放信息-playbackinfoapi)
6. [播放上报 (PlaybackReportingApi)](#6-播放上报-playbackreportingapi)
7. [快捷连接 (QuickConnectApi)](#7-快捷连接-quickconnectapi)
8. [系统接口 (SystemApi)](#8-系统接口-systemapi)
9. [用户数据 (UserDataApi)](#9-用户数据-userdataapi)
10. [视频流 (VideoApi)](#10-视频流-videoapi)

---

## 1. 认证 (Authentication)

文件：`lib/emby_api/auth_api.dart`

---

### `authenticateByName`

**作用**：通过用户名和密码获取 Emby 认证令牌（AccessToken）。

**HTTP 方法与端点**

```
POST /Users/AuthenticateByName
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `username` | `String` | 是 | Emby 用户名 |
| `password` | `String` | 否 | 密码，未设置密码时传空字符串 |
| `client` | `String` | 否 | 客户端标识，默认 `MyFlutterApp` |
| `device` | `String` | 否 | 设备名称，默认 `MyDevice` |
| `deviceId` | `String?` | 否 | 设备唯一 ID，未传时自动从 SharedPreferences 读取或生成 UUIDv4 |
| `version` | `String` | 否 | 客户端版本，默认 `1.0.0` |

**请求模型 / Body**

请求体为 `application/x-www-form-urlencoded` 格式的表单数据：

```
Username={username}
Pw={password}
```

请求头：
```
Authorization: MediaBrowser Client="MyFlutterApp", Device="MyDevice", DeviceId="xxx", Version="1.0.0"
Content-Type: application/x-www-form-urlencoded
```

**响应模型**

返回 `Map<String, dynamic>`，核心字段如下：

| 字段 | 类型 | 说明 |
|------|------|------|
| `AccessToken` | `String` | 访问令牌，即后续请求用的 `api_key` |
| `User` | `Map` | 用户信息对象 |
| `User.Id` | `String` | 用户唯一 ID |
| `User.Name` | `String` | 用户名 |
| `SessionInfo` | `Map?` | 会话信息 |
| `SessionInfo.Id` | `String?` | 会话 ID，用于播放上报 |

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Users/AuthenticateByName" \
  -H "Authorization: MediaBrowser Client=\"MyFlutterApp\", Device=\"MyDevice\", DeviceId=\"550e8400-e29b-41d4-a716-446655440000\", Version=\"1.0.0\"" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "Username=$USERNAME" \
  -d "Pw=$PASSWORD"
```

---

### `authenticateByNameQuery`

**作用**：通过 Query 参数进行认证的备用方法（兼容旧版本）。

**HTTP 方法与端点**

```
GET /Users/AuthenticateByName
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `username` | `String` | 是 | Emby 用户名 |
| `password` | `String` | 否 | 密码 |

**响应模型**

同 `authenticateByName`。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/AuthenticateByName?username=$USERNAME&password=$PASSWORD"
```

---

## 2. 统一 API 服务 (EmbyApiService)

文件：`lib/emby_api/emby_api_service.dart`

> `EmbyApiService` 是新架构下的统一 HTTP API 服务，通过构造函数注入 `Dio` 实例。所有请求自动携带 `api_key`。

---

### `getItemsRaw`

**作用**：通用媒体项目查询接口，返回原始响应（含 `Items` 数组和 `TotalRecordCount`）。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `parentId` | `String?` | 否 | 父文件夹/媒体库 ID，限定在该父级下递归查询 |
| `includeTypes` | `List<String>?` | 否 | 包含的项目类型，如 `['Movie', 'Series']`，多个用逗号连接 |
| `excludeTypes` | `List<String>?` | 否 | 排除的项目类型 |
| `limit` | `int?` | 否 | 返回结果数量上限 |
| `startIndex` | `int?` | 否 | 分页起始偏移量 |
| `sortBy` | `String?` | 否 | 排序字段，如 `DateCreated`, `SortName`, `ProductionYear` |
| `sortOrder` | `String?` | 否 | 排序方向：`Ascending` 或 `Descending` |
| `recursive` | `bool?` | 否 | 是否递归查询子目录 |
| `filters` | `Map<String, dynamic>?` | 否 | 额外过滤参数，直接拼接到 Query |
| `fields` | `List<String>?` | 否 | 需要返回的额外字段，如 `['MediaSources', 'Overview']` |
| `searchTerm` | `String?` | 否 | 搜索关键词 |

**响应模型**

```json
{
  "Items": [
    {
      "Id": "string",
      "Name": "string",
      "Type": "Movie|Series|Episode|...",
      "ProductionYear": 2024,
      "Overview": "string",
      "ImageTags": {"Primary": "tag1"},
      "UserData": {"PlaybackPositionTicks": 0, "PlayedPercentage": 0.0},
      "MediaSources": [...]
    }
  ],
  "TotalRecordCount": 100
}
```

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/$USER_ID/Items?ParentId=13951&IncludeItemTypes=Movie,Series&Limit=30&SortBy=DateCreated&SortOrder=Descending&Recursive=true&Fields=MediaSources,Overview,UserData,ImageTags,ProductionYear&api_key=$API_KEY"
```

---

### `getItems`

**作用**：`getItemsRaw` 的简化版，仅返回 `Items` 数组。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items
```

**请求参数表**

同 `getItemsRaw`。

**响应模型**

`List<Map<String, dynamic>>` — 仅返回 `Items` 数组内容。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/$USER_ID/Items?ParentId=13951&IncludeItemTypes=Movie&Limit=10&api_key=$API_KEY"
```

---

### `getUserViews`

**作用**：获取用户可见的媒体库视图列表（首页展示的媒体库）。

**HTTP 方法与端点**

```
GET /Users/{userId}/Views
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `videoOnly` | `bool` | 否 | 是否只返回视频类媒体库（电影/电视剧/混合），默认 `false` |
| `fields` | `List<String>?` | 否 | 额外返回字段 |

**响应模型**

`List<Map<String, dynamic>>`，每个元素代表一个媒体库：

| 字段 | 类型 | 说明 |
|------|------|------|
| `Id` | `String` | 媒体库 ID |
| `Name` | `String` | 媒体库名称 |
| `CollectionType` | `String` | 类型：`movies`, `tvshows`, `music`, `mixed` 等 |
| `ImageTags` | `Map` | 图片标签 |

**完整响应示例**

```json
{
  "Items": [
    {
      "Id": "13951",
      "Name": "电影",
      "CollectionType": "movies",
      "ImageTags": {"Primary": "abc123"}
    },
    {
      "Id": "13952",
      "Name": "电视剧",
      "CollectionType": "tvshows",
      "ImageTags": {"Primary": "def456"}
    }
  ]
}
```

**curl 示例**

```bash
# 获取所有媒体库
curl -X GET "$SERVER_URL/Users/$USER_ID/Views?api_key=$API_KEY"

# 只获取视频类媒体库
curl -X GET "$SERVER_URL/Users/$USER_ID/Views?api_key=$API_KEY"
```

---

### `getLibraryDetail`

**作用**：获取指定媒体库的详细信息。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items/{libraryId}
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `libraryId` | `String` | 是 | 媒体库 ID（从 `getUserViews` 获取）|

**响应模型**

`Map<String, dynamic>`，包含媒体库的完整元数据。

**完整响应示例**

```json
{
  "Id": "13951",
  "Name": "电影",
  "Type": "CollectionFolder",
  "CollectionType": "movies",
  "Path": "/media/movies",
  "ImageTags": {"Primary": "abc123"},
  "Overview": "电影媒体库"
}
```

**curl 示例**

```bash
# 先获取媒体库列表，再用 Id 查详情
curl -X GET "$SERVER_URL/Users/$USER_ID/Views?api_key=$API_KEY" | jq '.Items[].Id'

# 获取指定媒体库详情
curl -X GET "$SERVER_URL/Users/$USER_ID/Items/13951?api_key=$API_KEY"
```

---

### `getLatestMedia`

**作用**：获取指定媒体库下的最新添加项目。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items/Latest
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `parentId` | `String?` | 否 | 父级 ID（媒体库 ID） |
| `limit` | `int?` | 否 | 返回数量，默认 `20` |
| `includeTypes` | `List<String>?` | 否 | 过滤类型 |
| `groupItems` | `bool` | 否 | 是否按系列分组，默认 `true` |

**响应模型**

`List<Map<String, dynamic>>` — 最新项目列表。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/$USER_ID/Items/Latest?ParentId=13951&Limit=10&GroupItems=true&api_key=$API_KEY"
```

---

### `getResumeItems`

**作用**：获取用户的"继续观看"列表（有播放进度且未看完的项目）。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `limit` | `int?` | 否 | 返回数量，默认 `20` |
| `startIndex` | `int?` | 否 | 分页偏移 |
| `sortBy` | `String?` | 否 | 排序字段，默认 `DatePlayed` |
| `sortOrder` | `String?` | 否 | 排序方向，默认 `Descending` |

**Query 固定参数**

- `IncludeItemTypes: Movie,Episode`
- `Filters: IsResumable`
- `Recursive: true`
- `Fields: PrimaryImageAspectRatio,UserData,MediaSources,Overview,RunTimeTicks,SeriesName,SeasonName,IndexNumber,ParentIndexNumber,ProductionYear`

**响应模型**

`List<Map<String, dynamic>>` — 每个项目包含 `UserData.PlaybackPositionTicks` 等续播信息。

**完整响应示例**

```json
{
  "Items": [
    {
      "Id": "10001",
      "Name": "阿凡达：水之道",
      "Type": "Movie",
      "ProductionYear": 2022,
      "RunTimeTicks": 115200000000,
      "ImageTags": {"Primary": "tag1"},
      "UserData": {
        "PlaybackPositionTicks": 36000000000,
        "PlayedPercentage": 31.25,
        "Played": false
      },
      "MediaSources": [
        {"Id": "10001", "Path": "/media/avatar2.mkv", "Protocol": "File"}
      ]
    },
    {
      "Id": "20001",
      "Name": "绝命毒师 S01E03",
      "Type": "Episode",
      "SeriesName": "绝命毒师",
      "SeasonName": "第一季",
      "IndexNumber": 3,
      "ImageTags": {"Primary": "tag2"},
      "UserData": {
        "PlaybackPositionTicks": 18000000000,
        "PlayedPercentage": 50.0,
        "Played": false
      }
    }
  ],
  "TotalRecordCount": 2
}
```

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/$USER_ID/Items?IncludeItemTypes=Movie,Episode&Filters=IsResumable&Recursive=true&SortBy=DatePlayed&SortOrder=Descending&Limit=20&Fields=PrimaryImageAspectRatio,UserData,MediaSources,Overview,RunTimeTicks,SeriesName,SeasonName,IndexNumber,ParentIndexNumber,ProductionYear&api_key=$API_KEY"
```

---

### `getFavorites`

**作用**：获取用户收藏的项目列表。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `includeTypes` | `List<String>?` | 否 | 过滤类型 |
| `limit` | `int?` | 否 | 返回数量，默认 `100` |
| `startIndex` | `int?` | 否 | 分页偏移 |
| `sortBy` | `String?` | 否 | 排序字段，默认 `SortName` |
| `sortOrder` | `String?` | 否 | 排序方向，默认 `Ascending` |

**Query 固定参数**

- `Filters: IsFavorite`
- `Recursive: true`

**响应模型**

`List<Map<String, dynamic>>` — 收藏项目列表。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/$USER_ID/Items?Filters=IsFavorite&Recursive=true&Limit=100&SortBy=SortName&SortOrder=Ascending&api_key=$API_KEY"
```

---

### `getNextUp`

**作用**：获取电视剧的"下一集"列表。

**HTTP 方法与端点**

```
GET /Shows/NextUp
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `seriesId` | `String?` | 否 | 限定特定剧集系列 |
| `limit` | `int?` | 否 | 返回数量，默认 `20` |

**响应模型**

`List<Map<String, dynamic>>` — 下一集列表。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Shows/NextUp?UserId=$USER_ID&Limit=20&api_key=$API_KEY"
```

---

### `getUpcoming`

**作用**：获取即将播出的剧集。

**HTTP 方法与端点**

```
GET /Shows/Upcoming
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `limit` | `int?` | 否 | 返回数量，默认 `20` |

**响应模型**

`List<Map<String, dynamic>>` — 即将播出列表。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Shows/Upcoming?UserId=$USER_ID&Limit=20&api_key=$API_KEY"
```

---

### `getMovieRecommendations`

**作用**：获取电影推荐列表（按分类返回，如"因为你观看了..."、"相似于..."）。

**HTTP 方法与端点**

```
GET /Movies/Recommendations
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemLimit` | `int?` | 否 | 每个分类的项目数，默认 `10` |
| `categoryLimit` | `int?` | 否 | 分类数量上限，默认 `3` |
| `parentId` | `String?` | 否 | 限定媒体库（从 `getUserViews` 获取的 `Id`）|
| `enableImages` | `bool?` | 否 | 是否包含图片信息 |
| `enableUserData` | `bool?` | 否 | 是否包含用户数据 |

**响应模型**

`List<Map<String, dynamic>>` — 每个元素是一个推荐分类：

| 字段 | 类型 | 说明 |
|------|------|------|
| `Items` | `List<Map>` | 该类别的推荐电影列表 |
| `RecommendationType` | `String` | 推荐类型，如 `SimilarToRecentlyPlayed`、`BecauseYouWatched` |
| `BaselineItemName` | `String?` | 基础项目名称（BecauseYouWatched 类型时存在）|

**完整响应示例**

```json
[
  {
    "Items": [
      {
        "Id": "10010",
        "Name": "星际穿越",
        "ProductionYear": 2014,
        "Type": "Movie",
        "ImageTags": {"Primary": "tag10"},
        "Overview": "地球末日来临，探险家穿越虫洞寻找新家园。",
        "UserData": {"Played": false, "IsFavorite": false}
      }
    ],
    "RecommendationType": "BecauseYouWatched",
    "BaselineItemName": "盗梦空间"
  },
  {
    "Items": [
      {
        "Id": "10011",
        "Name": "银翼杀手 2049",
        "ProductionYear": 2017,
        "Type": "Movie",
        "ImageTags": {"Primary": "tag11"}
      }
    ],
    "RecommendationType": "SimilarToRecentlyPlayed"
  }
]
```

**curl 示例**

```bash
# 获取首页推荐电影（3 个分类，每类 10 部）
curl -X GET "$SERVER_URL/Movies/Recommendations?UserId=$USER_ID&ItemLimit=10&CategoryLimit=3&api_key=$API_KEY"

# 限定特定电影媒体库
curl -X GET "$SERVER_URL/Movies/Recommendations?UserId=$USER_ID&ParentId=13951&ItemLimit=10&CategoryLimit=3&api_key=$API_KEY"
```

---

### `getItemDetail`

**作用**：获取指定项目的完整详情（Movie / Series / Episode / Season 等）。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items/{itemId}
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |

**响应模型**

`Map<String, dynamic>`，包含项目的完整元数据。不同类型的项目返回的字段略有差异：

**Movie 类型返回示例**

| 字段 | 类型 | 说明 |
|------|------|------|
| `Id` | `String` | 项目 ID |
| `Name` | `String` | 名称 |
| `Type` | `String` | `Movie` |
| `Overview` | `String` | 简介 |
| `ProductionYear` | `int` | 年份 |
| `RunTimeTicks` | `int` | 时长（Ticks，1 Tick = 100 纳秒）|
| `ImageTags` | `Map` | 图片标签，如 `{"Primary": "tag1"}` |
| `BackdropImageTags` | `List<String>` | 背景图标签列表 |
| `Genres` | `List<String>` | 类型标签，如 `["科幻", "冒险"]` |
| `People` | `List<Map>` | 演职员列表，含 `Name`, `Type`(`Actor`/`Director`) |
| `MediaSources` | `List` | 媒体源列表 |
| `UserData` | `Map` | 用户数据 |

**Series 类型特有字段**

| 字段 | 类型 | 说明 |
|------|------|------|
| `Status` | `String` | 状态：`Continuing`（连载中）/ `Ended`（已完结）|
| `SeasonCount` | `int` | 总季数 |
| `EpisodeCount` | `int` | 总集数 |

**完整响应示例（Movie）**

```json
{
  "Id": "10001",
  "Name": "阿凡达：水之道",
  "Type": "Movie",
  "ProductionYear": 2022,
  "RunTimeTicks": 115200000000,
  "Overview": "杰克·萨利一家在潘多拉星球的新冒险...",
  "Genres": ["科幻", "动作", "冒险"],
  "ImageTags": {"Primary": "tag1", "Logo": "tag2"},
  "BackdropImageTags": ["bd1", "bd2"],
  "People": [
    {"Name": "詹姆斯·卡梅隆", "Type": "Director"},
    {"Name": "萨姆·沃辛顿", "Type": "Actor"}
  ],
  "MediaSources": [
    {
      "Id": "10001",
      "Path": "/media/avatar2.mkv",
      "Protocol": "File",
      "Type": "Default"
    }
  ],
  "UserData": {
    "PlaybackPositionTicks": 36000000000,
    "PlayedPercentage": 31.25,
    "Played": false,
    "IsFavorite": false
  }
}
```

**curl 示例**

```bash
# 获取电影详情
curl -X GET "$SERVER_URL/Users/$USER_ID/Items/10001?api_key=$API_KEY"

# 获取电视剧详情
curl -X GET "$SERVER_URL/Users/$USER_ID/Items/20001?api_key=$API_KEY"

# 获取季详情
curl -X GET "$SERVER_URL/Users/$USER_ID/Items/30001?api_key=$API_KEY"

# 获取单集详情
curl -X GET "$SERVER_URL/Users/$USER_ID/Items/40001?api_key=$API_KEY"
```

---

### `getResumePositionMs`

**作用**：获取指定项目的续播位置（毫秒）。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items/{itemId}
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |

**响应模型**

`int?` — 毫秒数。内部逻辑：`UserData.PlaybackPositionTicks / 10000`。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/$USER_ID/Items/12345?api_key=$API_KEY" | jq '.UserData.PlaybackPositionTicks'
# 将返回值除以 10000 即为毫秒
```

---

### `getSeasons`

**作用**：获取指定剧集的所有季列表。

**HTTP 方法与端点**

```
GET /Shows/{seriesId}/Seasons
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `seriesId` | `String` | 是 | 剧集系列 ID |

**Query 固定参数**

- `UserId: {userId}`
- `Fields: Overview,Genres,ImageTags,ProductionYear`

**响应模型**

`List<Map<String, dynamic>>` — 季列表，每个元素包含 `Id`, `Name`, `IndexNumber`, `ImageTags` 等。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Shows/12345/Seasons?UserId=$USER_ID&Fields=Overview,Genres,ImageTags,ProductionYear&api_key=$API_KEY"
```

---

### `getEpisodes`

**作用**：获取指定剧集和季的所有集列表。

**HTTP 方法与端点**

```
GET /Shows/{seriesId}/Episodes
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `seriesId` | `String` | 是 | 剧集系列 ID |
| `seasonId` | `String` | 是 | 季 ID |
| `fields` | `List<String>?` | 否 | 额外字段，默认 `['Overview', 'ImageTags', 'MediaSources', 'UserData']` |

**Query 固定参数**

- `SeasonId: {seasonId}`
- `UserId: {userId}`

**响应模型**

`List<Map<String, dynamic>>` — 集列表，每个元素包含 `Id`, `Name`, `IndexNumber`, `Overview`, `MediaSources`, `UserData` 等。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Shows/12345/Episodes?SeasonId=67890&UserId=$USER_ID&Fields=Overview,ImageTags,MediaSources,UserData&api_key=$API_KEY"
```

---

### `getPlaybackInfo`

**作用**：获取项目的播放信息（媒体源、转码选项等）。

**HTTP 方法与端点**

```
GET /Items/{itemId}/PlaybackInfo
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |

**Query 固定参数**

- `UserId: {userId}`

**响应模型**

`Map<String, dynamic>?`，核心字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `MediaSources` | `List<Map>` | 可用媒体源列表 |
| `PlaySessionId` | `String` | 播放会话 ID |
| `RunTimeTicks` | `int` | 总时长 |

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Items/12345/PlaybackInfo?UserId=$USER_ID&api_key=$API_KEY"
```

---

### `getSimilarItems`

**作用**：获取与指定项目相似的项目列表。

**HTTP 方法与端点**

```
GET /Items/{itemId}/Similar
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `limit` | `int?` | 否 | 返回数量，默认 `12` |
| `includeTypes` | `List<String>?` | 否 | 限定返回类型 |

**响应模型**

`List<Map<String, dynamic>>` — 相似项目列表。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Items/12345/Similar?UserId=$USER_ID&Limit=12&api_key=$API_KEY"
```

---

### `getSearchHints`

**作用**：获取搜索建议列表（快速搜索提示）。

**HTTP 方法与端点**

```
GET /Search/Hints
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `searchTerm` | `String` | 是 | 搜索关键词 |
| `limit` | `int?` | 否 | 返回数量，默认 `20` |
| `includeTypes` | `List<String>?` | 否 | 包含的类型 |
| `excludeTypes` | `List<String>?` | 否 | 排除的类型 |

**响应模型**

`List<dynamic>` — 搜索结果列表。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Search/Hints?SearchTerm=Avatar&Limit=20&UserId=$USER_ID&api_key=$API_KEY"
```

---

### `search`

**作用**：执行完整搜索，返回项目详情列表。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `searchTerm` | `String` | 是 | 搜索关键词 |
| `limit` | `int?` | 否 | 返回数量，默认 `100` |
| `startIndex` | `int?` | 否 | 分页偏移 |
| `includeTypes` | `List<String>?` | 否 | 包含的类型 |
| `mediaTypes` | `String?` | 否 | 媒体类型过滤 |

**Query 固定参数**

- `Recursive: true`
- `Fields: Overview,Genres,ImageTags,ProductionYear,UserData`

**响应模型**

`Map<String, dynamic>` — 同 `getItemsRaw` 格式（含 `Items` 和 `TotalRecordCount`）。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/$USER_ID/Items?SearchTerm=Avatar&Recursive=true&Limit=100&Fields=Overview,Genres,ImageTags,ProductionYear,UserData&api_key=$API_KEY"
```

---

### `reportPlaybackStart`

**作用**：上报播放开始事件。

**HTTP 方法与端点**

```
POST /Sessions/Playing
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `mediaSourceId` | `String` | 是 | 媒体源 ID |
| `sessionId` | `String?` | 否 | 会话 ID |
| `playSessionId` | `String?` | 否 | 播放会话 ID |
| `playMethod` | `String?` | 否 | 播放方式，默认 `DirectStream` |

**请求 Body**

```json
{
  "ItemId": "12345",
  "MediaSourceId": "12345",
  "CanSeek": true,
  "PlayMethod": "DirectStream",
  "SessionId": "...",
  "PlaySessionId": "..."
}
```

**响应模型**

`void` — 无返回值，HTTP 200 即成功。

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Sessions/Playing?api_key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "ItemId": "12345",
    "MediaSourceId": "12345",
    "CanSeek": true,
    "PlayMethod": "DirectStream"
  }'
```

---

### `reportPlaybackProgress`

**作用**：上报播放进度（周期性调用，通常每 5-10 秒一次）。

**HTTP 方法与端点**

```
POST /Sessions/Playing/Progress
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `mediaSourceId` | `String` | 是 | 媒体源 ID |
| `position` | `Duration` | 是 | 当前播放位置 |
| `sessionId` | `String?` | 否 | 会话 ID |
| `playSessionId` | `String?` | 否 | 播放会话 ID |
| `runtime` | `Duration?` | 否 | 总时长 |
| `isPaused` | `bool` | 否 | 是否暂停，默认 `false` |
| `playMethod` | `String?` | 否 | 播放方式 |

**请求 Body**

```json
{
  "ItemId": "12345",
  "MediaSourceId": "12345",
  "PositionTicks": 600000000,
  "IsPaused": false,
  "PlaybackRate": 1.0,
  "CanSeek": true,
  "PlayMethod": "DirectStream",
  "RunTimeTicks": 7200000000
}
```

> 注意：`PositionTicks = position.inMicroseconds * 10`，即 1 秒 = 10,000,000 Ticks。

**响应模型**

`void` — HTTP 200 即成功。

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Sessions/Playing/Progress?api_key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "ItemId": "12345",
    "MediaSourceId": "12345",
    "PositionTicks": 600000000,
    "IsPaused": false,
    "PlaybackRate": 1.0,
    "CanSeek": true,
    "PlayMethod": "DirectStream"
  }'
```

---

### `reportPlaybackStopped`

**作用**：上报播放停止事件（用户退出播放器或切换项目时调用）。

**HTTP 方法与端点**

```
POST /Sessions/Playing/Stopped
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `mediaSourceId` | `String` | 是 | 媒体源 ID |
| `position` | `Duration?` | 否 | 停止时的播放位置 |
| `runtime` | `Duration?` | 否 | 总时长 |
| `sessionId` | `String?` | 否 | 会话 ID |
| `playSessionId` | `String?` | 否 | 播放会话 ID |

**请求 Body**

```json
{
  "ItemId": "12345",
  "MediaSourceId": "12345",
  "PositionTicks": 600000000,
  "RunTimeTicks": 7200000000
}
```

**响应模型**

`void` — HTTP 200 即成功。

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Sessions/Playing/Stopped?api_key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "ItemId": "12345",
    "MediaSourceId": "12345",
    "PositionTicks": 600000000,
    "RunTimeTicks": 7200000000
  }'
```

---

### `markPlayed`

**作用**：将指定项目标记为已播放。

**HTTP 方法与端点**

```
POST /Users/{userId}/PlayedItems/{itemId}
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |

**响应模型**

`void` — HTTP 200 即成功。

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Users/$USER_ID/PlayedItems/12345?api_key=$API_KEY"
```

---

### `markUnplayed`

**作用**：将指定项目标记为未播放。

**HTTP 方法与端点**

```
DELETE /Users/{userId}/PlayedItems/{itemId}
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |

**响应模型**

`void` — HTTP 200 即成功。

**curl 示例**

```bash
curl -X DELETE "$SERVER_URL/Users/$USER_ID/PlayedItems/12345?api_key=$API_KEY"
```

---

### `updateFavoriteStatus`

**作用**：更新项目的收藏状态。

**HTTP 方法与端点**

```
POST /Users/{userId}/FavoriteItems/{itemId}    (收藏)
DELETE /Users/{userId}/FavoriteItems/{itemId}  (取消收藏)
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `isFavorite` | `bool` | 是 | `true` 收藏，`false` 取消 |

**响应模型**

`Map<String, dynamic>` — 更新后的用户数据。

**curl 示例**

```bash
# 收藏
curl -X POST "$SERVER_URL/Users/$USER_ID/FavoriteItems/12345?api_key=$API_KEY"

# 取消收藏
curl -X DELETE "$SERVER_URL/Users/$USER_ID/FavoriteItems/12345?api_key=$API_KEY"
```

---

### `getSystemInfo`

**作用**：获取 Emby 服务器系统信息，用于验证连接和 Token 有效性。

**HTTP 方法与端点**

```
GET /System/Info
```

**响应模型**

`Map<String, dynamic>` — 服务器版本、操作系统、插件等信息。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/System/Info?api_key=$API_KEY"
```

---

### `getSessions`

**作用**：获取当前所有会话列表。

**HTTP 方法与端点**

```
GET /Sessions
```

**响应模型**

`List<dynamic>` — 会话列表，每个会话包含 `Id`, `UserId`, `DeviceName`, `Client` 等。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Sessions?api_key=$API_KEY"
```

---

### `fetchSessionId`

**作用**：从会话列表中查找与当前用户匹配的会话 ID。

**HTTP 方法与端点**

```
GET /Sessions
```

**响应模型**

`String?` — 匹配的会话 ID，未找到返回 `null`。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Sessions?api_key=$API_KEY" | jq '.[] | select(.UserId == "'$USER_ID'") | .Id'
```

---

## 3. 图片服务 (ImageApi)

文件：`lib/emby_api/image_api.dart`

> `ImageApi` 是一个 **URL 构造器**，不直接发起 HTTP 请求（除 `fetchImageTag`/`fetchImageTags` 外）。它根据 Emby 图片接口规则构造可访问的图片 URL。

---

### `buildUrl`

**作用**：构造 Emby 图片访问 URL。

**HTTP 方法与端点**

```
GET {serverUrl}/Items/{itemId}/Images/{type}
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `type` | `ImageType` | 否 | 图片类型，默认 `primary` |
| `index` | `int?` | 否 | 图片索引（用于 Backdrop 等多图类型）|
| `width` | `int?` | 否 | 最大宽度（200~1920 之间）|
| `height` | `int?` | 否 | 最大高度（200~1920 之间）|
| `quality` | `int?` | 否 | 图片质量 1~100 |
| `tag` | `String?` | 否 | 图片标签（用于缓存和一致性）|
| `enableImageEnhancers` | `bool` | 否 | 是否启用图片增强器，默认 `true` |

**ImageType 枚举**

| 枚举值 | 字符串 |
|--------|--------|
| `primary` | `Primary` |
| `backdrop` | `Backdrop` |
| `logo` | `Logo` |
| `thumb` | `Thumb` |
| `banner` | `Banner` |
| `art` | `Art` |
| `screenshot` | `Screenshot` |
| `chapter` | `Chapter` |

**响应模型**

返回 `String` — 可直接用于 `<img>` 或 `CachedNetworkImage` 的图片 URL。

**curl 示例**

```bash
# 获取海报（Primary）
curl -I "$SERVER_URL/Items/12345/Images/Primary?api_key=$API_KEY&maxWidth=400&quality=85&tag=abc123"

# 获取背景图（Backdrop）第 0 张
curl -I "$SERVER_URL/Items/12345/Images/Backdrop/0?api_key=$API_KEY&maxWidth=1920&quality=95&tag=def456"
```

---

### `poster` / `backdrop` / `thumbnail` / `logo` / `banner`

**作用**：预设参数的图片 URL 快捷方法。

| 方法 | 类型 | 默认宽度 | 默认质量 |
|------|------|----------|----------|
| `poster` | `Primary` | 400 | 85 |
| `backdrop` | `Backdrop` | 800 | 95 |
| `thumbnail` | `Thumb` | 200 | 60 |
| `logo` | `Logo` | 400 | - |
| `banner` | `Banner` | 800 | - |

**curl 示例**

```bash
# 等同于 buildUrl(itemId, type: Primary, width: 400)
curl -I "$SERVER_URL/Items/12345/Images/Primary?api_key=$API_KEY&maxWidth=400&quality=85"
```

---

### `fetchImageTag`

**作用**：从服务器获取指定项目的图片标签（用于构造带缓存的图片 URL）。

**HTTP 方法与端点**

```
GET /Users/Me/Items/{itemId}
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `type` | `ImageType` | 否 | 图片类型，默认 `primary` |

**响应模型**

`String?` — 图片标签值，位于响应 JSON 的 `ImageTags[type.value]` 中。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/Me/Items/12345?api_key=$API_KEY" | jq '.ImageTags.Primary'
```

---

## 4. 项目详情 (ItemDetailApi)

文件：`lib/emby_api/item_detail_api.dart`

> **已弃用**，推荐使用 `EmbyApiService` 中对应方法。

---

### `getItem`

**作用**：获取项目详情。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items/{itemId}
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |

**响应模型**

同 `EmbyApiService.getItemDetail`。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/$USER_ID/Items/12345?api_key=$API_KEY"
```

---

### `getSeasons`

**作用**：获取剧集的季列表。

**HTTP 方法与端点**

```
GET /Shows/{seriesId}/Seasons
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `seriesId` | `String` | 是 | 剧集系列 ID |

**Query 固定参数**

- `UserId: {userId}`
- `Fields: Overview,Genres,ImageTags,ProductionYear`

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Shows/12345/Seasons?UserId=$USER_ID&Fields=Overview,Genres,ImageTags,ProductionYear&api_key=$API_KEY"
```

---

### `getEpisodes`

**作用**：获取指定季的集列表。

**HTTP 方法与端点**

```
GET /Shows/{seriesId}/Episodes
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `seriesId` | `String` | 是 | 剧集系列 ID |
| `seasonId` | `String` | 是 | 季 ID |

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Shows/12345/Episodes?SeasonId=67890&UserId=$USER_ID&api_key=$API_KEY"
```

---

### `getSimilarItems`

**作用**：获取相似项目。

**HTTP 方法与端点**

```
GET /Items/{itemId}/Similar
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `limit` | `int?` | 否 | 返回数量，默认 `12` |

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Items/12345/Similar?Limit=12&UserId=$USER_ID&api_key=$API_KEY"
```

---

### `getMediaSources` (已弃用)

**作用**：获取项目的媒体源列表。

**HTTP 方法与端点**

```
GET /Items/{itemId}/PlaybackInfo
```

> 已弃用，请使用 `PlaybackInfoApi` 的 `getPlaybackInfo`。

---

## 5. 播放信息 (PlaybackInfoApi)

文件：`lib/emby_api/playback_info_api.dart`

---

### `getPlaybackInfo`

**作用**：获取项目的播放信息（含媒体源列表、PlaySessionId 等），带 2 分钟缓存。

**HTTP 方法与端点**

```
GET [/emby]/Items/{itemId}/PlaybackInfo
```

> 注意：如果服务器 baseUrl 以 `/emby` 结尾，则路径为 `/Items/{itemId}/PlaybackInfo`；否则自动补 `/emby` 前缀。

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |

**Query 固定参数**

- `UserId: {userId}`

**响应模型**

`Map<String, dynamic>?`，核心字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `MediaSources` | `List<Map>` | 可用媒体源，每个含 `Id`, `Path`, `Protocol`, `Type` |
| `PlaySessionId` | `String` | 播放会话 ID |
| `RunTimeTicks` | `int` | 总时长（Ticks）|

**curl 示例**

```bash
curl -X GET "$SERVER_URL/emby/Items/12345/PlaybackInfo?UserId=$USER_ID&api_key=$API_KEY"
```

---

### `getEmbyResumePositionMs`

**作用**：获取项目的续播位置（毫秒）。

**HTTP 方法与端点**

```
GET [/emby]/Users/{userId}/Items/{itemId}
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |

**响应模型**

`int?` — 毫秒数。内部逻辑：`UserData.PlaybackPositionTicks / 10000`。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/emby/Users/$USER_ID/Items/12345?api_key=$API_KEY" | jq '.UserData.PlaybackPositionTicks'
# 除以 10000 得毫秒
```

---

## 6. 播放上报 (PlaybackReportingApi)

文件：`lib/emby_api/playback_reporting_api.dart`

> **已弃用**，推荐使用 `EmbyApiService` 中对应方法。该类使用全局 `DioProvider.instance` 而非注入的 Dio。

---

### `reportPlaybackStart`

**作用**：上报播放开始。

**HTTP 方法与端点**

```
POST /Sessions/Playing
```

**请求 Body**

```json
{
  "ItemId": "12345",
  "MediaSourceId": "12345",
  "CanSeek": true,
  "PlayMethod": "DirectStream",
  "SessionId": "...",
  "PlaySessionId": "..."
}
```

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Sessions/Playing?api_key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "ItemId": "12345",
    "MediaSourceId": "12345",
    "CanSeek": true,
    "PlayMethod": "DirectStream"
  }'
```

---

### `reportPlaybackProgress`

**作用**：上报播放进度。

**HTTP 方法与端点**

```
POST /Sessions/Playing/Progress
```

**请求 Body**

```json
{
  "ItemId": "12345",
  "MediaSourceId": "12345",
  "PositionTicks": 600000000,
  "IsPaused": false,
  "PlaybackRate": 1.0,
  "CanSeek": true,
  "PlayMethod": "DirectStream",
  "RunTimeTicks": 7200000000,
  "AudioStreamIndex": 0,
  "SubtitleStreamIndex": -1,
  "EventName": "timeupdate"
}
```

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Sessions/Playing/Progress?api_key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "ItemId": "12345",
    "MediaSourceId": "12345",
    "PositionTicks": 600000000,
    "IsPaused": false,
    "PlaybackRate": 1.0,
    "CanSeek": true,
    "PlayMethod": "DirectStream"
  }'
```

---

### `reportPlaybackStopped`

**作用**：上报播放停止。

**HTTP 方法与端点**

```
POST /Sessions/Playing/Stopped
```

**请求 Body**

```json
{
  "ItemId": "12345",
  "MediaSourceId": "12345",
  "PositionTicks": 600000000,
  "RunTimeTicks": 7200000000
}
```

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Sessions/Playing/Stopped?api_key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "ItemId": "12345",
    "MediaSourceId": "12345",
    "PositionTicks": 600000000,
    "RunTimeTicks": 7200000000
  }'
```

---

### `markPlayed`

**作用**：标记为已播放。

**HTTP 方法与端点**

```
POST /Users/{userId}/PlayedItems/{itemId}
```

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Users/$USER_ID/PlayedItems/12345?api_key=$API_KEY"
```

---

### `markUnplayed`

**作用**：标记为未播放。

**HTTP 方法与端点**

```
DELETE /Users/{userId}/PlayedItems/{itemId}
```

**curl 示例**

```bash
curl -X DELETE "$SERVER_URL/Users/$USER_ID/PlayedItems/12345?api_key=$API_KEY"
```

---

## 7. 快捷连接 (QuickConnectApi)

文件：`lib/emby_api/quick_connect_api.dart`

---

### `initiateQuickConnect`

**作用**：初始化 QuickConnect 流程，获取 Secret。

**HTTP 方法与端点**

```
GET /QuickConnect/Initiate
```

**响应模型**

`Map<String, dynamic>` — 包含 `Secret` 等字段。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/QuickConnect/Initiate?api_key=$API_KEY"
```

---

### `checkQuickConnect`

**作用**：检查 QuickConnect 是否已被授权。

**HTTP 方法与端点**

```
GET /QuickConnect/Connect
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `secret` | `String` | 是 | 初始化时获取的 Secret |

**响应模型**

`bool` — HTTP 200 返回 `true`，其他返回 `false`。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/QuickConnect/Connect?secret=$SECRET&api_key=$API_KEY"
```

---

### `authenticateWithQuickConnect`

**作用**：使用 QuickConnect Secret 完成认证。

**HTTP 方法与端点**

```
POST /Users/AuthenticateWithQuickConnect
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `secret` | `String` | 是 | QuickConnect Secret |

**请求 Body**

```json
{"Secret": "xxx"}
```

**响应模型**

同 `authenticateByName`（返回 `AccessToken` 和 `User`）。

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Users/AuthenticateWithQuickConnect?api_key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"Secret": "'$SECRET'"}'
```

---

## 8. 系统接口 (SystemApi)

文件：`lib/emby_api/system_api.dart`

---

### `getPublicInfo`

**作用**：获取服务器公共信息（无需认证）。

**HTTP 方法与端点**

```
GET /System/Info/Public
```

**响应模型**

`Map<String, dynamic>` — 服务器版本、操作系统、局域网地址等。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/System/Info/Public"
```

---

### `getSystemInfo`

**作用**：获取服务器完整系统信息（需认证）。

**HTTP 方法与端点**

```
GET /System/Info
```

**响应模型**

`Map<String, dynamic>` — 完整系统信息。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/System/Info?api_key=$API_KEY"
```

---

### `getUsers`

**作用**：获取服务器用户列表（需管理员权限）。

**HTTP 方法与端点**

```
GET /Users
```

**响应模型**

`List<dynamic>` — 用户列表，每个用户含 `Id`, `Name`, `Policy` 等。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users?api_key=$API_KEY"
```

---

### `ping`

**作用**：测试服务器是否可达。

**HTTP 方法与端点**

```
GET /System/Ping
```

**响应模型**

`bool` — HTTP 200 返回 `true`。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/System/Ping"
```

---

## 9. 用户数据 (UserDataApi)

文件：`lib/emby_api/user_data_api.dart`

> **已弃用**，推荐使用 `EmbyApiService` 中对应方法。

---

### `getUserData`

**作用**：获取指定项目的用户数据（播放进度、收藏状态等）。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items/{itemId}/UserData
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |

**响应模型**

`Map<String, dynamic>` — 用户数据：

| 字段 | 类型 | 说明 |
|------|------|------|
| `PlaybackPositionTicks` | `int` | 播放位置 |
| `PlayedPercentage` | `double` | 播放百分比 |
| `IsFavorite` | `bool` | 是否收藏 |
| `Played` | `bool` | 是否已看完 |
| `LastPlayedDate` | `String` | 最后播放时间 |

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/$USER_ID/Items/12345/UserData?api_key=$API_KEY"
```

---

### `updateFavoriteStatus`

**作用**：更新项目的收藏状态。

**HTTP 方法与端点**

```
POST /Users/{userId}/FavoriteItems/{itemId}    (收藏)
DELETE /Users/{userId}/FavoriteItems/{itemId}  (取消收藏)
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `isFavorite` | `bool` | 是 | `true` 收藏，`false` 取消 |

**响应模型**

`Map<String, dynamic>` — 更新后的用户数据。

**curl 示例**

```bash
# 收藏
curl -X POST "$SERVER_URL/Users/$USER_ID/FavoriteItems/12345?api_key=$API_KEY"

# 取消收藏
curl -X DELETE "$SERVER_URL/Users/$USER_ID/FavoriteItems/12345?api_key=$API_KEY"
```

---

### `updateRating`

**作用**：对项目进行评分。

**HTTP 方法与端点**

```
POST /Users/{userId}/Items/{itemId}/Rating
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `rating` | `double` | 是 | 评分 0~5，0 表示取消评分 |

**Query 参数**

- `Likes: rating > 0`

**响应模型**

`Map<String, dynamic>` — 更新后的用户数据。

**curl 示例**

```bash
curl -X POST "$SERVER_URL/Users/$USER_ID/Items/12345/Rating?Likes=true&api_key=$API_KEY"
```

---

### `getUserDataForItems`

**作用**：批量获取多个项目的用户数据。

**HTTP 方法与端点**

```
GET /Users/{userId}/Items
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemIds` | `List<String>` | 是 | 项目 ID 列表（逗号分隔）|

**Query 固定参数**

- `Ids: {逗号分隔的 ID 列表}`
- `Fields: UserData`

**响应模型**

`Map<String, dynamic>` — `Items` 数组中的每个元素都包含 `UserData`。

**curl 示例**

```bash
curl -X GET "$SERVER_URL/Users/$USER_ID/Items?Ids=12345,67890&Fields=UserData&api_key=$API_KEY"
```

---

## 10. 视频流 (VideoApi)

文件：`lib/emby_api/video_api.dart`

> `VideoApi` 是一个 **URL 构造器**，不发起 HTTP 请求。它根据项目 ID 和媒体源构造可直接播放的 URL。

---

### `getStreamUrl`

**作用**：构造视频直链 URL。

**HTTP 方法与端点**

```
GET [/emby]/Videos/{sourceId}/stream
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `mediaSourceId` | `String?` | 否 | 媒体源 ID，为空时使用 `itemId` |
| `streamType` | `StreamType` | 否 | `static`（直接传输）或 `dynamic`（支持转码），默认 `static` |
| `transcodeParams` | `TranscodeParams?` | 否 | 转码参数（动态流时有效）|
| `additionalParams` | `Map<String, String>?` | 否 | 额外 Query 参数 |

**TranscodeParams 字段**

| 字段 | 类型 | Query 键 | 说明 |
|------|------|----------|------|
| `maxBitrate` | `int?` | `MaxBitrate` | 最大比特率 |
| `audioStreamIndex` | `int?` | `AudioStreamIndex` | 音轨索引 |
| `subtitleStreamIndex` | `int?` | `SubtitleStreamIndex` | 字幕索引 |
| `maxWidth` | `int?` | `MaxWidth` | 最大宽度 |
| `maxHeight` | `int?` | `MaxHeight` | 最大高度 |
| `audioCodec` | `String?` | `AudioCodec` | 音频编码 |
| `videoCodec` | `String?` | `VideoCodec` | 视频编码 |
| `container` | `String?` | `Container` | 容器格式 |
| `startTimeTicks` | `int?` | `StartTimeTicks` | 起始位置（Ticks）|

**响应模型**

返回 `String` — 可直接传给播放器的视频 URL。

**curl 示例**

```bash
# 静态直链
curl -I "$SERVER_URL/emby/Videos/12345/stream?api_key=$API_KEY&Static=true"

# 动态转码流（指定比特率和容器）
curl -I "$SERVER_URL/emby/Videos/12345/stream?api_key=$API_KEY&MaxBitrate=8000000&Container=mp4&VideoCodec=h264&AudioCodec=aac"
```

---

### `getDownloadUrl`

**作用**：构造视频下载 URL。

**HTTP 方法与端点**

```
GET [/emby]/Items/{sourceId}/Download
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `mediaSourceId` | `String?` | 否 | 媒体源 ID |

**curl 示例**

```bash
curl -I "$SERVER_URL/emby/Items/12345/Download?api_key=$API_KEY"
```

---

### `getHlsUrl`

**作用**：构造 HLS（m3u8）播放 URL。

**HTTP 方法与端点**

```
GET [/emby]/Videos/{sourceId}/master.m3u8
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `mediaSourceId` | `String?` | 否 | 媒体源 ID |
| `transcodeParams` | `TranscodeParams?` | 否 | 转码参数 |

**curl 示例**

```bash
curl -I "$SERVER_URL/emby/Videos/12345/master.m3u8?api_key=$API_KEY&MaxBitrate=8000000"
```

---

### `getUniversalUrl`

**作用**：构造通用播放 URL（Emby  Universal Player 格式）。

**HTTP 方法与端点**

```
GET [/emby]/Videos/{sourceId}/universal
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `mediaSourceId` | `String?` | 否 | 媒体源 ID |
| `container` | `String?` | 否 | 容器格式，默认 `mp4,mkv,ts` |
| `videoCodec` | `String?` | 否 | 视频编码，默认 `h264,hevc,vp9` |
| `audioCodec` | `String?` | 否 | 音频编码，默认 `aac,mp3,ac3,eac3,flac,opus` |
| `maxBitrate` | `int?` | 否 | 最大比特率 |
| `audioStreamIndex` | `int?` | 否 | 音轨索引 |
| `subtitleStreamIndex` | `int?` | 否 | 字幕索引 |
| `startTimeTicks` | `int?` | 否 | 起始位置 |
| `playSessionId` | `String?` | 否 | 播放会话 ID |
| `deviceId` | `String?` | 否 | 设备 ID |
| `userId` | `String?` | 否 | 用户 ID |

**响应模型**

返回 `String` — 通用播放 URL。

**curl 示例**

```bash
curl -I "$SERVER_URL/emby/Videos/12345/universal?api_key=$API_KEY&Container=mp4&VideoCodec=h264&AudioCodec=aac&MaxBitrate=8000000"
```

---

### `buildPlaybackInfoUrl`

**作用**：构造 PlaybackInfo 查询 URL。

**HTTP 方法与端点**

```
GET [/emby]/Items/{itemId}/PlaybackInfo
```

**请求参数表**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `itemId` | `String` | 是 | 项目 ID |
| `userId` | `String?` | 否 | 用户 ID |

**curl 示例**

```bash
curl -X GET "$SERVER_URL/emby/Items/12345/PlaybackInfo?UserId=$USER_ID&api_key=$API_KEY"
```

---

## 附录：常用 Emby 字段常量

项目中定义了以下字段常量（来自 `EmbyFields` 类），在 `getItems` 等接口的 `fields` 参数中使用：

| 常量名 | 值 | 说明 |
|--------|-----|------|
| `mediaSources` | `MediaSources` | 媒体源信息 |
| `overview` | `Overview` | 简介 |
| `path` | `Path` | 文件路径 |
| `userData` | `UserData` | 用户数据（播放进度等）|
| `imageTags` | `ImageTags` | 图片标签 |
| `genres` | `Genres` | 类型/风格 |
| `people` | `People` | 演职员 |
| `studios` | `Studios` | 制片公司 |
| `productionYear` | `ProductionYear` | 年份 |
| `runtime` | `RunTimeTicks` | 时长（Ticks）|
| `primaryImageAspectRatio` | `PrimaryImageAspectRatio` | 主图宽高比 |
| `backdropImageTags` | `BackdropImageTags` | 背景图标签 |

## 附录：Emby 项目类型常量

来自 `EmbyItemTypes` 类：

| 常量名 | 值 |
|--------|-----|
| `movie` | `Movie` |
| `series` | `Series` |
| `episode` | `Episode` |
| `season` | `Season` |
| `audio` | `Audio` |
| `musicAlbum` | `MusicAlbum` |
| `musicArtist` | `MusicArtist` |
| `playlist` | `Playlist` |
| `boxSet` | `BoxSet` |
| `person` | `Person` |
| `studio` | `Studio` |
| `genre` | `Genre` |
| `collectionFolder` | `CollectionFolder` |
| `video` | `Video` |
| `trailer` | `Trailer` |

## 附录：时间单位换算

Emby API 使用 **Ticks** 作为时间单位：

```
1 Tick = 100 纳秒 = 0.1 微秒
1 秒 = 10,000,000 Ticks
1 毫秒 = 10,000 Ticks
```

代码中常用换算：
- `Ticks → 毫秒`: `ticks / 10000`
- `Duration → Ticks`: `duration.inMicroseconds * 10`
