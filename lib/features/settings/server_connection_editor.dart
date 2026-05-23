import 'package:emby_client/features/settings/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 服务器连接编辑器组件
///
/// 显示当前服务器地址，支持编辑和测试连接
class ServerConnectionEditor extends ConsumerStatefulWidget {
  /// 创建服务器连接编辑器
  const ServerConnectionEditor({super.key});

  @override
  ConsumerState<ServerConnectionEditor> createState() =>
      _ServerConnectionEditorState();
}

class _ServerConnectionEditorState
    extends ConsumerState<ServerConnectionEditor> {
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final settingsAsync = ref.watch(settingsViewModelProvider);

    return Semantics(
      label: '服务器连接设置',
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
                    Icons.dns,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '服务器',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              settingsAsync.when(
                data: (settings) => _buildServerTile(
                  context,
                  settings.serverUrl,
                  colorScheme,
                  textTheme,
                ),
                loading: () => const ListTile(
                  leading: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  title: Text('加载中...'),
                ),
                error: (_, __) => const ListTile(
                  leading: Icon(Icons.error_outline),
                  title: Text('加载失败'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerTile(
    BuildContext context,
    String? serverUrl,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final hasServer = serverUrl != null && serverUrl.isNotEmpty;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasServer
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasServer ? Icons.check_circle : Icons.warning,
              color: hasServer
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
              size: 20,
            ),
          ),
          title: Text(
            hasServer ? '已连接' : '未配置',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            serverUrl ?? '点击编辑服务器地址',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasServer) ...[
                _isTesting
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : IconButton(
                        onPressed: () => _testConnection(serverUrl),
                        icon: const Icon(Icons.network_check),
                        tooltip: '测试连接',
                        color: colorScheme.primary,
                      ),
                const SizedBox(width: 8),
              ],
              IconButton(
                onPressed: () => _showEditDialog(serverUrl),
                icon: const Icon(Icons.edit),
                tooltip: '编辑服务器地址',
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _testConnection(String serverUrl) async {
    setState(() => _isTesting = true);

    final success = await ref
        .read(settingsViewModelProvider.notifier)
        .testConnection(serverUrl);

    if (mounted) {
      setState(() => _isTesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                success ? '连接成功' : '连接失败',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ],
          ),
          backgroundColor: success
              ? Theme.of(context).colorScheme.inverseSurface
              : Theme.of(context).colorScheme.errorContainer,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showEditDialog(String? currentUrl) async {
    final controller = TextEditingController(text: currentUrl ?? '');
    final colorScheme = Theme.of(context).colorScheme;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑服务器地址'),
        content: Semantics(
          label: '服务器地址输入框',
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'https://your-server.com:8096',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;
    if (!mounted) return;

    await ref
        .read(settingsViewModelProvider.notifier)
        .updateServerUrl(result);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '服务器地址已更新',
          style: TextStyle(color: colorScheme.onInverseSurface),
        ),
        backgroundColor: colorScheme.inverseSurface,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
