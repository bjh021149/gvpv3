import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Material Design 3 断点定义
///
/// 参考：
/// - compact: < 600dp（手机）
/// - medium: 600dp ~ 839dp（小平板/折叠屏）
/// - expanded: 840dp ~ 1199dp（平板/小桌面）
/// - large: 1200dp ~ 1599dp（桌面）
/// - extraLarge: >= 1600dp（大桌面）
enum ScreenType { compact, medium, expanded, large, extraLarge }

/// 屏幕布局信息
///
/// 封装当前设备的屏幕类型和尺寸信息，提供响应式判断的便捷属性。
///
/// 使用示例：
/// ```dart
/// final layout = ScreenLayout.of(context);
/// if (layout.isDesktop) {
///   return DesktopView();
/// }
/// return MobileView();
/// ```
@immutable
class ScreenLayout {
  /// 当前屏幕类型
  final ScreenType type;

  /// 当前屏幕尺寸
  final Size size;

  const ScreenLayout({required this.type, required this.size});

  /// 从 [BuildContext] 获取当前布局信息
  ///
  /// 基于 [MediaQuery.sizeOf] 获取屏幕宽度，根据 Material Design 3 断点规则分类。
  static ScreenLayout of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    return ScreenLayout(
      type: switch (width) {
        < 600 => ScreenType.compact,
        < 840 => ScreenType.medium,
        < 1200 => ScreenType.expanded,
        < 1600 => ScreenType.large,
        _ => ScreenType.extraLarge,
      },
      size: size,
    );
  }

  /// 屏幕宽度
  double get width => size.width;

  /// 屏幕高度
  double get height => size.height;

  /// 是否为横屏
  bool get isLandscape => size.width > size.height;

  /// 是否为竖屏
  bool get isPortrait => size.width <= size.height;

  // --- 屏幕类型判断 ---

  /// 手机尺寸（< 600dp）
  bool get isCompact => type == ScreenType.compact;

  /// 小平板/折叠屏（600dp ~ 839dp）
  bool get isMedium => type == ScreenType.medium;

  /// 平板/小桌面（840dp ~ 1199dp）
  bool get isExpanded => type == ScreenType.expanded;

  /// 桌面（1200dp ~ 1599dp）
  bool get isLarge => type == ScreenType.large;

  /// 大桌面（>= 1600dp）
  bool get isExtraLarge => type == ScreenType.extraLarge;

  // --- 设备类别快捷判断 ---

  /// 是否为手机
  bool get isMobile => isCompact;

  /// 是否为平板（含小平板）
  bool get isTablet => isMedium || isExpanded;

  /// 是否为桌面设备
  bool get isDesktop => isLarge || isExtraLarge;

  /// 是否为大屏幕（平板+桌面）
  bool get isLargeScreen => isMedium || isExpanded || isLarge || isExtraLarge;

  // --- 网格布局参数 ---

  /// 根据屏幕类型返回网格列数
  ///
  /// 适用于海报/卡片等固定宽高比的网格视图。
  int get gridCrossAxisCount => switch (type) {
        ScreenType.compact => 2,
        ScreenType.medium => 3,
        ScreenType.expanded => 4,
        ScreenType.large => 5,
        ScreenType.extraLarge => 6,
      };

  /// 根据屏幕类型返回网格子项宽高比
  ///
  /// 值越小表示子项越高（纵向更长），适用于海报类内容。
  double get gridChildAspectRatio => switch (type) {
        ScreenType.compact => 0.65,
        ScreenType.medium => 0.7,
        ScreenType.expanded => 0.72,
        ScreenType.large => 0.75,
        ScreenType.extraLarge => 0.78,
      };

  /// 水平方向内边距
  ///
  /// 大屏幕使用更多留白。
  double get horizontalPadding => switch (type) {
        ScreenType.compact => 16.0,
        ScreenType.medium => 24.0,
        ScreenType.expanded => 32.0,
        ScreenType.large => 48.0,
        ScreenType.extraLarge => 64.0,
      };

  /// 内容最大宽度
  ///
  /// 用于限制大屏幕上的内容区域宽度，保持阅读体验。
  double? get maxContentWidth => switch (type) {
        ScreenType.compact => null, // 手机全宽
        ScreenType.medium => 720.0,
        ScreenType.expanded => 960.0,
        ScreenType.large => 1200.0,
        ScreenType.extraLarge => 1440.0,
      };

  /// 导航栏类型
  ///
  /// 手机使用底部导航栏，平板/桌面使用侧边导航栏。
  NavigationType get navigationType => switch (type) {
        ScreenType.compact => NavigationType.bottom,
        ScreenType.medium => NavigationType.rail,
        ScreenType.expanded => NavigationType.rail,
        ScreenType.large => NavigationType.drawer,
        ScreenType.extraLarge => NavigationType.drawer,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScreenLayout && other.type == type && other.size == size;
  }

  @override
  int get hashCode => Object.hash(type, size);

  @override
  String toString() => 'ScreenLayout(type: $type, ${size.width.toInt()}x${size.height.toInt()})';
}

/// 导航栏类型枚举
enum NavigationType {
  /// 底部导航栏（手机）
  bottom,

  /// 导航轨道（小平板/折叠屏）
  rail,

  /// 侧边抽屉（桌面）
  drawer,
}

/// 屏幕布局 Provider
///
/// ⚠️ 注意：此 Provider 需要在 Widget build 中通过 [ScreenLayout.of(context)] 覆盖：
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   final layout = ScreenLayout.of(context);
///   return ProviderScope(
///     overrides: [
///       screenLayoutProvider.overrideWithValue(layout),
///     ],
///     child: const MyApp(),
///   );
/// }
/// ```
final screenLayoutProvider = Provider<ScreenLayout>((ref) {
  throw UnimplementedError(
    'Override with ScreenLayout.of(context) in build method',
  );
});

/// 当前屏幕类型 Provider
final screenTypeProvider = Provider<ScreenType>((ref) {
  return ref.watch(screenLayoutProvider).type;
});

/// 是否为桌面设备 Provider
final isDesktopProvider = Provider<bool>((ref) {
  return ref.watch(screenLayoutProvider).isDesktop;
});

/// 是否为手机设备 Provider
final isMobileProvider = Provider<bool>((ref) {
  return ref.watch(screenLayoutProvider).isMobile;
});

/// 导航栏类型 Provider
final navigationTypeProvider = Provider<NavigationType>((ref) {
  return ref.watch(screenLayoutProvider).navigationType;
});
