import 'package:emby_client/features/settings/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 关于应用组件
///
/// 显示应用名称、版本号、开源许可和 GitHub 链接
class AboutAppSection extends ConsumerWidget {
  /// 创建关于应用组件
  const AboutAppSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final settingsAsync = ref.watch(settingsViewModelProvider);

    return Semantics(
      label: '关于应用',
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
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '关于',
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
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.app_shortcut,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Emby Client',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  '跨平台媒体播放器',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.new_releases_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                title: Text(
                  '版本号',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: settingsAsync.when(
                  data: (settings) => Text(
                    'v${settings.appVersion ?? '1.0.0'}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  loading: () => SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                  error: (_,_) =>  const Text('v1.0.0'),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.balance_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                title: Text(
                  '开源许可',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  '查看第三方开源库许可',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: () => _showLicensePage(context),
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.code,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                title: Text(
                  'GitHub',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  '查看源代码',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: () => _openGitHub(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLicensePage(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Emby Client',
      applicationVersion: '1.0.0',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(16),
        child: Icon(
          Icons.play_circle_fill,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      applicationLegalese: 'Copyright 2024 Emby Client',
    );
  }

  void _openGitHub(BuildContext context) {
    // 预留：通过 url_launcher 打开 GitHub 仓库
    // final uri = Uri.parse('https://github.com/your-org/emby-client');
    // launchUrl(uri, mode: LaunchMode.externalApplication);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'GitHub 链接功能预留中',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
