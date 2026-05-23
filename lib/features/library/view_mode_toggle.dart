import 'package:emby_client/features/library/library_viewmodel.dart';
import 'package:flutter/material.dart';

/// A toggle button that switches between grid and list view modes.
///
/// Uses an [AnimatedSwitcher] to smoothly transition between icons
/// when the view mode changes.
class ViewModeToggle extends StatelessWidget {
  final ViewMode currentMode;
  final ValueChanged<ViewMode> onChanged;

  const ViewModeToggle({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: '视图模式: ${currentMode.label}',
      button: true,
      child: PopupMenuButton<ViewMode>(
        tooltip: '切换视图模式',
        initialValue: currentMode,
        onSelected: onChanged,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Icon(
            currentMode == ViewMode.grid ? Icons.grid_view : Icons.view_list,
            key: ValueKey<ViewMode>(currentMode),
          ),
        ),
        itemBuilder: (context) {
          return [
            PopupMenuItem<ViewMode>(
              value: ViewMode.grid,
              child: ListTile(
                leading: Icon(
                  Icons.grid_view,
                  color:
                      currentMode == ViewMode.grid
                          ? colorScheme.primary
                          : null,
                ),
                title: Text(
                  ViewMode.grid.label,
                  style: TextStyle(
                    color:
                        currentMode == ViewMode.grid
                            ? colorScheme.primary
                            : null,
                    fontWeight:
                        currentMode == ViewMode.grid
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
                trailing:
                    currentMode == ViewMode.grid
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            PopupMenuItem<ViewMode>(
              value: ViewMode.list,
              child: ListTile(
                leading: Icon(
                  Icons.view_list,
                  color:
                      currentMode == ViewMode.list
                          ? colorScheme.primary
                          : null,
                ),
                title: Text(
                  ViewMode.list.label,
                  style: TextStyle(
                    color:
                        currentMode == ViewMode.list
                            ? colorScheme.primary
                            : null,
                    fontWeight:
                        currentMode == ViewMode.list
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
                trailing:
                    currentMode == ViewMode.list
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ];
        },
      ),
    );
  }
}
