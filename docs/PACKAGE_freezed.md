> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# freezed ^3.2.5 + json_serializable ^6.13.2 使用方法

## 1. 概述

`freezed` 是 Dart 生态中最流行的不可变数据类生成器。v3.x 版本基于 Dart 3 的 Records 和 Patterns，大幅简化了代码生成，同时保持强大的类型安全。

**核心优势：**
- 自动生成 `copyWith`、`==`、`hashCode`、`toString`
- 自动生成 JSON 序列化代码（配合 `json_serializable`）
- 支持 Union Types（密封类）
- 零运行时开销（全部代码生成）

---

## 2. 环境配置

```yaml
dependencies:
  freezed_annotation: ^3.1.0
  json_annotation: ^4.11.0

dev_dependencies:
  build_runner: ^2.15.0
  freezed: ^3.2.5
  json_serializable: ^6.13.2
```

---

## 3. 基础用法

### 3.1 简单数据类
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    String? email,
    @Default(0) int age,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### 3.2 生成的能力
```dart
final user = User(id: '1', name: 'John');

// copyWith
final updated = user.copyWith(name: 'Jane');

// 相等性比较
print(user == User(id: '1', name: 'John')); // true

// toString
print(user.toString()); // User(id: 1, name: John, email: null, age: 0)

// toJson
final json = user.toJson();

// fromJson
final fromJson = User.fromJson(json);
```

---

## 4. 进阶特性

### 4.1 Union Types（密封类）
```dart
@freezed
sealed class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse.loading() = ApiResponseLoading;
  const factory ApiResponse.data(T value) = ApiResponseData;
  const factory ApiResponse.error(String message) = ApiResponseError;
}

// 使用 — Dart 3 模式匹配
final response = apiResponse;
switch (response) {
  case ApiResponseLoading():
    return CircularProgressIndicator();
  case ApiResponseData(:final value):
    return Text('Data: $value');
  case ApiResponseError(:final message):
    return Text('Error: $message');
}
```

### 4.2 自定义字段序列化
```dart
@freezed
class Movie with _$Movie {
  const factory Movie({
    required String id,
    required String title,
    // 自定义字段名映射
    @JsonKey(name: 'release_date') required DateTime releaseDate,
    // 自定义转换器
    @JsonKey(fromJson: _ratingFromJson, toJson: _ratingToJson)
    required double rating,
    // 忽略字段
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? localPath,
  }) = _Movie;

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
}

double _ratingFromJson(dynamic value) => (value as num).toDouble();
dynamic _ratingToJson(double value) => value;
```

### 4.3 集合类型
```dart
@freezed
class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    @Default([]) List<Track> tracks, // 空列表默认值
    @Default({}) Set<String> tags,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
}
```

### 4.4 继承与混入
```dart
abstract class Entity {
  String get id;
}

@freezed
class User extends Entity with _$User {
  const factory User({
    required String id,
    required String name,
  }) = _User;

  const User._(); // 私有构造函数，支持自定义方法

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // 自定义方法
  String get displayName => name.toUpperCase();
}
```

---

## 5. 代码生成命令

```bash
# 生成代码（首次或新增/修改模型后）
flutter pub run build_runner build

# 监听模式（开发时自动重新生成）
flutter pub run build_runner watch

# 删除冲突输出并重新生成
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 6. analysis_options.yaml 配置

```yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore
```

---

## 7. 与 Riverpod 集成

```dart
// 使用 Freezed 类作为 Riverpod State
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<Movie> movies,
    @Default(false) bool isLoading,
    String? error,
  }) = _HomeState;
}

// AsyncNotifier 中使用
class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final repo = ref.read(movieRepositoryProvider);
    final movies = await repo.getMovies();
    return HomeState(movies: movies);
  }
}
```

---

## 8. 项目集成建议

当前项目已正确使用 Freezed + json_serializable。建议改进：

1. **添加 Union Types**：ApiResponse 可用 Union Type 替代当前的 `AsyncValue` 包装
2. **自定义字段映射**：Emby API 字段名与 Dart 命名规范不一致时，使用 `@JsonKey(name: '...')`
3. **添加 `includeIfNull: false`**：减少 JSON 输出体积
4. **私有化构造函数**：需要自定义方法时，添加 `const ClassName._()`
5. **考虑 `sealed` 关键字**：Dart 3 的 `sealed class` 与 Freezed Union 配合，可让模式匹配更完整
