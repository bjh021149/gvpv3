import 'package:emby_client/features/library/library_viewmodel.dart';
import 'package:emby_client/features/library/view_mode_toggle.dart';
import 'package:flutter/material.dart';

/// A filter and sort toolbar for the library screen.
///
/// Provides controls for:
/// - Sorting items via a [SegmentedButton]
/// - Toggling between grid and list view modes
/// - Opening a filter dialog
class FilterSortBar extends StatelessWidget {
  final SortOption currentSort;
  final ViewMode currentViewMode;
  final ValueChanged<SortOption> onSortChanged;
  final ValueChanged<ViewMode> onViewModeChanged;
  final VoidCallback? onFilterPressed;

  const FilterSortBar({
    super.key,
    required this.currentSort,
    required this.currentViewMode,
    required this.onSortChanged,
    required this.onViewModeChanged,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Sort segmented button
          Expanded(
            child: Semantics(
              label: '排序选项',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<SortOption>(
                  segments: const [
                    ButtonSegment<SortOption>(
                      value: SortOption.name,
                      label: Text('名称'),
                      tooltip: '按名称排序',
                    ),
                    ButtonSegment<SortOption>(
                      value: SortOption.dateAdded,
                      label: Text('添加时间'),
                      tooltip: '按添加时间排序',
                    ),
                    ButtonSegment<SortOption>(
                      value: SortOption.rating,
                      label: Text('评分'),
                      tooltip: '按评分排序',
                    ),
                    ButtonSegment<SortOption>(
                      value: SortOption.year,
                      label: Text('年份'),
                      tooltip: '按年份排序',
                    ),
                  ],
                  selected: <SortOption>{currentSort},
                  onSelectionChanged: (selected) {
                    if (selected.isNotEmpty) {
                      onSortChanged(selected.first);
                    }
                  },
                  emptySelectionAllowed: false,
                  multiSelectionEnabled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter button
          Semantics(
            button: true,
            label: '打开筛选',
            child: IconButton(
              onPressed: onFilterPressed,
              icon: const Icon(Icons.filter_list),
              tooltip: '筛选内容',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // View mode toggle
          ViewModeToggle(
            currentMode: currentViewMode,
            onChanged: onViewModeChanged,
          ),
        ],
      ),
    );
  }
}
