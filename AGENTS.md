# Emby Client — AI Agent 项目指南

> 本文档面向 AI 编程助手。阅读者被假设为完全不了解本项目。

---

## 项目概述

**Emby Client** 是一个基于 Flutter 的跨平台 Emby 媒体播放器客户端，支持 Android、iOS、Windows、macOS、Linux 和 Web（实验性）。

- **名称**: `emby_client`（Dart package 名）
- **版本**: 1.0.0+1
- **SDK 约束**: Dart >= 3.8.0, Flutter >= 3.27.0
- **主要语言**: 简体中文（代码注释、文档、UI 文本均以中文为主）

### 核心功能
- Emby 服务器连接与用户名/密码认证
- 媒体库浏览（电影、电视剧、合集等）
- 首页仪表盘：Hero 轮播、继续观看、最近添加
- 详情页：海报、元数据、演职人员、季/集列表、相似推荐
- 视频播放：基于 fvp（libmpv）的全屏播放器，含手势控制、音轨/字幕切换
- 响应式布局：自动适配手机、平板、桌面
- 深度链接：`emby://` 自定义 scheme

---

## 技术栈

| 领域 | 包名 | 用途 |
|------|------|------|
| 状态管理 | `flutter_riverpod` ^3.2.1 | 依赖注入 + 响应式状态（AsyncNotifier / FutureProvider） |
| 路由 | `go_router` ^17.2.3 | 声明式路由，支持 StatefulShellRoute.indexedStack |
| HTTP | `dio` ^5.9.2 | 网络请求 + 拦截器（认证、日志、错误处理） |
| 视频播放 | `fvp` ^0.36.2 | 跨平台 libmpv 封装（Player 单例全局复用） |
| 图片缓存 | `cached_network_image_ce` ^4.6.4 | 网络图片 LRU 缓存 + 占位图 |
| 主题 | `flex_color_scheme` ^8.4.0 | Material 3 动态主题（亮/暗/OLED 纯黑） |
| 安全存储 | `flutter_secure_storage` ^10.2.0 | Token、密码等敏感信息存储 |
| 本地配置 | `shared_preferences` ^2.5.5 | 非敏感配置 + AccessToken 同步缓存 |
| 本地缓存 | `hive_ce` ^2.19.3 + `hive_ce_flutter` | 多 Box Hive 缓存，存储 API 响应数据 |
| 数据模型 | `freezed` ^3.2.5 + `json_serializable` ^6.13.2 | 不可变数据类 + JSON 序列化 |
| 深度链接 | `app_links` ^7.0.0 | 冷/热启动深度链接监听 |
| 加载占位 | `shimmer` ^3.0.0 + `skeletonizer` ^2.1.3 | 骨架屏与闪烁占位 |
| 取色 | `palette_generator_master` ^1.1.0 | 从海报提取动态主题色 |
| 窗口管理 | `window_manager` ^0.5.1 | 桌面端窗口控制 |
| 测试 | `flutter_test` + `mocktail` ^1.0.4 | 单元测试与 Mock |
| 代码生成 | `build_runner` ^2.15.0 | Freezed / JSON / Hive 生成器 |

> ⚠️ 注意：README 中写的是 `media_kit`，但实际依赖和播放器实现使用的是 `fvp`。

---

## 项目结构

```
lib/
├── main.dart                     # 入口：初始化绑定、fvp、SharedPreferences、Hive、屏幕方向
├── app.dart                      # MaterialApp.router，主题与国际化配置
├── routes.dart                   # GoRouter 配置（含认证重定向、StatefulShellRoute）
├── app_shell.dart                # 响应式导航壳层（BottomNav / Rail / Drawer）
│
├── core/                         # 平台基础设施
│   ├── api/
│   │   ├── dio_client.dart       # Dio 实例工厂 + Provider（baseUrl、设备信息、token）
│   │   ├── emby_api_service.dart # 所有 Emby REST API 的封装方法
│   │   └── auth_interceptor.dart # Token 注入、401 自动刷新、错误转换
│   ├── models/                   # DTO 数据模型（Freezed + json_serializable）
│   │   ├── base_item_dto.dart    # 核心媒体项模型
│   │   ├── authentication_result.dart
│   │   ├── playback_info.dart
│   │   ├── media_source_info.dart
│   │   ├── media_stream.dart
│   │   ├── query_result.dart
│   │   ├── user_dto.dart
│   │   └── user_item_data.dart
│   ├── theme/
│   │   ├── app_theme.dart        # FlexColorScheme 配置（亮/暗/纯黑）
│   │   └── theme_notifier.dart   # 主题模式与动态取色状态
│   ├── responsive/
│   │   ├── screen_layout.dart    # Material Design 3 断点工具（compact~extraLarge）
│   │   └── adaptive_grid.dart    # 自适应网格布局
│   └── utils/
│       └── extensions.dart       # BuildContext/Color/String/Duration/List/Widget 扩展
│
├── services/                     # 数据层与服务层
│   ├── repositories/
│   │   ├── auth_repository.dart      # 认证仓库接口
│   │   ├── auth_repository_impl.dart # 实现：SecureStorage + SharedPreferences
│   │   ├── media_repository.dart     # 媒体仓库接口
│   │   └── media_repository_impl.dart# 实现：API + Hive 缓存优先策略
│   ├── cache/
│   │   ├── cache.dart            # 缓存接口（预留）
│   │   ├── cache_keys.dart       # 确定性缓存 key 生成器
│   │   └── emby_cache.dart       # 多 Box Hive 缓存实现（7 个 Box）
│   ├── deep_link/
│   │   └── deep_link_service.dart # emby:// 深度链接解析与导航
│   └── navigation_history_service.dart
│
└── features/                     # 功能模块（按页面/业务划分）
    ├── auth/                     # 服务器配置 + 登录
    ├── home/                     # 首页仪表盘（carousel、继续观看、最近添加）
    ├── library/                  # 媒体库浏览（网格/列表、排序、筛选）
    ├── detail/                   # 详情页（海报、元数据、演职人员、季集）
    ├── player/                   # 视频播放页（fvp 控制层、手势、进度条）
    ├── settings/                 # 设置（主题、服务器、缓存清理）
    └── shared/                   # 跨功能复用的 Widget（MediaCard、EmbyCachedImage 等）
```

### 关键约定
- `core/models/*.freezed.dart` 和 `*.g.dart` 为代码生成文件，**禁止手动编辑**。
- `core/models/` 下的所有模型使用 **PascalCase JSON 键**映射（由 `build.yaml` 统一配置 `field_rename: pascal`），以匹配 Emby API 返回的字段名（如 `Id`、`AccessToken`、`MediaSources`）。
- 所有模型文件顶部通常有 `library;` 指令（Dart 3 库声明风格）。

---

## 构建与运行

### 前置依赖
- Flutter SDK >= 3.27.0
- Dart SDK >= 3.8.0
- 一个可访问的 Emby Server 实例（用于实际播放测试）

### 常用命令

```bash
# 安装依赖
flutter pub get

# 代码生成（Freezed / JSON Serializable / Hive）
flutter pub run build_runner build --delete-conflicting-outputs

# 开发运行（默认设备）
flutter run

# 运行指定平台
flutter run -d linux
flutter run -d android
flutter run -d chrome

# 分析检查
flutter analyze

# 运行所有测试
flutter test

# 运行单个测试文件
flutter test test/services/auth_repository_impl_test.dart

# 构建发布版
flutter build apk          # Android
flutter build ios          # iOS
flutter build windows      # Windows
flutter build macos        # macOS
flutter build linux        # Linux
```

### 代码生成说明
本项目大量依赖 `build_runner` 生成代码：
- `*.freezed.dart` — Freezed 不可变类、`copyWith`、相等运算符
- `*.g.dart` — `json_serializable` 的 `fromJson` / `toJson`
- Hive 类型适配器（如需要）

**修改任何 `core/models/` 下的 `.dart` 文件后，必须重新运行 `build_runner`**。

`build.yaml` 配置：
```yaml
json_serializable:
  options:
    field_rename: pascal   # 所有模型统一映射 PascalCase JSON
```

> 注意：Freezed 3.x **不会**将类上的 `@JsonSerializable()` 参数透传到生成的 `_$ClassImpl`，因此必须在 `build.yaml` 中全局配置，而不能仅靠类级注解。

---

## 代码风格指南

### Lint 规则（analysis_options.yaml）
- 继承 `package:flutter_lints/flutter.yaml`
- 排除生成的文件：`"**/*.g.dart"`、`"**/*.freezed.dart"`、`test/**`
- 强制规则：
  - `prefer_const_constructors: true`
  - `prefer_const_literals_to_create_immutables: true`
  - `prefer_single_quotes: true`
  - `avoid_print: true`（使用 `debugPrint`）
  - `prefer_final_locals: true`
  - `prefer_final_in_for_each: true`
  - `always_use_package_imports: true`
  - `avoid_relative_lib_imports: true`
  - `directives_ordering: true`

### 命名与注释
- **使用简体中文注释**。所有类、方法、复杂逻辑必须有中文文档注释。
- 状态类使用 `copyWith` 模式实现不可变更新。
- ViewModel 命名：`XxxViewModel`，对应 Provider：`xxxViewModelProvider`。
- Riverpod Provider 文件内联定义，不单独抽取到 `providers/` 目录。
- 常量/配置优先使用 `static const`，避免魔法字符串。

### 导入检查（重要）
项目有专门的《执行修改守则》要求：
> **每次修改代码后，必须检查是否引入未导入的包**。跨文件复制粘贴时极易遗漏 import。

检查命令：
```bash
flutter analyze lib/目标文件.dart
```
重点关注 `Undefined name` 和 `isn't defined` 错误。

---

## 架构模式

### 状态管理：Riverpod 3.x
- **全局状态**：使用 `Provider` / `AsyncNotifierProvider` 管理认证、主题等。
- **页面状态**：使用 `AsyncNotifierProvider.family`（如 `playerViewModelProvider`、`detailViewModelProvider`）绑定到具体 itemId。
- **细粒度数据**：首页使用多个独立的 `FutureProvider.autoDispose`（如 `carouselItemsProvider`、`resumableSeriesProvider`），避免整页重建。
- **依赖注入**：通过 `ref.watch` / `ref.read` 获取 Repository、API Service、Cache 实例。

### 数据流
```
UI (ConsumerWidget)
  ↓ watch / read
ViewModel (AsyncNotifier / FutureProvider)
  ↓ read
Repository (AuthRepository / MediaRepository)
  ↓ call
API Service (EmbyApiService)  +  Cache (EmbyCache)
  ↓ HTTP / Hive
Emby Server
```

### 缓存策略
`MediaRepositoryImpl` 实现 **缓存优先（cache-first）**：
1. 生成确定性 cache key（`CacheKeys`）
2. 先查 `EmbyCache`（Hive）→ 命中且未过期则直接返回
3. 未命中 → 请求 `EmbyApiService` → 写入缓存 → 返回数据
4. `getPlaybackInfo` **不走缓存**（播放 URL 含临时 token）

`EmbyCache` 将 `BaseItemDto` 拆分到 **7 个 Hive Box**，按 itemId 索引：
- `core` — 基础字段
- `userdata` — 播放进度、收藏状态（频繁变化）
- `genres` / `studios` / `providerIds` / `people` / `mediaSources` — 详情级重字段
- `listIndices` / `listMeta` — 列表结果索引 + 元数据（过期时间）

### 认证与存储分层
- **FlutterSecureStorage**：`emby_access_token`、`emby_server_url`、`emby_password`、`emby_session_id`
- **SharedPreferences**：`emby_user_id`、`emby_username`、`emby_access_token`（同步缓存，供图片加载使用）
- 认证失败（401）时，`AuthInterceptor` 自动尝试用保存的 username/password 刷新 token，刷新失败则清除凭证并跳转登录页。

### 响应式导航
`AppShell` 根据屏幕宽度自动切换三种导航模式：
- `< 600dp`：底部 `NavigationBar`
- `600~839dp`：侧边 `NavigationRail`
- `>= 840dp`：侧边 `NavigationDrawer`

---

## 测试策略

### 测试框架
- `flutter_test`（Dart 官方）
- `mocktail` ^1.0.4（Mock 与 Stub）

### 测试目录
```
test/
├── services/
│   ├── auth_repository_impl_test.dart   # 认证仓库：mock SecureStorage + Dio
│   ├── media_repository_impl_test.dart  # 媒体仓库：mock API + 真实 Hive 临时目录
│   ├── emby_cache_test.dart             # 缓存 round-trip、过期、列表分页
│   ├── deep_link_service_test.dart      # 深度链接 URI 解析逻辑
│   └── resumable_media_*.dart           # 继续观看相关测试
└── utils/
    └── auth_info_decryptor.dart         # 测试工具（加密凭证解密）
```

### Mock 规范
- 对第三方依赖（`Dio`、`FlutterSecureStorage`、`SharedPreferences`、`AppLinks`、`GoRouter`）使用 `class MockXxx extends Mock implements Xxx {}`
- `Dio` 的 `RequestOptions` / `Options` 需要注册 `registerFallbackValue(FakeRequestOptions())` 避免参数匹配报错。
- `SharedPreferences` 测试中使用 `SharedPreferences.setMockInitialValues({})` 初始化。
- `Hive` 测试中使用系统临时目录：`Directory.systemTemp.createTemp()`，并在 `tearDownAll` 中清理。

### 测试注意事项
- 部分测试文件包含**真实服务器集成测试**（硬编码了测试服务器 URL 和账号密码）。运行全部测试时请留意网络请求。
- 测试文件被 `analysis_options.yaml` 排除，因此不强制 const/单引号等 lint 规则。

### 常用测试命令
```bash
# 运行全部测试
flutter test

# 运行特定文件
flutter test test/services/emby_cache_test.dart

# 运行特定 group / test（通过名称过滤）
flutter test --name "cache-first behavior"
```

---

## 安全注意事项

1. **凭证存储**：密码和 AccessToken 存储在 `FlutterSecureStorage`（Keychain/Keystore）中，**不要**将其写入 `SharedPreferences` 或日志。
2. **自签名证书**：`DioClient` 和 `AuthRepositoryImpl` 在非 Web 平台允许自签名证书（`badCertificateCallback` 返回 `true`），这是为了兼容局域网内常见的不安全 Emby 服务器。生产环境如需更严格策略，请调整 `_isAllowedHost` 或 dio 配置。
3. **播放 URL**：`PlaybackInfo` 包含带 `api_key` 的临时直链，**不要缓存** `PlaybackInfo`，也不要将其序列化到持久存储。
4. **测试凭证**：`test/services/auth_repository_impl_test.dart` 中包含真实服务器的 URL 和明文密码，**不要在公共 CI 中直接运行该测试**，或将其中的真实凭证替换为环境变量/Secrets。
5. **图片请求**：`EmbyCachedImage` 通过 HTTP Header `X-Emby-Token` 传递 token，确保 `CachedNetworkImage` 的缓存键不会因 token 变化而失效。

---

## 关键文件速查

| 目的 | 文件路径 |
|------|----------|
| 入口与初始化顺序 | `lib/main.dart` |
| 路由表与认证守卫 | `lib/routes.dart` |
| Dio 配置 + Provider | `lib/core/api/dio_client.dart` |
| API 方法全集 | `lib/core/api/emby_api_service.dart` |
| 认证拦截器（401 处理） | `lib/core/api/auth_interceptor.dart` |
| 核心模型 | `lib/core/models/base_item_dto.dart` |
| 认证仓库实现 | `lib/services/repositories/auth_repository_impl.dart` |
| 媒体仓库实现（含缓存） | `lib/services/repositories/media_repository_impl.dart` |
| Hive 缓存实现 | `lib/services/cache/emby_cache.dart` |
| 响应式布局工具 | `lib/core/responsive/screen_layout.dart` |
| 主题配置 | `lib/core/theme/app_theme.dart` |
| 播放器 ViewModel | `lib/features/player/player_viewmodel.dart` |
| 全局扩展方法 | `lib/core/utils/extensions.dart` |
| 依赖与版本 | `pubspec.yaml` |
| JSON 序列化配置 | `build.yaml` |
| Lint 规则 | `analysis_options.yaml` |
| API 接口文档（中文） | `EMBY_API_DOCUMENTATION.md` |
| 修改守则 | `执行修改守则.md` |
