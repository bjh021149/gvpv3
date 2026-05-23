import 'package:emby_client/features/settings/about_app_section.dart';
import 'package:emby_client/features/settings/cache_management.dart';
import 'package:emby_client/features/settings/server_connection_editor.dart';
import 'package:emby_client/features/settings/settings_viewmodel.dart';
import 'package:emby_client/features/settings/theme_mode_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 设置页面（主组装页）
///
/// 使用 ResponsiveNav 作为壳层，包含主题选择、服务器连接、
/// 缓存管理、关于应用和退出登录等功能区块。
class SettingsPage extends ConsumerWidget {
  /// 创建设置页面
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: 'Settings page title',
          child: Text(
            'Settings',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                // Appearance
                const ThemeModeSelector(),
                // Playback settings (placeholder)
                _buildPlaybackSettingsGroup(context, colorScheme, textTheme),
                // Server connection
                const ServerConnectionEditor(),
                // Cache management
                const CacheManagement(),
                // About
                const AboutAppSection(),
                const SizedBox(height: 16),
                // Logout
                _buildLogoutButton(context, ref, colorScheme, textTheme),
                const SizedBox(height: 32),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  /// 播放设置区块（预留）
  Widget _buildPlaybackSettingsGroup(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Semantics(
      label: '播放设置',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '播放',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.speed,
                    color: colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                ),
                title: Text(
                  '默认播放速度',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  '1.0x',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: () => _showPlaybackSpeedDialog(context),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.high_quality_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                title: Text(
                  '默认画质',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  '自动',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 退出登录按钮
  Widget _buildLogoutButton(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Semantics(
        label: '退出登录按钮',
        button: true,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: colorScheme.errorContainer.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(
            Icons.logout,
            color: colorScheme.error,
          ),
          title: Text(
            '退出登录',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '清除登录状态并返回登录页',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.error,
          ),
          onTap: () => _showLogoutConfirm(context, ref),
        ),
      ),
    );
  }

  /// 显示退出登录确认对话框
  Future<void> _showLogoutConfirm(BuildContext context, WidgetRef ref) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('退出登录'),
          ],
        ),
        content: Text(
          '确定要退出登录吗？退出后将清除所有登录状态并返回登录页面。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('退出登录'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(settingsViewModelProvider.notifier).logout();
      // 导航到登录页
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  /// 显示播放速度选择对话框（预留）
  void _showPlaybackSpeedDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('默认播放速度'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: speeds.length,
            itemBuilder: (context, index) {
              final speed = speeds[index];
              final isSelected = speed == 1.0;
              return ListTile(
                title: Text('${speed}x'),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  // 预留：更新播放速度设置
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
