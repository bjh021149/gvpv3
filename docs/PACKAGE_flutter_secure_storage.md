> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# flutter_secure_storage ^10.2.0 使用方法

## 1. 概述

`flutter_secure_storage` 是 Flutter 生态中存储敏感数据的标准方案。v10.2.0 是重大更新版本，Android 端弃用了已废弃的 Jetpack Security 库，改用自定义 RSA OAEP + AES-GCM 加密实现，并新增生物识别认证支持。

**核心变更（v10）：**
- Android：弃用 `encryptedSharedPreferences`，改用 RSA OAEP + AES-GCM
- 新增生物识别认证支持（`AndroidOptions.biometric()`）
- 自动迁移旧加密数据
- 支持 WASM（Web 平台）
- 新增 `storageNamespace` 实现多实例隔离

---

## 2. 基础用法

### 2.1 默认实例
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 默认：RSA OAEP + AES-GCM（推荐）
const storage = FlutterSecureStorage();

// 读写
await storage.write(key: 'token', value: 'abc123');
final token = await storage.read(key: 'token');
await storage.delete(key: 'token');
await storage.deleteAll();

// 检查存在
final hasToken = await storage.containsKey(key: 'token');

// 读取全部
final all = await storage.readAll();
```

---

## 3. Android 配置

### 3.1 默认配置（无需 EncryptedSharedPreferences）
```dart
const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(),
);
```

### 3.2 生物识别认证（可选）
```dart
const storage = FlutterSecureStorage(
  aOptions: AndroidOptions.biometric(
    enforceBiometrics: false, // false = 无生物识别时回退到普通加密
    biometricPromptTitle: 'Authenticate to access data',
  ),
);

// 严格生物识别（必须设置 PIN/指纹/面部）
const strictStorage = FlutterSecureStorage(
  aOptions: AndroidOptions.biometric(
    enforceBiometrics: true, // true = 必须生物识别
  ),
);
```

### 3.3 迁移旧数据（从 v9 升级）
```dart
const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    migrateOnAlgorithmChange: true, // 自动迁移（默认开启）
    migrateWithBackup: true,        // 带备份的安全迁移
  ),
);
```

### 3.4 多实例隔离（namespace）
```dart
// 不同 namespace 完全隔离
const authStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(storageNamespace: 'auth'),
);
const cacheStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(storageNamespace: 'cache'),
);
```

### 3.5 AndroidManifest 配置
```xml
<application
  android:allowBackup="false"  <!-- 禁用自动备份，避免密钥恢复异常 -->
  ...>
</application>
```

---

## 4. iOS/macOS 配置

### 4.1 基础配置
```dart
const storage = FlutterSecureStorage(
  iOptions: IOSOptions(
    accountName: 'com.example.myapp', // Keychain 分组
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false, // 是否 iCloud 同步
    // useSecureEnclave: true, // 硬件级安全（v10.1+）
  ),
);
```

### 4.2 KeychainAccessibility 级别
| 级别 | 说明 |
|------|------|
| `after_first_unlock` | 设备首次解锁后可访问 |
| `when_unlocked` | 仅设备解锁时可访问 |
| `when_passcode_set_this_device_only` | 最高安全，不迁移 |
| `first_unlock_this_device` | 首次解锁，仅限本设备 |

### 4.3 监听数据可用性变化（iOS）
```dart
storage.onCupertinoProtectedDataAvailabilityChanged.listen((available) {
  if (!available) {
    // 设备被锁，敏感数据不可访问
    _handleLockedState();
  }
});
```

### 4.4 Entitlements 配置
```xml
<!-- ios/Runner/DebugProfile.entitlements 和 Release.entitlements -->
<key>keychain-access-groups</key>
<array/>

<!-- 如果使用 App Groups： -->
<key>keychain-access-groups</key>
<array>
  <string>$(AppIdentifierPrefix)your.group.name</string>
</array>
```

---

## 5. Web 平台配置

```dart
const storage = FlutterSecureStorage(
  webOptions: WebOptions(
    useSessionStorage: false, // false = localStorage, true = sessionStorage
  ),
);
```

**注意：** Web 端使用 WebCrypto，密钥由浏览器生成，加密数据**不可跨浏览器/设备迁移**。

---

## 6. 与 Riverpod 集成

```dart
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accountName: 'com.example.app',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
});

final tokenProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return storage.read(key: 'access_token');
});
```

---

## 7. 异常处理

```dart
try {
  await storage.write(key: 'token', value: 'secret');
} on PlatformException catch (e) {
  if (e.code == 'BadPaddingException') {
    // 密钥损坏，重置存储
    await storage.deleteAll();
  } else if (e.code == 'UserCanceled') {
    // 用户取消生物识别
  } else {
    // 其他错误
    print('SecureStorage error: ${e.message}');
  }
}
```

---

## 8. 项目集成建议

当前项目已正确使用 `flutter_secure_storage`。建议改进：

1. **移除 `encryptedSharedPreferences`**：v10 已弃用，当前代码中 `AndroidOptions(encryptedSharedPreferences: true)` 会在升级时自动迁移，但应更新为新的构造函数
2. **添加 `migrateWithBackup: true`**：生产环境安全迁移
3. **使用 `storageNamespace`**：如果有多个存储实例，使用 namespace 隔离
4. **iOS 添加 `useSecureEnclave`**：v10.1+ 支持硬件级安全
5. **监听 `onCupertinoProtectedDataAvailabilityChanged`**：处理 iOS 设备锁定状态
6. **Web 平台检查**：确保 Web 端 HTTPS 环境（`flutter_secure_storage` 仅工作在安全上下文中）
