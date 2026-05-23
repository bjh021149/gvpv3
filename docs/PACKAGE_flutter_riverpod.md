> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# flutter_riverpod ^3.2.1 使用方法

## 1. 概述

`flutter_riverpod` 是 Flutter 生态中最现代的状态管理方案之一。v3.2.1 是目前最新稳定版，基于 Dart 3 的 Records 和 Patterns 特性进行了大量优化，类型安全且编译时安全。

**核心优势：**
- 编译时安全：Provider 的依赖关系在编译期即可检测
- 类型安全：无需运行时类型检查
- 自动垃圾回收：未使用的 Provider 自动 dispose
- 支持 DevTools 调试

---

## 2. 基础 Provider 类型

### Provider — 不可变值
```dart
final helloWorldProvider = Provider<String>((ref) => 'Hello World');

// 在 Widget 中使用
class HelloWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(helloWorldProvider);
    return Text(value);
  }
}
```

### StateProvider — 简单状态（v3 已移至 legacy.dart）
```dart
// v3 中 StateProvider 已标记为 legacy，推荐改用 Notifier
final counterProvider = StateProvider<int>((ref) => 0);

// 使用
ref.read(counterProvider.notifier).state++;
```

### FutureProvider — 异步数据
```dart
final userProvider = FutureProvider<User>((ref) async {
  final dio = ref.watch(dioClientProvider);
  final response = await dio.get('/user');
  return User.fromJson(response.data);
});

// Widget 中使用 AsyncValue
class UserWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    return userAsync.when(
      data: (user) => Text(user.name),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### StreamProvider — 流数据
```dart
final positionProvider = StreamProvider<Duration>((ref) {
  final player = ref.watch(playerProvider);
  return player.stream.position;
});
```

---

## 3. AsyncNotifier（v3 推荐）

### 基础用法
```dart
final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);

class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    // build 是异步初始化入口
    final repo = ref.read(mediaRepositoryProvider);
    final items = await repo.getItems();
    return HomeState(items: items);
  }

  // 刷新数据
  Future<void> refresh() async {
    state = const AsyncLoading(); // 进入 loading 状态
    state = await AsyncValue.guard(() => build()); // 重新执行 build
  }

  // 局部更新（不触发完整 rebuild）
  void updateItem(String id, Item newItem) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(
        items: current.items.map((i) => i.id == id ? newItem : i).toList(),
      ),
    );
  }
}
```

### Family 参数化 Provider
```dart
final detailViewModelProvider =
    AsyncNotifierProvider.family<DetailViewModel, DetailState, String>(
  DetailViewModel.new,
);

class DetailViewModel extends FamilyAsyncNotifier<DetailState, String> {
  // arg 就是传入的 itemId
  String get itemId => arg;

  @override
  Future<DetailState> build() async {
    final repo = ref.read(mediaRepositoryProvider);
    final item = await repo.getItemDetail(itemId);
    return DetailState(item: item);
  }
}

// 使用
ref.watch(detailViewModelProvider('item-123'));
```

---

## 4. v3 重要变更与最佳实践

### 4.1 `AsyncValue.value` 在 error 时返回 null（Breaking）
```dart
// v3 之前：value 在 error 时 throw
// v3：value 在 error 时返回 null，valueOrNull 已被移除
final data = asyncValue.value; // error 状态下返回 null
final requireData = asyncValue.requireValue; // error 状态下 throw
```

### 4.2 使用 `ref.invalidate` 替代 `ref.refresh`
```dart
// 推荐：invalidate 会在下一帧触发重建，避免同步重建问题
ref.invalidate(homeViewModelProvider);

// 配合 asReload 可跳过 loading 状态保留旧数据
ref.invalidate(homeViewModelProvider, asReload: true);
```

### 4.3 `ref.watch` 与 `ref.read` 的正确使用
```dart
// ✅ watch：建立依赖关系，数据变化时 Widget/Provider 会重建
final value = ref.watch(myProvider);

// ✅ read：一次性读取，不建立依赖（仅在事件回调中使用）
void onPressed() {
  ref.read(myProvider.notifier).doSomething();
}
```

### 4.4 自动重试（v3 新特性）
```dart
// 失败的 Provider 会自动延迟重试
final apiProvider = FutureProvider((ref) async {
  final dio = ref.watch(dioProvider);
  return await dio.get('/data');
});

// 监听重试状态
final async = ref.watch(apiProvider);
if (async is AsyncError && async.retrying) {
  return Text('Retrying in a moment...');
}
```

### 4.5 Mutation（代码生成器专属）
使用 `@riverpod` 代码生成时，可以自动生成 Mutation：
```dart
@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async => AuthState.unauthenticated();

  // 自动生成 loginMutationProvider
  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await api.login(username, password);
      return AuthState.authenticated(result);
    });
  }
}
```

---

## 5. 测试

### ProviderContainer 测试
```dart
test('HomeViewModel fetches items', () async {
  final container = ProviderContainer(
    overrides: [
      mediaRepositoryProvider.overrideWithValue(MockMediaRepository()),
    ],
  );

  addTearDown(container.dispose);

  final viewModel = container.read(homeViewModelProvider.notifier);
  await container.read(homeViewModelProvider.future);

  expect(viewModel.state.value?.items, isNotEmpty);
});
```

### Widget 测试获取 Container
```dart
// v3 新增：tester.container() 快速获取 ProviderContainer
testWidgets('displays user name', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: UserWidget()),
    ),
  );

  final container = tester.container();
  container.read(userProvider.notifier).state = User('Alice');

  await tester.pump();
  expect(find.text('Alice'), findsOneWidget);
});
```

---

## 6. 项目集成建议

当前项目已正确使用 `AsyncNotifierProvider` + `AsyncValue` 模式。建议改进：

1. **首页状态拆分**：将 `HomeState` 拆分为独立 Provider，减少不必要的重建
2. **使用 `ref.invalidate` 替代手动 refresh**
3. **添加 `dependencies` 声明**：帮助 Riverpod 优化 Provider 重建顺序
4. **考虑 `@riverpod` 代码生成**：引入 `riverpod_annotation` + `build_runner`
