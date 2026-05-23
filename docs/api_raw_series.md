# Emby API 原始响应样本 — Series

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

## 2. Series 完整详情请求

**Item:** 在大韩民国成为房主的方法  
**Item ID:** `389566`

```bash
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items/389566?Fields=PrimaryImageAspectRatio,UserData,Genres,Overview,ProductionYear,RunTimeTicks,ProviderIds,Studios,MediaSources,People,OfficialRating,CommunityRating,CriticRating,Path&api_key=ec6fa914ac424e64864aa03574cedf49"
```

---

## 3. Series 完整响应

```json
{
    "Name": "在大韩民国成为房主的方法",
    "OriginalTitle": "대한민국에서 건물주 되는 법",
    "ServerId": "4f1dbe372c3c456d9757dea582898ec3",
    "Id": "389566",
    "Etag": "716afec7b6672d90f6e027c333d90653",
    "DateCreated": "2026-04-13T14:27:10.0000000Z",
    "CanDelete": false,
    "CanDownload": false,
    "PresentationUniqueKey": "458929-zh-CN-7cd3c9e12c774c59a88094e033d49d04",
    "SortName": "ZDHMGCWFZDFF",
    "ForcedSortName": "ZDHMGCWFZDFF",
    "PremiereDate": "2026-03-14T00:00:00.0000000Z",
    "ExternalUrls": [
        {
            "Name": "IMDb",
            "Url": "https://www.imdb.com/title/tt39695941"
        },
        {
            "Name": "TheMovieDb",
            "Url": "https://www.themoviedb.org/tv/281965"
        },
        {
            "Name": "TheTVDB",
            "Url": "https://thetvdb.com/?tab=series&id=458929"
        },
        {
            "Name": "Trakt",
            "Url": "https://trakt.tv/search/tmdb/281965?id_type=show"
        }
    ],
    "Path": "/media/xunleistrm/openlist/好东西/电视剧/日韩剧/2026-3-15/在韩国成为房主的方法 대한민국에서 건물주 되는 법 (2026)",
    "OfficialRating": "SG-NC16",
    "Overview": "故事讲述一名中产家庭男主角如何在为守住家庭与资产的挣扎中，走向绑架等非法行为的边缘，试图呈现当代社会阶级移动与金融风险交织下的人性选择。",
    "Taglines": [],
    "Genres": [
        "犯罪",
        "喜剧",
        "剧情"
    ],
    "CommunityRating": 10,
    "FileName": "在韩国成为房主的方法 대한민국에서 건물주 되는 법 (2026)",
    "ProductionYear": 2026,
    "RemoteTrailers": [],
    "ProviderIds": {
        "Tmdb": "281965",
        "Imdb": "tt39695941",
        "Tvdb": "458929"
    },
    "IsFolder": true,
    "ParentId": "280723",
    "Type": "Series",
    "People": [
        {
            "Name": "河正宇",
            "Id": "34734",
            "Role": "Ki Su-jong",
            "Type": "Actor",
            "PrimaryImageTag": "f5327dd5c13944938c5f6efcaced9a39"
        },
        {
            "Name": "林秀晶",
            "Id": "134180",
            "Role": "Kim Seon",
            "Type": "Actor",
            "PrimaryImageTag": "fe4c0608530b14209a74c1571035cc3a"
        },
        {
            "Name": "金俊翰",
            "Id": "109361",
            "Role": "Min Hwal-seong",
            "Type": "Actor",
            "PrimaryImageTag": "ba40b37dd46c9a820acdd04aa5176995"
        },
        {
            "Name": "郑秀晶",
            "Id": "45223",
            "Role": "Jeon Yi-gyeong",
            "Type": "Actor",
            "PrimaryImageTag": "a4c44c7d4c02362e35ab1e3e70e5cbb5"
        },
        {
            "Name": "沈恩敬",
            "Id": "133616",
            "Role": "Yo-na",
            "Type": "Actor",
            "PrimaryImageTag": "aa39fed2ae9d41c148b4264ffc99ad5a"
        },
        {
            "Name": "李信琦",
            "Id": "268132",
            "Role": "Jang Eui-sa",
            "Type": "Actor",
            "PrimaryImageTag": "75c33e581f351aa1ebc11c1d156d4f4e"
        },
        {
            "Name": "朴绪耿",
            "Id": "389588",
            "Role": "Ki Da-rae",
            "Type": "Actor",
            "PrimaryImageTag": "e9c5099bfac7a1663976d2a0eecaef93"
        },
        {
            "Name": "金锦顺",
            "Id": "29752",
            "Role": "Jeon Yang-ja",
            "Type": "Actor",
            "PrimaryImageTag": "6ab2fc9d2ac0699281732e9cba5251ad"
        },
        {
            "Name": "李珠雨",
            "Id": "134682",
            "Role": "Ko Ju-ran",
            "Type": "Actor",
            "PrimaryImageTag": "8e3bdde02bba2dc08a3cc15f22a77b5b"
        },
        {
            "Name": "南明烈",
            "Id": "88995",
            "Role": "Mr. Kim",
            "Type": "Actor",
            "PrimaryImageTag": "dccfa450bf4d89ad8626e9c167caaa4e"
        },
        {
            "Name": "玄奉植",
            "Id": "121028",
            "Role": "Oh Dong-ki",
            "Type": "Actor",
            "PrimaryImageTag": "037cebc94c8b05b3e6102269489220b6"
        },
        {
            "Name": "尹俊元",
            "Id": "389589",
            "Role": "Yoon Bo-ram",
            "Type": "Actor",
            "PrimaryImageTag": "a3aa265123e7328d003a9f66fe6f287b"
        },
        {
            "Name": "MIYAVI",
            "Id": "25136",
            "Role": "Morgan Lee",
            "Type": "Actor",
            "PrimaryImageTag": "9711368227b3d44dce190ba7b389ceaf"
        }
    ],
    "Studios": [
        {
            "Name": "tvN",
            "Id": 40782
        }
    ],
    "GenreItems": [
        {
            "Name": "犯罪",
            "Id": 435
        },
        {
            "Name": "喜剧",
            "Id": 607
        },
        {
            "Name": "剧情",
            "Id": 267
        }
    ],
    "TagItems": [],
    "LocalTrailerCount": 0,
    "UserData": {
        "UnplayedItemCount": 10,
        "PlaybackPositionTicks": 0,
        "PlayCount": 0,
        "IsFavorite": false,
        "Played": false
    },
    "ChildCount": 1,
    "DisplayPreferencesId": "f63033ff6886ecc7083a696cbeced1b0",
    "Status": "Continuing",
    "AirDays": [],
    "PrimaryImageAspectRatio": 0.6652217405801933,
    "DisplayOrder": "Aired",
    "ImageTags": {
        "Primary": "6d51c08223dc960e0142f137f25b7470",
        "Logo": "44d7e1811c51551e93822894c5ccafd4"
    },
    "BackdropImageTags": [
        "3672e3bd306249c3375d62e886dd678f"
    ],
    "LockedFields": [],
    "LockData": false
}
```

---

## 4. 关键字段速查

| 字段 | 值 | 说明 |
|---|---|---|
| `Id` | `389566` | 唯一标识 |
| `Type` | `Series` | 类型 |
| `Name` | `在大韩民国成为房主的方法` | 中文名称 |
| `OriginalTitle` | `대한민국에서 건물주 되는 법` | 原始韩文标题 |
| `ProductionYear` | `2026` | 年份 |
| `CommunityRating` | `10` | 评分 |
| `OfficialRating` | `SG-NC16` | 分级 |
| `Genres` | `["犯罪", "喜剧", "剧情"]` | 类型标签 |
| `ProviderIds` | `{"Tmdb":"281965", "Imdb":"tt39695941", "Tvdb":"458929"}` | 外部平台ID |
| `Studios` | `[{"Name":"tvN", "Id":40782}]` | 制片公司 |
| `People` | 13 条目 | 演员 |
| `Status` | `Continuing` | 连载状态 |
| `ChildCount` | `1` | 子项数量（季度数）|
| `UserData.UnplayedItemCount` | `10` | 未观看集数 |
| `ImageTags.Primary` | `6d51c082...` | 海报图 tag |
| `ImageTags.Logo` | `44d7e181...` | Logo 图 tag |
| `BackdropImageTags` | `3672e3bd...` | 背景图 tag |
