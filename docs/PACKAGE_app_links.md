> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# app_links ^7.0.0 使用方法

## 1. 概述

`app_links` 是 Flutter 生态中最全面的深度链接处理包。v7.0.0 针对 Flutter 3.38+ 和 iOS UIScene 生命周期进行了适配，支持 Android App Links、Deep Links、iOS Universal Links、Custom URL Schemes 以及桌面端（Windows/macOS/Linux）。

**核心优势：**
- 支持所有 6 大平台（Android/iOS/Web/macOS/Windows/Linux）
- 支持 HTTPS 深度链接和自定义 Scheme
- 流式监听（冷启动 + 热启动）
- 支持 Swift Package Manager（iOS/macOS）

---

## 2. 初始化

```dart
import 'package:app_links/app_links.dart';

class DeepLinkService {
  late final AppLinks _appLinks;
  StreamSubscription? _subscription;

  Future<void> init() async {
    _appLinks = AppLinks();

    // 处理冷启动时的初始链接
    final uri = await _appLinks.getInitialLink();
    if (uri != null) {
      _handleLink(uri);
    }

    // 监听后续链接（热启动）
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  void _handleLink(Uri uri) {
    print('Deep link: $uri');
    // 路由处理...
  }

  void dispose() {
    _subscription?.cancel();
  }
}
```

---

## 3. 平台配置

### 3.1 Android

**AndroidManifest.xml**
```xml
<activity android:name=".MainActivity">
  <!-- 深度链接 -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="yourdomain.com" />
  </intent-filter>

  <!-- 自定义 Scheme -->
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="myapp" android:host="open" />
  </intent-filter>
</activity>
```

**assetlinks.json**（验证域名所有权）
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.example.app",
    "sha256_cert_fingerprints": [
      "AA:BB:CC:DD:..."
    ]
  }
}]
```

### 3.2 iOS

**Info.plist**
```xml
<!-- Universal Links -->
<key>FlutterDeepLinkingEnabled</key>
<false/>  <!-- 禁用 Flutter 原生深度链接，避免冲突 -->

<!-- 自定义 URL Scheme -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

**ios/Runner/Runner.entitlements**
```xml
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:yourdomain.com</string>
</array>
```

**AppDelegate.swift**（v7 推荐）
```swift
import UIKit
import Flutter
import app_links

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 处理冷启动链接
    if let url = AppLinks.shared.getLink(launchOptions: launchOptions) {
      AppLinks.shared.handleLink(url: url)
      return true
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3.3 macOS
配置与 iOS 类似，使用 `RunnerRelease.entitlements` 和 `RunnerDebugProfile.entitlements`。

### 3.4 Windows
Windows 支持 https:// 和自定义 scheme（如 myapp://）。需要在 `windows/runner/main.cpp` 中处理参数（v7 已简化配置）。

### 3.5 Linux
支持自定义 scheme，无需额外配置。

### 3.6 Web
Web 平台仅支持获取初始链接（`getInitialLink()`），流式监听不可用。

---

## 4. 与 GoRouter 集成

```dart
final appLinks = AppLinks();

// 监听深度链接并导航
appLinks.uriLinkStream.listen((uri) {
  // 解析路径
  final path = uri.path; // /detail/123
  final queryParams = uri.queryParameters; // ?ref=email

  // 使用 GoRouter 导航
  navigatorKey.currentContext?.go(path);
});
```

### 统一处理
```dart
void _handleDeepLink(Uri uri) {
  final path = uri.pathSegments;
  
  if (path.isEmpty) return;
  
  switch (path[0]) {
    case 'detail':
      final id = path.length > 1 ? path[1] : '';
      context.go('/detail/$id');
      break;
    case 'player':
      final id = path.length > 1 ? path[1] : '';
      context.go('/player/$id');
      break;
    case 'library':
      final id = path.length > 1 ? path[1] : null;
      if (id != null) {
        context.go('/library/$id');
      } else {
        context.go('/library');
      }
      break;
  }
}
```

---

## 5. 测试深度链接

```bash
# Android
adb shell am start -a android.intent.action.VIEW \
  -d "https://yourdomain.com/detail/123" \
  com.example.app

# iOS
xcrun simctl openurl booted "https://yourdomain.com/detail/123"

# 自定义 Scheme
adb shell am start -a android.intent.action.VIEW \
  -d "myapp://open/detail/123" \
  com.example.app
```

---

## 6. v7 重要变更

| 变更 | 说明 |
|------|------|
| Flutter 3.38.1+ | 最低 Flutter 版本要求 |
| iOS 13+ | 最低 iOS 版本 |
| `allUriLinkStream` → `uriLinkStream` | 统一流名称 |
| `getInitialAppLink` → `getInitialLink` | API 更名 |
| `enabled` flag | 新增禁用自动处理标志 |
| Swift Package Manager | iOS/macOS 支持 SPM |
| Firebase Dynamic Links 移除 | Android 端移除 FDL |

---

## 7. 项目集成建议

当前项目已依赖 `app_links: ^7.0.0` 但未在代码中使用。建议：

1. **实现深度链接导航**：
   - `https://yourdomain.com/detail/:id` → 打开详情页
   - `https://yourdomain.com/player/:id` → 打开播放页
   - `https://yourdomain.com/library/:id` → 打开媒体库

2. **处理分享链接**：支持从外部应用（如浏览器、社交媒体）打开 Emby 内容

3. **与 GoRouter 结合**：在 `main.dart` 中初始化 `AppLinks`，监听到链接后调用 `context.go()`

4. **iOS 配置 `FlutterDeepLinkingEnabled`**：设置为 `false`，避免与 `app_links` 冲突

5. **AppDelegate 更新**：添加冷启动链接处理代码

6. **Web 平台降级**：Web 不支持流式监听，仅支持初始链接，需单独处理
