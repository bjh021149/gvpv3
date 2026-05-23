import 'package:emby_client/core/responsive/screen_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 响应式导航组件，根据屏幕尺寸自适应切换底部栏/侧边栏/抽屉导航。
class ResponsiveNav extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const ResponsiveNav({
    super.key,
    required this.body,
    required this.currentIndex,
  });

  static const destinations = [
    NavigationDestination(
      icon: Icon(Icons.home),
      label: '首页',
      tooltip: '首页',
    ),
    NavigationDestination(
      icon: Icon(Icons.video_library),
      label: '媒体库',
      tooltip: '媒体库',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings),
      label: '设置',
      tooltip: '设置',
    ),
  ];

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/library');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = ScreenLayout.of(context);

    // compact: BottomNavigationBar
    if (layout.isCompact) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => _onDestinationSelected(context, i),
          destinations: destinations,
        ),
      );
    }

    // medium: NavigationRail
    if (layout.isMedium) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (i) => _onDestinationSelected(context, i),
              destinations:
                  destinations
                      .map(
                        (d) => NavigationRailDestination(
                          icon: d.icon,
                          label: Text(d.label),
                        ),
                      )
                      .toList(),
              labelType: NavigationRailLabelType.all,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // expanded+: NavigationDrawer
    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => _onDestinationSelected(context, i),
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Emby Client',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ...destinations.asMap().entries.map(
                (e) => NavigationDrawerDestination(
                  icon: e.value.icon,
                  label: Text(e.value.label),
                ),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
