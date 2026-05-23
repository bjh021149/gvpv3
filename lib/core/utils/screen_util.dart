// utils/screen.dart
import 'dart:ui';

import 'package:flutter/widgets.dart';



/// 屏幕静态工具类
class Screen {
  Screen._();

  /// 获取当前应用的第一个 FlutterView，它代表了设备的主屏幕。
  static FlutterView get _view =>
      WidgetsBinding.instance.platformDispatcher.views.first;

  /// 屏幕物理宽度 (px)
  static double get physicalWidth => _view.physicalSize.width;

  /// 屏幕物理高度 (px)
  static double get physicalHeight => _view.physicalSize.height;

  /// 设备像素比 (物理像素 / 逻辑像素)
  static double get pixelRatio => _view.devicePixelRatio;

  /// 屏幕逻辑宽度 (dp)
  static double get width => physicalWidth / pixelRatio;

  /// 屏幕逻辑高度 (dp)
  static double get height => physicalHeight / pixelRatio;

  /// 是否为竖屏
  static bool get isPortrait => height >= width;

  /// 是否为横屏
  static bool get isLandscape => width > height;

  /// 是否为平板 (最短边 >= 600)
  static bool get isTablet {
    final shortest = width < height ? width : height;
    return shortest >= 600;
  }

  /// 顶部安全区域高度 (状态栏)
  static double get paddingTop => _view.padding.top / pixelRatio;

  /// 底部安全区域高度
  static double get paddingBottom => _view.padding.bottom / pixelRatio;
}


