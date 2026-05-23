# 设置页（SettingsPage）API 调用流程

**页面**: `SettingsPage` (`/settings`)
**核心文件**: `lib/features/settings/settings_page.dart`

---

## 一、页面结构

设置页包含以下 Section，大部分为纯本地操作：

| Section | 操作 | 是否涉及 API |
|---------|------|-------------|
| 服务器连接 | 编辑/测试服务器地址 | ✅ 测试连接 |
| 缓存管理 | 查看/清除缓存 | ✅ 清除缓存 |
| 主题设置 | 切换亮/暗/跟随系统 | ❌ 纯本地 |
| 关于应用 | 显示版本信息 | ❌ 纯本地 |
| 退出登录 | 清除认证 + 缓存 | ✅ 清除所有数据 |

---

## 二、服务器连接编辑

### 2.1 测试新服务器地址

```
GET {newServerUrl}/System/Info/Public
```

| 参数 | 说明 |
|------|------|
| 无 query 参数 | 公共 API，无需认证 |

**用途**: 用户修改服务器地址后，点击"测试连接"验证新地址是否可用。

**成功**: 保存新地址到 `flutter_secure_storage`，Dio baseUrl 更新。

**失败**: 显示错误提示，不保存。

---

## 三、缓存管理

### 3.1 查看缓存统计

```dart
final stats = ref.read(embyCacheProvider).stats();
```

**返回**: 各 box 的条目数
```dart
{
  'core': 1523,
  'userdata': 1523,
  'genres': 482,
  'studios': 1205,
  'providerIds': 1523,
  'people': 890,
  'mediaSources': 1523,
  'listIndices': 45,
  'listMeta': 45,
}
```

---

### 3.2 清除缓存

```dart
await ref.read(embyCacheProvider).clearAll();
```

**操作**: 清空所有 Hive box（`_core`, `_userdata`, `_genres`, `_studios`, `_providerIds`, `_people`, `_mediaSources`, `_listIndices`, `_listMeta`）。

**注意**: 不清除认证信息（Token / UserId）。

---

## 四、退出登录

### 4.1 清除认证信息

```dart
await secureStorage.deleteAll();
```

**操作**: 删除 `token`, `userId`, `serverUrl` 等所有加密存储的数据。

---

### 4.2 清除缓存

```dart
await ref.read(embyCacheProvider).clearAll();
```

**操作**: 同 3.2，清空所有 Hive box。

---

### 4.3 导航到登录页

```dart
context.go('/login');
```

**操作**: 清除当前路由栈，导航到登录页。

---

## 五、关键参数速查表

| 操作 | API/方法 | 说明 |
|------|---------|------|
| 测试服务器 | `GET /System/Info/Public` | 公共 API |
| 查看缓存 | `EmbyCache.stats()` | 本地方法 |
| 清除缓存 | `EmbyCache.clearAll()` | 本地方法 |
| 退出登录 | `secureStorage.deleteAll()` | 本地方法 |
