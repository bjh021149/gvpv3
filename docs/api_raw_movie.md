# Emby API 原始响应样本 — Movie

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

## 2. Movie 完整详情请求

**Item:** 惊奇队长2 (The Marvels)  
**Item ID:** `368536`

```bash
curl -X GET "http://qqpyf.vip:7001/Users/1f0c64ccceb84bf0826518adfe5af2a4/Items/368536?Fields=PrimaryImageAspectRatio,UserData,Genres,Overview,ProductionYear,RunTimeTicks,ProviderIds,Studios,MediaSources,People,OfficialRating,CommunityRating,CriticRating,Path&api_key=ec6fa914ac424e64864aa03574cedf49"
```

---

## 3. Movie 完整响应

```json
{
    "Name": "惊奇队长2",
    "OriginalTitle": "The Marvels",
    "ServerId": "4f1dbe372c3c456d9757dea582898ec3",
    "Id": "368536",
    "Etag": "20591401e5efefd46cc958f11869c20a",
    "DateCreated": "2026-04-09T11:26:32.0000000Z",
    "CanDelete": false,
    "CanDownload": false,
    "PresentationUniqueKey": "62bb1689856b57ed650c048c905193eb",
    "Container": "mkv",
    "SortName": "JQDZ2",
    "ForcedSortName": "JQDZ2",
    "PremiereDate": "2023-11-07T16:00:00.0000000Z",
    "ExternalUrls": [
        {
            "Name": "IMDb",
            "Url": "https://www.imdb.com/title/tt10676048"
        },
        {
            "Name": "TheMovieDb",
            "Url": "https://www.themoviedb.org/movie/609681"
        },
        {
            "Name": "TheTVDB",
            "Url": "https://thetvdb.com/dereferrer/movie/134366"
        },
        {
            "Name": "Trakt",
            "Url": "https://trakt.tv/search/tmdb/609681?id_type=movie"
        }
    ],
    "MediaSources": [
        {
            "Protocol": "Http",
            "Id": "62bb1689856b57ed650c048c905193eb",
            "Path": "http://172.17.0.4:5244/d/好东西/电影/漫威影业/4月8/惊奇队长2/The Marvels 2023 V3 BluRay REMUX UHD 2160p TrueHD7.1-DreamHD.mkv?cookie_name=xunlei&path=/好东西/电影/漫威影业/4月8/惊奇队长2/The Marvels 2023 V3 BluRay REMUX UHD 2160p TrueHD7.1-DreamHD.mkv",
            "Type": "Default",
            "Container": "mkv",
            "Size": 50212173497,
            "Name": "The Marvels 2023 V3 BluRay REMUX UHD 2160p TrueHD7.1-DreamHD",
            "IsRemote": true,
            "HasMixedProtocols": false,
            "RunTimeTicks": 62849920000,
            "SupportsTranscoding": true,
            "SupportsDirectStream": true,
            "SupportsDirectPlay": true,
            "IsInfiniteStream": false,
            "RequiresOpening": false,
            "RequiresClosing": false,
            "RequiresLooping": false,
            "SupportsProbing": false,
            "MediaStreams": [
                {
                    "Codec": "hevc",
                    "ColorTransfer": "smpte2084",
                    "ColorPrimaries": "bt2020",
                    "ColorSpace": "bt2020nc",
                    "TimeBase": "1/1000",
                    "VideoRange": "HDR 10",
                    "DisplayTitle": "4K HDR 10 HEVC",
                    "IsInterlaced": false,
                    "BitRate": 63913746,
                    "BitDepth": 10,
                    "RefFrames": 1,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Height": 2160,
                    "Width": 3840,
                    "AverageFrameRate": 23.976025,
                    "RealFrameRate": 23.976025,
                    "Profile": "Main 10",
                    "Type": "Video",
                    "AspectRatio": "16:9",
                    "Index": 0,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "PixelFormat": "yuv420p10le",
                    "Level": 153,
                    "IsAnamorphic": false,
                    "ExtendedVideoType": "Hdr10",
                    "ExtendedVideoSubType": "Hdr10",
                    "ExtendedVideoSubTypeDescription": "HDR 10",
                    "AttachmentSize": 0
                },
                {
                    "Codec": "truehd",
                    "Language": "eng",
                    "TimeBase": "1/1000",
                    "DisplayTitle": "English TRUEHD 7.1 (默认)",
                    "DisplayLanguage": "English",
                    "IsInterlaced": false,
                    "ChannelLayout": "7.1",
                    "BitDepth": 24,
                    "Channels": 8,
                    "SampleRate": 48000,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Audio",
                    "Index": 1,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0
                },
                {
                    "Codec": "ac3",
                    "Language": "eng",
                    "TimeBase": "1/1000",
                    "DisplayTitle": "English AC3 5.1 (默认)",
                    "DisplayLanguage": "English",
                    "IsInterlaced": false,
                    "ChannelLayout": "5.1",
                    "BitRate": 640000,
                    "Channels": 6,
                    "SampleRate": 48000,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Audio",
                    "Index": 2,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0
                },
                {
                    "Codec": "truehd",
                    "Language": "chi",
                    "TimeBase": "1/1000",
                    "Title": "公映国语全景声",
                    "DisplayTitle": "Chinese Simplified TRUEHD 7.1 (默认)",
                    "DisplayLanguage": "Chinese Simplified",
                    "IsInterlaced": false,
                    "ChannelLayout": "7.1",
                    "BitDepth": 24,
                    "Channels": 8,
                    "SampleRate": 48000,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Audio",
                    "Index": 3,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0
                },
                {
                    "Codec": "ac3",
                    "Language": "chi",
                    "TimeBase": "1/1000",
                    "Title": "公映国语",
                    "DisplayTitle": "Chinese Simplified AC3 5.1 (默认)",
                    "DisplayLanguage": "Chinese Simplified",
                    "IsInterlaced": false,
                    "ChannelLayout": "5.1",
                    "BitRate": 640000,
                    "Channels": 6,
                    "SampleRate": 48000,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Audio",
                    "Index": 4,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0
                },
                {
                    "Codec": "ac3",
                    "Language": "eng",
                    "TimeBase": "1/1000",
                    "Title": "导评音轨",
                    "DisplayTitle": "English AC3 stereo (默认)",
                    "DisplayLanguage": "English",
                    "IsInterlaced": false,
                    "ChannelLayout": "stereo",
                    "BitRate": 192000,
                    "Channels": 2,
                    "SampleRate": 48000,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Audio",
                    "Index": 5,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0
                },
                {
                    "Codec": "PGSSUB",
                    "Language": "eng",
                    "TimeBase": "1/1000",
                    "DisplayTitle": "English (默认 PGSSUB)",
                    "DisplayLanguage": "English",
                    "IsInterlaced": false,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Subtitle",
                    "Index": 6,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0,
                    "SubtitleLocationType": "InternalStream"
                },
                {
                    "Codec": "PGSSUB",
                    "Language": "chi",
                    "TimeBase": "1/1000",
                    "Title": "国配简体特效",
                    "DisplayTitle": "Chinese Simplified (默认 PGSSUB)",
                    "DisplayLanguage": "Chinese Simplified",
                    "IsInterlaced": false,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Subtitle",
                    "Index": 7,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0,
                    "SubtitleLocationType": "InternalStream"
                },
                {
                    "Codec": "PGSSUB",
                    "Language": "chi",
                    "TimeBase": "1/1000",
                    "Title": "国配繁体特效",
                    "DisplayTitle": "Chinese Traditional (默认 PGSSUB)",
                    "DisplayLanguage": "Chinese Traditional",
                    "IsInterlaced": false,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Subtitle",
                    "Index": 8,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0,
                    "SubtitleLocationType": "InternalStream"
                },
                {
                    "Codec": "PGSSUB",
                    "Language": "chi",
                    "TimeBase": "1/1000",
                    "Title": "简英双语特效",
                    "DisplayTitle": "Chinese Simplified (默认 PGSSUB)",
                    "DisplayLanguage": "Chinese Simplified",
                    "IsInterlaced": false,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Subtitle",
                    "Index": 9,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0,
                    "SubtitleLocationType": "InternalStream"
                },
                {
                    "Codec": "PGSSUB",
                    "Language": "eng",
                    "TimeBase": "1/1000",
                    "Title": "导评英字",
                    "DisplayTitle": "English (默认 PGSSUB)",
                    "DisplayLanguage": "English",
                    "IsInterlaced": false,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Subtitle",
                    "Index": 10,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0,
                    "SubtitleLocationType": "InternalStream"
                },
                {
                    "Codec": "PGSSUB",
                    "Language": "chi",
                    "TimeBase": "1/1000",
                    "Title": "繁英双语特效",
                    "DisplayTitle": "Chinese Simplified (默认 PGSSUB)",
                    "DisplayLanguage": "Chinese Simplified",
                    "IsInterlaced": false,
                    "IsDefault": true,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Type": "Subtitle",
                    "Index": 11,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0,
                    "SubtitleLocationType": "InternalStream"
                },
                {
                    "Codec": "mjpeg",
                    "ColorSpace": "bt470bg",
                    "TimeBase": "1/90000",
                    "IsInterlaced": false,
                    "BitDepth": 8,
                    "RefFrames": 1,
                    "IsDefault": false,
                    "IsForced": false,
                    "IsHearingImpaired": false,
                    "Height": 2057,
                    "Width": 1703,
                    "RealFrameRate": 90000,
                    "Profile": "Progressive",
                    "Type": "EmbeddedImage",
                    "AspectRatio": "1703:2057",
                    "Index": 12,
                    "IsExternal": false,
                    "IsTextSubtitleStream": false,
                    "SupportsExternalStream": false,
                    "Protocol": "File",
                    "PixelFormat": "yuvj420p",
                    "Level": -99,
                    "IsAnamorphic": false,
                    "ExtendedVideoType": "None",
                    "ExtendedVideoSubType": "None",
                    "ExtendedVideoSubTypeDescription": "None",
                    "AttachmentSize": 0
                }
            ],
            "Formats": [],
            "Bitrate": 63913746,
            "RequiredHttpHeaders": {},
            "AddApiKeyToDirectStreamUrl": false,
            "ReadAtNativeFramerate": false,
            "DefaultAudioStreamIndex": 1,
            "ItemId": "368536"
        }
    ],
    "ProductionLocations": [
        "United States of America"
    ],
    "Path": "/media/xunleistrm/openlist/好东西/电影/漫威影业/4月8/惊奇队长2/The Marvels 2023 V3 BluRay REMUX UHD 2160p TrueHD7.1-DreamHD.strm",
    "OfficialRating": "PG-13",
    "Overview": "\"惊奇队长\"卡罗尔·丹弗斯从残暴的克里人手中夺回了属于自己的身份，也对至高智慧完成了复仇。然而，意想不到的后果出现了。面对动荡脆弱的宇宙，她毅然决然地挺身而出。执行任务时，她来到一个神秘的特殊虫洞。在这里，她与另外两位女英雄产生了能力纠缠——一位是来自泽西市、惊奇队长的超级粉丝卡玛拉·克汗，另一位是曾与卡罗尔亲密无间的小侄女、如今长大在天剑局担任宇航员的莫妮卡·兰博队长。看似不搭界的三人必须齐心协力，以\"惊奇联盟\"的身份拯救宇宙。",
    "Taglines": [
        "复联超强战力 集结惊奇联盟"
    ],
    "Genres": [
        "科幻",
        "冒险",
        "动作"
    ],
    "CommunityRating": 5.9,
    "RunTimeTicks": 62849920000,
    "Size": 50212173497,
    "FileName": "The Marvels 2023 V3 BluRay REMUX UHD 2160p TrueHD7.1-DreamHD.strm",
    "Bitrate": 63913746,
    "ProductionYear": 2023,
    "RemoteTrailers": [
        {
            "Url": "https://www.youtube.com/watch?v=iuk77TjvfmE"
        },
        {
            "Url": "https://www.youtube.com/watch?v=wS_qbDztgVY"
        },
        {
            "Url": "https://www.youtube.com/watch?v=uwmDH12MAA4"
        }
    ],
    "ProviderIds": {
        "Tmdb": "609681",
        "Tvdb": "134366",
        "IMDB": "tt10676048"
    },
    "IsFolder": false,
    "ParentId": "368533",
    "Type": "Movie",
    "People": [
        {
            "Name": "布丽·拉尔森",
            "Id": "14311",
            "Role": "Carol Danvers / Captain Marvel",
            "Type": "Actor",
            "PrimaryImageTag": "c11c20bfcd56a1371de7836e13e54297"
        },
        {
            "Name": "泰柔娜·派丽丝",
            "Id": "145748",
            "Role": "Monica Rambeau",
            "Type": "Actor",
            "PrimaryImageTag": "365dd60a20c3bf7265dd806470560fe8"
        },
        {
            "Name": "伊曼·韦拉尼",
            "Id": "368571",
            "Role": "Kamala Khan / Ms. Marvel",
            "Type": "Actor",
            "PrimaryImageTag": "abd93465dac6508341929fb5d8db35b9"
        },
        {
            "Name": "塞缪尔·杰克逊",
            "Id": "277",
            "Role": "Nick Fury",
            "Type": "Actor",
            "PrimaryImageTag": "4dd6b10448b059bb50d9aadd4d370e36"
        },
        {
            "Name": "扎威·阿什顿",
            "Id": "50657",
            "Role": "Dar-Benn",
            "Type": "Actor",
            "PrimaryImageTag": "d1483b0aa51b7ee3eea06009e6ebb911"
        },
        {
            "Name": "加里·刘易斯",
            "Id": "81025",
            "Role": "Emperor Dro'ge",
            "Type": "Actor",
            "PrimaryImageTag": "b3f9955dbfad5d2eaefef05a3b46bf36"
        },
        {
            "Name": "朴叙俊",
            "Id": "19204",
            "Role": "Prince Yan",
            "Type": "Actor",
            "PrimaryImageTag": "446f8f01431ba03bcd93b85e7d198c81"
        },
        {
            "Name": "泽诺比娅·谢罗夫",
            "Id": "36048",
            "Role": "Muneeba Khan",
            "Type": "Actor",
            "PrimaryImageTag": "f9d57db807db566e78f83bd2f02c7ee0"
        },
        {
            "Name": "莫汉·卡普尔",
            "Id": "368572",
            "Role": "Yusuf Khan",
            "Type": "Actor",
            "PrimaryImageTag": "bb47a35fc5c02befd0e88eccf6ba526e"
        },
        {
            "Name": "萨加尔·谢赫",
            "Id": "297140",
            "Role": "Aamir Khan",
            "Type": "Actor",
            "PrimaryImageTag": "772593930f888b7ce3ddbebecbbcc622"
        },
        {
            "Name": "蕾拉·法扎德",
            "Id": "145042",
            "Role": "Talia",
            "Type": "Actor",
            "PrimaryImageTag": "dde1535a59f6a73159c15ee5d7db3307"
        },
        {
            "Name": "亚伯拉罕·波波拉",
            "Id": "16939",
            "Role": "Dag",
            "Type": "Actor",
            "PrimaryImageTag": "73d44eeeb9a57d77f4cc720a49714454"
        },
        {
            "Name": "拉什纳·林奇",
            "Id": "15827",
            "Role": "Maria Rambeau",
            "Type": "Actor",
            "PrimaryImageTag": "789b0275e3baaaf875ad4a4d03e6f7aa"
        },
        {
            "Name": "泰莎·汤普森",
            "Id": "18858",
            "Role": "Valkyrie",
            "Type": "Actor",
            "PrimaryImageTag": "aa7962effccd1cc948458219534ae44e"
        },
        {
            "Name": "丹尼尔·艾格斯",
            "Id": "9231",
            "Role": "Ty-Rone",
            "Type": "Actor",
            "PrimaryImageTag": "2bfe6453e6d1903ee2c7d76924ca4e56"
        },
        {
            "Name": "Alex Hughes",
            "Id": "256496",
            "Role": "Kree Announcer",
            "Type": "Actor",
            "PrimaryImageTag": "101bd8aa810c3501b99d773701b9c84f"
        },
        {
            "Name": "Cecily Cleeve",
            "Id": "224688",
            "Role": "Skrull Young Girl",
            "Type": "Actor",
            "PrimaryImageTag": "84b02ef010f4f43b9c1f70ded26c74d4"
        },
        {
            "Name": "Ffion Jolly",
            "Id": "17529",
            "Role": "Skrull Woman",
            "Type": "Actor",
            "PrimaryImageTag": "23e14cfa99e7def6aa4c2c437afab92a"
        },
        {
            "Name": "Kenedy McCallam-Martin",
            "Id": "368574",
            "Role": "Little Monica",
            "Type": "Actor",
            "PrimaryImageTag": "16998c2acc6a441c0f7850219d394ca1"
        },
        {
            "Name": "Savannah Skinner-Henry",
            "Id": "343573",
            "Role": "Aladnean Child",
            "Type": "Actor",
            "PrimaryImageTag": "643733e17ee92a04c294c1b08a790a5a"
        },
        {
            "Name": "Daniel Monteiro",
            "Id": "368576",
            "Role": "Royal Attaché",
            "Type": "Actor",
            "PrimaryImageTag": "fa829ee9976a3185ba0ccbc00057feb3"
        },
        {
            "Name": "Kya Garwood",
            "Id": "15668",
            "Role": "Awed Kree Soldier",
            "Type": "Actor",
            "PrimaryImageTag": "f0023bb524414435178f4c8ae43a6760"
        },
        {
            "Name": "Fikayo Ifarajimi",
            "Id": "368577",
            "Role": "Hala Citizen",
            "Type": "Actor",
            "PrimaryImageTag": "bbea7b53d4dbc96170e0677e82e43e18"
        },
        {
            "Name": "Shereen Walker",
            "Id": "368578",
            "Role": "Kree with Mask",
            "Type": "Actor",
            "PrimaryImageTag": "2e97767f4a6d7634e324237455a09101"
        },
        {
            "Name": "海莉·斯坦菲尔德",
            "Id": "17549",
            "Role": "Kate Bishop",
            "Type": "Actor",
            "PrimaryImageTag": "e45261b24a5a3d512e7fbef7d8ef4860"
        },
        {
            "Name": "凯尔塞·格拉玛",
            "Id": "13809",
            "Role": "Dr. Henry 'Hank' McCoy / Beast",
            "Type": "Actor",
            "PrimaryImageTag": "1c1df50e68cc4699b814e691b6a00cb5"
        },
        {
            "Name": "杰特·克莱恩",
            "Id": "93328",
            "Role": "Tommy Maximoff (archive footage) (uncredited)",
            "Type": "Actor",
            "PrimaryImageTag": "048208b1a26432c2cff9158afff6375c"
        },
        {
            "Name": "妮娅·达科斯塔",
            "Id": "44704",
            "Role": "Director",
            "Type": "Director",
            "PrimaryImageTag": "a92eea3d67d72406e3a23d8f4639854a"
        },
        {
            "Name": "梅根·麦克唐纳",
            "Id": "368581",
            "Role": "Writer",
            "Type": "Writer",
            "PrimaryImageTag": "cc88e1fa96cd29a71ea39aad890dbc13"
        },
        {
            "Name": "妮娅·达科斯塔",
            "Id": "44704",
            "Role": "Writer",
            "Type": "Writer",
            "PrimaryImageTag": "a92eea3d67d72406e3a23d8f4639854a"
        },
        {
            "Name": "艾丽莎·卡拉西克",
            "Id": "368580",
            "Role": "Writer",
            "Type": "Writer",
            "PrimaryImageTag": "bb22051f2ba7adad220c4463faf86bb2"
        },
        {
            "Name": "凯文·费奇",
            "Id": "7020",
            "Role": "Producer",
            "Type": "Producer",
            "PrimaryImageTag": "6db5dfade4d5b40c251d8d7397a2a2b0"
        }
    ],
    "Studios": [
        {
            "Name": "Marvel Studios",
            "Id": 7025
        },
        {
            "Name": "Kevin Feige Productions",
            "Id": 79502
        }
    ],
    "GenreItems": [
        {
            "Name": "科幻",
            "Id": 385
        },
        {
            "Name": "冒险",
            "Id": 383
        },
        {
            "Name": "动作",
            "Id": 384
        }
    ],
    "TagItems": [],
    "LocalTrailerCount": 0,
    "UserData": {
        "PlayedPercentage": 43.09687267700579,
        "PlaybackPositionTicks": 27086350000,
        "PlayCount": 19,
        "IsFavorite": false,
        "LastPlayedDate": "2026-05-14T07:54:54.0000000Z",
        "Played": false
    },
    "DisplayPreferencesId": "dbf7709c41faaa746463d67978eb863d",
    "PrimaryImageAspectRatio": 0.6666666666666666,
    "MediaStreams": [
        {
            "Codec": "hevc",
            "ColorTransfer": "smpte2084",
            "ColorPrimaries": "bt2020",
            "ColorSpace": "bt2020nc",
            "TimeBase": "1/1000",
            "VideoRange": "HDR 10",
            "DisplayTitle": "4K HDR 10 HEVC",
            "IsInterlaced": false,
            "BitRate": 63913746,
            "BitDepth": 10,
            "RefFrames": 1,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Height": 2160,
            "Width": 3840,
            "AverageFrameRate": 23.976025,
            "RealFrameRate": 23.976025,
            "Profile": "Main 10",
            "Type": "Video",
            "AspectRatio": "16:9",
            "Index": 0,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "PixelFormat": "yuv420p10le",
            "Level": 153,
            "IsAnamorphic": false,
            "ExtendedVideoType": "Hdr10",
            "ExtendedVideoSubType": "Hdr10",
            "ExtendedVideoSubTypeDescription": "HDR 10",
            "AttachmentSize": 0
        },
        {
            "Codec": "truehd",
            "Language": "eng",
            "TimeBase": "1/1000",
            "DisplayTitle": "English TRUEHD 7.1 (默认)",
            "DisplayLanguage": "English",
            "IsInterlaced": false,
            "ChannelLayout": "7.1",
            "BitDepth": 24,
            "Channels": 8,
            "SampleRate": 48000,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Audio",
            "Index": 1,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0
        },
        {
            "Codec": "ac3",
            "Language": "eng",
            "TimeBase": "1/1000",
            "DisplayTitle": "English AC3 5.1 (默认)",
            "DisplayLanguage": "English",
            "IsInterlaced": false,
            "ChannelLayout": "5.1",
            "BitRate": 640000,
            "Channels": 6,
            "SampleRate": 48000,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Audio",
            "Index": 2,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0
        },
        {
            "Codec": "truehd",
            "Language": "chi",
            "TimeBase": "1/1000",
            "DisplayTitle": "Chinese Simplified TRUEHD 7.1 (默认)",
            "DisplayLanguage": "Chinese Simplified",
            "IsInterlaced": false,
            "ChannelLayout": "7.1",
            "BitDepth": 24,
            "Channels": 8,
            "SampleRate": 48000,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Audio",
            "Index": 3,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0
        },
        {
            "Codec": "ac3",
            "Language": "chi",
            "TimeBase": "1/1000",
            "DisplayTitle": "Chinese Simplified AC3 5.1 (默认)",
            "DisplayLanguage": "Chinese Simplified",
            "IsInterlaced": false,
            "ChannelLayout": "5.1",
            "BitRate": 640000,
            "Channels": 6,
            "SampleRate": 48000,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Audio",
            "Index": 4,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0
        },
        {
            "Codec": "ac3",
            "Language": "eng",
            "TimeBase": "1/1000",
            "DisplayTitle": "English AC3 stereo (默认)",
            "DisplayLanguage": "English",
            "IsInterlaced": false,
            "ChannelLayout": "stereo",
            "BitRate": 192000,
            "Channels": 2,
            "SampleRate": 48000,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Audio",
            "Index": 5,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0
        },
        {
            "Codec": "PGSSUB",
            "Language": "eng",
            "TimeBase": "1/1000",
            "DisplayTitle": "English (默认 PGSSUB)",
            "DisplayLanguage": "English",
            "IsInterlaced": false,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Subtitle",
            "Index": 6,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0,
            "SubtitleLocationType": "InternalStream"
        },
        {
            "Codec": "PGSSUB",
            "Language": "chi",
            "TimeBase": "1/1000",
            "DisplayTitle": "Chinese Simplified (默认 PGSSUB)",
            "DisplayLanguage": "Chinese Simplified",
            "IsInterlaced": false,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Subtitle",
            "Index": 7,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0,
            "SubtitleLocationType": "InternalStream"
        },
        {
            "Codec": "PGSSUB",
            "Language": "chi",
            "TimeBase": "1/1000",
            "DisplayTitle": "Chinese Traditional (默认 PGSSUB)",
            "DisplayLanguage": "Chinese Traditional",
            "IsInterlaced": false,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Subtitle",
            "Index": 8,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0,
            "SubtitleLocationType": "InternalStream"
        },
        {
            "Codec": "PGSSUB",
            "Language": "chi",
            "TimeBase": "1/1000",
            "DisplayTitle": "Chinese Simplified (默认 PGSSUB)",
            "DisplayLanguage": "Chinese Simplified",
            "IsInterlaced": false,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Subtitle",
            "Index": 9,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0,
            "SubtitleLocationType": "InternalStream"
        },
        {
            "Codec": "PGSSUB",
            "Language": "eng",
            "TimeBase": "1/1000",
            "DisplayTitle": "English (默认 PGSSUB)",
            "DisplayLanguage": "English",
            "IsInterlaced": false,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Subtitle",
            "Index": 10,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0,
            "SubtitleLocationType": "InternalStream"
        },
        {
            "Codec": "PGSSUB",
            "Language": "chi",
            "TimeBase": "1/1000",
            "DisplayTitle": "Chinese Simplified (默认 PGSSUB)",
            "DisplayLanguage": "Chinese Simplified",
            "IsInterlaced": false,
            "IsDefault": true,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Type": "Subtitle",
            "Index": 11,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0,
            "SubtitleLocationType": "InternalStream"
        },
        {
            "Codec": "mjpeg",
            "ColorSpace": "bt470bg",
            "TimeBase": "1/90000",
            "IsInterlaced": false,
            "BitDepth": 8,
            "RefFrames": 1,
            "IsDefault": false,
            "IsForced": false,
            "IsHearingImpaired": false,
            "Height": 2057,
            "Width": 1703,
            "RealFrameRate": 90000,
            "Profile": "Progressive",
            "Type": "EmbeddedImage",
            "AspectRatio": "1703:2057",
            "Index": 12,
            "IsExternal": false,
            "IsTextSubtitleStream": false,
            "SupportsExternalStream": false,
            "Protocol": "File",
            "PixelFormat": "yuvj420p",
            "Level": -99,
            "IsAnamorphic": false,
            "ExtendedVideoType": "None",
            "ExtendedVideoSubType": "None",
            "ExtendedVideoSubTypeDescription": "None",
            "AttachmentSize": 0
        }
    ],
    "PartCount": 1,
    "ImageTags": {
        "Primary": "250d8492f494f982f7812dd7210f8bbd",
        "Logo": "5422bae8a5357e5640eab8e9c7460ed7",
        "Thumb": "10b26fd54fd4b3f25d7147d721c29083"
    },
    "BackdropImageTags": [
        "086210c50a3990de05ff65c26f11acca",
        "99ffa18668ea9770c1fae33683ba9285"
    ],
    "Chapters": [
        {
            "StartPositionTicks": 0,
            "Name": "第 01 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 0
        },
        {
            "StartPositionTicks": 2609690000,
            "Name": "第 02 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 1
        },
        {
            "StartPositionTicks": 4230060000,
            "Name": "第 03 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 2
        },
        {
            "StartPositionTicks": 6697110000,
            "Name": "第 04 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 3
        },
        {
            "StartPositionTicks": 8542700000,
            "Name": "第 05 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 4
        },
        {
            "StartPositionTicks": 12690180000,
            "Name": "第 06 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 5
        },
        {
            "StartPositionTicks": 16398880000,
            "Name": "第 07 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 6
        },
        {
            "StartPositionTicks": 17827390000,
            "Name": "第 08 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 7
        },
        {
            "StartPositionTicks": 20055030000,
            "Name": "第 09 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 8
        },
        {
            "StartPositionTicks": 22880770000,
            "Name": "第 10 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 9
        },
        {
            "StartPositionTicks": 26302530000,
            "Name": "第 11 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 10
        },
        {
            "StartPositionTicks": 28861330000,
            "Name": "第 12 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 11
        },
        {
            "StartPositionTicks": 30268150000,
            "Name": "第 13 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 12
        },
        {
            "StartPositionTicks": 31510230000,
            "Name": "第 14 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 13
        },
        {
            "StartPositionTicks": 35320700000,
            "Name": "第 15 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 14
        },
        {
            "StartPositionTicks": 39076950000,
            "Name": "第 16 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 15
        },
        {
            "StartPositionTicks": 41876830000,
            "Name": "第 17 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 16
        },
        {
            "StartPositionTicks": 46345470000,
            "Name": "第 18 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 17
        },
        {
            "StartPositionTicks": 50370320000,
            "Name": "第 19 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 18
        },
        {
            "StartPositionTicks": 52450310000,
            "Name": "第 20 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 19
        },
        {
            "StartPositionTicks": 53900100000,
            "Name": "第 21 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 20
        },
        {
            "StartPositionTicks": 55241020000,
            "Name": "第 22 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 21
        },
        {
            "StartPositionTicks": 55910850000,
            "Name": "第 23 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 22
        },
        {
            "StartPositionTicks": 57538310000,
            "Name": "第 24 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 23
        },
        {
            "StartPositionTicks": 58551830000,
            "Name": "第 25 章",
            "MarkerType": "Chapter",
            "ChapterIndex": 24
        }
    ],
    "MediaType": "Video",
    "LockedFields": [],
    "LockData": false,
    "Width": 3840,
    "Height": 2160
}
```

---

## 4. 关键字段速查

| 字段 | 值 | 说明 |
|---|---|---|
| `Id` | `368536` | 唯一标识 |
| `Type` | `Movie` | 类型 |
| `Name` | `惊奇队长2` | 中文名称 |
| `OriginalTitle` | `The Marvels` | 原始标题 |
| `ProductionYear` | `2023` | 年份 |
| `RunTimeTicks` | `62849920000` | 总时长（~104.7分钟） |
| `CommunityRating` | `5.9` | 评分 |
| `OfficialRating` | `PG-13` | 分级 |
| `Genres` | `["科幻", "冒险", "动作"]` | 类型标签 |
| `ProviderIds` | `{"Tmdb":"609681", "IMDB":"tt10676048"}` | 外部平台ID |
| `Studios` | `[{"Name":"Marvel Studios", "Id":7025}, ...]` | 制片公司 |
| `People` | 30+ 条目 | 演员/导演/编剧 |
| `MediaSources` | 1 个 | 媒体源（含 MediaStreams 音视频轨） |
| `UserData.PlayedPercentage` | `43.09` | 已观看百分比 |
| `UserData.PlaybackPositionTicks` | `27086350000` | 当前播放位置 |
| `ImageTags.Primary` | `250d8492...` | 海报图 tag |
| `ImageTags.Logo` | `5422bae8...` | Logo 图 tag |
