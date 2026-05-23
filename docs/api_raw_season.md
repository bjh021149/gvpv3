# Emby API 原始响应样本 — Season

> 服务器: http://qqpyf.vip:7001
> 生成时间: 2026-05-15

---

## 1. 认证请求

```bash
curl -X POST "http://qqpyf.vip:7001/Users/AuthenticateByName" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: MediaBrowser Client=\"EmbyFlutter\", Device=\"Unknown Device\", DeviceId=\"flutter-emby-device\", Version=\"1.0.0\"" \
  -d "Username=haoyuzhishijie&Pw=***"
```

**响应（关键字段）:**
```json
{
  "AccessToken": "ec6fa914ac424e64864aa03574cedf49",
  "User": {
    "Id": "1f0c64ccceb84bf0826518adfe5af2a4"
  }
}
```

---

## 2. Season 完整详情请求

**Item:** 在大韩民国成为房主的方法 · 第 1 季  
**Item ID:** `389590`

```bash
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items/389590?Fields=PrimaryImageAspectRatio,UserData,Genres,Overview,ProductionYear,RunTimeTicks,ProviderIds,Studios,MediaSources,People,OfficialRating,CommunityRating,CriticRating,Path,SeriesName,IndexNumber&api_key=ec6fa914ac424e64864aa03574cedf49"
```

---

## 3. Season 完整响应

```json
{
    "Name": "\u7b2c 1 \u5b63",
    "ServerId": "4f1dbe372c3c456d9757dea582898ec3",
    "Id": "389590",
    "Etag": "76b14d5575ab307fe2ed258c9c266a58",
    "DateCreated": "2026-04-13T14:28:45.0000000Z",
    "CanDelete": false,
    "CanDownload": false,
    "PresentationUniqueKey": "458929-zh-CN-7cd3c9e12c774c59a88094e033d49d04-001",
    "SortName": "\u7b2c 1 \u5b63",
    "ForcedSortName": "\u7b2c 1 \u5b63",
    "PremiereDate": "2026-03-14T00:00:00.0000000Z",
    "ExternalUrls": [],
    "Taglines": [],
    "Genres": [],
    "ProductionYear": 2026,
    "IndexNumber": 1,
    "RemoteTrailers": [],
    "ProviderIds": {},
    "IsFolder": true,
    "ParentId": "389566",
    "Type": "Season",
    "People": [],
    "Studios": [],
    "GenreItems": [],
    "TagItems": [],
    "ParentLogoItemId": "389566",
    "ParentBackdropItemId": "389566",
    "ParentBackdropImageTags": [
        "3672e3bd306249c3375d62e886dd678f"
    ],
    "UserData": {
        "UnplayedItemCount": 10,
        "PlaybackPositionTicks": 0,
        "PlayCount": 0,
        "IsFavorite": false,
        "Played": false
    },
    "ChildCount": 12,
    "SeriesName": "\u5728\u5927\u97e9\u6c11\u56fd\u6210\u4e3a\u623f\u4e3b\u7684\u65b9\u6cd5",
    "SeriesId": "389566",
    "DisplayPreferencesId": "dfd065f5787fb957a750d76dcf835aad",
    "PrimaryImageAspectRatio": 0.6652217405801933,
    "SeriesPrimaryImageTag": "6d51c08223dc960e0142f137f25b7470",
    "ImageTags": {
        "Primary": "4c64a98c1e7e45d742d9e22cf91873de"
    },
    "BackdropImageTags": [],
    "ParentLogoImageTag": "44d7e1811c51551e93822894c5ccafd4",
    "LockedFields": [],
    "LockData": false
}
```

---

## 4. 关键字段速查

| 字段 | 值 | 说明 |
|---|---|---|
| `Id` | `389590` | 唯一标识 |
| `Type` | `Season` | 类型 |
| `Name` | `第 1 季` | 季度名称 |
| `SeriesName` | `在大韩民国成为房主的方法` | 所属系列名称 |
| `SeriesId` | `389566` | 所属系列 ID |
| `IndexNumber` | `1` | 季度编号 |
| `ProductionYear` | `2026` | 年份 |
| `Genres` | `[]` | 类型标签（Season 通常为空）|
| `ProviderIds` | `{}` | 外部平台ID（Season 通常为空）|
| `Studios` | `[]` | 制片公司（Season 通常为空）|
| `People` | `[]` | 演员（Season 通常为空）|
| `ChildCount` | `12` | 子项数量（集数）|
| `UserData.UnplayedItemCount` | `10` | 未观看集数 |
| `ImageTags.Primary` | `4c64a98c...` | 季度海报图 tag |
| `ParentBackdropImageTags` | `3672e3bd...` | 继承自 Series 的背景图 |
| `ParentLogoImageTag` | `44d7e181...` | 继承自 Series 的 Logo |

---

## 5. Season vs Series vs Episode 字段对比

| 字段 | Series | Season | Episode |
|---|---|---|---|
| `Genres` | ✅ `["综艺", "真人秀"]` | ❌ `[]` | ❌ `[]` |
| `ProviderIds` | ✅ `{Tmdb:...}` | ❌ `{}` | ❌ `{}` |
| `Studios` | ✅ `[{id:7025,name:...}]` | ❌ `[]` | ❌ `[]` |
| `People` | ✅ `[演员列表]` | ❌ `[]` | ❌ `[]` |
| `CommunityRating` | ✅ `7.2` | ❌ `null` | ❌ `null` |
| `OfficialRating` | ✅ `TV-Y` | ❌ `null` | ❌ `null` |
| `RunTimeTicks` | ✅ | ❌ `null` | ✅ |
| `MediaSources` | ❌ 无 | ❌ 无 | ✅ `[媒体源]` |
| `ChildCount` | ✅ 季度数 | ✅ 集数 | ❌ 无 |
| `ImageTags.Primary` | ✅ | ✅ | ✅ |
| `ParentLogoImageTag` | ❌ 无 | ✅ 继承 | ✅ 继承 |
| `ParentBackdropImageTags` | ❌ 无 | ✅ 继承 | ✅ 继承 |

---

## 6. 结论

- **Genre/ProviderIds/Studios/People** 等丰富元数据仅存在于 **Series/Movie** 级别
- **Season/Episode** 通常只返回空数组或空对象
- **Episode** 独有的关键字段是 `MediaSources`（决定播放行为）
- **Season** 的关键字段是 `ChildCount`（集数）和继承自 Series 的图片 tag
