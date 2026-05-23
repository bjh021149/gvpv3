# 登录页（LoginPage）API 调用流程

**页面**: `LoginPage` (`/login`)
**核心文件**: `lib/features/auth/login_page.dart` + `auth_viewmodel.dart`

---

## 一、服务器配置

在进入登录页之前，用户需要先配置服务器地址。此步骤在 `ServerConfigPage` 中完成：

### 1.1 测试服务器连接

```
GET /System/Info/Public
```

| 参数 | 说明 |
|------|------|
| 无 query 参数 | 公共 API，无需认证 |

**用途**: 验证服务器地址是否正确，获取服务器基本信息（名称、版本等）。

**响应示例**:
```json
{
  "ServerName": "Emby Server",
  "Version": "4.8.0.0"
}
```

---

## 二、登录认证流程

### 2.1 AuthenticateByName

```
POST /Users/AuthenticateByName
Content-Type: application/x-www-form-urlencoded
```

| Body 参数 | 值 | 说明 |
|----------|-----|------|
| `Username` | 用户名 | 如 `haoyuzhishijie` |
| `Pw` | 密码 | 明文密码 |

**Header**:
```
Authorization: MediaBrowser Client=EmbyClient, Device=Test, DeviceId=test123, Version=1.0.0
```

**用途**: 用户名+密码认证，获取 AccessToken 和 UserId。

**响应**:
```json
{
  "User": {
    "Id": "1f0c64ccceb84bf0826518adfe5af2a4",
    "Name": "haoyuzhishijie"
  },
  "AccessToken": "c1d80a4f785447e19549ff467fab4fb3"
}
```

**本地存储**: Token 和 UserId 存入 `flutter_secure_storage`（加密存储）。

---

### 2.2 保存认证信息

```dart
await secureStorage.write(key: 'token', value: accessToken);
await secureStorage.write(key: 'userId', value: userId);
await secureStorage.write(key: 'serverUrl', value: serverUrl);
```

**用途**: 持久化认证信息，下次启动自动登录。

---

### 2.3 初始化 Dio Auth Interceptor

登录成功后，Dio 的 AuthInterceptor 会自动注入 Token 到后续请求中：

```dart
// lib/core/api/dio_client.dart
Dio(options)
  ..interceptors.add(AuthInterceptor(
    getToken: () => secureStorage.read('token'),
    getUserId: () => secureStorage.read('userId'),
  ));
```

**后续所有 API 请求自动携带**: `X-Emby-Token: {token}` 和 `X-Emby-UserId: {userId}`。

---

### 2.4 导航到首页

```dart
context.go('/home');
```

清除登录页路由栈，导航到首页。

---

## 三、自动登录流程

App 启动时，在 `main.dart` 中尝试自动登录：

```dart
// 1. 读取本地存储的认证信息
final token = await secureStorage.read('token');
final userId = await secureStorage.read('userId');
final serverUrl = await secureStorage.read('serverUrl');

// 2. 如果有认证信息，初始化 Dio 并验证 Token
if (token != null && userId != null) {
  dio.options.baseUrl = serverUrl;
  // 后续页面会自动使用 token
}
```

**注意**: 当前实现没有验证 Token 是否过期。如果 Token 过期，首次 API 请求会返回 401，AuthInterceptor 会导航到 `/login`。

---

## 四、登出流程

在 `SettingsPage` 中：

```dart
// 1. 清除本地存储
await secureStorage.deleteAll();

// 2. 清除缓存
await cache.clearAll();

// 3. 导航到登录页
context.go('/login');
```

---

## 五、关键参数速查表

| API | 参数 | 值 | 说明 |
|-----|------|-----|------|
| `GET /System/Info/Public` | 无 | — | 公共 API，测试连接 |
| `POST /Users/AuthenticateByName` | `Username` | body | 用户名 |
| `POST /Users/AuthenticateByName` | `Pw` | body | 密码 |
| `POST /Users/AuthenticateByName` | `Authorization` | header | 设备信息 |
