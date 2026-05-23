/// 登录页面
///
/// 用户输入凭据完成认证的页面。
/// 显示服务器地址、用户名/密码输入框，以及登录按钮。
library;

import 'package:emby_client/features/auth/auth_viewmodel.dart';
import 'package:emby_client/services/repositories/auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 登录页面路由路径
const loginRoute = '/login';

/// 登录页面
///
/// 提供用户认证功能:
/// - 顶部 AppBar 显示目标服务器地址
/// - 用户名和密码输入框
/// - 登录按钮（带加载状态）
/// - 错误提示（SnackBar）
/// - 成功后导航到首页
class LoginPage extends ConsumerWidget {
  /// 创建登录页面
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.read(authRepositoryProvider).getServerUrl() ?? '';

    // 监听认证状态，处理导航和错误提示
    ref.listen(authViewModelProvider, (previous, next) {
      next.whenOrNull(
        data: (state) {
          if (state.isAuthenticated) {
            // 认证成功，导航到首页
            context.go('/home');
          }
        },
        error: (error, _) {
          // 显示错误 SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Theme.of(context).colorScheme.onError,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '登录失败: $error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
        // 显示服务器地址作为副标题
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.dns_rounded,
                  size: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  serverUrl,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        // 深色渐变背景
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _LoginForm(serverUrl: serverUrl),
            ),
          ),
        ),
      ),
    );
  }
}

/// 登录表单
///
/// 内部 Widget，包含用户名/密码输入和登录按钮。
class _LoginForm extends ConsumerStatefulWidget {
  /// 目标服务器地址
  final String serverUrl;

  const _LoginForm({required this.serverUrl});

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  /// 表单全局键
  final _formKey = GlobalKey<FormState>();

  /// 用户名控制器
  final _usernameController = TextEditingController();

  /// 密码控制器
  final _passwordController = TextEditingController();

  /// 用户名焦点节点
  final _usernameFocusNode = FocusNode();

  /// 密码焦点节点
  final _passwordFocusNode = FocusNode();

  /// 是否隐藏密码
  bool _obscurePassword = true;

  /// 自动验证模式
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// 用户名校验
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入用户名';
    }
    if (value.trim().length < 2) {
      return '用户名至少 2 个字符';
    }
    return null;
  }

  /// 密码校验
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    return null;
  }

  /// 处理登录
  ///
  /// 验证表单后调用 ViewModel 进行认证。
  void _onLogin() {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    ref.read(authViewModelProvider.notifier).authenticate(
          widget.serverUrl,
          username,
          password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2D),
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
            // 用户图标
            Icon(
              Icons.account_circle_rounded,
              size: 72,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // 标题
            Text(
              '欢迎回来',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 副标题
            Text(
              '登录以访问您的媒体库',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),

            // 用户名输入框
            TextFormField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              decoration: InputDecoration(
                labelText: '用户名',
                hintText: '请输入用户名',
                prefixIcon: const Icon(Icons.person_outline_rounded),
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
              validator: _validateUsername,
            ),
            const SizedBox(height: 16),

            // 密码输入框
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscurePassword,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _onLogin(),
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
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
              validator: _validatePassword,
            ),
            const SizedBox(height: 24),

            // 登录按钮
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  /// 构建登录按钮
  ///
  /// 根据认证状态显示:
  /// - 加载中: [CircularProgressIndicator]
  /// - 默认: "登录" 按钮
  Widget _buildLoginButton() {
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
        label: const Text('登录中...'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      orElse: () => FilledButton.icon(
        onPressed: _onLogin,
        icon: const Icon(Icons.login_rounded),
        label: const Text(
          '登录',
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
