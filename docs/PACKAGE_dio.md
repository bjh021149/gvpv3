> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# dio ^5.9.2 使用方法

## 1. 概述

`dio` 是 Flutter/Dart 生态中最强大的 HTTP 客户端。v5.9.2 提供了拦截器、请求取消、文件上传下载、全局配置等丰富功能，适合构建复杂的网络层。

**核心优势：**
- 拦截器机制（请求/响应/错误拦截）
- 全局配置与单请求覆盖
- 自动 JSON 转换
- 文件上传/下载进度监听
- 请求取消（CancelToken）

---

## 2. 基础配置

### 2.1 创建 Dio 实例
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  sendTimeout: Duration(seconds: 30),
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
  responseType: ResponseType.json,
  // 自定义状态码校验
  validateStatus: (status) => status != null && status < 500,
));
```

### 2.2 单例模式（推荐）
```dart
class DioClient {
  DioClient._();
  
  static Dio? _instance;
  
  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }
  
  static Dio _createDio() {
    final dio = Dio(BaseOptions(/* ... */));
    dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(),
      RetryInterceptor(dio: dio),
    ]);
    return dio;
  }
}
```

---

## 3. 拦截器（Interceptors）

### 3.1 认证拦截器
```dart
class AuthInterceptor extends Interceptor {
  final SecureStorage storage;
  
  AuthInterceptor(this.storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read(key: 'token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token 过期，尝试刷新
      try {
        final newToken = await _refreshToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        
        // 重试原请求
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (_) {
        // 刷新失败，跳转登录
        _redirectToLogin();
      }
    }
    handler.next(err);
  }
}
```

### 3.2 日志拦截器
```dart
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  logPrint: (obj) => debugPrint(obj.toString()),
));
```

### 3.3 自定义拦截器（打印 + 错误处理）
```dart
class CustomLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('➡️ REQUEST [${options.method}] ${options.path}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) debugPrint('Body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('✅ RESPONSE [${response.statusCode}] ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ ERROR [${err.response?.statusCode}] ${err.requestOptions.path}');
    debugPrint('Message: ${err.message}');
    handler.next(err);
  }
}
```

---

## 4. 请求方法

### 4.1 GET / POST / PUT / DELETE
```dart
// GET
final response = await dio.get('/users');
final users = (response.data as List).map((e) => User.fromJson(e)).toList();

// GET with query params
final response = await dio.get('/users', queryParameters: {
  'page': 1,
  'limit': 20,
});

// POST
final response = await dio.post('/users', data: {
  'name': 'John',
  'email': 'john@example.com',
});

// PUT
await dio.put('/users/1', data: {'name': 'Jane'});

// DELETE
await dio.delete('/users/1');
```

### 4.2 表单提交
```dart
// x-www-form-urlencoded
await dio.post('/login', data: {
  'username': 'john',
  'password': 'secret',
}, options: Options(contentType: Headers.formUrlEncodedContentType));

// multipart/form-data（文件上传）
final formData = FormData.fromMap({
  'name': 'John',
  'file': await MultipartFile.fromFile('./image.jpg', filename: 'image.jpg'),
});
await dio.post('/upload', data: formData);
```

---

## 5. 文件下载与进度

### 5.1 下载文件
```dart
await dio.download(
  'https://example.com/file.zip',
  './downloads/file.zip',
  onReceiveProgress: (received, total) {
    if (total != -1) {
      final progress = (received / total * 100).toStringAsFixed(0);
      print('Download progress: $progress%');
    }
  },
);
```

### 5.2 上传文件带进度
```dart
await dio.post(
  '/upload',
  data: formData,
  onSendProgress: (sent, total) {
    print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
  },
);
```

---

## 6. 请求取消

```dart
final cancelToken = CancelToken();

// 发起请求
dio.get('/long-request', cancelToken: cancelToken);

// 取消请求
cancelToken.cancel('User cancelled');

// 批量取消（页面 dispose 时）
class ApiService {
  final List<CancelToken> _tokens = [];
  
  Future<Response> fetchData() async {
    final token = CancelToken();
    _tokens.add(token);
    try {
      return await dio.get('/data', cancelToken: token);
    } finally {
      _tokens.remove(token);
    }
  }
  
  void cancelAll() {
    for (final token in _tokens) {
      token.cancel('Service disposed');
    }
    _tokens.clear();
  }
}
```

---

## 7. 错误处理

### 7.1 DioException 类型
```dart
try {
  await dio.get('/data');
} on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      print('Timeout');
      break;
    case DioExceptionType.badResponse:
      print('Server error: ${e.response?.statusCode}');
      break;
    case DioExceptionType.cancel:
      print('Request cancelled');
      break;
    case DioExceptionType.connectionError:
      print('No internet');
      break;
    default:
      print('Unknown error: ${e.message}');
  }
}
```

### 7.2 统一异常封装
```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
}

extension DioErrorHandler on DioException {
  ApiException toApiException() {
    return switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        ApiException('请求超时，请检查网络'),
      DioExceptionType.connectionError =>
        ApiException('网络连接失败'),
      DioExceptionType.badResponse =>
        ApiException('服务器错误: ${response?.statusCode}'),
      _ => ApiException(message ?? '未知错误'),
    };
  }
}
```

---

## 8. 证书与自签名证书

### 8.1 信任自签名证书（开发环境）
```dart
import 'dart:io';
import 'package:dio/io.dart';

final dio = Dio();

(dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) {
    // ⚠️ 生产环境应校验 host 白名单
    return true;
  };
  return client;
};
```

### 8.2 带白名单的证书校验（推荐）
```dart
final _allowedHosts = {'192.168.1.100', 'localhost', 'myserver.local'};

client.badCertificateCallback = (cert, host, port) {
  return _allowedHosts.contains(host);
};
```

---

## 9. 测试

### 9.1 Mock Dio 拦截器
```dart
class MockDioAdapter extends HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/users') {
      return ResponseBody.fromString(
        jsonEncode([{'id': 1, 'name': 'Test'}]),
        200,
      );
    }
    return ResponseBody.fromString('{}', 404);
  }

  @override
  void close({bool force = false}) {}
}

// 使用
dio.httpClientAdapter = MockDioAdapter();
```

---

## 10. 项目集成建议

当前项目 Dio 配置基础良好，但存在以下改进空间：

1. **统一 Dio 创建逻辑**：`AuthRepositoryImpl._createDio()` 和 `DioClient.create()` 代码重复，应提取到单一 Factory
2. **认证请求统一走 Dio**：`AuthRepositoryImpl.authenticate()` 直接使用 `HttpClient`，应改用 Dio
3. **添加重试拦截器**：引入 `dio_smart_retry` 处理网络抖动
4. **白名单证书校验**：当前无条件信任所有证书，应添加 host 白名单
5. **添加请求取消机制**：页面 dispose 时自动取消进行中的请求
