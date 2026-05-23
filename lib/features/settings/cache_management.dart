import 'package:emby_client/features/settings/settings_viewmodel.dart';
import 'package:emby_client/services/cache/emby_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 缓存管理组件
///
/// 显示各 Hive Box 的条目统计并提供清除缓存功能。
class CacheManagement extends ConsumerStatefulWidget {
  /// 创建缓存管理组件
  const CacheManagement({super.key});

  @override
  ConsumerState<CacheManagement> createState() => _CacheManagementState();
}

class _CacheManagementState extends ConsumerState<CacheManagement> {
  bool _isClearing = false;

  Map<String, int> get _stats => ref.read(embyCacheProvider).stats();

  int get _totalEntries {
    return _stats.values.fold(0, (sum, count) => sum + count);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stats = _stats;
    final total = _totalEntries;

    return Semantics(
      label: '缓存管理',
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
                    Icons.storage,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '数据缓存',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 统计信息
              ...stats.entries.where((e) => e.value > 0).map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _boxNameToLabel(e.key),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${e.value} 条',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (total == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '暂无缓存数据',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image,
                    color: colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ),
                title: Text(
                  '缓存条目',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  total > 0 ? '共 $total 条缓存数据' : '缓存为空',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: _isClearing
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : FilledButton.tonalIcon(
                        onPressed: total > 0 ? _showClearConfirm : null,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('清除'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _boxNameToLabel(String key) {
    return switch (key) {
      'core' => '核心数据',
      'userdata' => '播放进度',
      'genres' => '类型标签',
      'studios' => '制片公司',
      'providerIds' => '外部平台ID',
      'people' => '演职员',
      'mediaSources' => '媒体源',
      'listIndices' => '列表索引',
      'listMeta' => '列表元数据',
      _ => key,
    };
  }

  Future<void> _showClearConfirm() async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('确认清除'),
          ],
        ),
        content: Text(
          '确定要清除所有数据缓存吗？已缓存的媒体元数据需要重新从服务器获取。',
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
            child: const Text('清除缓存'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _clearCache();
    }
  }

  Future<void> _clearCache() async {
    setState(() => _isClearing = true);

    try {
      await ref.read(settingsViewModelProvider.notifier).clearCache();

      if (mounted) {
        setState(() => _isClearing = false);

        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '缓存已清除',
              style: TextStyle(color: colorScheme.onInverseSurface),
            ),
            backgroundColor: colorScheme.inverseSurface,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isClearing = false);

        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '清除缓存失败: $e',
              style: TextStyle(color: colorScheme.onError),
            ),
            backgroundColor: colorScheme.errorContainer,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
