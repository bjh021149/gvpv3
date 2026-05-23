import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 应用壳层组件
///
/// 基于 [StatefulNavigationShell] 构建的响应式应用外壳，根据屏幕尺寸
/// 自动适配三种导航模式：
///
/// 1. **紧凑模式**（手机 < 600dp）：底部 [NavigationBar]
/// 2. **中等模式**（小平板 600dp ~ 839dp）：侧边 [NavigationRail]
/// 3. **扩展模式**（平板/桌面 >= 840dp）：侧边 [NavigationDrawer]
///
/// 通过 [ScreenLayout.of(context)] 动态获取屏幕类型进行响应式判断。
///
/// 使用示例：
/// ```dart
/// StatefulShellRoute.indexedStack(
///   builder: (context, state, navigationShell) {
///     return AppShell(navigationShell: navigationShell);
///   },
///   ...
/// )
/// ```
class AppShell extends StatelessWidget {
  /// 由 [StatefulShellRoute] 提供的导航壳层
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  /// 处理导航目标选择事件
  ///
  /// 通过 [navigationShell.goBranch] 切换分支，保留各分支导航历史。
  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // 使用初始位置避免重复压栈
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = ScreenLayout.of(context);

    // 紧凑布局：底部导航栏（手机）
    if (layout.isCompact) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
              tooltip: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.video_library_outlined),
              selectedIcon: Icon(Icons.video_library),
              label: 'Library',
              tooltip: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
              tooltip: 'Settings',
            ),
          ],
        ),
      );
    }

    // 中等布局：侧边导航轨道（小平板/折叠屏）
    if (layout.isMedium) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.video_library_outlined),
                  selectedIcon: Icon(Icons.video_library),
                  label: Text('Library'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    // 扩展/大桌面布局：侧边导航抽屉（平板/桌面）
    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.play_circle_filled,
                        size: 32, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Emby Client',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              NavigationDrawerDestination(
                icon: Icon(Icons.home_outlined),
                label: Text('Home'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.video_library_outlined),
                label: Text('Library'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.settings_outlined),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
