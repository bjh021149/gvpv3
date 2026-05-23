import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

/// 认证信息解密工具
///
/// 用于在集成测试中自动解密 `test/authInfo.txt.enc` 文件。
/// 密钥通过固定密码派生，与 Python 加密脚本保持一致。
///
/// 使用方式：
/// ```dart
/// final authInfo = await AuthInfoDecryptor.load();
/// print(authInfo.serverUrl);
/// ```
class AuthInfoDecryptor {
  /// 固定密钥（与 Python 加密脚本使用相同的密码派生）
  ///
  /// Python 端：
  /// ```python
  /// password = b'emby-client-test-key-2026'
  /// key = base64.urlsafe_b64encode(hashlib.sha256(password).digest())
  /// ```
  static final _key = Key.fromBase64(
    'PoP-4HO6kPfCttrXfE2PJ3buy0v0QbEWF-H7O8DY0g0=',
  );

  /// 加密文件路径（相对于项目根目录）
  static const _encFilePath = 'test/authInfo.txt.enc';

  /// 加载并解密认证信息
  static Future<AuthInfo> load() async {
    final encFile = File(_encFilePath);
    if (!encFile.existsSync()) {
      throw const FileSystemException(
        '加密认证文件不存在，请确保 $_encFilePath 存在',
        _encFilePath,
      );
    }

    final encryptedBase64 = (await encFile.readAsString()).trim();

    // Python Fernet 输出的是 base64 url-safe 编码的字符串
    // 先解码为 bytes，再用 Fernet 解密
    final encryptedBytes = base64Url.decode(encryptedBase64);
    final encrypted = Encrypted(Uint8List.fromList(encryptedBytes));

    final fernet = Fernet(_key);
    final decrypted = fernet.decrypt(encrypted);

    return AuthInfo._fromPlaintext(utf8.decode(decrypted));
  }
}

/// 认证信息数据类
class AuthInfo {
  final String serverUrl;
  final String username;
  final String password;

  const AuthInfo({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  factory AuthInfo._fromPlaintext(String text) {
    final lines = text.trim().split('\n');
    final map = <String, String>{};

    for (final line in lines) {
      final parts = line.split('=');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }

    return AuthInfo(
      serverUrl: map['serverUrl'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
    );
  }

  @override
  String toString() {
    return 'AuthInfo(serverUrl: $serverUrl, username: $username, password: ***)';
  }
}
