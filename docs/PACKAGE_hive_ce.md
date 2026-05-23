> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# hive_ce ^2.19.3 + hive_ce_flutter ^2.3.4 使用方法

## 1. 概述

`hive_ce` 是 Hive 数据库的社区维护版（Community Edition），`hive` 原版已停止维护。`hive_ce` 延续了 Hive 的高性能本地存储特性，并提供了持续的 bug 修复和新特性支持。

**核心优势：**
- 纯 Dart 实现，零原生依赖
- 极高的读写性能（比 SharedPreferences 快数倍）
- 支持复杂对象存储（通过 TypeAdapter）
- 支持加密 Box
- 支持 Lazy Box（按需加载）
- 与 `build_runner` 自动生成 Adapter

---

## 2. 环境配置

```yaml
dependencies:
  hive_ce: ^2.19.3
  hive_ce_flutter: ^2.3.4  # Flutter 初始化支持

dev_dependencies:
  hive_ce_generator: ^1.11.1
  build_runner: ^2.15.0
```

---

## 3. 初始化

```dart
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await Hive.initFlutter();
  
  // 注册自定义适配器（如果使用代码生成）
  Hive.registerAdapters();
  
  runApp(const MyApp());
}
```

---

## 4. 基础 CRUD

### 4.1 打开 Box
```dart
// 普通 Box（全部加载到内存）
final box = await Hive.openBox<String>('settings');

// Lazy Box（按需加载，适合大数据集）
final lazyBox = await Hive.openLazyBox<Movie>('movies');

// 加密 Box
final key = Hive.generateSecureKey();
final encryptedBox = await Hive.openBox<String>(
  'secrets',
  encryptionCipher: HiveAesCipher(key),
);
```

### 4.2 读写数据
```dart
// 写入
await box.put('username', 'John');
await box.putAll({'theme': 'dark', 'language': 'zh'});

// 读取
final username = box.get('username');
final theme = box.get('theme', defaultValue: 'light');

// 检查存在
final hasKey = box.containsKey('username');

// 删除
await box.delete('username');
await box.deleteAll(['key1', 'key2']);

// 清空
await box.clear();
```

### 4.3 遍历数据
```dart
// 获取所有值
final values = box.values.toList();

// 获取所有键
final keys = box.keys.toList();

// 遍历
for (final entry in box.toMap().entries) {
  print('${entry.key}: ${entry.value}');
}

// LazyBox 读取（返回 Future）
final movie = await lazyBox.getAt(0);
```

---

## 5. 复杂对象存储（TypeAdapter）

### 5.1 定义模型
```dart
import 'package:hive_ce/hive.dart';

part 'movie.g.dart';  // build_runner 生成

@HiveType(typeId: 1)  // typeId 必须唯一（0-223）
class Movie extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final int? year;
  
  @HiveField(3, defaultValue: false)
  final bool isFavorite;

  Movie({
    required this.id,
    required this.title,
    this.year,
    this.isFavorite = false,
  });
}
```

### 5.2 生成适配器
```bash
flutter pub run build_runner build
```

### 5.3 注册适配器
```dart
void main() async {
  await Hive.initFlutter();
  
  // 注册适配器（手动或自动）
  Hive.registerAdapter(MovieAdapter());
  
  runApp(const MyApp());
}

// 或使用 hive_ce 的自动注册（推荐）
// 在 main.dart 中：
// Hive.registerAdapters(); // 由 hive_ce_generator 自动生成
```

### 5.4 使用
```dart
final box = await Hive.openBox<Movie>('movies');

// 保存
final movie = Movie(id: '1', title: 'Inception', year: 2010);
await box.put(movie.id, movie);

// 读取
final saved = box.get('1');
print(saved?.title);

// 更新（HiveObject 支持 save）
saved?.year = 2011;
await saved?.save();

// 删除
await saved?.delete();
```

---

## 6. 监听变化

### 6.1 Box 级别监听
```dart
// 监听所有变化
box.watch().listen((event) {
  print('Key ${event.key} changed from ${event.oldValue} to ${event.value}');
});

// 监听特定键
box.watch(key: 'username').listen((event) {
  print('Username changed: ${event.value}');
});
```

### 6.2 ValueListenableBuilder
```dart
ValueListenableBuilder(
  valueListenable: Hive.box<String>('settings').listenable(),
  builder: (context, box, child) {
    final theme = box.get('theme', defaultValue: 'light');
    return Text('Current theme: $theme');
  },
)
```

---

## 7. 性能优化

### 7.1 Lazy Box（大数据集）
```dart
// 存储 10000+ 条记录时使用 LazyBox
final box = await Hive.openLazyBox<Movie>('movies');

// 只加载需要的项
final movie = await box.getAt(0); // 其他项仍在磁盘
```

### 7.2 批量操作
```dart
// 批量写入更高效
await box.putAll({
  'key1': 'value1',
  'key2': 'value2',
  'key3': 'value3',
});
```

### 7.3 压缩
```dart
// 手动压缩（删除碎片）
await box.compact();
```

---

## 8. 与 flutter_secure_storage 结合（加密密钥）

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> initEncryptedHive() async {
  const secureStorage = FlutterSecureStorage();
  
  // 尝试读取已有密钥
  String? keyString = await secureStorage.read(key: 'hive_key');
  List<int> encryptionKey;
  
  if (keyString == null) {
    // 生成新密钥
    encryptionKey = Hive.generateSecureKey();
    await secureStorage.write(
      key: 'hive_key',
      value: base64UrlEncode(encryptionKey),
    );
  } else {
    encryptionKey = base64UrlDecode(keyString);
  }
  
  final encryptedBox = await Hive.openBox(
    'secrets',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
}
```

---

## 9. 项目集成建议

当前项目已在 `pubspec.yaml` 中依赖 `hive_ce` 和 `hive_ce_flutter`，但代码中未使用。建议：

1. **缓存媒体元数据**：使用 `Hive.openBox<BaseItemDto>('media_cache')` 缓存 Emby 返回的媒体数据
2. **缓存图片**：配合 `cached_network_image_ce`（底层已用 `hive_ce`）
3. **用户配置存储**：将 `SharedPreferences` 中的主题/设置迁移到 Hive，性能更好
4. **离线播放列表**：使用 Hive 保存用户创建的播放列表
5. **观看历史**：使用 Hive 记录本地观看历史，减少 API 调用
6. **使用 `HiveObject`**：需要增删改查的模型继承 `HiveObject`，支持 `.save()` / `.delete()`
