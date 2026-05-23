import 'package:emby_client/app_shell.dart';
import 'package:emby_client/features/auth/login_page.dart';
import 'package:emby_client/features/auth/server_config_page.dart';
import 'package:emby_client/features/detail/detail_page.dart';
import 'package:emby_client/features/detail/related_items_page.dart';
import 'package:emby_client/features/home/home_page.dart';
import 'package:emby_client/features/library/library_page.dart';
import 'package:emby_client/features/player/player_page.dart';
import 'package:emby_client/features/settings/settings_page.dart';
import 'package:emby_client/services/navigation_history_service.dart';
import 'package:emby_client/services/repositories/auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// GoRouter Provider
///
/// 通过 Riverpod 管理路由实例，支持依赖注入和响应式刷新。
/// 包含认证状态重定向逻辑，确保未认证用户只能访问认证相关页面。
///
/// 路由结构：
/// ```
/// /           → 服务器配置页面（未认证入口）
/// /login      → 登录页面
/// /home       → 首页（带底部导航）
/// /library    → 媒体库（带底部导航）
/// /settings   → 设置（带底部导航）
/// /detail/:id → 详情页（独立页面）
/// /player/:id → 播放页（独立页面）
/// ```
final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      // 记录导航历史
      ref.read(navigationHistoryProvider).onLocationChanged(state.matchedLocation);

      final isAuthenticated = await authRepo.isAuthenticated();

      final isAuthRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/login';

      // 未认证用户只能访问认证相关页面
      if (!isAuthenticated && !isAuthRoute) return '/';
      // 已认证用户访问认证页面时重定向到首页
      if (isAuthenticated && isAuthRoute) return '/home';

      return null;
    },
    routes: [
      // === 认证路由（无底部导航） ===
      GoRoute(
        path: '/',
        builder: (context, state) => const ServerConfigPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // === 主壳层路由（带响应式导航） ===
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // 首页分支
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // 媒体库分支
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                name: 'library',
                builder: (context, state) => const LibraryPage(),
                routes: [
                  GoRoute(
                    path: ':parentId',
                    builder: (context, state) {
                      final parentId = state.pathParameters['parentId']!;
                      return LibraryPage(parentId: parentId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // 设置分支
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // === 独立页面（无底部导航） ===
      GoRoute(
        path: '/detail/:id',
        name: 'detail',
        builder: (context, state) {
          final itemId = state.pathParameters['id']!;
          return DetailPage(itemId: itemId);
        },
      ),
      GoRoute(
        path: '/player/:id',
        name: 'player',
        builder: (context, state) {
          final itemId = state.pathParameters['id']!;
          
          return PlayerPage(
            itemId: itemId,

          );
        },
      ),
      GoRoute(
        path: '/related',
        name: 'related',
        builder: (context, state) {
          final query = state.uri.queryParameters;
          return RelatedItemsPage(
            title: query['title'] ?? '关联作品',
            studioId: query['studioId'],
            personId: query['personId'],
            genre: query['genre'],
          );
        },
      ),
    ],

    // 错误页面配置
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
