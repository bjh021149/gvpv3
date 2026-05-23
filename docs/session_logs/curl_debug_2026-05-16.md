# Curl 调试记录 2026-05-16

**服务器**: http://qqpyf.vip:7001
**用户**: haoyuzhishijie
**UserId**: 1f0c64ccceb84bf0826518adfe5af2a4
**Token**: c1d80a4f785447e19549ff467fab4fb3

---

## 类别 1: 认证

### 1.1 AuthenticateByName (获取 Token)
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X POST "http://qqpyf.vip:7001/Users/AuthenticateByName" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: MediaBrowser Client=EmbyClient, Device=Test, DeviceId=test123, Version=1.0.0" \
  -d "Username=haoyuzhishijie&Pw=hi021149"
```
**响应**:
```json
{
  "User": {"Id": "1f0c64ccceb84bf0826518adfe5af2a4"},
  "AccessToken": "c1d80a4f785447e19549ff467fab4fb3"
}
```
**状态**: ✅ HTTP 200

### 1.2 获取 Sessions
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Sessions?api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**响应**:
```json
[
  {"Id": "967a16f7fb7c24b0eb9055e48c080f2e", "DeviceName": "Test", "UserName": "haoyuzhishijie"},
  {"Id": "f3109bd1837b7bed310031a659bdf7c5", "DeviceName": "linux", "UserName": "haoyuzhishijie"}
]
```
**状态**: ✅ HTTP 200

---

## 类别 2: 媒体库筛选 (Genre / Studio)

### 2.1 获取媒体库列表（含外部内容）
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Views?api_key=c1d80a4f785447e19549ff467fab4fb3&IncludeExternalContent=true"
```
**响应**:
```
Total: 14
  13951 | 电视剧 | CollectionType=tvshows
  183997 | 国产剧 | CollectionType=tvshows
  263526 | 港台剧 | CollectionType=tvshows
  243973 | 欧美剧 | CollectionType=tvshows
  263525 | 日韩剧 | CollectionType=tvshows
  43011 | 电影 | CollectionType=movies
  51187 | 华语电影 | CollectionType=movies
  374703 | 动画电影 | CollectionType=movies
  368529 | 漫威电影 | CollectionType=movies
  3 | 原盘 | CollectionType=movies
  44154 | 动画 | CollectionType=tvshows
  479593 | 日美番 | CollectionType=tvshows
  45203 | 横屏短剧 | CollectionType=tvshows
  79006 | 合集 | CollectionType=boxsets
```
**状态**: ✅ HTTP 200
**对比**: 与 `IncludeExternalContent=false`（或不传）结果完全一致，该服务器无 channels/live tv 等外部内容。

### 2.2 获取电影详情（含 genre/studio）
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items/141313?api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**响应**:
```json
{
  "Studios": [
    {"Name": "Maoyan Entertainment", "Id": 44015},
    {"Name": "Tianjin Maoyan Weiying Culture Media", "Id": 44460},
    {"Name": "Shanghai Ruyi Film & TV Production", "Id": 64656},
    {"Name": "上海他城影业有限公司", "Id": 66564},
    {"Name": "China Film Creative", "Id": 44459}
  ],
  "Genres": ["喜剧", "爱情"]
}
```
**状态**: ✅ HTTP 200

### 2.3 按 Genre 筛选（中文未编码）
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items?ParentId=43011&IncludeItemTypes=Movie&Recursive=true&Genres=喜剧&Limit=5&api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**响应**: (空)
**状态**: ❌ HTTP 400
**错误**: 中文 Genre 需要 URL 编码

### 2.4 按 Genre 筛选（URL 编码后）
```bash
# 时间: 2026-05-16 22:00+08:00
# Genre: 喜剧 → %E5%96%9C%E5%89%A7
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items?ParentId=43011&IncludeItemTypes=Movie&Recursive=true&Genres=%E5%96%9C%E5%89%A7&Limit=5&api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**响应**:
```json
{"TotalRecordCount": 1579, "Items": [...]}
```
**状态**: ✅ HTTP 200
**结论**: Dio 会自动编码 query 参数，代码中无需手动处理

### 2.5 按 StudioId 筛选
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items?ParentId=43011&IncludeItemTypes=Movie&Recursive=true&StudioIds=44015&Limit=5&api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**响应**:
```
Total: 8
  "骗骗"喜欢你 (2024)
  戴假发的人 (2024)
  封神第一部：朝歌风云 (2023)
```
**状态**: ✅ HTTP 200

### 2.6 Genre + Studio 组合筛选
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items?ParentId=43011&IncludeItemTypes=Movie&Recursive=true&Genres=%E5%96%9C%E5%89%A7&StudioIds=44015&Limit=5&api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**状态**: ✅ HTTP 200（Genre 编码后）

---

## 类别 3: 播放上报 (Start / Progress / Stopped)

### 3.1 播放开始 - 新端点 (/Users/{UserId}/PlayingItems/{Id})
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X POST "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/PlayingItems/141313?MediaSourceId=141313&CanSeek=true&PlayMethod=DirectStream&api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**响应**: `Value cannot be null. (Parameter 'key')`
**状态**: ❌ HTTP 400

### 3.2 播放开始 - 旧端点 (/Sessions/Playing)
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X POST "http://qqpyf.vip:7001/Sessions/Playing?api_key=c1d80a4f785447e19549ff467fab4fb3" \
  -H "Content-Type: application/json" \
  -d '{"ItemId":"141313","MediaSourceId":"141313","CanSeek":true,"PlayMethod":"DirectStream"}'
```
**响应**: `Value cannot be null. (Parameter 'key')`
**状态**: ❌ HTTP 400

### 3.3 播放开始 - 含 SessionId
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X POST "http://qqpyf.vip:7001/Sessions/Playing?api_key=c1d80a4f785447e19549ff467fab4fb3" \
  -H "Content-Type: application/json" \
  -d '{"ItemId":"141313","MediaSourceId":"141313","SessionId":"967a16f7fb7c24b0eb9055e48c080f2e","CanSeek":true,"PlayMethod":"DirectStream"}'
```
**响应**: `Value cannot be null. (Parameter 'key')`
**状态**: ❌ HTTP 400

### 3.4 播放进度 - 新端点
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X POST "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/PlayingItems/141313/Progress?MediaSourceId=141313&PositionTicks=600000000&IsPaused=false&PlayMethod=DirectStream&api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**响应**: `Value cannot be null. (Parameter 'key')`
**状态**: ❌ HTTP 400

### 3.5 播放停止 - 旧端点
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X POST "http://qqpyf.vip:7001/Sessions/Playing/Stopped?api_key=c1d80a4f785447e19549ff467fab4fb3" \
  -H "Content-Type: application/json" \
  -d '{"ItemId":"141313","MediaSourceId":"141313","PositionTicks":600000000}'
```
**响应**: (空)
**状态**: ✅ HTTP 204

---

## 类别 4: 关联作品查询

### 4.1 Studio 关联作品
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items?IncludeItemTypes=Movie,Series&Recursive=true&StudioIds=44015&SortBy=ProductionYear&SortOrder=Descending&Limit=100&api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**状态**: ✅ HTTP 200

### 4.2 Person 关联作品
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items?IncludeItemTypes=Movie,Series&Recursive=true&PersonIds=PERSON_ID&SortBy=ProductionYear&SortOrder=Descending&Limit=100&api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**状态**: 未测试（需要 Person ID）

---

## 总结

| 类别 | 成功率 | 关键问题 |
|------|--------|---------|
| 认证 | ✅ 100% | Token 获取正常 |
| 媒体库筛选 | ⚠️ 80% | 中文 Genre 需 URL 编码 |
| 播放上报 Start | ❌ 0% | 服务器返回 `Value cannot be null. (Parameter 'key')` |
| 播放上报 Progress | ❌ 0% | 同上 |
| 播放上报 Stopped | ✅ 100% | 204 No Content |
| 关联作品查询 | ✅ 100% | Studio 筛选正常 |

---

## 类别 5: getItemDetail 请求媒体库 (CollectionFolder)

### 5.1 电影库 (ID: 43011)
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items/43011?api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**关键字段**:
```json
{
  "Name": "电影",
  "Type": "CollectionFolder",
  "CollectionType": "movies",
  "ChildCount": 1,
  "Subviews": ["movies", "collections", "genres", "movies", "folders"]
}
```
**状态**: ✅ HTTP 200

### 5.2 电视剧库 (ID: 13951)
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items/13951?api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**关键字段**:
```json
{
  "Name": "电视剧",
  "Type": "CollectionFolder",
  "CollectionType": "tvshows",
  "ChildCount": 1,
  "Subviews": ["series", "studios", "genres", "episodes", "series", "folders"]
}
```
**状态**: ✅ HTTP 200

### 5.3 合集库 (ID: 79006)
```bash
# 时间: 2026-05-16 22:00+08:00
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items/79006?api_key=c1d80a4f785447e19549ff467fab4fb3"
```
**关键字段**:
```json
{
  "Name": "合集",
  "Type": "CollectionFolder",
  "CollectionType": "boxsets",
  "ChildCount": 1,
  "Subviews": ["folders"]
}
```
**状态**: ✅ HTTP 200

### 结论
- `getItemDetail` 可以用于获取媒体库 (CollectionFolder) 的详细信息
- `Subviews` 字段可以判断该媒体库支持的视图模式（如 movies, series, genres, studios, collections 等）
- `CollectionType` 与 Views API 返回的一致

---

## 类别 6: Subviews 与 IncludeItemTypes 映射测试

### 测试方法
通过 `getItemDetail` 获取 CollectionFolder 的 `Subviews` 字段，然后对每个 subview 用对应的 `IncludeItemTypes` 请求子项目。

### 6.1 genres → IncludeItemTypes=Genre
```bash
curl ".../Items?ParentId=43011&IncludeItemTypes=Genre&Recursive=true&Limit=20"
```
**结果**: TotalRecordCount=32
```
50890 | Action      | Type=Genre
50891 | Adventure   | Type=Genre
268   | 爱情        | Type=Genre
96658 | Comedy      | Type=Genre
606   | 动画        | Type=Genre
384   | 动作        | Type=Genre
...
```
**关键发现**: Genre 是独立的 Item 类型，有自己的 ID 和图片。点击 Genre 后需用 `Genres=爱情` 参数筛选 Movie，**不能**用 Genre ID 作为 ParentId。

### 6.2 studios → IncludeItemTypes=Studio
```bash
curl ".../Items?ParentId=43011&IncludeItemTypes=Studio&Recursive=true&Limit=10"
```
**结果**: TotalRecordCount=7523
```
571499 | "Sam" Productions     | Type=Studio
63446  | 1 Production Film     | Type=Studio
...
```

### 6.3 movies → IncludeItemTypes=Movie
```bash
curl ".../Items?ParentId=43011&IncludeItemTypes=Movie&Recursive=true&Limit=3"
```
**结果**: TotalRecordCount=6249
```
141313 | "骗骗"喜欢你
132563 | "湾区升明月"2024大湾区电影音乐晚会
...
```

### 6.4 series → IncludeItemTypes=Series (电视剧库 ParentId=13951)
```bash
curl ".../Items?ParentId=13951&IncludeItemTypes=Series&Recursive=true&Limit=3"
```
**结果**: TotalRecordCount=119
```
36338 | 爱欲焚身
36305 | 暗夜情报员
36342 | 变调瑜伽
```

### 6.5 collections → IncludeItemTypes=BoxSet
```bash
curl ".../Items?ParentId=43011&IncludeItemTypes=BoxSet&Recursive=true&Limit=3"
```
**结果**: TotalRecordCount=52
```
10664 | 007（系列）
70867 | 暗战（系列）
93223 | 暴力街区13（系列）
```

### 6.6 folders → IncludeItemTypes=Folder
```bash
curl ".../Items?ParentId=43011&IncludeItemTypes=Folder&Recursive=true&Limit=3"
```
**结果**: TotalRecordCount=14327
```
171448 | "骗骗"喜欢你[60帧率版本][高码版]... | Type=Folder
...
```
**说明**: 返回的是底层文件夹结构，不是聚合视图。

### 映射表总结

| Subview | IncludeItemTypes | 用途 |
|---------|-----------------|------|
| genres | Genre | 展示所有 Genre 标签 |
| studios | Studio | 展示所有 Studio 标签 |
| movies | Movie | 展示电影列表 |
| series | Series | 展示剧集列表 |
| episodes | Episode | 展示单集列表 |
| collections | BoxSet | 展示合集/系列 |
| folders | Folder | 展示底层文件夹 |

