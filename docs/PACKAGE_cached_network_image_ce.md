> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# cached_network_image_ce ^4.6.4 使用方法

## 1. 概述

`cached_network_image_ce` 是 `cached_network_image` 的社区维护版（Community Edition）。原版自 2024 年 8 月起基本停止维护，CE 版将缓存层从 `sqflite` 重构成 `hive_ce`，带来显著的性能提升。

**核心改进（CE 版）：**
- 缓存元数据查询：**8 倍更快**（16ms → 2ms）
- 新图片写入：**4 倍更快**（116ms → 29ms）
- 零滚动卡顿（jank-free scrolling）
- 完整的 Web 持久缓存（IndexedDB）
- 99% API 兼容原版，可无痛替换

---

## 2. 基础用法

### 2.1 直接替换原包
```dart
// 只需修改 import
import 'package:cached_network_image_ce/cached_network_image.dart';
// 替代原版：
// import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 2.2 带进度指示器
```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  progressIndicatorBuilder: (context, url, downloadProgress) {
    return CircularProgressIndicator(
      value: downloadProgress.progress,
    );
  },
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 2.3 自定义图片构建
```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  imageBuilder: (context, imageProvider) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  },
  placeholder: (context, url) => Container(color: Colors.grey[200]),
  errorWidget: (context, url, error) => Icon(Icons.broken_image),
)
```

---

## 3. 作为 ImageProvider

```dart
Image(
  image: CachedNetworkImageProvider('https://example.com/image.jpg'),
  fit: BoxFit.cover,
)

// 在 BoxDecoration 中使用
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: CachedNetworkImageProvider('https://example.com/image.jpg'),
      fit: BoxFit.cover,
    ),
  ),
)
```

---

## 4. 高级配置

### 4.1 缓存键（Cache Key）
```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  cacheKey: 'user_avatar_123', // 自定义缓存键
)
```

### 4.2 HTTP 头（认证图片）
```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/private-image.jpg',
  httpHeaders: {
    'Authorization': 'Bearer YOUR_TOKEN',
  },
)
```

### 4.3 缓存管理器配置
```dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// 自定义缓存配置
final customCacheManager = CacheManager(
  Config(
    'customCacheKey',
    stalePeriod: const Duration(days: 7),    // 缓存有效期
    maxNrOfCacheObjects: 100,                  // 最大缓存数量
  ),
);

CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  cacheManager: customCacheManager,
)
```

### 4.4 图片尺寸限制
```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/large-image.jpg',
  memCacheWidth: 400,   // 内存缓存宽度限制
  memCacheHeight: 400,  // 内存缓存高度限制
  maxWidthDiskCache: 800,  // 磁盘缓存宽度限制
  maxHeightDiskCache: 800, // 磁盘缓存高度限制
)
```

---

## 5. 预缓存

```dart
// 提前缓存图片（用于确定会显示的图片）
await precacheImage(
  CachedNetworkImageProvider('https://example.com/image.jpg'),
  context,
);
```

---

## 6. 清除缓存

```dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// 清除单张图片
await DefaultCacheManager().removeFile('https://example.com/image.jpg');

// 清空所有缓存
await DefaultCacheManager().emptyCache();

// 获取缓存信息
final fileInfo = await DefaultCacheManager().getFileFromCache('url');
```

---

## 7. 与 FadeInImage 结合

```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  fadeInDuration: Duration(milliseconds: 300),
  fadeOutDuration: Duration(milliseconds: 100),
  placeholder: (context, url) => Image.asset('assets/placeholder.png'),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

---

## 8. Web 平台注意事项

- CE 版在 Web 上使用 IndexedDB 存储图片数据，**完全支持持久缓存**
- 但大图片序列化/反序列化有开销，如 Web 缓存非必需，可条件使用 `Image.network`

```dart
Widget buildImage(String url) {
  if (kIsWeb) {
    // Web 使用浏览器内置缓存
    return Image.network(url, fit: BoxFit.cover);
  }
  // 原生平台使用持久缓存
  return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover);
}
```

---

## 9. 项目集成建议

当前项目已使用 `cached_network_image_ce`。建议改进：

1. **添加 `memCacheWidth` / `memCacheHeight`**：限制内存中图片尺寸，防止 OOM
2. **添加 HTTP 头**：Emby 图片需要 `X-Emby-Token`，通过 `httpHeaders` 传入
3. **使用自定义 `cacheKey`**：Emby 图片 URL 含 `api_key` 参数时，用不含 token 的 URL 作为 cacheKey
4. **预缓存详情页图片**：进入详情页前预加载 backdrop 和 poster
5. **缓存清理策略**：设置 `maxNrOfCacheObjects` 和 `stalePeriod`，避免磁盘占用过大
6. **错误占位图优化**：当前 `errorBuilder` 过于简单，应使用品牌色占位图
