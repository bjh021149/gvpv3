/// 服务器配置页面
///
/// 应用启动后的首个页面，用于配置 Emby 服务器地址。
/// 提供深色渐变背景和居中的配置卡片。
library;

import 'package:emby_client/features/auth/auth_viewmodel.dart';
import 'package:emby_client/services/repositories/auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 服务器配置页面路由路径
const serverConfigRoute = '/server-config';

/// 服务器配置页面
///
/// 深色渐变背景 + 居中卡片，包含:
/// - 服务器地址输入框（带 URL 格式校验）
/// - 连接按钮（触发导航到登录页）
///
/// 使用 [ConsumerWidget] + [authViewModelProvider] 监听认证状态。
///
/// 路由配置示例:
/// ```dart
/// GoRoute(
///   path: serverConfigRoute,
///   builder: (context, state) => const ServerConfigPage(),
/// ),
/// ```
class ServerConfigPage extends ConsumerWidget {
  /// 创建服务器配置页面
  const ServerConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听认证状态变化
    ref.listen(authViewModelProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          // 显示错误提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('连接失败: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      );
    });

    return Scaffold(
      body: Container(
        // 深色渐变背景
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0D0D), // 近黑色顶部
              Color(0xFF1A1A2E), // 深蓝黑色中部
              Color(0xFF16213E), // 深蓝底部
            ],
          ),
        ),
        child: const SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: _ServerConfigCard(),
            ),
          ),
        ),
      ),
    );
  }
}

/// 服务器配置卡片
///
/// 内部 Widget，包含表单和连接按钮。
class _ServerConfigCard extends ConsumerStatefulWidget {
  const _ServerConfigCard();

  @override
  ConsumerState<_ServerConfigCard> createState() => _ServerConfigCardState();
}

class _ServerConfigCardState extends ConsumerState<_ServerConfigCard> {
  /// 表单全局键
  final _formKey = GlobalKey<FormState>();

  /// 服务器地址控制器
  final _serverUrlController = TextEditingController();

  /// 表单焦点节点
  final _urlFocusNode = FocusNode();

  /// 自动验证模式
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _serverUrlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  /// URL 格式校验
  ///
  /// 支持 http:// 和 https:// 前缀，验证基本 URL 结构。
  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入服务器地址';
    }

    final trimmed = value.trim();

    // 协议校验
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return '地址必须以 http:// 或 https:// 开头';
    }

    // URI 格式校验
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) {
      return '请输入有效的服务器地址';
    }

    return null;
  }

  /// 处理连接按钮点击
  ///
  /// 验证表单后保存服务器地址并导航到登录页面。
  void _onConnect() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    if (!_formKey.currentState!.validate()) return;

    final serverUrl = _serverUrlController.text.trim();

    // 持久化保存服务器地址
    await ref.read(authRepositoryProvider).setServerUrl(serverUrl);

    // 导航到登录页面
    if (mounted) {
      context.push('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2D), // 深色卡片背景
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo / Icon
            Icon(
              Icons.tv_rounded,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // 标题
            Text(
              '连接服务器',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 副标题
            Text(
              '输入您的 Emby 服务器地址以继续',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),

            // 服务器地址输入框
            TextFormField(
              controller: _serverUrlController,
              focusNode: _urlFocusNode,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onFieldSubmitted: (_) => _onConnect(),
              decoration: InputDecoration(
                labelText: '服务器地址',
                hintText: 'http://192.168.1.100:8096',
                prefixIcon: const Icon(Icons.link_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
              validator: _validateUrl,
            ),
            const SizedBox(height: 24),

            // 连接按钮
            _buildConnectButton(),
          ],
        ),
      ),
    );
  }

  /// 构建连接按钮
  ///
  /// 根据认证状态显示不同内容:
  /// - 加载中: 圆形进度条
  /// - 默认: "连接" 按钮
  Widget _buildConnectButton() {
    final authAsync = ref.watch(authViewModelProvider);

    return authAsync.maybeWhen(
      loading: () => FilledButton.icon(
        onPressed: null,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
        label: const Text('连接中...'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      orElse: () => FilledButton.icon(
        onPressed: _onConnect,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text(
          '连接',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
