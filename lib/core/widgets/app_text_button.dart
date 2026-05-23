import 'package:flutter/material.dart';

/// 按钮变体类型。
enum AppButtonVariant { text, outlined, filled }

/// 应用通用文字按钮，基于 Material 3 风格设计。
///
/// 支持三种变体：
/// - [AppButtonVariant.text]：纯文字按钮，无边框和背景
/// - [AppButtonVariant.outlined]：带边框的轮廓按钮
/// - [AppButtonVariant.filled]：填充背景色按钮
///
/// 颜色和文字样式均从当前 [ThemeData] / [ColorScheme] 获取，
/// 可通过 [foregroundColor] / [backgroundColor] 覆盖。
///
/// 典型用法：
/// ```dart
/// AppTextButton(
///   label: '轨道',
///   variant: AppButtonVariant.outlined,
///   onPressed: () => _showTrackDialog(context),
/// )
/// ```
class AppTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final AppButtonVariant variant;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const AppTextButton({
    super.key,
    this.onPressed,
    required this.label,
    this.icon,
    this.variant = AppButtonVariant.text,
    this.foregroundColor,
    this.backgroundColor,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final fg = foregroundColor ?? colorScheme.primary;
    final bg = backgroundColor ?? colorScheme.primary;

    final buttonStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: WidgetStateProperty.all(
        padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      fixedSize: WidgetStateProperty.all(
        width != null || height != null
            ? Size(width ?? double.infinity, height ?? 36)
            : null,
      ),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return fg.withValues(alpha: 0.38);
        }
        return fg;
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (variant != AppButtonVariant.filled) return null;
        if (states.contains(WidgetState.disabled)) {
          return bg.withValues(alpha: 0.12);
        }
        return bg;
      }),
      overlayColor: WidgetStateProperty.all(fg.withValues(alpha: 0.08)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      side: variant == AppButtonVariant.outlined
          ? WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return BorderSide(color: fg.withValues(alpha: 0.12));
              }
              return BorderSide(color: fg.withValues(alpha: 0.5));
            })
          : null,
      textStyle: WidgetStateProperty.all(
        theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );

    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 6),
        ],
        Text(label),
      ],
    );

    switch (variant) {
      case AppButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child,
        );
      case AppButtonVariant.filled:
        return FilledButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child,
        );
    }
  }
}
