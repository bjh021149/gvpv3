> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# flex_color_scheme ^8.4.0 使用方法

## 1. 概述

`flex_color_scheme`（FCS）是 Flutter 生态中最强大的主题生成包。v8.4.0 完全适配 Flutter 3.38+ 的 Material 3 规范，提供比 Flutter 原生 `ColorScheme.fromSeed` 更丰富的主题定制能力。

**核心优势：**
- 预置 36+ 套配色方案
- 独立种子色控制（primary/secondary/tertiary/error 可分别设定种子色）
- 9 种表面颜色混合模式
- 完整组件子主题定制
- 支持动态取色（Android 12+）

---

## 2. 基础用法

### 2.1 快速创建主题
```dart
import 'package:flex_color_scheme/flex_color_scheme.dart';

ThemeData lightTheme = FlexThemeData.light(
  scheme: FlexScheme.blue, // 使用预置方案
  useMaterial3: true,
);

ThemeData darkTheme = FlexThemeData.dark(
  scheme: FlexScheme.blue,
  useMaterial3: true,
);
```

### 2.2 动态种子色
```dart
ThemeData lightTheme = FlexThemeData.light(
  colors: FlexSchemeColor.from(
    primary: Colors.teal,
    secondary: Colors.amber,
  ),
  useMaterial3: true,
);
```

---

## 3. 高级主题定制

### 3.1 表面颜色混合
```dart
ThemeData theme = FlexThemeData.light(
  scheme: FlexScheme.blue,
  // 表面混合模式
  surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
  blendLevel: 10, // 混合强度 0-40
  // AppBar 样式
  appBarStyle: FlexAppBarStyle.surface,
  appBarOpacity: 0.95,
  // 使用 Material 3 错误颜色
  useMaterial3ErrorColors: true,
);
```

**surfaceMode 选项：**
| 模式 | 效果 |
|------|------|
| `level` | 基础混合 |
| `highBackgroundLowScaffold` | 高背景低脚手架 |
| `highScaffoldLowSurface` | 高脚手架低表面（推荐） |
| `highScaffoldLevelSurface` | 高脚手架分级表面 |

### 3.2 组件子主题
```dart
ThemeData theme = FlexThemeData.light(
  scheme: FlexScheme.blue,
  subThemesData: FlexSubThemesData(
    // 交互效果
    interactionEffects: true,
    tintedDisabledControls: true,
    // 圆角配置
    defaultRadius: 12.0,
    cardRadius: 12.0,
    dialogRadius: 16.0,
    bottomSheetRadius: 20.0,
    // 输入框
    inputDecoratorRadius: 12.0,
    inputDecoratorUnfocusedHasBorder: false,
    // 按钮
    elevatedButtonRadius: 12.0,
    outlinedButtonRadius: 12.0,
    textButtonRadius: 8.0,
    // 开关/复选框
    switchSchemeColor: SchemeColor.primary,
    checkboxSchemeColor: SchemeColor.primary,
    radioSchemeColor: SchemeColor.primary,
    // AppBar
    appBarCenterTitle: true,
  ),
);
```

### 3.3 导航栏主题
```dart
FlexSubThemesData(
  // 底部导航栏
  bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
  bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
  bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurfaceVariant,
  
  // NavigationRail
  navigationRailBackgroundSchemeColor: SchemeColor.surface,
  navigationRailLabelSchemeColor: SchemeColor.onSurface,
  
  // NavigationDrawer
  navigationDrawerBackgroundSchemeColor: SchemeColor.surfaceContainerLow,
)
```

---

## 4. Material 3 动态取色

### 4.1 使用系统动态颜色（Android 12+）
```dart
ThemeData lightTheme = FlexThemeData.light(
  scheme: FlexScheme.materialBaseline,
  useMaterial3: true,
  // 自动使用系统动态颜色
  useMaterial3ErrorColors: true,
);
```

### 4.2 自定义 DynamicSchemeVariant
```dart
ThemeData theme = FlexThemeData.light(
  colors: FlexSchemeColor.from(
    primary: seedColor,
    secondary: seedColor.withOpacity(0.8),
  ),
  // 使用 Flutter 原生的动态变体
  variant: DynamicSchemeVariant.tonalSpot, // 或 .fidelity, .vibrant, .expressive
  useMaterial3: true,
);
```

**DynamicSchemeVariant 选项：**
- `tonalSpot`：标准 Material 3（默认）
- `fidelity`：高保真，更鲜艳
- `vibrant`：活力，更饱和
- `expressive`：表现力，更大胆
- `content`：内容驱动
- `monochrome`：单色

---

## 5. FlexTones 自定义调色

```dart
// 使用预定义 FlexTones
ThemeData theme = FlexThemeData.light(
  scheme: FlexScheme.blue,
  tones: FlexTones.vivid(Brightness.light), // 鲜艳
  // 或 FlexTones.soft(Brightness.light)     // 柔和
  // 或 FlexTones.ultraContrast(Brightness.light) // 超高对比
);

// 完全自定义
ThemeData customTheme = FlexThemeData.light(
  colors: FlexSchemeColor.from(primary: Colors.blue),
  tones: FlexTones.custom(
    chroma: 50, // 色度目标
    primaryTone: 40, // primary 映射的色调
    onPrimaryTone: 100,
    primaryContainerTone: 90,
    // ... 更多色调映射
  ),
);
```

---

## 6. 与 ThemeData.copyWith 结合

```dart
final baseTheme = FlexThemeData.light(
  scheme: FlexScheme.blue,
  useMaterial3: true,
);

// 进一步微调
final theme = baseTheme.copyWith(
  scaffoldBackgroundColor: Colors.grey[50],
  textTheme: baseTheme.textTheme.copyWith(
    headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.bold,
    ),
  ),
);
```

---

## 7. Themes Playground

FlexColorScheme 提供在线配置工具 [Themes Playground](https://rydmike.com/flexcolorscheme/themesplayground-v8)，可以：
1. 可视化调整所有参数
2. 实时预览主题效果
3. 一键导出 Dart 代码

---

## 8. v8 迁移要点（从 v7 升级）

| v7 | v8 | 说明 |
|----|----|------|
| `useFlutterDefaults` | 已移除 | M3 默认使用 Flutter 默认值 |
| `useTextTheme` | `useMaterial3Typography` | 更名 |
| `blendTextTheme` | 已弃用 | 不再生效 |
| `primaryVariant` | `primaryContainer` | 命名统一 |
| `secondaryVariant` | `secondaryContainer` | 命名统一 |
| `FlexSubThemes.bottomNavigationBar` | `FlexSubThemes.bottomNavigationBarTheme` | 更名 |

---

## 9. 项目集成建议

当前项目已正确使用 FlexColorScheme。建议改进：

1. **更新 `interactionEffects` / `tintedDisabledControls` 默认值**：v8 默认改为 `false`，如需保持 v7 效果需显式设为 `true`
2. **使用 `DynamicSchemeVariant`**：替换简单的 `FlexSchemeColor.from`，体验更丰富的 Material 3 调色
3. **NavigationDrawer 宽度**：v8 默认改为 304dp，如需 360dp 需显式配置
4. **考虑 `useMaterial3Typography`**：显式开启 M3 字体排版
5. **Dialog/Drawer 背景色**：v8 默认使用 `surfaceContainerHigh` / `surfaceContainerLow`，检查是否符合预期
