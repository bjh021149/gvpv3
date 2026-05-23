> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# go_router ^17.2.3 使用方法

## 1. 概述

`go_router` 是 Flutter 官方推荐的声明式路由包。v17.2.3 支持 `StatefulShellRoute.indexedStack`、类型安全路由（`go_router_builder`）、深度链接等现代特性。

**核心优势：**
- 声明式路由配置，URL 驱动导航
- 内置 `StatefulShellRoute` 支持底部导航栏状态保持
- 深度链接支持（Android App Links / iOS Universal Links）
- 与 `flutter_riverpod` 无缝集成

---

## 2. 基础路由配置

### 2.1 声明式路由
```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailPage(id: id);
      },
    ),
  ],
);

// 使用 MaterialApp.router
MaterialApp.router(
  routerConfig: router,
);
```

### 2.2 三种导航方式
```dart
// go() — 替换整个导航栈，用于顶级导航
context.go('/home');

// push() — 压入新页面，用户可以返回
context.push('/detail/123');

// pushReplacement() — 替换当前页面，不添加新栈
context.pushReplacement('/login');
```

---

## 3. StatefulShellRoute（底部/侧边导航）

### 3.1 基础配置
```dart
final router = GoRouter(
  initialLocation: '/home',
  routes: [
    // 认证路由（无壳层）
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    
    // 主壳层路由（带底部导航）
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNav(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    
    // 全屏路由（跳出壳层）
    GoRoute(
      path: '/player/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => PlayerPage(id: state.pathParameters['id']!),
    ),
  ],
);
```

### 3.2 Scaffold 实现
```dart
class ScaffoldWithNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNav({required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.library_music), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

---

## 4. 认证守卫与重定向

### 4.1 基础重定向
```dart
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authService.isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) return '/login';
    if (isLoggedIn && isLoggingIn) return '/home';
    return null; // 不重定向
  },
  routes: [ /* ... */ ],
);
```

### 4.2 响应式重定向（配合 Riverpod）
```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    refreshListenable: authNotifier, // 状态变化时重新评估 redirect
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isLoggedIn;
      final isAuthRoute = state.matchedLocation == '/login' ||
                          state.matchedLocation == '/';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [ /* ... */ ],
  );
});
```

### 4.3 登录后返回原页面
```dart
redirect: (context, state) {
  final isLoggedIn = ref.read(authNotifierProvider).isLoggedIn;
  final isLoggingIn = state.matchedLocation == '/login';

  // 保存目标地址
  final from = state.uri.queryParameters['from'];

  if (!isLoggedIn) return isLoggingIn ? null : '/login?from=${state.matchedLocation}';
  if (isLoggingIn) return from ?? '/home';
  return null;
},
```

---

## 5. 类型安全路由（go_router_builder）

### 5.1 定义路由
```dart
// lib/routes.dart
import 'package:go_router/go_router.dart';

part 'routes.g.dart'; // build_runner 生成

@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

@TypedGoRoute<DetailRoute>(path: '/detail/:id')
class DetailRoute extends GoRouteData {
  final String id;
  const DetailRoute({required this.id});

  @override
  Widget build(BuildContext context, GoRouterState state) => DetailPage(id: id);
}
```

### 5.2 使用
```dart
// 替代字符串导航
HomeRoute().go(context);
DetailRoute(id: '123').push(context);

// 替代 context.go('/detail/123')
```

### 5.3 生成命令
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 6. 自定义转场动画

```dart
GoRoute(
  path: '/detail/:id',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      key: state.pageKey, // 重要！用于区分页面
      child: DetailPage(id: state.pathParameters['id']!),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  },
),
```

** tab 切换禁用动画：**
```dart
GoRoute(
  path: '/home',
  pageBuilder: (context, state) => const NoTransitionPage(
    child: HomePage(),
  ),
),
```

---

## 7. 深度链接

### 7.1 Android 配置
```xml
<!-- AndroidManifest.xml -->
<activity>
  <meta-data
    android:name="flutter_deeplinking_enabled"
    android:value="true" />
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="yourdomain.com" />
  </intent-filter>
</activity>
```

### 7.2 iOS 配置
```xml
<!-- Info.plist -->
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

### 7.3 测试
```bash
# Android
adb shell am start -a android.intent.action.VIEW \
  -d "https://yourdomain.com/detail/123" \
  com.example.app

# iOS
xcrun simctl openurl booted "https://yourdomain.com/detail/123"
```

---

## 8. 项目集成建议

当前项目已正确使用 `StatefulShellRoute.indexedStack` + `GoRouter` + `Riverpod` 组合。建议改进：

1. **添加 `refreshListenable`**：当前 `routerProvider` 使用 `ref.watch(authRepositoryProvider)` 在 redirect 中异步检查认证状态。建议改用 `refreshListenable` + `Listenable` 模式，避免每次导航都触发异步读取
2. **引入 `go_router_builder`**：将 `/detail/:id` 和 `/player/:id` 改为类型安全路由
3. **统一返回按钮逻辑**：详情页不同场景下的返回行为应统一
4. **设置页移除 `ResponsiveNav`**：与外层 `StatefulShellRoute` 冲突
