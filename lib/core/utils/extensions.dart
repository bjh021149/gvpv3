import 'package:flutter/material.dart';

/// ============================
/// BuildContext 扩展
/// ============================

extension BuildContextX on BuildContext {
  /// 当前主题数据
  ThemeData get theme => Theme.of(this);

  /// 当前颜色方案
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// 当前文本主题
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// 当前媒体查询数据
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// 屏幕尺寸
  Size get screenSize => MediaQuery.sizeOf(this);

  /// 屏幕宽度
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// 屏幕高度
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// 设备像素比
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// 顶部安全区域高度
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// 底部安全区域高度
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// 是否处于暗色模式
  bool get isDarkMode {
    final brightness = MediaQuery.platformBrightnessOf(this);
    return brightness == Brightness.dark;
  }

  /// 显示底部 SnackBar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(this);
    scaffoldMessenger.hideCurrentSnackBar();
    return scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// 显示错误 SnackBar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    return showSnackBar(
      message,
      duration: duration,
      backgroundColor: colorScheme.error,
    );
  }

  /// 显示成功 SnackBar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    return showSnackBar(
      message,
      duration: duration,
      backgroundColor: colorScheme.primary,
    );
  }

  /// 导航到指定路由
  Future<T?> push<T>(Widget page) =>
      Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));

  /// 替换当前路由
  Future<T?> pushReplacement<T>(Widget page) => Navigator.of(this)
      .pushReplacement<T, dynamic>(
          MaterialPageRoute(builder: (_) => page));

  /// 返回到上一页
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
}

/// ============================
/// Color 扩展
/// ============================

extension ColorX on Color {
  /// 将颜色转为 RGBA 字符串（用于网络请求等场景）
  String toRgbaString() =>
      'rgba(${r.toInt()}, ${g.toInt()}, ${b.toInt()}, ${a.toStringAsFixed(2)})';

  /// 将颜色转为十六进制字符串
  String toHexString({bool withAlpha = false}) {
    final buffer = StringBuffer('#');
    if (withAlpha) {
      buffer.write(a.toInt().toRadixString(16).padLeft(2, '0'));
    }
    buffer
      ..write(r.toInt().toRadixString(16).padLeft(2, '0'))
      ..write(g.toInt().toRadixString(16).padLeft(2, '0'))
      ..write(b.toInt().toRadixString(16).padLeft(2, '0'));
    return buffer.toString().toUpperCase();
  }

  /// 获取对比色（黑/白），用于在背景色上显示文字
  Color get contrastColor {
    // 计算亮度：Y = 0.299*R + 0.587*G + 0.114*B
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// 轻微加深颜色
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// 轻微提亮颜色
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}

/// ============================
/// String 扩展
/// ============================

extension StringX on String {
  /// 限制字符串长度，超出部分显示省略号
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 驼峰命名转空格分隔（如 "camelCase" -> "Camel Case"）
  String get camelCaseToWords {
    if (isEmpty) return this;
    final result = StringBuffer();
    for (var i = 0; i < length; i++) {
      final char = this[i];
      if (i > 0 && char == char.toUpperCase()) {
        result.write(' ');
      }
      result.write(i == 0 ? char.toUpperCase() : char);
    }
    return result.toString();
  }

  /// 安全的文件名字符（移除不合法字符）
  String get sanitizeFileName {
    return replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }

  /// 检查是否为有效 URL
  bool get isValidUrl {
    final uri = Uri.tryParse(this);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  /// 解析为时长（格式如 "01:23:45" 或 "23:45"）
  Duration? parseDuration() {
    final parts = split(':');
    if (parts.isEmpty || parts.length > 3) return null;

    try {
      final seconds = int.parse(parts.last);
      final minutes = parts.length > 1 ? int.parse(parts[parts.length - 2]) : 0;
      final hours = parts.length > 2 ? int.parse(parts.first) : 0;
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } catch (_) {
      return null;
    }
  }
}

/// ============================
/// Duration 扩展
/// ============================

extension DurationX on Duration {
  /// 格式化为 "HH:MM:SS" 或 "MM:SS"
  String get formatted {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final buffer = StringBuffer();
    if (hours > 0) {
      buffer.write('${hours.toString().padLeft(2, '0')}:');
    }
    buffer
      ..write('${minutes.toString().padLeft(2, '0')}:')
      ..write(seconds.toString().padLeft(2, '0'));

    return buffer.toString();
  }

  /// 格式化为人类可读的短文本
  String get humanReadable {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// ============================
/// DateTime 扩展
/// ============================

extension DateTimeX on DateTime {
  /// 格式化为相对时间（如 "刚刚", "5分钟前", "昨天" 等）
  String toRelativeTime() {
    final now = DateTime.now();
    final diff = now.difference(this);

    return switch (diff) {
      _ when diff.inSeconds < 60 => '刚刚',
      _ when diff.inMinutes < 60 => '${diff.inMinutes}分钟前',
      _ when diff.inHours < 24 && now.day == day => '${diff.inHours}小时前',
      _ when diff.inDays == 1 || (now.difference(this).inHours < 48 && now.day != day) => '昨天',
      _ when diff.inDays < 7 => '${diff.inDays}天前',
      _ when diff.inDays < 30 => '${(diff.inDays / 7).floor()}周前',
      _ when diff.inDays < 365 => '${(diff.inDays / 30).floor()}个月前',
      _ => '${(diff.inDays / 365).floor()}年前',
    };
  }

  /// 格式化为 "YYYY-MM-DD"
  String get toDateString {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

/// ============================
/// List 扩展
/// ============================

extension ListX<T> on List<T> {
  /// 安全地获取元素，越界时返回 null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// 将列表分块
  List<List<T>> chunk(int size) {
    if (size <= 0) throw ArgumentError('Chunk size must be positive');
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, (i + size).clamp(0, length)));
    }
    return result;
  }
}

/// ============================
/// AsyncSnapshot 扩展
/// ============================

extension AsyncSnapshotX<T> on AsyncSnapshot<T> {
  /// 是否为加载中状态
  bool get isLoading => connectionState == ConnectionState.waiting;

  /// 是否为错误状态
  bool get isError => hasError;

  /// 是否已加载数据
  bool get isSuccess => hasData && !hasError;

  /// 安全地获取数据，错误时返回 null
  T? get dataOrNull => hasData ? data : null;
}

/// ============================
/// Widget 扩展
/// ============================

extension WidgetX on Widget {
  /// 包装为 Sliver
  Widget get sliver => SliverToBoxAdapter(child: this);

  /// 包装为可滚动的 Sliver
  Widget sliverPadding(EdgeInsetsGeometry padding) => SliverPadding(
        padding: padding,
        sliver: sliver,
      );

  /// 包装为居中
  Widget get centered => Center(child: this);

  /// 包装为带内边距
  Widget padding(EdgeInsetsGeometry padding) => Padding(
        padding: padding,
        child: this,
      );

  /// 包装为圆角卡片
  Widget card({
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double borderRadius = 12,
    Color? color,
    double? elevation,
  }) {
    Widget result = this;
    if (padding != null) {
      result = Padding(padding: padding, child: result);
    }
    return Card(
      margin: margin,
      color: color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: result,
    );
  }
}

/// ============================
/// Emby 图片 URL 构建工具
/// ============================

/// Emby 图片 URL 构建扩展
///
/// 用于构建符合 Emby API 规范的图片请求 URL。
extension EmbyImageUrl on String {
  /// 构建 Emby 图片 URL
  ///
  /// [serverUrl] Emby 服务器地址（如 "http://192.168.1.100:8096"）
  /// [itemId] 媒体项 ID
  /// [type] 图片类型（Primary, Backdrop, Logo, Thumb 等）
  /// [maxWidth] 最大宽度
  /// [maxHeight] 最大高度
  /// [quality] 图片质量（0-100）
  /// [tag] 图片标签（用于缓存失效）
  static String buildImageUrl({
    required String serverUrl,
    required String itemId,
    String type = 'Primary',
    int? maxWidth,
    int? maxHeight,
    int quality = 90,
    String? tag,
  }) {
    final buffer = StringBuffer();
    buffer.write(serverUrl.endsWith('/') ? serverUrl.substring(0, serverUrl.length - 1) : serverUrl);
    buffer.write('/Items/$itemId/Images/$type');

    final queryParams = <String, String>{
      'quality': quality.toString(),
    };
    if (maxWidth != null) queryParams['maxWidth'] = maxWidth.toString();
    if (maxHeight != null) queryParams['maxHeight'] = maxHeight.toString();
    if (tag != null) queryParams['tag'] = tag;

    if (queryParams.isNotEmpty) {
      buffer.write('?');
      buffer.write(queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&'));
    }

    return buffer.toString();
  }

  /// 构建用户头像 URL
  static String buildUserImageUrl({
    required String serverUrl,
    required String userId,
  }) {
    final base = serverUrl.endsWith('/') ? serverUrl.substring(0, serverUrl.length - 1) : serverUrl;
    return '$base/emby/Users/$userId/Images/Primary';
  }
}

/// ============================
/// 数值格式化扩展
/// ============================

extension NumX on num {
  /// 格式化为文件大小字符串（B, KB, MB, GB）
  String get fileSize {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    if (unitIndex == 0) {
      return '${size.toInt()} ${units[unitIndex]}';
    }
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// 格式化为带千分位分隔符的字符串
  String get formatted => toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}
