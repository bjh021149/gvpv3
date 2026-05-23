import 'package:emby_client/features/settings/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 主题模式选择器组件
///
/// 提供跟随系统 / 亮色 / 暗色 / OLED 四种主题模式切换
class ThemeModeSelector extends ConsumerWidget {
  /// 创建一个主题模式选择器
  const ThemeModeSelector({super.key});

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => '跟随系统',
      ThemeMode.light => '亮色',
      ThemeMode.dark => '暗色',
    };
  }

  IconData _themeModeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.brightness_high,
      ThemeMode.dark => Icons.brightness_2,
    };
  }

  static const List<ThemeMode> _modes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark,
    // OLED 模式通过 ThemeMode.dark + 特殊 OLED theme 实现
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final settingsAsync = ref.watch(settingsViewModelProvider);

    return Semantics(
      label: '外观设置',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '外观',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              settingsAsync.when(
                data: (settings) => _buildModeSelector(
                  context,
                  ref,
                  settings.themeMode,
                  colorScheme,
                  textTheme,
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    if (isDesktop) {
      return SegmentedButton<ThemeMode>(
        segments: _modes.map((mode) {
          return ButtonSegment<ThemeMode>(
            value: mode,
            label: Text(_themeModeLabel(mode)),
            icon: Icon(_themeModeIcon(mode)),
          );
        }).toList(),
        selected: {currentMode},
        onSelectionChanged: (selected) {
          if (selected.isNotEmpty) {
            _onThemeModeChanged(ref, selected.first);
          }
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chipWidth = (constraints.maxWidth - 12) / 3;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _modes.map((mode) {
            final isSelected = mode == currentMode;
            return SizedBox(
              width: chipWidth,
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _themeModeIcon(mode),
                      size: 16,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _themeModeLabel(mode),
                      style: textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => _onThemeModeChanged(ref, mode),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _onThemeModeChanged(WidgetRef ref, ThemeMode mode) {
    ref.read(settingsViewModelProvider.notifier).setThemeMode(mode);
  }
}
