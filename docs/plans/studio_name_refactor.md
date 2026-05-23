# StudioName 组件重构计划

## 目标

1. 新建 `StudioName` 组件（类似 `LogoTitle`），优先用图片显示 studio，无图则显示文字 name
2. `MetadataChips` 中移除 studio chips
3. `StudioSection` 改用 `StudioName` 组件显示制片公司

## 修改文件清单（4 个）

### 1. 新建 `lib/features/detail/studio_name.dart`

接收 `BaseItemDto studio`，逻辑：
- 若 `studio.id != null` → `EmbyCachedImage(imageTagList: [Primary, Thumb])`
- 图片加载失败 → `errorWidget` 显示 `studio.name` 文字
- 若 `studio.id == null` → 直接显示 `studio.name` 文字

```dart
class StudioName extends StatelessWidget {
  final BaseItemDto studio;
  final double? maxWidth;
  final double? maxHeight;
  final TextStyle? textStyle;
  ...
}
```

### 2. 修改 `lib/features/detail/metadata_chips.dart`

删除 "Studio chips" 段落（约 13 行）：
```dart
// Studio chips
final studios = item.studios;
if (studios != null && studios.isNotEmpty) {
  for (final studio in studios) {
    ...
  }
}
```

### 3. 修改 `lib/features/detail/studio_section.dart`

- 删除 `studios` 参数（只保留 `studioDetails`）
- 删除 `_buildStudioImages` 和 `_buildStudioChips` 两个私有方法
- 改为直接用 `StudioName` 组件横向排列：

```dart
class StudioSection extends StatelessWidget {
  final List<BaseItemDto> studioDetails;
  const StudioSection({required this.studioDetails});

  @override
  Widget build(BuildContext context) {
    if (studioDetails.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        const SectionHeader(title: '制片公司'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: studioDetails.map((s) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: StudioName(studio: s),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
```

### 4. 修改 `lib/features/detail/detail_page.dart`

`StudioSection` 调用处去掉 `studios` 参数：
```dart
StudioSection(studioDetails: state.studioDetails)
```

## 实现步骤

1. 新建 `studio_name.dart`
2. 修改 `metadata_chips.dart` 删除 studio chips
3. 重写 `studio_section.dart`
4. 修改 `detail_page.dart` 调整 `StudioSection` 传参
